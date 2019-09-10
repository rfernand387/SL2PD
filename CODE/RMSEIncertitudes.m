function [RMSEI]=RMSEIncertitudes(Def_Base,Perf_Theo,Input,Output)
%% Computation of uncertainties model from input values
% It consists in computing the RMSE values of the output variables for the
% inputs that are within the measurement confidence interval
% Fred August 2009
% Fred Septembre 2009
% Fred Novembre 2009
% Richard July 2019

%% Initialisation
Ref=['Rho_' Def_Base.Toc_Toa]; % données Toc ou Toa
Var_Name=fieldnames(Perf_Theo);
Delta_Ang=[5 5 10]; % Selection des ecarts angulaires autorisés pour la recherche des cas proches.
Input_Train=Input.(Ref); % les Inputs de la base d'apprentissage
Ang_Train=acos(Input.Angles)*180/pi;

%% boucle sur les variables
for ivar=1:length(Var_Name)
    Input_Valid=Perf_TheoInput.Valid(:,1:length(Def_Base.Bandes_Utiles)); % les Inputs de la base de validation
    RMSE=zeros(length(Input_Valid),1);
    Ang_Valid=acos(Perf_Theo.(Var_Name{ivar}).Input.Valid(:,end-length(Def_Base.Angles)+1:end))*180/pi;
%     h=waitbar(0,['Computation of the RMSE for ' Var_Name{ivar}]);
    parfor i_case=1:length(Input_Valid) % boucle sur les cas de l'apprentissage
%         waitbar(i_case/length(Input_Valid),h)
        %% Selection des configurations angulaires proches
        Delta=abs(repmat(Ang_Valid(i_case,:),length(Ang_Train),1)-Ang_Train); % l'écart angulaire
        I_Ang=find(prod(double(Delta < repmat(Delta_Ang,length(Input.(Ref)),1)),2)==1); % les indices des solutions
        %% Selection des cas dans l'intervalle de confiance
        
        Sigma=Input_Valid(i_case,:).*(Def_Base.Bruit_Bandes.MI/100+Def_Base.Bruit_Bandes.MD'./100) ...
            +Def_Base.Bruit_Bandes.AI+Def_Base.Bruit_Bandes.AD'; % Calcul de l'intervalle sigma
        Delta=abs(repmat(Input_Valid(i_case,:),length(I_Ang),1)- Input_Train(I_Ang,:)); % l'écart
        I=find(prod(double(Delta < repmat(2*Sigma,length(I_Ang),1)),2)==1); % les indices des solutions
        %% Calcul des RMSE
        RMSE(i_case)=rmse(repmat(Perf_Theo.(Var_Name{ivar}).Output.Valid(i_case),length(I),1),Output.(Var_Name{ivar})(I_Ang(I)));
    end % fin boucle i_case
end

end % fin boucle i_var