function Def_Base =  Read_Start_Data(Version_Name)
%% Read current simulation options
% Richard July 2019


xlswrite([Version_Name '.xls'],{Version_Name},'Start','B1');
Def_Base.Name=Version_Name;
Def_Base.File_XLS=Version_Name;
[x,y]= xlsread([Def_Base.File_XLS '.xls'],'Start','B3');
Def_Base.Algorithm_Name=char(y);
[x,y]= xlsread([Def_Base.File_XLS '.xls'],'Start','B4');
Def_Base.Validation_Name=char(y);
[x,y]= xlsread([Def_Base.File_XLS '.xls'],'Start','B5');
Def_Base.CopyFlag=x;



