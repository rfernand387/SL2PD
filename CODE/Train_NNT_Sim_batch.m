function [Results,Perf_Theo]= Train_NNT_Sim_batch(Output_Name,Input, Output,Regression,Cats,numBatches,maxSims,trimPrctile)
% Training NNT over simulated cases
% Richard July 2019

%% Initialisation
Input_Name = fieldnames(Input);
Input_Name = Input_Name(find(~strcmp(Input_Name,'Cats') & ~strcmp(Input_Name,'P')));
restCats= unique(Cats);
nrestCats = length(restCats);
ntrainCats = ceil(nrestCats*0.66);


% On met les Input en vecteurs
In=[];
for ivar = 1:length(Input_Name)
    In=cat(2,In,Input.(Input_Name{ivar}));
end
In = In';



%% boucle sur les Variables à estimer
for ivar=1:length(Output_Name)
    


    %% Initialization of network for this output
    % Format output
    Out = (Output.(Output_Name{ivar})');
    
        %Trim the data
    goodind = find((Out >=prctile(Out ,trimPrctile(1))).* (Out <=prctile(Out ,trimPrctile(2)))>0);
    Outtrim = Out(goodind);
    Intrim = In(:,goodind);
    Catstrim = Cats(goodind);
        N = length(Outtrim);
    testInd = 1:N;
    
    % Create a template Fitting Network
    net = fitnet(Regression.Var_out.(Output_Name{ivar}).Nb_Neurons(1),'trainlm');
    net.performParam.regularization = 0.1;
    net.trainParam.show = 50;
    net.trainParam.epochs = 250;
    net.trainParam.goal = 1e-3;
    net.performFcn = 'mse';  % Mean Squared Error
    net.input.processFcns = {'removeconstantrows','mapminmax'};
    net.output.processFcns = {'removeconstantrows','mapminmax'};
    net.divideFcn = 'divideind';
    net.divideMode = 'sample';
    net.trainParam.showWindow = true;
    
    % initialization of transfer fn
    for k = 1:length(Regression.Var_out.(Output_Name{ivar}).Transfer)
        net.layers{k}.transferFcn = Regression.Var_out.(Output_Name{ivar}).Transfer{k};
    end
    
    % Initialisation des performances des reseaux testes
    Rmse_net=zeros(Regression.Var_out.(Output_Name{ivar}).Nb_Reseau,2).*NaN;
    
    % Initialize Replicate Networks 
    for ires=1:Regression.Var_out.(Output_Name{ivar}).Nb_Reseau        
        NETS(ires).net = init(net);
    end
    
    %% repeat for k batchs, this must be sequential
    for b = 1:numBatches
        
        % randomize choice of categories for training and validation
        restCats = restCats(randperm(nrestCats));
        trainCats = restCats(1:ntrainCats);
        [dummy trainInd] = ismember(Catstrim,trainCats);
        trainInd = find(trainInd>0);
        ntrainInd = length(trainInd);
        valCats = restCats((ntrainCats+1):nrestCats);
        [dummy valInd] = ismember(Catstrim,valCats);
        valInd = find(valInd>0);
        nvalInd = length(valInd);
        
        %% repeat multiple networks for this batch - this is parallel
        % determine number of networks we can train using parallel option
        tic
        for ires=1:Regression.Var_out.(Output_Name{ivar}).Nb_Reseau
            
            % initialize network
            net = struct();
            net = NETS(ires).net;
            
            % Randomize Order of Training Data
            net.divideParam.trainInd = trainInd(randperm(ntrainInd));
            net.divideParam.valInd = valInd;
            net.divideParam.testInd = testInd;
                      
            % Train the Network
            if ( gpuDeviceCount > 0 )
                [net,tr] = train(net,Intrim,Outtrim,'useParallel','no','useGPU','yes');
            else
                [net,tr] = train(net,Intrim,Outtrim,'useParallel','yes','useGPU','no');
                
            end
            %  Performance
            y = net(Intrim);
            trainTargets = Outtrim .* tr.trainMask{1};
            valTargets = Outtrim  .* tr.valMask{1};
            testTargets = Outtrim  .* tr.testMask{1};
            trainPerformance = perform(NETS(ires).net,trainTargets,y);
            valPerformance = perform(NETS(ires).net,valTargets,y);
            testPerformance = perform(NETS(ires).net,testTargets,y);
            
            % On garde le meilleur réseau en prenant comme référence la base d'apprentissage
            Rmse_net(ires,:)=[trainPerformance valPerformance];
            
            % copy back to global variable
            NETS(ires).net = net;
                                   
        end % fin boucle sur n reseaux (ires)
        toc
    end
    
    %% chose best network
    [dummy Best_Res] =min(Rmse_net(:,2));
    Results.(Output_Name{ivar}).NET=NETS(Best_Res).net; % on garde le meilleur réseau
    
    % rmse of  training
    Estime =  Results.(Output_Name{ivar}).NET(Intrim(:,NETS(Best_Res).net.divideParam.trainInd));
    Valid = Outtrim(NETS(Best_Res).net.divideParam.trainInd);
    Results.(Output_Name{ivar}).RMSE(1) = sqrt(mean((Valid-Estime).^2));
    
    % rmse of cross validation
    Estime =  Results.(Output_Name{ivar}).NET(Intrim(:,NETS(Best_Res).net.divideParam.valInd));
    Valid = Outtrim(NETS(Best_Res).net.divideParam.valInd);
    Results.(Output_Name{ivar}).RMSE(2) = sqrt(mean((Valid-Estime).^2));
    
    % rmse of testing (this defaults to the entire input database)
    % if you want actual independent testing use Validate.m
    Estime =  Results.(Output_Name{ivar}).NET(Intrim(:,NETS(Best_Res).net.divideParam.testInd));
    Valid = Outtrim(NETS(Best_Res).net.divideParam.testInd);
    Results.(Output_Name{ivar}).RMSE(3) = sqrt(mean((Valid-Estime).^2));
    
    % save only testing resuylts
    Perf_Theo.(Output_Name{ivar}).Estime =  Estime;
    Perf_Theo.(Output_Name{ivar}).Valid = Valid;
    
    % we need this for incertitudes , the name is .Valid even though
    % it is really from the testing data set
    Perf_Theo.Input.Valid = Intrim(:,NETS(Best_Res).net.divideParam.testInd);
    
end




