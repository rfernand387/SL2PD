function [Def_Base,Input]=Streamline_LAI_D(Def_Base,Output,Input,Law,Class)
%% Elimination des cas qui sont en dehors de la relation LAI_D attendue
% et des cas avec LAI 'local' trop fort 
% Fred Fevrier 2006
% Modif Fred 09/03/2007
% Modif Marie 20/04/2007 
% Modif Fred Avril 2008

%% Définitions et lecture des entrées
[x,y]= xlsread([Def_Base.File_XLS '.xls'],'Learning_Data','C5'); % valeur minimum de D max
Def_Base.Streamline.LAI_D.Delta=x(1);
[x,y]= xlsread([Def_Base.File_XLS '.xls'],'Learning_Data','C6'); % valeur de LAI local 'maximum'
Def_Base.Streamline.LAI_Max_Local=x(1);

%% élimination des cas avec LAI 'local' trop fort
I_Max=Output.LAI./Law.Crown_Cover < Def_Base.Streamline.LAI_Max_Local;

%% élimination des cas avec D <0 arrive quand position du soleil à l'heure demandée est top basse
I_Max = intersect(I_Max,find(Output.D>0));

%% visualisation de la relation LAI_D 'brute' de la base d'apprentissage initiale
i=0;
LAI=cell(1,length(0:0.1:5.9));
D=cell(1,length(0:0.01:0.59));
for I_LAI=0:0.1:Def_Base.Var_in.(['Class_' num2str(Class)]).LAI.Max % boucle sur les classes de LAI
    i=i+1;
    I=find(Output.LAI>I_LAI & Output.LAI<(I_LAI+0.1));
    LAI(i)={Output.LAI(I)};
    D{i}=Output.D(I);
end
close
figure(1)
%     LAI_D=load('MODIS_LAI_D.txt'); % tracé de la relation LAI_D de MODIS
%     h_plot(1) = plot(LAI_D(:,1),LAI_D(:,2),'ko');

%% tracé des histogrammes des valeurs
D_Percent=[];
D_Out=cell(size(LAI,2),2);
for i=1:(size(LAI,2)-1)
    if isempty(D{i}) % si classe vide
        D_Percent=cat(1,D_Percent,[i./10-0.05 nan nan nan nan nan]);
        D_Out{i,1}=nan;
        D_Out{i,2}=nan;
    else
        D_Percent=cat(1,D_Percent,[i./10-0.05 prctile(D{i},[2.5 25 50 75 97.5])]);
        D_Out{i,1}=D{i}(D{i}<D_Percent(i,2));
        D_Out{i,2}=D{i}(D{i}>D_Percent(i,6));
    end
end
hold on
h = plot(D_Percent(:,1),D_Percent(:,[2 6]),':k');
h_plot(5) = h(1);
h = plot(D_Percent(:,1),D_Percent(:,[3 5]),'--k');
h_plot(4) = h(1);
h_plot(3) = plot(D_Percent(:,1),D_Percent(:,4),'-k');
x=(0:0.1:Def_Base.Var_in.(['Class_' num2str(Class)]).LAI.Max)';
plot(x,Def_Base.Streamline.LAI_D.Delta.*(1-exp(-0.6.*(x-0.2))),'k^','linewidth',2)% plot de la limite basse
xlabel('LAI')
ylabel('D')
box on
str={'MODIS relationship';'threshold model';'median';'+/- 50 %';'+/- 1% extrem'};
ind=find(h_plot~=0);
l=legend(h_plot(ind),str{ind});
set(l,'position',[0.6 0.15 0.28 0.21])
set(l,'fontsize',8)
t=suptitle('Streamline');
set(t,'fontsize',12,'fontweight','bold')
axis([0 Def_Base.Var_in.(['Class_' num2str(Class)]).LAI.Max 0 1])
print(fullfile([Def_Base.Report_Dir '\Class_' num2str(Class) '\learn_Data_Base'],'LAI_D_Streamline'),'-dpng')
close

%% filtrage de la base d'apprentissage
I=Output.D-(Def_Base.Streamline.LAI_D.Delta.*(1-exp(-0.6.*(Output.LAI-0.2))))>0;
Input.Streamline.LAI_D=I & I_Max;
