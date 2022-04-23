Filtres_Smac.LANDSAT = [];
Filtres_Smac.LANDSAT5 = [];
Filtres_Smac.LANDSAT7 = [];
Filtres_Smac.LANDSAT8 = [];
Filtres_Smac.SENTINEL2 = [];
Filtres_Smac.WV3 = [];

% LANDSAT 5 
srfFile = 'F:\camryn\SL2PD-master\DATA\spectral-response-functions\L5_TM_RSR.xlsx';
Filtres_Smac.LANDSAT5.B1 = Landsat5srf(srfFile, 'Spectral Response (LANDSAT 5)', 'B1')
Filtres_Smac.LANDSAT5.B2 = Landsat5srf(srfFile, 'Spectral Response (LANDSAT 5)', 'B2')
Filtres_Smac.LANDSAT5.B3 = Landsat5srf(srfFile, 'Spectral Response (LANDSAT 5)', 'B3')
Filtres_Smac.LANDSAT5.B4 = Landsat5srf(srfFile, 'Spectral Response (LANDSAT 5)', 'B4')
Filtres_Smac.LANDSAT5.B5 = Landsat5srf(srfFile, 'Spectral Response (LANDSAT 5)', 'B5')
Filtres_Smac.LANDSAT5.B7 = Landsat5srf(srfFile, 'Spectral Response (LANDSAT 5)', 'B7')

Filtres_Smac.LANDSAT5.B1.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT5_b1_CONT.dat');
Filtres_Smac.LANDSAT5.B2.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT5_b2_CONT.dat');
Filtres_Smac.LANDSAT5.B3.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT5_b3_CONT.dat');
Filtres_Smac.LANDSAT5.B4.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT5_b4_CONT.dat');
Filtres_Smac.LANDSAT5.B5.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT5_b5_CONT.dat');
Filtres_Smac.LANDSAT5.B7.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT5_b7_CONT.dat');

% LANDSAT 7
srfFile = 'F:\camryn\SL2PD-master\DATA\spectral-response-functions\L7_ETM_RSR.xlsx';
Filtres_Smac.LANDSAT7.B1 = Landsat7srf(srfFile, 'Spectral Response (LANDSAT 7)', 'B1')
Filtres_Smac.LANDSAT7.B2 = Landsat7srf(srfFile, 'Spectral Response (LANDSAT 7)', 'B2')
Filtres_Smac.LANDSAT7.B3 = Landsat7srf(srfFile, 'Spectral Response (LANDSAT 7)', 'B3')
Filtres_Smac.LANDSAT7.B4 = Landsat7srf(srfFile, 'Spectral Response (LANDSAT 7)', 'B4')
Filtres_Smac.LANDSAT7.B5 = Landsat7srf(srfFile, 'Spectral Response (LANDSAT 7)', 'B5')
Filtres_Smac.LANDSAT7.B7 = Landsat7srf(srfFile, 'Spectral Response (LANDSAT 7)', 'B7')


Filtres_Smac.LANDSAT7.B1.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT7_b1_CONT.dat');
Filtres_Smac.LANDSAT7.B2.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT7_b2_CONT.dat');
Filtres_Smac.LANDSAT7.B3.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT7_b3_CONT.dat');
Filtres_Smac.LANDSAT7.B4.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT7_b4_CONT.dat');
Filtres_Smac.LANDSAT7.B5.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT7_b5_CONT.dat');
Filtres_Smac.LANDSAT7.B7.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT7_b7_CONT.dat');

% LANDSAT 8
srfFile = 'F:\camryn\SL2PD-master\DATA\spectral-response-functions\Ball_BA_RSR_OLI.xlsx';
Filtres_Smac.LANDSAT8.B1 = Landsat8srf(srfFile, 'Spectral Response (LANDSAT 8)', 'B1')
Filtres_Smac.LANDSAT8.B2 = Landsat8srf(srfFile, 'Spectral Response (LANDSAT 8)', 'B2')
Filtres_Smac.LANDSAT8.B3 = Landsat8srf(srfFile, 'Spectral Response (LANDSAT 8)', 'B3')
Filtres_Smac.LANDSAT8.B4 = Landsat8srf(srfFile, 'Spectral Response (LANDSAT 8)', 'B4')
Filtres_Smac.LANDSAT8.B5 = Landsat8srf(srfFile, 'Spectral Response (LANDSAT 8)', 'B5')
Filtres_Smac.LANDSAT8.B6 = Landsat8srf(srfFile, 'Spectral Response (LANDSAT 8)', 'B6')
Filtres_Smac.LANDSAT8.B7 = Landsat8srf(srfFile, 'Spectral Response (LANDSAT 8)', 'B7')
Filtres_Smac.LANDSAT8.B8 = Landsat8srf(srfFile, 'Spectral Response (LANDSAT 8)', 'B8')

