%% Correction radiometrique des données VEGETATION en fonction de MODIS
% Fred Avril 2008

%% initialisation (Cyc=slope*Mod+offset)
slope=[0.935; 0.926;0.961];% slope
offset=[0.007; 0.012; 0.005];% offset

%% Correction du fichier mismatch
% chargement de mismatch
load('D:\Home\DATA\NNT_New\Data\Mismatch\BELMANIP_CYCL_VGT_V3_L3A1_Sinus_2000_2003_31Juil2007.mat') % Fichier mismatch
Band_Name={'b002_670';'b003_810';'b004_1640'};
for isite=1:length(Data)
    for iband=1:length(Band_Name)
        Data(isite).x33.Rho.(Band_Name{iband})=(Data(isite).x33.Rho.(Band_Name{iband})-offset(iband))./slope(iband);
    end
end
save('D:\Home\DATA\NNT_New\Data\Mismatch\BELMANIP_CYCL_VGT_V3_L3A1_Sinus_2000_2003_31Juil2007_RAD_COR.mat','Data');

%% correction du fichier Valid
load('D:\Home\DATA\NNT_New\Data\Mismatch\CYCL_3x3_BELMANIP_2001_2003_Aleix.mat')
for iband=1:length(Band_Name)
    Base_Mes.Rho_Toc(:,iband)=(Base_Mes.Rho_Toc(:,iband)-offset(iband))./slope(iband);
end
save('D:\Home\DATA\NNT_New\Data\Mismatch\CYCL_3x3_BELMANIP_2001_2003_Aleix_RAD_CORR.mat','Base_Mes')
