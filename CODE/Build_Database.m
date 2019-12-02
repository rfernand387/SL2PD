function    [NewInput,NewOutput,NewLaw] = Build_Database( Def_Base, Law, Class, copyFlag, Debug)
%% builds database for a class by either copying or perfoming simulations
% Richard July 2019
if ( Debug ) 
disp(['Computing reflectances for Class ' num2str(Class)])
end

%% initializations
lowLAI = Def_Base.Class_1.Var_in.LAI.Lb;
highLAI = Def_Base.Class_1.Var_in.LAI.Ub + 0.1;
Nb_Classe = Def_Base.Class_1.Var_in.LAI.Nb_Classe;
deltaLAI = (highLAI - lowLAI)/Nb_Classe;
listLAI = [lowLAI:deltaLAI:highLAI];
Var_names = fieldnames(Def_Base.(['Class_' num2str(Class)]).Var_in);
nVar_names = length(Var_names);
Law_names = fieldnames(Law);
nLaw_names = length(Law_names);
Output_names =fieldnames(Def_Base.Regression.(Def_Base.Algorithm_Name).Var_out);
nOutput_names = length(Output_names);
%Input_names ={['Rho_' Def_Base.Toc_Toa] 'Angles' 'Cats'};
Input_names ={'Rho_Toc' 'Rho_Toa' 'Angles' 'Cats'};
nInput_names = 4;

for ivar = 1:nLaw_names
    NewLaw.(Law_names{ivar}) = [];
end
for ivar = 1:nOutput_names
    NewOutput.(Output_names{ivar}) = [];
end
for ivar = 1:nInput_names
    NewInput.(Input_names{ivar}) = [];
end
% determine maximum interpolation distance
% based on stratification levels OTHER than LAI
nlevels = 0;
for ivar = 2:nVar_names
    nlevels = max(nlevels,Def_Base.Class_1.Var_in.(Var_names{ivar}).Nb_Classe);
end
maxdists = 2/nlevels;
Mglobal = [];

%% check if we can copy existsing simulations
if ( copyFlag )
    %% check each input class
    for classS = 1:Def_Base.Num_Classes
        
        %% try to copy data if the current class exists
        
        try
            %% load in data from existing class
            S = load(fullfile([Def_Base.Report_Dir '\Class_' num2str(classS)],[char(Def_Base.Name) '_inout.mat']),'-mat', 'Law','Input','Output');
            
            
            
            for n = 1:Nb_Classe
                Matches(n).M = [];
            end
            % loop through LAI
            for n = 1:Nb_Classe
                
                % identify target and source samples in this LAI range
                indT = find((Law.LAI>=listLAI(n)).*(Law.LAI<listLAI(n+1)));
                indS = find((S.Law.LAI>=listLAI(n)).*(S.Law.LAI<listLAI(n+1)));
                nsam_T = length(indT);
                nsam_S = length(indS);
                
                % extract samples
                Target = zeros(nVar_names,nsam_T);
                Source = zeros(nVar_names,nsam_S);
                for ivar = 1:nVar_names
                    Target(ivar,:) = Law.(Var_names{ivar})(indT);
                    Source(ivar,:) = S.Law.(Var_names{ivar})(indS);
                end
                
                Target2 = Target;
                Source2 = Source;
                % compute pairwise distances after normalizing each var
                if strcmp(Def_Base.RTM,'sail3')
                [Target,ts] = mapminmax(Target([1 2 5 6 7 8 9 11],:),-1,1);
                [Source] = mapminmax.apply(Source([1 2 5  6 7 8 9 11],:),ts);
                else
                [Target,ts] = mapminmax(Target([1 2 5 6 7 8 9 10],:),-1,1);
                [Source] = mapminmax.apply(Source([1 2 5  6 7 8 9 10],:),ts);
                end
                
                % compute pariwise distances for nearest 10%ile samples
                % convert distance
                dists = boxdist(Target',Source);
                dists = dists .* (dists<maxdists) + 10*(dists>=maxdists);
                [M,uR,uC] =  matchpairs(dists,maxdists,'min');
                
                % append found matches to the global list of matches
                Matches(n).M = [indT(M(:,1)) indS(M(:,2))];
                
                xc = [Source2(1,M(:,2)); Target2(1,M(:,1))];
                yc = [Source2(6,M(:,2)); Target2(6,M(:,1))];
                plot(yc,xc,'-o')
            end
            
            %% move these matches to the new Law
            AllMatches = [];
            for n = 1:Nb_Classe
                AllMatches = [AllMatches;  Matches(n).M];
                
            end
            Unmatched = ~ismember(1:length(Law.LAI),AllMatches(:,1));
            sum(Unmatched)
            for ivar = 1:nLaw_names
                NewLaw.(Law_names{ivar}) = [NewLaw.(Law_names{ivar}) ; S.Law.(Law_names{ivar})(AllMatches(:,2))];
            end
            for ivar = 1:nOutput_names
                NewOutput.(Output_names{ivar}) = [NewOutput.(Output_names{ivar}) ; S.Output.(Output_names{ivar})(AllMatches(:,2))];
            end
            for ivar = 1:nInput_names
                NewInput.(Input_names{ivar}) = [NewInput.(Input_names{ivar}) ; S.Input.(Input_names{ivar})(AllMatches(:,2),:)];
            end
            
            % remove these matches from the target law
            for ivar = 1:nLaw_names
                Law.(Law_names{ivar}) = Law.(Law_names{ivar})(find(Unmatched==1));
            end
        catch
        end
    end
end

%% simulate reflectances for unmatched samples

if ( length(Law.LAI>0) )
    [Def_Base,Input,Output] = Create_Input_Output_D(Def_Base, Law, Class, Debug); % calcul des réflectances et des variables de sortie
    for ivar = 1:nLaw_names
        NewLaw.(Law_names{ivar}) = [NewLaw.(Law_names{ivar}) ; Law.(Law_names{ivar})];
    end
    for ivar = 1:nOutput_names
        NewOutput.(Output_names{ivar}) = [NewOutput.(Output_names{ivar}) ; Output.(Output_names{ivar})];
    end
    for ivar = 1:nInput_names
        NewInput.(Input_names{ivar}) = [NewInput.(Input_names{ivar}) ; Input.(Input_names{ivar})];
    end
end
return

