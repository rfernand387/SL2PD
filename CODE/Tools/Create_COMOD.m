%% Create_COMOD
% Creation d'une nouvelle classification (COMOD) pour BELMANIP basée sur ECOCLIMAP et MODIS

%% Initialisations
load('D:\Home\DATA\NNT_new\DATA\Data_Valid\Land_Cover');
% matrice de correspondance entre New_Class et MODIS (en colonne) et ECOCLIMAP (en ligne)
Correspondance=[1	1	1	2	3	4	5
                1	1	1	2	3	4	5
                2	2	2	2	3	4	5
                2	2	2	2	3	4	5
                5	5	2	2	3	4	5
                4	3	2	2	3	4	5];

%% Ecriture des nouvelles classes pour tous les sites
for i=1:length(Land_Cover.Info)
    if ~isempty(Land_Cover.Modis.Class{i})
        Land_Cover.COMOD.Class(i)=Correspondance(mode(Land_Cover.Modis.Class{i}),Land_Cover.Ecoclimap.Class(i));
    else
        Land_Cover.COMOD.Class(i)=Correspondance(1,Land_Cover.Ecoclimap.Class(i));
    end
end
%% on complete par les autres informations
Land_Cover.COMOD.Class_Name={'Shrubs & Savana'
    'Grasses & Crops'
    'Deciduous Broadleaf Forest'
    'Evergreen Broadleaf Forest'
    'Needle Leaf Foest'};
Land_Cover.COMOD.Class_Symbol='sgden';
Land_Cover.COMOD.Doy=Land_Cover.Ecoclimap.Doy;

%% Sauvergarde de la nouvelle classif
save 'D:\Home\DATA\NNT_new\DATA\Data_Valid\Land_Cover' Land_Cover 

%% Ajout de COMOD à la base mismatch
load('D:\Home\DATA\NNT_new\DATA\Mismatch\CYCL_3x3_BELMANIP_2001_2003_Aleix')
MODIS=Base_Mes.Class.MODIS;
I=find(isnan(MODIS)); % on cherche les indices des NaN
MODIS(I)=ones(size(I)); % on remplace par des '1'
% on calcule les classes COMOD
Base_Mes.Class.COMOD=zeros(length(MODIS),1);
for i=1:length(MODIS)
Base_Mes.Class.COMOD(i,1)=Correspondance(round(MODIS(i)),Base_Mes.Class.ECO(i));
end
for i=I
Base_Mes.Class.COMOD(i,1)=Correspondance(1,Base_Mes.Class.ECO(i)); % On remlace les NaN par les classes ECO qui vont bien
end
save 'D:\Home\DATA\NNT_new\DATA\Mismatch\CYCL_3x3_BELMANIP_2001_2003_Aleix' Base_Mes