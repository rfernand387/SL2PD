function [Output]= Predict_NNT_Sim_batch(Output_Name,Input, Results,Cats,testCats,P,Plist)
% Predict NNT over simulated cases
% Richard July 2019

%% Initialisation
Input_Name = fieldnames(Input);
Input_Name = Input_Name(find((~strcmp(Input_Name,'Cats'))&(~strcmp(Input_Name,'D'))));

% On met les Input en vecteurs
% We do not use P if we are doing a single regression estimate only
In=[];
if (isempty(Plist) )
    indIn = find(~strcmp(Input_Name,P));
else
    indIn = 1:length(Input_Name);
end

for ivar = 1:length(indIn)   
    In=cat(2,In,Input.(Input_Name{indIn(ivar)}));
end
In = In';

% erxtract the test indices
% find samples who matching the test and rest categories
[dummy testInd] = ismember(Cats,testCats);
testInd = find(testInd>0);




%% boucle sur les Variables à estimer
if ( isempty(Plist) )
    for ivar=1:length(Output_Name)
        Output.(Output_Name{ivar})  = Results.(Output_Name{ivar}).NET(In(:,testInd))';
    end
else
    % do a separate retrieval for each cateogry of D
    for ivar=1:length(Output_Name)
        Output.(Output_Name{ivar})  = zeros(length(testInd),1);
    end
    Num_Dclass = length(Plist);
    for d = 1:Num_Dclass
        % subset Output and Input and Cats
        dInd= find((Input.(P)>Plist(max(1,d-1)))&(Input.(P)<=Plist(min(length(Plist),d+1))));
        [outInd dummy ] = ismember(testInd,dInd);
        outInd = testInd(outInd);
        for ivar=1:length(Output_Name)
            Output.(Output_Name{ivar})(outInd)  = Results.(P).(Output_Name{ivar}).NETS(d).NET(In(:,outInd))';
        end
    end
end




