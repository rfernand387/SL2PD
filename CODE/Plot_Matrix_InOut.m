function Plot_Matrix_InOut(Def_Base, Law, Input, Output, Class)
%% Edition des distributions et co-distributions des variables In et Out
% Fred Septembre 2009
% Marie, septembre 2010: matrice des résidus (bruit - valeur nominale) en
% fonction des valeurs nominales
% Richard July 2019

Ref=['Rho_' Def_Base.Toc_Toa]; % choix Toc ou Toa

%% les distributions en entrée
Var_Name=fieldnames(Law);
Var_Name = Var_Name(~ismember(Var_Name,[{'Dates'},{'View_Zenith'},{'View_Azimuth'},{'Sun_Zenith'} ,{'Sun_Azimuth'},{'Sun_Zenith_FAPAR'},{'I_Soil'}]));
x=[];
for ivar=1:length(Var_Name)
    x=cat(2,x,Law.(Var_Name{ivar}));
end

figure
set(gcf,'defaulttextinterpreter','none')
gplotmatrixv2(x,[],[],'k',[],[],'on','hist',Var_Name)
print([Def_Base.Report_Dir '\Class_' num2str(Class) '\Learn_Data_Base\Matrix_Law_' Def_Base.Algorithm_Name Def_Base.Regression.(Def_Base.Algorithm_Name).Method],'-dpng') 


%% les réflectances
clf
gplotmatrixv2(Input.(Ref),[],[],'k',[],[],'on','hist',reshape(Def_Base.Bandes_Utiles,length(Def_Base.Bandes_Utiles),1))
print([Def_Base.Report_Dir '\Class_' num2str(Class) '\Learn_Data_Base\Matrix_Reflectance_' Def_Base.Algorithm_Name Def_Base.Regression.(Def_Base.Algorithm_Name).Method],'-dpng') 


%% les angles
if isfield(Input,'Angles')
    clf
    gplotmatrixv2(Input.Angles,[],[],'k',[],[],'on','hist',reshape(Def_Base.Angles,length(Def_Base.Angles),1))
    print([Def_Base.Report_Dir '\Class_' num2str(Class) '\Learn_Data_Base\Matrix_Angles_' Def_Base.Algorithm_Name Def_Base.Regression.(Def_Base.Algorithm_Name).Method],'-dpng')
end

%% les variables de sortie
Var_Names=fieldnames(Output);
x=[];
for ivar=1:length(Var_Names)
    x=cat(2,x,Output.(Var_Names{ivar}));
end
clf
gplotmatrixv2(x,[],[],'k',[],[],'on','hist',Var_Names)
print([Def_Base.Report_Dir '\Class_' num2str(Class) '\Learn_Data_Base\Matrix_Variables_' Def_Base.Algorithm_Name Def_Base.Regression.(Def_Base.Algorithm_Name).Method],'-dpng') 
close(gcf)

%% D
Var_Names=fieldnames(Output);
x=[];
x=cat(2,x,Output.D);
x=cat(2,x,Output.LAI);
x=cat(2,x,Output.FCOVER);

clf
density_f(Output.D,Output.LAI)
colorbar()
xlabel('D')
ylabel('LAI')
print([Def_Base.Report_Dir '\Class_' num2str(Class) '\Learn_Data_Base\DvsLAI_' Def_Base.Algorithm_Name Def_Base.Regression.(Def_Base.Algorithm_Name).Method],'-dpng') 
close(gcf)
clf
density_f(Output.D,Output.FCOVER)
colorbar()
xlabel('D')
ylabel('FCOVER')
print([Def_Base.Report_Dir '\Class_' num2str(Class) '\Learn_Data_Base\DvsFCOVER_'  Def_Base.Algorithm_Name Def_Base.Regression.(Def_Base.Algorithm_Name).Method],'-dpng') 
close(gcf)

