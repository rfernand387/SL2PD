function Plot_Law(Def_Base,Law,I_Select_Sim,Class)
% edition des distributions des variables
% Fred 28/11/2005
% Modif Fred Aout 2007
% Modif Fred Octobre 2007
% Modif Fred Janvier 2008
% Modif Fred Avril 2008

%% Initialisations
List_Var.Canopy={'LAI';'ALA';'Crown_Cover';'HsD';'D'; 'Age'};
List_Var.Leaf={'Cab';'Cbp';'Cdm';'Cw_Rel';'N'};
List_Var.Soil={'Bs';'I_Soil'};
List_Var.Geometry={'Sun_Zenith';'View_Zenith';'Rel_Azimuth';'Sun_Zenith_FAPAR'};
if strcmp(Def_Base.Toc_Toa,'Toa') % dans le cas de l'atmosphere
        List_Var.Atmosphere={'P';'Tau550';'H2O';'O3'};
end
Type_Name=fieldnames(List_Var);
Ordre_Fig={1;[1 2];[1 2 3];[1 2 4 5];[1 2 3 4 5];[1 2 3 4 5 6]}; % définition de l'ordre des figures
if isempty(I_Select_Sim)
    I_Select_Sim=ones(length(Law.LAI),1);
end

%% Edition des hitogrammes
for itype=1:size(Type_Name,1)% boucle sur les types
    figure
    Nb_Var=size(List_Var.(Type_Name{itype}),1); % Nombre de variables du type
    for ivar=1:Nb_Var; % boucle sur les variables par type
        if isfield(Law,List_Var.(Type_Name{itype}){ivar}) % si il y a bien la variable
            if itype == 4 % dans le cas de la géométrie, on met les angles en degrés
                deg_rad=180./pi;
            else
                deg_rad=1; % sinon, pas de correction
            end
            max_X=max(Law.(List_Var.(Type_Name{itype}){ivar}).*deg_rad); % maxi en x
            min_X=min(Law.(List_Var.(Type_Name{itype}){ivar}).*deg_rad); % mini en x
            if min_X < max_X
                subplot(2,3,Ordre_Fig{Nb_Var}(ivar)),% définition des subplots
                X=min_X+(1:30)'.*(max_X-min_X)/30;
                N=hist(Law.(List_Var.(Type_Name{itype}){ivar}).*deg_rad,X); % histogramme initial de la variable
                plot(X,N./sum(N),'k-','linewidth',2)
                max_N=max(N./sum(N));% maxi en frequence
                hold on
                N=hist(Law.(List_Var.(Type_Name{itype}){ivar})(I_Select_Sim==1).*deg_rad,X); % histogramme de la variable filtrée 
                plot(X,N./sum(N),'k--','linewidth',1)
                max_N=max([N./sum(N) max_N]);
                axis('square')
                axis([min_X max_X 0 max_N])
                xlabel(List_Var.(Type_Name{itype}){ivar},'interpreter','none')
                ylabel('Frequency')
                box on
                hold off
            else
                subplot(2,3,Ordre_Fig{Nb_Var}(ivar)),% définition des subplots
                plot(min_X,1)
                axis('square')
                ylabel('Frequency')
                box on
            end
        end
    end
%% Ajout de la legende    
subplot(2,3,6)
plot([0 2],[5 5],'k-','linewidth',2)
hold on
plot([0 2],[3 3],'k--','linewidth',1)
axis('off')
axis([0 10 0 10])
axis('square')
text(2.5,5,'initial')
text(2.5,3,'filtered')
saveas(gcf,fullfile([Def_Base.Report_Dir '\Class_' num2str(Class) '\Learn_Data_Base'],['Hist_Law_' Type_Name{itype}]),'emf') 
close
end

