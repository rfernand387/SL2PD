function SL2PD(Version_Name)
% Simplified Level 2 Processor D 
% Version_Name : 1
% Created: Fred Baret and Marie Weiss, January 2006
% Modified: Richard July 2019

%% Initialisation of Matlab Environment
% clear
%Version_Name='s2_sl2p_small_uniform_SOcopy';
addpath(genpath('.\CODE'));
addpath(genpath('.\DATA'));
tic


%% Définition de la base de données, nom et commentaires
xlswrite([Version_Name '.xls'],{Version_Name},'Start','B1');
Def_Base.Name=Version_Name;
Def_Base.File_XLS=Version_Name;
[x,y]= xlsread([Def_Base.File_XLS '.xls'],'Start','B3');
Def_Base.Algorithm=char(y);
[x,y]= xlsread([Def_Base.File_XLS '.xls'],'Start','B4');
Def_Base.Algorithm_Name=char(y);
Def_Base = Read_Learning_Data(Def_Base);

%% Création des directory 'Report'
Def_Base.Report_Dir=fullfile('.',['Report_' Def_Base.Name]);
if ~isdir(Def_Base.Report_Dir)
    mkdir(Def_Base.Report_Dir)
end

%% Identification of directory 'Validation'
Def_Base.Validation_Dir=fullfile('.',['Report_' Def_Base.Validation_Name]);
if ~isdir(Def_Base.Report_Dir)
    disp(['No Validation Database Found  '])
end

%% Create sensor sampling law and save it for all sims
disp(['Creating distributions of observational conditions  '])
Def_Base = Read_Observations(Def_Base); % définition du capteur et des observations
Law=Create_Law_Obs(Def_Base); % creation des distributions des conditions d'observation
save(fullfile(Def_Base.Report_Dir,'Law.mat'), 'Law','-mat')


%% Define regression algorithm and make a copy of the definition
Def_Base = Read_Alg_Archi(Def_Base);
Def_Base_New = Def_Base;

%% Save definition globally
save(fullfile(Def_Base.Report_Dir,'Def_Base.mat'), 'Def_Base','-mat')

