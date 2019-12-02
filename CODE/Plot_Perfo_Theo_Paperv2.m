function Plot_Perfo_Theo_paperv2(Def_Base,Results,Perf_Theo,Class,AlgName,Errorflag)
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
        Min_xy = 0;  
        Low_xy = prctile([ Perf_Theo.(Var_Name{ivar}).Valid],5)
        Median_xy = prctile([ Perf_Theo.(Var_Name{ivar}).Valid],50)
                Hi_xy=prctile([Perf_Theo.(Var_Name{ivar}).Valid],95)

        Max_xy=prctile([Perf_Theo.(Var_Name{ivar}).Valid],99)
        if ( ~isempty(Max_xy))
    %%  Scatterplot (density) entre mesurée et estimée
    figure
    clf
    p1=subplot(1,2,1)
    density_fp(Perf_Theo.(Var_Name{ivar}).Valid,Perf_Theo.(Var_Name{ivar}).Estime,[Min_xy Max_xy Min_xy Max_xy]);
    hold on
    plot([Min_xy Max_xy],[Min_xy Max_xy],'k-')
    axis square
    
%     d=title(['RMSE = ' num2str(Results.(Var_Name{ivar}).RMSE)]);
%     set(d,'interpreter','none')
    if ( strcmp(Var_Name{ivar},'FCOVER'))
                                ylabel('$$\hat{FCOVER}$$ ' ,'Interpreter','Latex');
    xlabel('$$FCOVER$$' ,'Interpreter','Latex');
    elseif ( strcmp(Var_Name{ivar},'LAI'))
                                ylabel('$$\hat{LAI}$$ ' ,'Interpreter','Latex');
    xlabel('LAI' ,'Interpreter','Latex');
        elseif ( strcmp(Var_Name{ivar},'Albedo'))
                                ylabel('$$\hat{A}$$ ' ,'Interpreter','Latex');
    xlabel('$$A$$' ,'Interpreter','Latex');
    elseif ( strcmp(Var_Name{ivar},'D'))
    ylabel('$$\hat{D}$$ ' ,'Interpreter','Latex');
    xlabel('$$D$$' ,'Interpreter','Latex');
                            
    elseif ( strcmp(Var_Name{ivar},'LAI_Cw'))
                                ylabel('$$\hat{CWC}$$ ' ,'Interpreter','Latex');
    xlabel('$$CWC$$' ,'Interpreter','Latex');
        elseif ( strcmp(Var_Name{ivar},'LAI_Cab'))
                                ylabel('$$\hat{CCC}$$' ,'Interpreter','Latex');
    xlabel('$$CCC$$' ,'Interpreter','Latex');
    end

    box on

%     %%  Analyse des résidus et modele polynomial
%     subplot(2,2,2)
    Residus=Perf_Theo.(Var_Name{ivar}).Valid-Perf_Theo.(Var_Name{ivar}).Estime; % les résidus
    Residus(length(Residus)) = Residus(length(Residus)) + 1e-6;