Filtres_Smac.LANDSAT8.B1.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT8_440_1.dat');
Filtres_Smac.LANDSAT8.B2.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT8_490_1.dat');
Filtres_Smac.LANDSAT8.B3.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT8_560_1.dat');
Filtres_Smac.LANDSAT8.B4.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT8_660_1.dat');
Filtres_Smac.LANDSAT8.B5.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT8_860_1.dat');
Filtres_Smac.LANDSAT8.B6.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT8_1630_1.dat');
Filtres_Smac.LANDSAT8.B7.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT8_2250_1.dat');
Filtres_Smac.LANDSAT8.B8.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_LANDSAT8_PAN_1.dat');

% Sentinel 2a
srfFile = 'F:\camryn\SL2PD-master\DATA\spectral-response-functions\Ball_BA_RSR.v1.2.xlsx';
Filtres_Smac.SENTINEL2.B1 = Sentinel2Asrf(srfFile, 'Spectral Responses (S2A)', 'B1')
Filtres_Smac.SENTINEL2.B2 = Sentinel2Asrf(srfFile, 'Spectral Responses (S2A)', 'B2')
Filtres_Smac.SENTINEL2.B3 = Sentinel2Asrf(srfFile, 'Spectral Responses (S2A)', 'B3')
Filtres_Smac.SENTINEL2.B4 = Sentinel2Asrf(srfFile, 'Spectral Responses (S2A)', 'B4')
Filtres_Smac.SENTINEL2.B5 = Sentinel2Asrf(srfFile, 'Spectral Responses (S2A)', 'B5')
Filtres_Smac.SENTINEL2.B6 = Sentinel2Asrf(srfFile, 'Spectral Responses (S2A)', 'B6')
Filtres_Smac.SENTINEL2.B7 = Sentinel2Asrf(srfFile, 'Spectral Responses (S2A)', 'B7')
Filtres_Smac.SENTINEL2.B8 = Sentinel2Asrf(srfFile, 'Spectral Responses (S2A)', 'B8')
Filtres_Smac.SENTINEL2.B8A = Sentinel2Asrf(srfFile, 'Spectral Responses (S2A)', 'B8A')
Filtres_Smac.SENTINEL2.B9 = Sentinel2Asrf(srfFile, 'Spectral Responses (S2A)', 'B9')
Filtres_Smac.SENTINEL2.B10 = Sentinel2Asrf(srfFile, 'Spectral Responses (S2A)', 'B10')
Filtres_Smac.SENTINEL2.B11 = Sentinel2Asrf(srfFile, 'Spectral Responses (S2A)', 'B11')
Filtres_Smac.SENTINEL2.B12 = Sentinel2Asrf(srfFile, 'Spectral Responses (S2A)', 'B12')

Filtres_Smac.SENTINEL2.B1.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_S2A_CONT_B1.dat');
Filtres_Smac.SENTINEL2.B2.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_S2A_CONT_B2.dat');
Filtres_Smac.SENTINEL2.B3.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_S2A_CONT_B3.dat');
Filtres_Smac.SENTINEL2.B4.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_S2A_CONT_B4.dat');
Filtres_Smac.SENTINEL2.B5.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_S2A_CONT_B5.dat');
Filtres_Smac.SENTINEL2.B6.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_S2A_CONT_B6.dat');
Filtres_Smac.SENTINEL2.B7.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_S2A_CONT_B7.dat');
Filtres_Smac.SENTINEL2.B8.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_S2A_CONT_B8.dat');
Filtres_Smac.SENTINEL2.B8A.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_S2A_CONT_B8a.dat');
Filtres_Smac.SENTINEL2.B9.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_S2A_CONT_B9.dat');
Filtres_Smac.SENTINEL2.B10.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_S2A_CONT_B10.dat');
Filtres_Smac.SENTINEL2.B11.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_S2A_CONT_B11.dat');
Filtres_Smac.SENTINEL2.B12.smac.cont = coefSMAC('F:\camryn\SL2PD-master\DATA\smac\smac-python.git\COEFS\Coef_S2A_CONT_B12.dat');
