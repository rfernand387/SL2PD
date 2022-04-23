function ShortCut()

status = 1;
tic;
addpath(genpath('.\CODE'));
addpath(genpath('.\DATA'));
addpath(genpath('.\Toee'));
[x,class_name] = xlsread('sl2p_indextable.xlsx','L5', 'A2:C13');
%[x,class_name] = xlsread('sl2p_indextable.xlsx','Prosail', 'A1:C11');


for x= 9:12

parameter_file = class_name{x,2};    
%xlswrite(s2_sl20_single_or_prosail,parameter_file,'Start','B4');
%status=SL2PD(s2_sl20_single_or_prosail,0,1);
status = SL2PD([parameter_file],1,1);
ToCSV(parameter_file);
end
toc 