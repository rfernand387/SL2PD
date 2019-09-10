function Plot_Perfo_Theo2(Def_Base,Results,Perf_Theo,Perf_Theo2,Class,AlgName,Errorflag)
% Calcul et édition des performances théoriques des réseaux
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

for ivar=1:length(Var_Name)
    Perf_Theo.(Var_Name{ivar}).Estime = Perf_Theo.(Var_Name{ivar}).Estime- Perf_Theo2.(Var_Name{ivar}).Estime';
        Max_xy=max(max([Perf_Theo.(Var_Name{ivar}).Estime,Perf_Theo.(Var_Name{ivar}).Valid]));
        if ( ~isempty(Max_xy))
    %%  Scatterplot (density) entre mesurée et estimée
    figure
    clf
    subplot(2,2,1)
    density_fp(Perf_Theo.(Var_Name{ivar}).Valid,Perf_Theo.(Var_Name{ivar}).Estime,[0 Max_xy 0 Max_xy]);
    hold on
    plot([0 Max_xy],[0 Max_xy],'k-')
    axis square
    
    d=title(['RMSE = ' num2str(Results.(Var_Name{ivar}).RMSE)]);
    set(d,'interpreter','none')
    xlabel(['Validation ' Var_Name{ivar} Errorflag]);
    ylabel(['Estimated ' Var_Name{ivar} Errorflag]);
    box on

    %%  Analyse des résidus et modele polynomial
    subplot(2,2,2)
    Residus=Perf_Theo.(Var_Name{ivar}).Valid-Perf_Theo.(Var_Name{ivar}).Estime; % les résidus
    Residus(length(Residus)) = Residus(length(Residus)) + 1e-6;
    density_f(Perf_Theo.(Var_Name{ivar}).Valid,Residus,[0 Max_xy  min(Residus) max(Residus)]);
    axis square
    axis([0 Max_xy min(Residus) max(Residus)]);
    xlabel(['Estimated ' Var_Name{ivar} Errorflag ]);
    ylabel([Var_Name{ivar} Errorflag '_{Mes}-' Var_Name{ivar}  Errorflag '_{Est}']);
    % modele quadratique des résidus
    P = polyfit(Perf_Theo.(Var_Name{ivar}).Estime,Perf_Theo.(Var_Name{ivar}).Valid-Perf_Theo.(Var_Name{ivar}).Estime,2);
    hold on
    plot(0:0.1:Max_xy,polyval(P,(0:0.1:Max_xy)'),'-r','linewidth',1.5)
    plot([0 Max_xy],[0 0],'-k')
    hold off
    box on

    %%  Box_plot des residus
    subplot(2,2,3)
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
    axis square
    axis([0 Max_xy min(Residus) max(Residus)]);
    title(['RMSE=(',num2str(P(1),'%0.4g'),').' Var_Name{ivar}  Errorflag '² + (',num2str(P(2),'%0.4g'),').' Var_Name{ivar}  Errorflag '+ (',num2str(P(3),'%0.4g'),')'],'FontSize',7)
    xlabel(['Estimated ' Var_Name{ivar} Errorflag] );
    ylabel([Var_Name{ivar}  Errorflag '_{Mes}-' Var_Name{ivar}  Errorflag '_{Est} & RMSE ']);
    plot([0 Max_xy],[0 0],'-k')
    hold off
    box on


    %%  Analyse des résidus/True
    subplot(2,2,4)
    density_f(Perf_Theo.(Var_Name{ivar}).Valid,Perf_Theo.(Var_Name{ivar}).Valid-Perf_Theo.(Var_Name{ivar}).Estime,[0 Max_xy nan nan]);
    axis square
    axis([0 Max_xy min(Residus) max(Residus)]);
    xlabel(['Validation ' Var_Name{ivar} Errorflag ]);
    ylabel([Var_Name{ivar} Errorflag  '_{Mes}-' Var_Name{ivar} Errorflag   '_{Est}' ]);
    % modele quadratique de biais
    P = polyfit(Perf_Theo.(Var_Name{ivar}).Valid,Residus,2);
    hold on
    plot(0:0.1:Max_xy,polyval(P,(0:0.1:Max_xy)'),'-r','linewidth',1.5)
    plot(X,Var_Rmse_True,'ok','linewidth',1.5);
    plot([0 Max_xy],[0 0],'-k')
    hold off
    box on
    colormap(anti_gray)
    set(gcf,'position',[145    41   767   644])
    str={'median';'Rmse';'Rmse model'};
    l=legend(h_plot,str);
    set(l,'fontsize',7)
    set(l,'position',[0.45 0.48 0.13 0.1])
    print([Def_Base.Report_Dir '\Class_' num2str(Class) '\Perf' AlgName '_' Var_Name{ivar} ],'-dpng')
    close

%% histogramme des sorties avant et apres apprentissage
figure(ceil(ivar/4)+1)
subplot(2,2,Ordre_Fig(ivar))
% histogramme de la variable de la base d'apprentissage (sur toute la base)
Edges= 0:Max_xy/25:Max_xy;
hold on
% histogramme de la variable de la base d'apprentissage filtrée
N=histc(Perf_Theo.(Var_Name{ivar}).Valid,Edges);
max_N=max(N./sum(N));% maxi en frequence
plot(Edges,N./sum(N),'k-','linewidth',1)
% histogramme des variables estimées par le réseau (sur la base filtrée)
N=hist(Perf_Theo.(Var_Name{ivar}).Estime,Edges);
plot(Edges,N./sum(N),'k-','linewidth',2)
max_N=max([N./sum(N) max_N]);
axis('square')
axis([0 max(Edges) 0 max_N])
xlabel([Var_Name{ivar} Errorflag] )
ylabel('Frequency')
hold off
print([Def_Base.Report_Dir '\Class_' num2str(Class) '\Hist2' AlgName '_'  num2str(ceil(ivar/4)+1)],'-dpng')% print des figures
        end
end
close all