%% Loop through all classes
for Class = 1:Def_Base.Num_Classes
    
    
    %% check if the required database class exist,if not make it
    try
        %% save the current def base
        load(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '_inout.mat']),'-mat')
        
    catch
        %% Make directories for this class
        mkdir([Def_Base.Report_Dir '\Class_' num2str(Class)])
        mkdir([Def_Base.Report_Dir '\Class_' num2str(Class) '\Learn_Data_Base'])
        
        %% Création des distributions de la base d'apprentissage
        disp(['Reading Learning data base information for Class ' num2str(Class)])
        Def_Base = Read_Canopy_Atmos(Def_Base,Class); % definition des distributions des variables d'entrée des modeles de la surface et de l'atmosphère
        Plot_Sol_Bandes(Def_Base,Class);% graphiques de définition du sol et des capteurs
        
        %% save definition for this class and globally
        save(fullfile(Def_Base.Report_Dir,'Def_Base.mat'), 'Def_Base','-mat')
        save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat')
        
        
        disp(['Creating distributions of input variables for Class ' num2str(Class)])
        Nb_Sims = Def_Base.(['Class_' num2str(Class)]).Nb_Sims;
        [Law]=Create_Law_Var(Def_Base,Class,[],Law,Nb_Sims);
        save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat')
        
        [Input,Output,Law] = Build_Database( Def_Base, Law, Class,Def_Base.CopyFlag)
        Plot_Law(Def_Base,Law,[],Class) % Edition des histogrammes des lois
        save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '_inout.mat']),'-mat')
    end
    
    %attach the new algorithm name to this def base
    Def_Base.Algorithm = Def_Base_New.Algorithm;
    Def_Base.Algorithm_Name = Def_Base_New.Algorithm_Name;
    Def_Base.Var_out = Def_Base_New.Var_out;
    Def_Base.(Def_Base.Algorithm_Name) = Def_Base_New.(Def_Base.Algorithm_Name);
    
    % add noise to the input data
    Input_Noise=Add_Noise_Input(Def_Base,Input,Class);
    
    % plot the inputs amd outputs for this algorithm
    Plot_Matrix_InOut(Def_Base, Law, Input_Noise, Output,Class);
    
    % cluster Inputs for block training
    Cats = 1:length(Law.LAI);
    % block training by clustering some of the laws in blocks of 100 samples
    nclus = ceil(length(Cats)/100);
    abc = (([ Law.ALA Law.Cab Law.N Law.Cdm Law.Cw_Rel Law.Bs])');
    Cats = kmeans(abc',nclus, 'Replicates',5,'MaxIter',1000);
    
    
    % [Def_Base,Input_Noise]=Streamline_LAI_fAPAR(Def_Base,Output,Input_Noise,Law,Class); % Relations LAI/fAPAR
    save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat')
    
    switch Def_Base.Algorithm
       case {'NNT'}
            % run unconstrained nnet to estimate all vars
            [Results,Perf_Theo]= Train_NNT_Sim_batch([Def_Base.Var_out],Input_Noise,Output,Def_Base,Class,Cats,5);
            Plot_Perfo_Theo(Def_Base,Results,Perf_Theo,Class,'Baseline','');
            
            
            % save the networks
            save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat')
            save(fullfile(Def_Base.Report_Dir,'Def_Base.mat'), 'Def_Base','-mat')
            
            %load the validation database
            load(fullfile([Def_Base.Validation_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '_inout.mat']),'-mat','Input');
            load(fullfile([Def_Base.Validation_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '_inout.mat']),'-mat','Output');
            
            % add noise to the input validation data
            Input_Noise=Add_Noise_Input(Def_Base,Input,Class);
            
            % do validation and plot results
            [ResultsActual,Perf_Actual]= Validate( [Def_Base.Var_out],Input_Noise,Output,Class,Results,[],[]);
            Plot_Perfo_Theo(Def_Base,ResultsActual,Perf_Actual,Class,[Def_Base.Validation_name '_' Def_Base.Algorithm_Name],'');
            
            %% incertitudes based on the validation results
            [ResultsActualI,Perf_ActualI]=Incertitudes([Def_Base.Var_out],Def_Base,Results,Perf_Theo,Class,Cats,5);
            Plot_Perfo_Theo(Def_Base,ResultsActualI,Perf_ActualI,Class,['Incertitudes' Def_Base.Validation_name '_' Def_Base.Algorithm_Name],'-Error');
            
            % Add_NNT_XlsFile(Def_Base,Results,Class);
            save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[Def_Base.Validation_name '_' Def_Base.Algorithm_Name '.mat']),'-mat')
            save(fullfile(Def_Base.Report_Dir,['Def_Base' char(Def_Base.Algorithm_Name) '.mat']), 'Def_Base','-mat')
     
        case {'NNTP'}
            % run unconstrained nnet to estimate d (var 7 in this case)
            [Results,Perf_Theo]= Train_NNT_Sim_batch([Def_Base.Var_out],Input_Noise,Output,Def_Base,Class,Cats,5);
            Plot_Perfo_Theo(Def_Base,Results,Perf_Theo,Class,'Baseline','');
            
            % predict P for all inputs, the intervals for D are based on its rmse
            % prediction and will span +/-1 interval of each centre interval
            P = Def_Base.(Def_Base.(['Class_' num2str(class)]).P);
            [Pest] = Predict_NNT_Sim_batch(P,Class,Cats,unique(Cats),[])';
            Input_Noise.P = Pest.(P);
            Plist = (min(Input_Noise.(P))):Results.(P).RMSE(3):(max(Input_Noise.(P)));
            Plist(1) = min(min(Input_Noise.(P)),Plist(1));
            Plist(length(Plist)) = max(max(Input_Noise.(P)),Plist(length(Plist)) );
            [ResultsP,Perf_TheoP]= Train_NNT_Sim_batch_P([Def_Base.Var_out], Input_Noise,Output,Def_Base,Class,Cats,5,Plist);
            Plot_Perfo_Theo(Def_Base,ResultsP,Perf_TheoP,Class,[P '_constr'],'');
            
            % save the networks
            save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '.mat']),'-mat')
            save(fullfile(Def_Base.Report_Dir,'Def_Base.mat'), 'Def_Base','-mat')
            
            %load the validation database
            load(fullfile([Def_Base.Validation_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '_inout.mat']),'-mat','Input');
            load(fullfile([Def_Base.Validation_Dir '\Class_' num2str(Class)],[char(Def_Base.Name) '_inout.mat']),'-mat','Output');
            
            % add noise to the input validation data
            Input_Noise=Add_Noise_Input(Def_Base,Input,Class);
            
            % do validation and plot results
            [ResultsActual,Perf_Actual]= Validate( [Def_Base.Var_out],Input_Noise,Output,Class,Results,P,ResultsP);
            Plot_Perfo_Theo(Def_Base,ResultsActual,Perf_Actual,Class,[Def_Base.Validation_name '_' Def_Base.Algorithm_Name],'');
            
            %% incertitudes based on the validation results
            [ResultsActualI,Perf_ActualI]=Incertitudes([Def_Base.Var_out],Def_Base,Results,Perf_Theo,Class,Cats,5);
            Plot_Perfo_Theo(Def_Base,ResultsActualI,Perf_ActualI,Class,['Incertitudes' Def_Base.Validation_name '_' Def_Base.Algorithm_Name],'-Error');
            
            % Add_NNT_XlsFile(Def_Base,Results,Class);
            save(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class)],[Def_Base.Validation_name '_' Def_Base.Algorithm_Name '.mat']),'-mat')
            save(fullfile(Def_Base.Report_Dir,['Def_Base' char(Def_Base.Algorithm_Name) '.mat']), 'Def_Base','-mat')
            
    end
    
end


toc

















