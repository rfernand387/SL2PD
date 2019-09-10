%% Transform Land_Cover
% Création d'un fichier 'Land_Cover'
% Fred Aout 2007

%% Initialisation
clear Land_Cover
load('LAI_BELMANIP')
load('..\DATA\Data_Valid\LANDCOVER') % Le fichier d'Aleix (MODIS)
load('..\DATA\Data_Valid\ECO') % le fichier ECOCLIMAP
Info_Name=fieldnames(LAI_BELMANIP(1))

%% Le nom des classes
Land_Cover.Modis.Class_Name={'Shrubs';'Savanna';'Grasses & cereal crops';'Broadleaf crops';'Needleleaf Forest';'Broadleaf Forest'};
Land_Cover.Ecoclimap.Class_Name={'Water Bodies';'Bare Soil';'Grassland';'Crops';'Decid. Broad. For.';'Needle Leaf For.';'Everg. Broad. For.'};

%% Ordre des classes
Ordre_Class_Modis=  [3 1 4 2 6 5]
Ordre_Class_Ecoclimap=[2 1 5 6 7 4 3];

%% Les symboles des classes
Land_Cover.Modis.Class_Symbol='sagcnb';
Land_Cover.Ecoclimap.Class_Symbol='wsgcdne';

%% Remplissage des données
for isite=1:length(ECO) % boucle sur les sites
    Land_Cover.Ecoclimap.Class(isite)=Ordre_Class_Ecoclimap(ECO(isite).Class);
    Land_Cover.Ecoclimap.Doy(isite)={NaN};
    x=zeros(length({LANDCOVER(isite).x33.LAI}),1)
    if ~isempty(LANDCOVER(isite).x33.LAI.Mean)
        for idate=1:length(LANDCOVER(isite).x33.LAI.Mean)
            x(idate,1)=Ordre_Class_Modis(LANDCOVER(isite).x33.LAI.Mean(idate));
        end
        Land_Cover.Modis.Class(isite)={x};
    else
        Land_Cover.Modis.Class(isite)={[]};
    end
    Land_Cover.Modis.Doy(isite)={LANDCOVER(isite).Doy};
    
%% Remplissage des autres infos
    for iinfo=[2 3];
        eval(['Land_Cover.Info(isite).' Info_Name{iinfo} '=LAI_BELMANIP(isite).' Info_Name{iinfo}]);
    end
end
save Land_Cover Land_Cover