function status = SL2PD(Version_Name, Overwrite, Debug)
% Simplified Level 2 Processor D
%   status = SL2PD(Version_Name,Overwrite Debug) returns status of SL2PD
%   when provided with a parameter file corresponding to Version_Name.
%
% Inputs
%
% Version_Name :  Name of Processor Parameter File.
% Overwrite : 1 overwriting of existing class database or regressions
% Debug : Debug level,  1 for debug output
%
% Outputs
%
% status :  1 no exceptions, 0 otherwise
%
% Created: Fred Baret and Marie Weiss, January 2006
% Modified: Richard July 2019

%% Initialisation of Matlab Environment
% .\CODE holds matlab source code and other libraries and executables
%   ..\Tools holds generic MALTAB source code and libraries
%
% .\DATA holds data files requires by files in .\code
%    ..\Filtres_Smac_SL2PD.mat - spectral response functions and smac coefficients
%    ..\struct_Orbito_Sensor.m - code that generates orbital parameters
%
status = 1;
tic;
addpath(genpath('.\CODE'));
addpath(genpath('.\DATA'));


%% Definition of Dataset Name ,Regression Algorithm, Validation Database
% Read options for current simulation
Def_Base =  Read_Start_Data(Version_Name);

% Read global description of calibration database
Def_Base = Read_Learning_Data(Def_Base);

% Création des directory 'Report'
Def_Base.Report_Dir=fullfile('.',['Report_' Def_Base.Name]);
if ~isdir(Def_Base.Report_Dir)
    mkdir(Def_Base.Report_Dir)
else
    if (Debug)
        disp('Report Directory Exists ')
    end
end

% Identification of directory 'Validation'
Def_Base.Validation_Dir=fullfile('.',['Report_' Def_Base.Validation_Name]);
if ~isdir(Def_Base.Validation_Dir)
    if (Debug)
        disp('No Validation Database Found, Validation Skipped ')
    end
    Def_Base.Validation_Dir= [];
end

%% Define regression algorithm and make a copy of the definition
Def_Base = Read_Alg_Archi(Def_Base);
if (Debug)
    disp(['Regression Algorithm ',Def_Base.Algorithm_Name])
end

%% Create sensor sampling law for maximum number of simulations if it does not exist
% Verify the size of the created Sensor sampling Law is same as maximum
% number simulations
Def_Base = Read_Observations(Def_Base); % définition du capteur et des observations
try
    load(fullfile(Def_Base.Report_Dir,'Law.mat'),'-mat')
catch
    if (Debug)
        disp('Creating distributions of observational conditions  ')
    end
    Law=Create_Law_Obs(Def_Base); % creation des distributions des conditions d'observation
end
if (length(Law.View_Zenith) ~= Def_Base.Max_Sims)
    if (Debug)
        disp('Sensor sampling does not match maximum required simulations.');
    end
    status = 0;
    return
end

%% Save definition and sensor sampling Law  globally
save(fullfile(Def_Base.Report_Dir,'Law.mat'), 'Law','-mat')
save(fullfile(Def_Base.Report_Dir,'Def_Base.mat'), 'Def_Base','-mat')

