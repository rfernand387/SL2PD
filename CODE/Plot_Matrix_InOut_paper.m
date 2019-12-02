function Plot_Matrix_InOut_paper(Def_Base, Law, Input, Output, Class,subsamp)
%% Edition des distributions et co-distributions des variables In et Out
% Fred Septembre 2009
% Marie, septembre 2010: matrice des résidus (bruit - valeur nominale) en
% fonction des valeurs nominales
% Richard July 2019

Ref=['Rho_' Def_Base.Toc_Toa]; % choix Toc ou Toa
% Subsampling Rate for visualization
ind = 1:subsamp:length(Law.LAI);

%% les distributions en entrée
Var_Name=fieldnames(Law);
Var_Name = Var_Name(~ismember(Var_Name,[{'Dates'},{'View_Zenith'},{'View_Azimuth'},{'Sun_Zenith'} ,{'Sun_Azimuth'},{'Sun_Zenith_FAPAR'},{'I_Soil'},{'P'},{'Tau550'},{'H2O'},{'O3'},{'Crown_Cover'},{'Age'}]));
x=[];
for ivar=1:length(Var_Name)
    x=cat(2,x,Law.(Var_Name{ivar})(ind));
end

figure
set(gcf,'defaulttextinterpreter','none')
gplotmatrixv2(x,[],[],'k',[],[],'on','hist',Var_Name)
print('-bestfit',[Def_Base.Report_Dir '\Class_' num2str(Class) '\Learn_Data_Base\Matrix_Law_subsam' num2str(subsamp) '_' Def_Base.Algorithm_Name Def_Base.Regression.(Def_Base.Algorithm_Name).Method],'-dpdf') 


%% les réflectances
clf
gplotmatrixv2(Input.(Ref),[],[],'k',[],[],'on','hist',reshape(Def_Base.Bandes_Utiles,length(Def_Base.Bandes_Utiles),1))
print([Def_Base.Report_Dir '\Class_' num2str(Class) '\Learn_Data_Base\Matrix_Reflectance_subsam' num2str(subsamp) '_' Def_Base.Algorithm_Name Def_Base.Regression.(Def_Base.Algorithm_Name).Method],'-dpng') 


%% les angles
if isfield(Input,'Angles')
    clf
    %gplotmatrixv2(Input.Angles(ind,:),[],[],'k',[],[],'on','hist',reshape(Def_Base.Angles,length(Def_Base.Angles),1))
    gplotmatrixv2(Input.Angles(ind,:),[],[],'k',[],[],'on','hist',{'View Zenith','Sun Zenith','Rel. Azimuth'})
    print('-bestfit',[Def_Base.Report_Dir '\Class_' num2str(Class) '\Learn_Data_Base\Matrix_Angles_subsam' num2str(subsamp) '_' Def_Base.Algorithm_Name Def_Base.Regression.(Def_Base.Algorithm_Name).Method],'-dpdf')
end

%% les variables de sortie
Var_Names=fieldnames(Output);
x=[];
for ivar=1:length(Var_Names)
    x=cat(2,x,Output.(Var_Names{ivar}));
end
clf
gplotmatrixv2(x(ind,:),[],[],'k',[],[],'on','hist',Var_Names)
print([Def_Base.Report_Dir '\Class_' num2str(Class) '\Learn_Data_Base\Matrix_Variables_subsam' num2str(subsamp) '_' Def_Base.Algorithm_Name Def_Base.Regression.(Def_Base.Algorithm_Name).Method],'-dpng') 
close(gcf)

%% D (now called S)
Var_Names=fieldnames(Output);
x=[];
x=cat(2,x,Output.D);
x=cat(2,x,Output.LAI);
x=cat(2,x,Output.FCOVER);

clf
density_f(Output.D,Output.LAI)
colorbar()
xlabel('S')
ylabel('LAI')
print([Def_Base.Report_Dir '\Class_' num2str(Class) '\Learn_Data_Base\DvsLAI_' Def_Base.Algorithm_Name Def_Base.Regression.(Def_Base.Algorithm_Name).Method],'-dpng') 
close(gcf)
clf
density_f(Output.D,Output.FCOVER)
colorbar()
xlabel('S')
ylabel('FCOVER')
print([Def_Base.Report_Dir '\Class_' num2str(Class) '\Learn_Data_Base\DvsFCOVER_'  Def_Base.Algorithm_Name Def_Base.Regression.(Def_Base.Algorithm_Name).Method],'-dpng') 
close(gcf)

