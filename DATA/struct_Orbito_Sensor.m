% Création structure Orbito des satellites
% Fred & Kathy, 07/09/2005, Marie Novembre 2006
% MERIS
Orbit.MERIS.Altitude    = 799.790;
Orbit.MERIS.Inclinaison = 98.549*pi/180;
Orbit.MERIS.Period      = 35*1440/501;
Orbit.MERIS.Beta_0      = 0;
Orbit.MERIS.Beta_Alpha  = 35/501;
Orbit.MERIS.Scan        = 68.5/2*pi/180;
Orbit.MERIS.Heure       = 10.0;
Orbit.MERIS.Duree       = 35;


%VEGETATION
Orbit.VGT.Altitude      = 832;
Orbit.VGT.Inclinaison   = 98.7*pi/180;
Orbit.VGT.Period        = 26*1440/369;
Orbit.VGT.Beta_0        = 0;
Orbit.VGT.Beta_Alpha    = 26/369;
Orbit.VGT.Scan          = 50.5*pi/180;
Orbit.VGT.Heure         = 10.5;
Orbit.VGT.Duree         = 26;

%MODIS TERRA
Orbit.MODIS.Altitude      = 705;
Orbit.MODIS.Inclinaison   = 98.2*pi/180;
Orbit.MODIS.Period        = 16*1440/233;%98.8
Orbit.MODIS.Beta_0        = 0;
Orbit.MODIS.Beta_Alpha    = 16/233;
Orbit.MODIS.Scan          = 55*pi/180;
Orbit.MODIS.Heure         = 10.5;
Orbit.MODIS.Duree         = 16;


%NOAA 07
Orbit.NOAA07.Altitude      = 833;
Orbit.NOAA07.Inclinaison   = 98.5176*pi/180;
Orbit.NOAA07.Period        = 101.6436;
Orbit.NOAA07.Beta_0        = 0;
Orbit.NOAA07.Beta_Alpha    = 1/14.1671;
Orbit.NOAA07.Scan          = 55.4*pi/180;
Orbit.NOAA07.Heure         = 14.5;
Orbit.NOAA07.Duree         = 18;

%NOAA 09
Orbit.NOAA09.Altitude      = 852 ;
Orbit.NOAA09.Inclinaison   = 98.4795*pi/180;
Orbit.NOAA09.Period        = 101.7489;
Orbit.NOAA09.Beta_0        = 0;
Orbit.NOAA09.Beta_Alpha    = 1/14.1525;
Orbit.NOAA09.Scan          = 55.4*pi/180;
Orbit.NOAA09.Heure         = 14.5;
Orbit.NOAA09.Duree         = 26;

%NOAA 11
Orbit.NOAA11.Altitude      = 851;
Orbit.NOAA11.Inclinaison   = 98.8226*pi/180;
Orbit.NOAA11.Period        = 101.7793;
Orbit.NOAA11.Beta_0        = 0;
Orbit.NOAA11.Beta_Alpha    = 1/14.1483;
Orbit.NOAA11.Scan          = 55.4*pi/180;
Orbit.NOAA11.Heure         = 14.5;
Orbit.NOAA11.Duree         = 27;

%NOAA 14
Orbit.NOAA14.Altitude      = 853;
Orbit.NOAA14.Inclinaison   = 99.0188*pi/180;
Orbit.NOAA14.Period        = 201.8619;
Orbit.NOAA14.Beta_0        = 0;
Orbit.NOAA14.Beta_Alpha    = 1/14.1368;
Orbit.NOAA14.Scan          = 55.4*pi/180;
Orbit.NOAA14.Heure         = 14.5;
Orbit.NOAA14.Duree         = 22;

%NOAA 16 valeur apogee sur iste web http://www.n2yo.com/list.php?c=4
Orbit.NOAA16.Altitude      = 859;
Orbit.NOAA16.Inclinaison   = 99.0901*pi/180;
Orbit.NOAA16.Period        = 101.9551;
Orbit.NOAA16.Beta_0        = 0;
Orbit.NOAA16.Beta_Alpha    = 1/14.1239;
Orbit.NOAA16.Scan          = 55.4*pi/180;
Orbit.NOAA16.Heure         = 10.5;%13.91;
Orbit.NOAA16.Duree         = 16;


%NOAA 18
Orbit.NOAA18.Altitude      = 866;
Orbit.NOAA18.Inclinaison   = 98.8067*pi/180;
Orbit.NOAA18.Period        = 102.0545;
Orbit.NOAA18.Beta_0        = 0;
Orbit.NOAA18.Beta_Alpha    = 1/14.1101;
Orbit.NOAA18.Scan          = 55.4*pi/180;
Orbit.NOAA18.Heure         = 13.6667;
Orbit.NOAA18.Duree         = 18;

% SENTINEL2
Orbit.SENTINEL2.Altitude    = 799.790;
Orbit.SENTINEL2.Inclinaison = 98.549*pi/180;
Orbit.SENTINEL2.Period      = 35*1440/501;
Orbit.SENTINEL2.Beta_0      = 0;
Orbit.SENTINEL2.Beta_Alpha  = 35/501;
Orbit.SENTINEL2.Scan        = 15*pi/180;
Orbit.SENTINEL2.Heure       = 10.0;
Orbit.SENTINEL2.Duree       = 35;

% SPOT5HRG1
Orbit.SPOT5HRG1.Altitude      = 832;
Orbit.SPOT5HRG1.Inclinaison   = 98.7*pi/180;
Orbit.SPOT5HRG1.Period        = 26*1440/369;
Orbit.SPOT5HRG1.Beta_0        = 0;
Orbit.SPOT5HRG1.Beta_Alpha    = 26/369;
Orbit.SPOT5HRG1.Scan          = 30*pi/180;
Orbit.SPOT5HRG1.Heure         = 10.5;
Orbit.SPOT5HRG1.Duree         = 26;

% Other sensors
Orbit.LANDSAT7 = Orbit.SENTINEL2;
Orbit.RE = Orbit.SENTINEL2;
Orbit.WV3 = Orbit.SENTINEL2;
Orbit.PL1= Orbit.SENTINEL2;
Orbit.PL2= Orbit.SENTINEL2;
Orbit.INFOAG = Orbit.SENTINEL2;
Orbit.CU =  Orbit.SENTINEL2;
Orbit.UC = Orbit.SENTINEL2;
Orbit.CALMIT = Orbit.SENTINEL2;
Orbit.VNIR = Orbit.SENTINEL2;