%% Loop through all classes
for Class = 1:Def_Base.Num_Classes
    
    %% create training database
    try
        %% load current database if it exists and overwrite not specified
        if ( ~Overwrite)
            % load the current class data base if it exists
            load(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '_inout.mat']),'-mat')
            
        else
            % force error to make the database
            ME = MException('MyComponent:noSuchVariable', ...
                'Variable %s not found', inputstr);
            throw(MException('Dummy'));
        end
    catch
        %% Produce this class
        
        % Make directories for this class
        mkdir([Def_Base.Report_Dir '\Class_' num2str(Class)])
        mkdir([Def_Base.Report_Dir '\Class_' num2str(Class) '\Learn_Data_Base'])
        
        % Création des distributions de la base d'apprentissage
        disp(['Reading Learning data base information for Class ' num2str(Class)])
        Def_Base = Read_Canopy_Atmos(Def_Base,Class); % definition des distributions des variables d'entrée des modeles de la surface et de l'atmosphère
        
        % graphiques de définition du sol et des capteurs
        Plot_Sol_Bandes(Def_Base,Class);
        
        % save definition for this class and globally
        save(fullfile(Def_Base.Report_Dir,'Def_Base.mat'), 'Def_Base','-mat')
        try
            save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','-append' )
        catch
            save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat' )
        end
        
        % create and save canopy and atmsopeher parameter sampling Law for this class
        disp(['Creating distributions of input variables for Class ' num2str(Class)])
        Nb_Sims = Def_Base.(['Class_' num2str(Class)]).Nb_Sims;
        [Law]=Create_Law_Var(Def_Base,Class,[],Law,Nb_Sims);
        try
            save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','-append' )
        catch
            save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat' )
        end
        
        % simulate using Law and specified RTM and save plots and results
        [Input,Output,Law] = Build_Database( Def_Base, Law, Class,Def_Base.CopyFlag,Debug);
        Plot_Law(Def_Base,Law,[],Class) % Edition des histogrammes des lois
        try
            save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '_inout.mat']),'-mat','Input','Output','Law','-append' )
        catch
            save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '_inout.mat']),'-mat','Input','Output','Law' )
        end
        

        
        % plot the noise free inputs and outputs for this class
        Plot_Matrix_InOut(Def_Base, Law, Input, Output,Class);
        
        % 
        % [Def_Base,Input_Noise]=Streamline_LAI_fAPAR(Def_Base,Output,Input_Noise,Law,Class); % Relations LAI/fAPAR
        
    end
       
    %% calibrate and/or validate regression algorithm if requested
    Regression = Def_Base.Regression.(Def_Base.Algorithm_Name);
    Input.Cats = Input.Cats';
    try ( ~isempty(Regression.Method) )

        % parse regression method name
        P = (Regression.Partition_Name);
        
        % define regression method
        try
            % check if algorithm already exists for this class
            load(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','Perf_Theo' );
            load(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','Results' );           
            if ( ~isempty('Perf_Theo') && ~isempty( 'Results' ) )
                if ( Debug && ~isempty(Results.(Def_Base.Algorithm_Name).(P)))
                    disp(['Loaded results for ' Def_Base.Algorithm_Name '.' P  ' for Class ' num2str(Class)]);
                end
            end           
        catch
            % if method does not exist for this class calibrate a new regression
            if ( Debug )
                disp(['Calibrating ' Def_Base.Algorithm_Name '.' P  ' for Class ' num2str(Class)]);
            end
            

            % add noise to the input data
            Input_Noise=Add_Noise_Input(Def_Base,Input,Class);
            
            %Determine convex hull of inputs used for this network
            Results.(Def_Base.Algorithm_Name).Input_Convex_Hull = Get_Convex_Hull(Input.(['Rho_' Def_Base.Toc_Toa]),0.01,10);

            %Determine coded defintion domain of inputs used for this network
            Results.(Def_Base.Algorithm_Name).Input_Definition_Domain = Get_Definition_Domain(Input.(['Rho_' Def_Base.Toc_Toa]));
            
            % plot the noisy inputs amd outputs for this class and regression
%             Plot_Matrix_InOut(Def_Base, Law, Input_Noise, Output,Class);
            
            % check the regression method against available methods
            switch Def_Base.Regression.(Def_Base.Algorithm_Name).Method   
                
                % method NNT selected
                case {'NNT'}                    
                    % Check if single or cacsading regression
                    if ( strcmp(P,'Single')  )
                        %% calibrate single regression
                        [Results.(Def_Base.Algorithm_Name).(P),Perf_Theo.(Def_Base.Algorithm_Name).(P)]= Train_NNT_Sim_batch([Def_Base.Var_out],Input_Noise,Output,Regression,Input.Cats,Def_Base.Regression.(Def_Base.Algorithm_Name).Num_Batches,100000,[1 99]);
                    else
                        % calibrate cascading regression
                        [Results.(Def_Base.Algorithm_Name).Single,Perf_Theo.(Def_Base.Algorithm_Name).Single]= Train_NNT_Sim_batch({P},Input_Noise,Output,Regression,Input.Cats,Def_Base.Regression.(Def_Base.Algorithm_Name).Num_Batches,100000,[1 99]);
                        [Pest] = Predict_NNT_Sim_batch( {P},Input_Noise, Results.(Def_Base.Algorithm_Name).Single,Input.Cats,unique(Input.Cats),[],[])';
                        Input_Noise.P = Pest.(P);
                        % use a power transform of P to determine subnet
%                         Ppow = max(0,(1-Input_Noise.P)).^1;
%                         deltaPpow = (((1-(median(Input_Noise.P)+Results.(Def_Base.Algorithm_Name).Single.(P).RMSE(3)*1)).^1 - (1-median(Input_Noise.P)).^1));
%                         Ppowlist = (max(Ppow)):deltaPpow:(min(Ppow));
%                         Plist = 1-Ppowlist.^1;
%                         Plist(1) = min(0,min(Input_Noise.P,Plist(1)));
%                         Plist(length(Plist)) = max(max(Input_Noise.P,Plist(length(Plist))),1 );
                        % use constant intervals to determine subsets of P
                        Plist = [0.1:0.05:0.9, 1.2 ];
                        Results.(Def_Base.Algorithm_Name).Plist = Plist;
                        [Results.(Def_Base.Algorithm_Name).(P),Perf_Theo.(Def_Base.Algorithm_Name).(P)]= Train_NNT_Sim_batch_P([Def_Base.Var_out], Input_Noise,Output,Regression,Input.Cats,Def_Base.Regression.(Def_Base.Algorithm_Name).Num_Batches,Results.(Def_Base.Algorithm_Name).Plist);
                    end                    
                otherwise
                    if ( Debug )
                        disp('Invalid Regression');
                    end
                    status = 0;
                    return                  
            end
            
            % save the resulting performance
            try
                save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','Perf_Theo','-append'  );
            catch
                save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','Perf_Theo'  );
            end
            
            % save the resulting calibrated regression
            try
                save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','Results','-append' );
            catch
                save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','Results' );
            end            
            
        end
        
        %% perform cross validation
        try
            
            % load in cross validation database
            load(fullfile([Def_Base.Validation_Dir '\Class_' num2str(Class)],[char(Def_Base.Validation_Name) '_inout.mat']),'-mat','Input');
            load(fullfile([Def_Base.Validation_Dir '\Class_' num2str(Class)],[char(Def_Base.Validation_Name) '_inout.mat']),'-mat','Output');
            
            % add noise to the input validation data
            Input_Noise=Add_Noise_Input(Def_Base,Input,Class);
            
         
            % do validation and plot results, calibrate incertitude predictions
            % try to load results from other validation 
            try
                load(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','ResultsActual');
                load(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','Perf_Actual');
                load(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','ResultsIncertitudes');
                load(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','Perf_Incertitudes');
                if ( isempty(ResultsActual ) || isempty( Perf_Actual ) || isempty( ResultsIncertitudes) || isempty( Perf_Incertitudes ) )
                    % force error to make the database
                    ME = MException('MyComponent:noSuchVariable', ...
                        'Variable %s not found', inputstr);
                    throw(MException('Dummy'));
                end             
            catch
                ResultsActual = [];
                Perf_Actual = [];
                ResultsIncertitudes = [];
                Perf_Incertitudes = [];
            end
            
            % determine input out of range flag
            [ResultsActual.(Def_Base.Algorithm_Name).(Def_Base.Validation_Name).flag]=input_out_of_range_flag_function(Input_Noise.(['Rho_' Def_Base.Toc_Toa]), Results.(Def_Base.Algorithm_Name).Input_Convex_Hull);
   
            
            % validate and plot results
            [ResultsActual.(Def_Base.Algorithm_Name).(Def_Base.Validation_Name),Perf_Actual.(Def_Base.Algorithm_Name).(Def_Base.Validation_Name)]= Validate( [Def_Base.Var_out],Input_Noise,Output,Results.(Def_Base.Algorithm_Name),P,Def_Base.Regression.(Def_Base.Algorithm_Name).Method);
            Plot_Perfo_Theo(Def_Base,ResultsActual.(Def_Base.Algorithm_Name).(Def_Base.Validation_Name),Perf_Actual.(Def_Base.Algorithm_Name).(Def_Base.Validation_Name),Class,[Def_Base.Algorithm_Name '-' Def_Base.Algorithm_Name  '-'  Def_Base.Validation_Name  '_' P],'');
            
            % calibrate and plot regressions for incertitudes based on the validation results
            % estimate rmse for sims sharing same inputs
            Bruit_Angles.AD = ([ 0 0 0 ])';
            Bruit_Angles.AI = ([ 10 10 10 ] *pi/180)';
            Bruit_Angles.MD = ([ 0 0 0 ])';
            Bruit_Angles.MI = ([ 0 0 0 ])';
%             [RMSE] = getRMSE(  Def_Base.Bruit_Bandes , Bruit_Angles, Perf_Actual.(Def_Base.Algorithm_Name).(Def_Base.Validation_Name), Def_Base.Toc_Toa );
%             
%             % calibrate regression for each incertitude and plot results
%             Cats = 1:length(Input.Angles);
%             [ResultsIncertitudes.(Def_Base.Algorithm_Name).(Def_Base.Validation_Name),Perf_Incertitudes.(Def_Base.Algorithm_Name).(Def_Base.Validation_Name)]= Train_NNT_Sim_batch([Def_Base.Var_out],Input_Noise,RMSE,Regression,Cats,5,Def_Base.Max_Sims,[0 100]);         
%             Plot_Perfo_Theo(Def_Base,ResultsIncertitudes.(Def_Base.Algorithm_Name).(Def_Base.Validation_Name),Perf_Incertitudes.(Def_Base.Algorithm_Name).(Def_Base.Validation_Name),Class,[Def_Base.Algorithm_Name '-' Def_Base.Algorithm_Name  '-'  Def_Base.Validation_Name  '_Errors' ],'');

            % save cross validation
            try
                save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','ResultsActual','-append');
                save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','Perf_Actual','-append');
%                 save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','ResultsIncertitudes','-append');
%                 save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','Perf_Incertitudes','-append');
            catch
                save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','ResultsActual');
                save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','Perf_Actual');
%                 save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','ResultsIncertitudes');
%                 save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat','Perf_Incertitudes');
            end
           
            if (Debug )
                disp(['Class_' num2str(Class) ' cross validated']);
            end
            
        catch
            if (Debug )
                disp(['Class_' num2str(Class) ' not cross validated']);
            end
        end
    catch
        if (Debug)
            disp(['Class_' num2str(Class) ' created. No regression algorithm selected.']);
        end
    end
    
end


toc

















