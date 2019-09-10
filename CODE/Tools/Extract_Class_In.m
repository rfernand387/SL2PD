%Extract_Class_In
%% Extraction des réflectances par classe de végétation
% Fred 17/10/2007

%%initialisation
clear Base_Mes;
load('D:\Home\DATA\NNT_new\DATA\Data_Valid\BELMANIP_MedStd_CYC_MOD_MajLANDCOVER_2001_2003.mat'); % Chargement des données avec réflectance et angles
Nb_Site=length(BELMANIP); % Nombre de sites
load('D:\Home\DATA\NNT_new\DATA\Data_Valid\LANDCOVER.mat'); % chargement du Land_Cover
Base_Mes.Angles=[];
Base_Mes.Rho_Toc=[];
Base_Mes.Class.MODIS=[];
Base_Mes.Class.ECO=[];
Base_Mes.Doy=[];
Base_Mes.Site=[];

h = waitbar(0,'Please wait...');
for isite=1:Nb_Site % boucle sur les sites
    waitbar(isite/Nb_Site,h)
    for idate=1:length(BELMANIP(isite).Doy)
        if prod(double(~isnan(cell2mat(BELMANIP(isite).x33.CYC_Rho.Median(idate))))) % si il y a des données valides
            Base_Mes.Rho_Toc=cat(1,Base_Mes.Rho_Toc,[NaN cell2mat(BELMANIP(isite).x33.CYC_Rho.Median(idate))]);
            Base_Mes.Angles=cat(1,Base_Mes.Angles,BELMANIP(isite).x33.Angles(idate));
            Base_Mes.Doy=cat(1,Base_Mes.Doy,BELMANIP(isite).Doy(idate));
            Base_Mes.Site=cat(1,Base_Mes.Site,isite);
            I=find(Land_Cover.Modis.Doy{isite}==BELMANIP(isite).Doy(idate));
            Base_Mes.Class.ECO=cat(1,Base_Mes.Class.ECO,Land_Cover.Ecoclimap.Class(isite));
            if ~isempty(I) & ~isnan(Land_Cover.Modis.Class{isite}(I))
                Base_Mes.Class.MODIS=cat(1,Base_Mes.Class.MODIS,Land_Cover.Modis.Class{isite}(I));
            else
                Base_Mes.Class.MODIS=cat(1,Base_Mes.Class.MODIS,median(Land_Cover.Modis.Class{isite}));
            end
        end
    end
end % fin boucle i_site
close(h)
save('D:\Home\DATA\NNT_new\DATA\Mismatch\CYCL_3x3_BELMANIP_2001_2003_Aleix','Base_Mes')

