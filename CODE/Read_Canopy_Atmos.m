function Def_Base =  Read_Canopy_Atmos(Def_Base,Class)
%% Definition of class parameters for simulation database creation.
% Fred 12/12/2005
% Modif Fred Septembre 2007
% Modif Avril 2008
% Fred Mai 2008
% Richard July 2019

%% Initialisations
Var={'LAI' 'ALA' 'Crown_Cover' 'HsD' 'N' 'Cab' 'Cdm' 'Cw_Rel' 'Cbp' 'Bs' 'Age' 'P' 'Tau550' 'H2O' 'O3'};
Champ={'Lb' 'Ub' 'P1' 'P2' 'Nb_Classe'};


%% NUmber of SImulations
[x,y]= xlsread([Def_Base.File_XLS '.xls'],['Canopy_Atmos_Class_' num2str(Class)],'G17');
Def_Base.(['Class_' num2str(Class)]).Nb_Sims = x;

%% Select the class to be used												
[x,y]= xlsread([Def_Base.File_XLS '.xls'],['Canopy_Atmos_Class_' num2str(Class)],'C18');
Def_Base.(['Class_' num2str(Class)]).ClassNumber=x;

%% Name of the class selected
[x,y]= xlsread([Def_Base.File_XLS '.xls'],['Canopy_Atmos_Class_' num2str(Class)],'C19');
Def_Base.(['Class_' num2str(Class)]).ClassName=char(y);

%% Asymptotic value of fAPAR reached for infinite LAI and used as a threshold in the LAI_fAPAR relationship												
[x,y]= xlsread([Def_Base.File_XLS '.xls'],['Canopy_Atmos_Class_' num2str(Class)],'C20');
Def_Base.(['Class_' num2str(Class)]).LAI_fAPAR_streamline=x;

%% Maximum LAI value authorized for the 'pure' vegetation component												
[x,y]= xlsread([Def_Base.File_XLS '.xls'],['Canopy_Atmos_Class_' num2str(Class)],'C21');
Def_Base.(['Class_' num2str(Class)]).LAI_Max_Local=x;

%% Method used to sample canopy parameters												
[x,y]= xlsread([Def_Base.File_XLS '.xls'],['Canopy_Atmos_Class_' num2str(Class)],'C22');
Def_Base.(['Class_' num2str(Class)]).SamplingDesign=char(y);

%% Provide the path and file name corresponding to the soil reflectance spectra used												
[x,y]= xlsread([Def_Base.File_XLS '.xls'],['Canopy_Atmos_Class_' num2str(Class)],'C23');
Def_Base.(['Class_' num2str(Class)]).R_Soil.File=char(y);
load(Def_Base.(['Class_' num2str(Class)]).R_Soil.File);
Def_Base.(['Class_' num2str(Class)]).R_Soil.Lambda = R_Soil.Lambda;
Def_Base.(['Class_' num2str(Class)]).R_Soil.Refl = R_Soil.Refl;

%% Provide the path and file name corresponding to reflectance spectra for streamlining the learning data base  through reflectance mismatch
[x,y]= xlsread([Def_Base.File_XLS '.xls'],['Canopy_Atmos_Class_' num2str(Class)],'C24');
Def_Base.(['Class_' num2str(Class)]).File_Mismatch=char(y);
if ( isempty(Def_Base.(['Class_' num2str(Class)]).File_Mismatch) )
    Def_Base.(['Class_' num2str(Class)]).Mismatch_Filtering='N';
else
    Def_Base.(['Class_' num2str(Class)]).Mismatch_Filtering='Y';
    load(Def_Base.(['Class_' num2str(Class)]).File_Mismatch);
end

%% Define parent class from whcih simulations can be used											
[x,y]= xlsread([Def_Base.File_XLS '.xls'],['Canopy_Atmos_Class_' num2str(Class)],'C25');
Def_Base.(['Class_' num2str(Class)]).ParentClassNumber=x;


%% Select 'yes' if filtering the data base using the reflectance mismatch file
[x,y]= xlsread([Def_Base.File_XLS '.xls'],['Canopy_Atmos_Class_' num2str(Class)],'C15');
Def_Base.(['Class_' num2str(Class)]).Mismatch_Filtering=char(y);


%% Les autres variables
%if strcmpi('TOC',Def_Base.Toc_Toa)
 %   [x,y]= xlsread([Def_Base.File_XLS '.xls'],['Canopy_Atmos_Class_' num2str(Class)],'C2:O12');
%else
    [x,y]= xlsread([Def_Base.File_XLS '.xls'],['Canopy_Atmos_Class_' num2str(Class)],'C2:O16');
%end
for ivar=1:size(x,1)
    for i_Champ=1:size(Champ,2)
        Def_Base.(['Class_' num2str(Class)]).Var_in.(Var{ivar}).(Champ{i_Champ})= x(ivar,i_Champ);
    end
    %Def_Base.Var_in.(['Class_' num2str(Class)]).(Var{ivar}).Distribution=char(y(ivar,6));
    Def_Base.(['Class_' num2str(Class)]).Var_in.(Var{ivar}).Distribution=char(y(ivar,1));
    % lecture des contraintes sur l'évolution de la variable en fonction du
    % LAI
    Def_Base.(['Class_' num2str(Class)]).Var_in.(Var{ivar}).LAI_Conv=x(ivar,7);
    Def_Base.(['Class_' num2str(Class)]).Var_in.(Var{ivar}).min=[x(ivar,8) x(ivar,10)];
    Def_Base.(['Class_' num2str(Class)]).Var_in.(Var{ivar}).max=[x(ivar,9) x(ivar,11)];
end    
return
