function [Results,Perf_Theo]= Train_NNT_Sim_batch_P(outvars,Input, Output,Regression,Cats,numBatches, Plist )
% Training NNT over simulated cases
% RIchard April 2019

% initializaton
Input_Name = fieldnames(Input);
Input_Name = Input_Name(find(~strcmp(Input_Name,'Cats')));
Output_Name = fieldnames(Output);
% subsampling regularily to limit to maxsims
for ivar=1:length(Output_Name)
    Results.(Output_Name{ivar}).RMSE=0;
    Perf_Theo.(Output_Name{ivar}).Estime =[];
    Perf_Theo.(Output_Name{ivar}).Valid = [];
end

% fit network for each D class
Num_Dclass = length(Plist);
for d = 1:Num_Dclass
    d
    % subset Output and Input and Cats
    dindex = find((Input.P>Plist(max(1,d-1)))&(Input.P<=Plist(min(length(Plist),d+1))));
    for ivar=1:length(Output_Name)
        Out.(Output_Name{ivar}) = Output.(Output_Name{ivar})(dindex);
    end
    for ivar=1:length(Input_Name)
        In.(Input_Name{ivar}) = Input.(Input_Name{ivar})(dindex,:);
    end
    
    Cat = Cats(dindex);
    
    % train the networks for this range of d
    [Resultsd,Perf_Theod]= Train_NNT_Sim_batch(outvars,In,Out,Regression,Cat,numBatches,100000,[1 99]);
    
    % copy results into arry for all d, note that indices into samples are
    % no longer the same as into the global array
    for ivar=1:length(Output_Name)
        Results.(Output_Name{ivar}).NETS(d).NET=Resultsd.(Output_Name{ivar}).NET; % on garde le meilleur réseau
        Results.(Output_Name{ivar}).NETS(d).RMSE=Resultsd.(Output_Name{ivar}).RMSE; % RMSE du meilleur réseau
        Results.(Output_Name{ivar}).NSAM(d) = length(Resultsd.LAI.NET.divideParam.testInd);
        Results.(Output_Name{ivar}).RMSE=Results.(Output_Name{ivar}).RMSE+(Resultsd.(Output_Name{ivar}).RMSE).^2*Results.(Output_Name{ivar}).NSAM(d); % RMSE du meilleur réseau
        Perf_Theo.(Output_Name{ivar}).Estime = [ Perf_Theo.(Output_Name{ivar}).Estime  Perf_Theod.(Output_Name{ivar}).Estime];
        Perf_Theo.(Output_Name{ivar}).Valid = [Perf_Theo.(Output_Name{ivar}).Valid  Perf_Theod.(Output_Name{ivar}).Valid];
    end
end
for ivar=1:length(Output_Name)
    Results.(Output_Name{ivar}).RMSE=(Results.(Output_Name{ivar}).RMSE./sum(Results.(Output_Name{ivar}).NSAM)).^0.5; % RMSE du meilleur réseau
end
return

