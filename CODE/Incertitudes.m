function [Results,Perf_Theo]=Incertitudes(Def_Base,Results,Perf_Theo,Input,Output,Class)  
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
    Input_Valid=Perf_Theo.Input.Valid(:,1:length(Def_Base.Bandes_Utiles)); % les Inputs de la base de validation
    RMSE=zeros(length(Input_Valid),1);
    Ang_Valid=acos(Perf_Theo.(Var_Name{ivar}).Input.Valid(:,end-length(Def_Base.Angles)+1:end))*180/pi;
%     h=waitbar(0,['Computation of the RMSE for ' Var_Name{ivar}]);
    for i_case=1:length(Input_Valid) % boucle sur les cas de l'apprentissage
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
%     close(h)
    %% APPRENTISSAGE DES INCERTITUDES
    %% Détermination des entrées du réseau
    Vec = randperm(length(Input_Valid));
    Vec_Learn=Vec(1:round(2/3*length(Input_Valid)));
    Vec_Valid=Vec(length(Vec_Learn)+1:end);

    %% Entrées sorties
    In_Learn = Perf_Theo.(Var_Name{ivar}).Input.Valid(Vec_Learn,:);
    In_Valid = Perf_Theo.(Var_Name{ivar}).Input.Valid(Vec_Valid,:);
    Out_Learn = RMSE(Vec_Learn);
    Out_Valid = RMSE(Vec_Valid);
    %% Normalisation des entrées pour l'apprentissage
    [pn,ps]=mapminmax(In_Learn');
    Results.(Var_Name{ivar}).Uncertainties.Norm_Input=ps;
    %%  normalisation des sorties pour l'apprentissage
    [tn,ts]=mapminmax(Out_Learn');
    Results.(Var_Name{ivar}).Uncertainties.Norm_Output=ts;
    %%  On créé les 3 jeux de données: Learn, Hyper, Valid
    Learn.P=pn;
    Hyper.P=mapminmax('apply',In_Valid',ps);
    Valid.P=Hyper.P;
    Learn.T=tn;
    Hyper.T=mapminmax('apply',Out_Valid',ts);
    Valid.T=Hyper.T;
    %%  Entrainement des X réseaux de neurones
    Rmse_net=zeros(5,2).*NaN; % Initialisation des performances des reseaux testes
    for ires=1:3
        
                %%      Initialisation du réseau
        NET = feedforwardnet(Def_Base.NNT_Archi.LAI.Nb_Neurons);
        NET.trainParam.show = 50;
        NET.trainParam.epochs = 250;
        NET.trainParam.goal = 1e-3;
                %%      Apprentissage du réseau
        NET=train(NET,Learn.P,Learn.T,'useParallel','yes','useGPU','yes');
        %%      Application du reseau et Renormalisation des sorties
        Var_Learn  = mapminmax('reverse',sim(NET,Learn.P),ts);
        Var_Valid  = mapminmax('reverse',sim(NET,Valid.P),ts);
        %%      On garde le meilleur réseau en prenant comme référence la base d'apprentissage
        Rmse_net(ires,:)=[rmse(Out_Learn,Var_Learn') rmse(Out_Valid,Var_Valid')];
        if min(Rmse_net(:,1))==Rmse_net(ires,1)
            Best_Res=ires; %  meilleur réseau
            Results.(Var_Name{ivar}).Uncertainties.NET=NET; % on garde le meilleur réseau
            Results.(Var_Name{ivar}).Uncertainties.RMSE=Rmse_net(Best_Res,:); % RMSE du meilleur réseau
        end
    end % fin boucle sur n reseaux (ires)
    Perf_Theo.(Var_Name{ivar}).Uncertainties.Output.Estime=mapminmax('reverse',sim(Results.(Var_Name{ivar}).Uncertainties.NET, Valid.P),ts)'; % les estimées
    Perf_Theo.(Var_Name{ivar}).Uncertainties.Input.Valid = In_Valid;
    Perf_Theo.(Var_Name{ivar}).Uncertainties.Output.Valid = Out_Valid;
    Perf_Theo.(Var_Name{ivar}).Uncertainties.Output.All(Vec(1:round(2/3*length(Input_Valid)))) =  Out_Learn ;
    Perf_Theo.(Var_Name{ivar}).Uncertainties.Output.All(Vec(length(Vec_Learn)+1:end)) =  Out_Valid ;    
    %% EDITION DES FIGURES
    figure(2)
    plot(Perf_Theo.(Var_Name{ivar}).Uncertainties.Output.Valid,Perf_Theo.(Var_Name{ivar}).Uncertainties.Output.Estime,'k.')
    hold on
    plot([ts.xmin ts.xmax],[ts.xmin ts.xmax],'-k')
    axis('square')
    axis([ts.xmin ts.xmax ts.xmin ts.xmax])
    box on
    xlabel(['RMSE(' Var_Name{ivar} ') Observed'])
    ylabel(['RMSE(' Var_Name{ivar} ') Estimated'])
    print([Def_Base.Report_Dir '\Class_' num2str(Class) '\Perfo_Model_Uncertainties_' Var_Name{ivar}],'-dpng')
    clear In_Valid Out_Valid Var_Learn NET Best_Res Lear Valid Hyper tn ts pn ps Vec_Learn Vec_Valid Vec

end % fin boucle i_var