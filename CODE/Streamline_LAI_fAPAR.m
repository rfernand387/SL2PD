function [Def_Base]=Streamline_LAI_fAPAR(Def_Base,Output,Input,Law,Class)
%% Elimination des cas qui sont en dehors de la relation LAI_fAPAR attendue
% et des cas avec LAI 'local' trop fort 
% Fred Fevrier 2006
% Modif Fred 09/03/2007
% Modif Marie 20/04/2007 
% Modif Fred Avril 2008

%% Définitions et lecture des entrées
[x,y]= xlsread([Def_Base.File_XLS '.xls'],'Learning_Data','C5'); % valeur minimum de fAPAR max
Def_Base.Streamline.LAI_fAPAR.Delta=x(1);
[x,y]= xlsread([Def_Base.File_XLS '.xls'],'Learning_Data','C6'); % valeur de LAI local 'maximum'
Def_Base.Streamline.LAI_Max_Local=x(1);

%% élimination des cas avec LAI 'local' trop fort
I_Max=Output.LAI./Law.Crown_Cover < Def_Base.Streamline.LAI_Max_Local;

%% élimination des cas avec FAPAR <0 arrive quand position du soleil à l'heure demandée est top basse
I_Max = intersect(I_Max,find(Output.FAPAR>0));

%% visualisation de la relation LAI_fAPAR 'brute' de la base d'apprentissage initiale
i=0;
LAI=cell(1,length(0:0.1:5.9));
fAPAR=cell(1,length(0:0.1:5.9));
for I_LAI=0:0.1:Def_Base.Var_in.(['Class_' num2str(Class)]).LAI.Ub % boucle sur les classes de LAI
    i=i+1;
    I=find(Output.LAI>I_LAI & Output.LAI<(I_LAI+0.1));
    LAI(i)={Output.LAI(I)};
    fAPAR{i}=Output.FAPAR(I);
end
close
figure(1)
    LAI_fAPAR=load('MODIS_LAI_fAPAR.txt'); % tracé de la relation LAI_fAPAR de MODIS
    h_plot(1) = plot(LAI_fAPAR(:,1),LAI_fAPAR(:,2),'ko');

%% tracé des histogrammes des valeurs
fAPAR_Percent=[];
fAPAR_Out=cell(size(LAI,2),2);
for i=1:(size(LAI,2)-1)
    if isempty(fAPAR{i}) % si classe vide
        fAPAR_Percent=cat(1,fAPAR_Percent,[i./10-0.05 nan nan nan nan nan]);
        fAPAR_Out{i,1}=nan;
        fAPAR_Out{i,2}=nan;
    else
        fAPAR_Percent=cat(1,fAPAR_Percent,[i./10-0.05 prctile(fAPAR{i},[2.5 25 50 75 97.5])]);
        fAPAR_Out{i,1}=fAPAR{i}(fAPAR{i}<fAPAR_Percent(i,2));
        fAPAR_Out{i,2}=fAPAR{i}(fAPAR{i}>fAPAR_Percent(i,6));
    end
end
hold on
h = plot(fAPAR_Percent(:,1),fAPAR_Percent(:,[2 6]),':k');
h_plot(5) = h(1);
h = plot(fAPAR_Percent(:,1),fAPAR_Percent(:,[3 5]),'--k');
h_plot(4) = h(1);
h_plot(3) = plot(fAPAR_Percent(:,1),fAPAR_Percent(:,4),'-k');
x=(0:0.1:Def_Base.Var_in.(['Class_' num2str(Class)]).LAI.Ub)';
plot(x,Def_Base.Streamline.LAI_fAPAR.Delta.*(1-exp(-0.6.*(x-0.2))),'k^','linewidth',2)% plot de la limite basse
xlabel('LAI')
ylabel('fAPAR')
box on
str={'MODIS relationship';'threshold model';'median';'+/- 50 %';'+/- 1% extrem'};
ind=find(h_plot~=0);
%l=legend(h_plot(ind),str{ind});
l=legend(str{ind});

set(l,'position',[0.6 0.15 0.28 0.21])
set(l,'fontsize',8)
%t=suptitle('Streamline');
%set(t,'fontsize',12,'fontweight','bold')
axis([0 Def_Base.Var_in.(['Class_' num2str(Class)]).LAI.Ub 0 1])
print(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class) '\learn_Data_Base'],'LAI_fAPAR_Streamline'),'-dpng')
close

%% filtrage de la base d'apprentissage
I=Output.FAPAR-(Def_Base.Streamline.LAI_fAPAR.Delta.*(1-exp(-0.6.*(Output.LAI-0.2))))>0;
Def_Base.Input.Streamline.LAI_fAPAR=I & I_Max;
