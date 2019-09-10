function Def_Base =  Read_Learning_Data(Def_Base)
%% Déclaration de la structure permettant de caractériser l'ensemble de la
% base d'apprentissage pour le développement de réseaux de neurones.
% Fred 12/12/2005
% Modif Fred Septembre 2007
% Modif Avril 2008
% Fred Mai 2008
% Richard July 2019


%% Simulations Toc ou Toa?
[x,y]= xlsread([Def_Base.File_XLS '.xls'],'Learning_Data','C1');
Def_Base.Toc_Toa=char(y);


%% terrain complexity method
[x,y]= xlsread([Def_Base.File_XLS '.xls'],'Learning_Data','C2');
Def_Base.Terrain=char(y);

%% classification 
[x,y]= xlsread([Def_Base.File_XLS '.xls'],'Learning_Data','C3');
Def_Base.Classification=char(y);

%% Number of Classes 
[x,y]= xlsread([Def_Base.File_XLS '.xls'],'Learning_Data','C4');
Def_Base.Num_Classes=x;



%% Time used for the computation of fAPAR (decimal hour)
[x,y]= xlsread([Def_Base.File_XLS '.xls'],'Learning_Data','C5');
Def_Base.FAPAR_Time.Hour=floor(x); % l'heure
Def_Base.FAPAR_Time.Minute=(x-floor(x))*60; % l'heure

%% RTM
[x,y]= xlsread([Def_Base.File_XLS '.xls'],'Learning_Data','C6');
Def_Base.RTM=char(y);

%% Maximum number of Sims
[x,y]= xlsread([Def_Base.File_XLS '.xls'],'Learning_Data','C7');
Def_Base.Max_Sims=x;