%     density_f(Perf_Theo.(Var_Name{ivar}).Valid,Residus,[Min_xy Max_xy  min(Residus) max(Residus)]);
%     axis square
%     axis([Min_xy Max_xy min(Residus) max(Residus)]);
%     xlabel(['Estimated ' Var_Name{ivar} Errorflag ]);
%     ylabel([Var_Name{ivar} Errorflag '_{Mes}-' Var_Name{ivar}  Errorflag '_{Est}']);
%     % modele quadratique des résidus
%     P = polyfit(Perf_Theo.(Var_Name{ivar}).Estime,Perf_Theo.(Var_Name{ivar}).Valid-Perf_Theo.(Var_Name{ivar}).Estime,2);
%     hold on
%     plot(Min_xy:0.1:Max_xy,polyval(P,(Min_xy:0.1:Max_xy)'),'-r','linewidth',1.5)
%     plot([Min_xy Max_xy],[0 0],'-k')
%     hold off
%     box on

    %%  Box_plot des residus
    p2 = subplot(1,2,2)
    Nb_Class=50; % On fixe le nombre de classe à 50
    Var_Rmse_True=zeros(Nb_Class,1);
    Var_Rmse_Est=zeros(Nb_Class,1);
    Delta=(Max_xy-Min_xy)/Nb_Class; % pas des classes
    x=-Delta./2 + Min_xy; % valeur initiale du centre de la classe
    X=[];
    Y=zeros(Nb_Class,5);
    hold on
    for i=1:Nb_Class % boucle sur les classes
        x=x+Delta; % incrémentation de la valeur du centre de la classe
        X=cat(1,X,x);
        I=find((Perf_Theo.(Var_Name{ivar}).Estime>x-Delta/2) & (Perf_Theo.(Var_Name{ivar}).Estime<x+Delta/2)); % par rapport aux estimées
        II=find((Perf_Theo.(Var_Name{ivar}).Valid>x-Delta/2) & (Perf_Theo.(Var_Name{ivar}).Valid<x+Delta/2)); % par rapport aux 'vraies'
        Var_Rmse_True(i)=rmse(Perf_Theo.(Var_Name{ivar}).Valid(II),Perf_Theo.(Var_Name{ivar}).Estime(II));
        if ~isempty(II)
            Res=-(Perf_Theo.(Var_Name{ivar}).Valid(II)-Perf_Theo.(Var_Name{ivar}).Estime(II)); % les residus de la classe
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
            Var_Rmse_Est(i)=rmse(Perf_Theo.(Var_Name{ivar}).Valid(II),Perf_Theo.(Var_Name{ivar}).Estime(II));
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
    axis([Min_xy Max_xy min(Residus) max(Residus)]);
    if ( strcmp(Var_Name{ivar},'FCOVER'))
            axis([Min_xy Max_xy -0.151 0.151]);
                plot([Low_xy Low_xy], [ -0.151 0.151],':b','linewidth',1.5) 
                                plot([Median_xy Median_xy ], [-0.151 0.151],'b','linewidth',1.5) 
                                                                plot([Hi_xy Hi_xy ], [-0.151 0.151],':b','linewidth',1.5) 
                                ylabel('$$\hat{FCOVER}$$ - $$FCOVER$$ ' ,'Interpreter','Latex');
    xlabel('$$FCOVER$$' ,'Interpreter','Latex');
    elseif ( strcmp(Var_Name{ivar},'LAI'))
            axis([Min_xy Max_xy -2.1 2.1]);
                            plot([Low_xy Low_xy], [-2.1 2.1],':b','linewidth',1.5) 
                                plot([Median_xy Median_xy ], [-2.1 2.1],'b','linewidth',1.5) 
                                                                plot([Median_xy Median_xy ], [-2.1 2.1],'b','linewidth',1.5) 
                            plot([Hi_xy Hi_xy], [-2.1 2.1],':b','linewidth',1.5) 
                                ylabel('$$\hat{LAI}$$ - $$LAI$$ ' ,'Interpreter','Latex');
    xlabel('$$LAI$$' ,'Interpreter','Latex');
        elseif ( strcmp(Var_Name{ivar},'Albedo'))
            axis([Min_xy Max_xy -2.1 2.1]);
                            plot([Low_xy Low_xy], [-0.1 0.1],':b','linewidth',1.5) 
                                plot([Median_xy Median_xy ], [-0.1 0.1],'b','linewidth',1.5) 
                                                                plot([Median_xy Median_xy ], [--0.1 0.1],'b','linewidth',1.5) 
                            plot([Hi_xy Hi_xy], [-0.1 0.1],':b','linewidth',1.5) 
                                ylabel('$$\hat{A}$$ - $$A$$ ' ,'Interpreter','Latex');
    xlabel('$$A$$' ,'Interpreter','Latex');

    elseif ( strcmp(Var_Name{ivar},'D'))
            axis([Min_xy Max_xy -0.2 0.2]);
                            plot([Low_xy Low_xy], [-0.2 0.2],':b','linewidth',1.5) 
                                plot([Median_xy Median_xy ], [-0.2 0.2],'b','linewidth',1.5) 
                                                                plot([Median_xy Median_xy ], [-0.2 0.2],'b','linewidth',1.5) 
                            plot([Hi_xy Hi_xy], [-0.2 0.2],':b','linewidth',1.5) 

    ylabel('$$D$$ - $$\hat{D}$$ ' ,'Interpreter','Latex');
    xlabel('$$D$$' ,'Interpreter','Latex');
                            
    elseif ( strcmp(Var_Name{ivar},'LAI_Cw'))
            axis([Min_xy Max_xy -0.11 0.11]);
                            plot([Low_xy Low_xy], [-0.11 0.11],':b','linewidth',1.5) 
                                plot([Median_xy Median_xy], [-0.11 0.11],'b','linewidth',1.5) 
                            plot([Hi_xy Hi_xy], [-0.11 0.11],':b','linewidth',1.5) 
                                ylabel('$$\hat{CWC}$$ - $$CWC$$ ' ,'Interpreter','Latex');
    xlabel('$$CWC$$' ,'Interpreter','Latex');
        elseif ( strcmp(Var_Name{ivar},'LAI_Cab'))
            axis([Min_xy Max_xy -100 100]);
                            plot([Low_xy Low_xy], [-100 100],':b','linewidth',1.5) 
                                plot([Median_xy Median_xy], [-100 100],'b','linewidth',1.5) 
                            plot([Hi_xy Hi_xy], [-100 100],':b','linewidth',1.5) 
                                ylabel('$$\hat{CCC}$$ - $$CCC$$ ' ,'Interpreter','Latex');
    xlabel('$$CCC$$' ,'Interpreter','Latex');
    end

    
    %title(['RMSE=(',num2str(P(1),'%0.4g'),').' Var_Name{ivar}  Errorflag '² + (',num2str(P(2),'%0.4g'),').' Var_Name{ivar}  Errorflag '+ (',num2str(P(3),'%0.4g'),')'],'FontSize',7)
    plot([Min_xy Max_xy],[0 0],'-k')

    hold off
    box on


    %%  Analyse des résidus/True
%     subplot(2,2,4)
%     density_f(Perf_Theo.(Var_Name{ivar}).Valid,Perf_Theo.(Var_Name{ivar}).Valid-Perf_Theo.(Var_Name{ivar}).Estime,[Min_xy Max_xy nan nan]);
%     axis square
%     axis([Min_xy Max_xy min(Residus) max(Residus)]);Perf
%     xlabel(['Validation ' Var_Name{ivar} Errorflag ]);
%     ylabel([Var_Name{ivar} Errorflag  '_{Mes}-' Var_Name{ivar} Errorflag   '_{Est}' ]);
%     % modele quadratique de biais
%     P = polyfit(Perf_Theo.(Var_Name{ivar}).Valid,Residus,2);
%     hold on
%     plot(Min_xy:0.1:Max_xy,polyval(P,(Min_xy:0.1:Max_xy)'),'-r','linewidth',1.5)
%     plot(X,Var_Rmse_True,'ok','linewidth',1.5);
%     plot([0 Max_xy],[0 0],'-k')
%     hold off
%     box on
%     colormap(anti_gray)
%     set(gcf,'position',[145    41   767   644])
%     str={'median';'Rmse';'Rmse model'};
%     l=legend(h_plot,str);
%     set(l,'fontsize',7)
%     set(l,'position',[0.45 0.48 0.13 0.1])
p1.Position = [0.0700 0.1100 0.3347 0.8150];
p2.Position = [0.6000 0.1100 0.3347 0.8150];
    print('-bestfit',[Def_Base.Report_Dir '\Class_' num2str(Class) '\Perf' AlgName '_' Var_Name{ivar} ],'-dpdf')
print([Def_Base.Report_Dir '\Class_' num2str(Class) '\Perf' AlgName '_' Var_Name{ivar} 'Paperx'],'-dpng')
%     close
% 
% %% histogramme des sorties avant et apres apprentissage
% figure(ceil(ivar/4)+1)
% subplot(2,2,Ordre_Fig(ivar))
% % histogramme de la variable de la base d'apprentissage (sur toute la base)
% Edges= Min_xy:Max_xy/25:Max_xy;
% hold on
% % histogramme de la variable de la base d'apprentissage filtrée
% N=histc(Perf_Theo.(Var_Name{ivar}).Valid,Edges);
% max_N=max(N./sum(N));% maxi en frequence
% plot(Edges,N./sum(N),'k-','linewidth',1)
% % histogramme des variables estimées par le réseau (sur la base filtrée)
% N=hist(Perf_Theo.(Var_Name{ivar}).Estime,Edges);
% plot(Edges,N./sum(N),'k-','linewidth',2)
% max_N=max([N./sum(N) max_N]);
% axis('square')
% axis([min(Edges) max(Edges) 0 max_N])
% xlabel([Var_Name{ivar} Errorflag] )
% ylabel('Frequency')
% hold off
% print([Def_Base.Report_Dir '\Class_' num2str(Class) '\Hist2' AlgName '_'  num2str(ceil(ivar/4)+1)],'-dpng')% print des figures
        end
end
close all
