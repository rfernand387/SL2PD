function [ResultsVal,Perf]= Validate( Output_Name,Input,Output,Results,P,Method)
%% Validate network by applying it to a new database
% Richard July 2019

%%do a prediction for all samples
if (sum(ismember(fieldnames(Input),{'Rho_Toa'}))>0)
    Nb_Sims = length(Input.Rho_Toa);
else
    Nb_Sims = length(Input.Rho_Toc);
end
Cats = ones(Nb_Sims,1);
Perf.Input = Input ;

switch Method
    
    case {'NNT'}
        
        %% detrmine if the network is cascaded
        
        %% prediction with no cascade
        if (  strcmp(P,'Single') )
            Estime = Predict_NNT_Sim_batch(Output_Name,Input, Results.Single,Cats,1,P,[]);
        else
            % prediction with cascade
            [Pest] = Predict_NNT_Sim_batch({P},Input,Results.Single,Cats,1,P,[])';
            Input.(P) = Pest.(P);
            % predict for each D class and reconstitue estime
            Estime = Predict_NNT_Sim_batch(Output_Name,Input, Results,Cats,1,P, Results.Plist );
            
        end
        for ivar = 1:length(Output_Name)
            
            Perf.(Output_Name{ivar}).Estime = Estime.(Output_Name{ivar});
            Perf.(Output_Name{ivar}).Valid = Output.(Output_Name{ivar});
            RMSE = sqrt(mean((Output.(Output_Name{ivar})-Estime.(Output_Name{ivar})).^2));
            ResultsVal.(Output_Name{ivar}).RMSE= [RMSE RMSE RMSE];
            
        end
    otherwise
        if ( Debug )
            disp('Invalid Regression');
        end
        status = 0;
        return
end

