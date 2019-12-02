function Plot_Perfo_Theo_D(Def_Base,Results,Perf_Theo,Class,AlgName,Errorflag)
% Calcul et édition des performances théoriques des réseaux for D only
% Richard July 2019

%% couleurs des figures de densité
x=colormap(gray(256));
x=colormap(jet(256));
x(1,:)=[1 1 1];
anti_gray=x.^(1/4);
Var_Name=sort(fieldnames(Results)); % le nom des variables
Ordre_Fig=[1 2 3 4 1 2 3 4]; % définition de l'ordre des figures

%% boucle sur les variables
% Les valeurs max des variables dans l'ordre alphabétique
Var = find(strcmp(Var_Name,'D'));
for ivar=Var
        Min_xy = 0;  
        Low_xy = prctile([ Perf_Theo.(Var_Name{ivar}).Valid],5)
        Median_xy = prctile([ Perf_Theo.(Var_Name{ivar}).Valid],50)
                Hi_xy=prctile([Perf_Theo.(Var_Name{ivar}).Valid],95)

        Max_xy=prctile([Perf_Theo.(Var_Name{ivar}).Valid],99)
        Max_xy=max(max([Perf_Theo.(Var_Name{ivar}).Estime,Perf_Theo.(Var_Name{ivar}).Valid]));
        if ( ~isempty(Max_xy))
    %%  Scatterplot (density) entre mesurée et estimée
    figure
    clf
    p1 = subplot(1,2,1)
    density_fp(Perf_Theo.(Var_Name{ivar}).Estime,Perf_Theo.(Var_Name{ivar}).Valid,[0 Max_xy 0 Max_xy]);
    hold on
    plot([0 Max_xy],[0 Max_xy],'k-')
    axis square
    colorbar()
    ylabel('$$D$$ ' ,'Interpreter','Latex');
    xlabel('$$\hat{D}$$' ,'Interpreter','Latex');
    box on

    %%  Analyse des résidus et modele polynomial
    Residus=Perf_Theo.(Var_Name{ivar}).Estime-Perf_Theo.(Var_Name{ivar}).Valid; % les résidus
    Residus(length(Residus)) = Residus(length(Residus)) + 1e-6;


    %%  Box_plot des residus
    p2 = subplot(1,2,2)
    Nb_Class=50; % On fixe le nombre de classe à 50
    Var_Rmse_True=zeros(Nb_Class,1);
    Var_Rmse_Est=zeros(Nb_Class,1);
    Delta=Max_xy/Nb_Class; % pas des classes
    x=-Delta./2; % valeur initiale du centre de la classe
    X=[];
    Y=zeros(Nb_Class,5);
    hold on
    for i=1:Nb_Class % boucle sur les classes
        x=x+Delta; % incrémentation de la valeur du centre de la classe
        X=cat(1,X,x);
        I=find((Perf_Theo.(Var_Name{ivar}).Estime>x-Delta/2) & (Perf_Theo.(Var_Name{ivar}).Estime<x+Delta/2)); % par rapport aux estimées
        II=find((Perf_Theo.(Var_Name{ivar}).Valid>x-Delta/2) & (Perf_Theo.(Var_Name{ivar}).Valid<x+Delta/2)); % par rapport aux 'vraies'
        Var_Rmse_True(i)=rmse(Perf_Theo.(Var_Name{ivar}).Valid(II),Perf_Theo.(Var_Name{ivar}).Estime(II));
        if ~isempty(I)
            Res=Perf_Theo.(Var_Name{ivar}).Valid(I)-Perf_Theo.(Var_Name{ivar}).Estime(I); % les residus de la classe
            Y(i,:)=prctile(Res,[2.5 25 50 75 97.5]);
            plot([x-Delta/4 x+Delta/4 x+Delta/4 x-Delta/4 x-Delta/4],[Y(i,2) Y(i,2) Y(i,4) Y(i,4) Y(i,2)],'-k'); % la boite 25-75%
            plot([x x],[Y(i,1) Y(i,2)],':k'); % la moustache à 2.5-25%
            plot([x-Delta/4 x+Delta/4],[Y(i,1) Y(i,1)],'-k');
            plot([x x],[Y(i,4) Y(i,5)],':k') % la moustache à 75-97.5%
            plot([x-Delta/4 x+Delta/4],[Y(i,5) Y(i,5)],'-k');
            dum=find(Res<Y(i,1)); % les 'outliers bas'
            if ~isempty(dum)
                plot(repmat(x,size(dum,1),1),Res(dum),'k.');
            end
            dum=find(Res>Y(i,5)); % les 'outliers haut'
            if ~isempty(dum)
                plot(repmat(x,size(dum,1),1),Res(dum),'k.');
            end
            Var_Rmse_Est(i)=rmse(Perf_Theo.(Var_Name{ivar}).Valid(I),Perf_Theo.(Var_Name{ivar}).Estime(I));
        end
    end
    I=find(Var_Rmse_Est>0);
    h_plot(1) = plot(X(I),Y(I,3),'-r','linewidth',1.5); % la mediane

    %%  Ajustement du modele quadratique d'erreur
    P = polyfit(X(I),Var_Rmse_Est(I),2);
    Results.(Var_Name{ivar}).Error_Model=P; %Coefficients du polynome decrivant l'erreur
    hold on
    h_plot(2) = plot(X,Var_Rmse_Est,'ok');
    h_plot(3) = plot(X,polyval(P,X),'-k');
       plot([Low_xy Low_xy], [-2.1 2.1],':b','linewidth',1.5) 
                                plot([Median_xy Median_xy ], [-2.1 2.1],'b','linewidth',1.5) 
                            plot([Hi_xy Hi_xy], [-2.1 2.1],':b','linewidth',1.5) 
    axis square
    axis([0 0.85 -0.2 0.2]);
%     title(['RMSE=(',num2str(P(1),'%0.4g'),').' Var_Name{ivar}  Errorflag '² + (',num2str(P(2),'%0.4g'),').' Var_Name{ivar}  Errorflag '+ (',num2str(P(3),'%0.4g'),')'],'FontSize',7)
    xlabel('$$\hat{D}$$' ,'Interpreter','Latex' );
    ylabel('$$\hat{D} - $$D ' ,'Interpreter','Latex');
    plot([0 Max_xy],[0 0],'-k')
    hold off
    box on

p1.Position = [0.0700 0.1100 0.3347 0.8150];
p2.Position = [0.6000 0.1100 0.3347 0.8150];
    print([Def_Base.Report_Dir '\Class_' num2str(Class) '\PerfS' AlgName '_' Var_Name{ivar} ],'-dpng')
    %close


        end

end
%close all
