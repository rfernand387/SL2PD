
Filtres_Smac.WV3.B1.lambda = spectralinfoVNIRWV1.Wavelengthum * 1000;
Filtres_Smac.WV3.B1.sensi = spectralinfoVNIRWV1.Blue(Filtres_Smac.WV3.B1.lambda>0);
Filtres_Smac.WV3.B1.lambda = Filtres_Smac.WV3.B1.lambda(Filtres_Smac.WV3.B1.lambda>0);
Filtres_Smac.WV3.B1.begin = Filtres_Smac.WV3.B1.lambda(find(Filtres_Smac.WV3.B1.sensi>0.1,1,'first'));
Filtres_Smac.WV3.B1.mode = Filtres_Smac.WV3.B1.lambda(find(Filtres_Smac.WV3.B1.sensi>max(Filtres_Smac.WV3.B1.sensi),1,'first'));
Filtres_Smac.WV3.B1.end = Filtres_Smac.WV3.B1.lambda(find(Filtres_Smac.WV3.B1.sensi>0.1,1,'last'));

Filtres_Smac.WV3.B2.lambda = spectralinfoVNIRWV1.Wavelengthum * 1000;
Filtres_Smac.WV3.B2.sensi = spectralinfoVNIRWV1.Green(Filtres_Smac.WV3.B2.lambda>0);
Filtres_Smac.WV3.B2.lambda = Filtres_Smac.WV3.B2.lambda(Filtres_Smac.WV3.B2.lambda>0);
Filtres_Smac.WV3.B2.begin = Filtres_Smac.WV3.B2.lambda(find(Filtres_Smac.WV3.B2.sensi>0.1,1,'first'));
Filtres_Smac.WV3.B2.mode = Filtres_Smac.WV3.B2.lambda(find(Filtres_Smac.WV3.B2.sensi>max(Filtres_Smac.WV3.B2.sensi),1,'first'));
Filtres_Smac.WV3.B2.end = Filtres_Smac.WV3.B2.lambda(find(Filtres_Smac.WV3.B2.sensi>0.1,1,'last'));

Filtres_Smac.WV3.B3.lambda = spectralinfoVNIRWV1.Wavelengthum * 1000;
Filtres_Smac.WV3.B3.sensi = spectralinfoVNIRWV1.Yellow(Filtres_Smac.WV3.B3.lambda>0);
Filtres_Smac.WV3.B3.lambda = Filtres_Smac.WV3.B3.lambda(Filtres_Smac.WV3.B3.lambda>0);
Filtres_Smac.WV3.B3.begin = Filtres_Smac.WV3.B3.lambda(find(Filtres_Smac.WV3.B3.sensi>0.1,1,'first'));
Filtres_Smac.WV3.B3.mode = Filtres_Smac.WV3.B3.lambda(find(Filtres_Smac.WV3.B3.sensi>max(Filtres_Smac.WV3.B3.sensi),1,'first'));
Filtres_Smac.WV3.B3.end = Filtres_Smac.WV3.B3.lambda(find(Filtres_Smac.WV3.B3.sensi>0.1,1,'last'));

Filtres_Smac.WV3.B4.lambda = spectralinfoVNIRWV1.Wavelengthum * 1000;
Filtres_Smac.WV3.B4.sensi = spectralinfoVNIRWV1.Red(Filtres_Smac.WV3.B4.lambda>0);
Filtres_Smac.WV3.B4.lambda = Filtres_Smac.WV3.B4.lambda(Filtres_Smac.WV3.B4.lambda>0);
Filtres_Smac.WV3.B4.begin = Filtres_Smac.WV3.B4.lambda(find(Filtres_Smac.WV3.B4.sensi>0.1,1,'first'));
Filtres_Smac.WV3.B4.mode = Filtres_Smac.WV3.B4.lambda(find(Filtres_Smac.WV3.B4.sensi>max(Filtres_Smac.WV3.B4.sensi),1,'first'));
Filtres_Smac.WV3.B4.end = Filtres_Smac.WV3.B4.lambda(find(Filtres_Smac.WV3.B4.sensi>0.1,1,'last'));

Filtres_Smac.WV3.B5.lambda = spectralinfoVNIRWV1.Wavelengthum * 1000;
Filtres_Smac.WV3.B5.sensi = spectralinfoVNIRWV1.RedEdge(Filtres_Smac.WV3.B5.lambda>0);
Filtres_Smac.WV3.B5.lambda = Filtres_Smac.WV3.B5.lambda(Filtres_Smac.WV3.B5.lambda>0);
Filtres_Smac.WV3.B5.begin = Filtres_Smac.WV3.B5.lambda(find(Filtres_Smac.WV3.B5.sensi>0.1,1,'first'));
Filtres_Smac.WV3.B5.mode = Filtres_Smac.WV3.B5.lambda(find(Filtres_Smac.WV3.B5.sensi>max(Filtres_Smac.WV3.B5.sensi),1,'first'));
Filtres_Smac.WV3.B5.end = Filtres_Smac.WV3.B5.lambda(find(Filtres_Smac.WV3.B5.sensi>0.1,1,'last'));

Filtres_Smac.WV3.B6.lambda = spectralinfoVNIRWV1.Wavelengthum * 1000;
Filtres_Smac.WV3.B6.sensi = spectralinfoVNIRWV1.NIR1(Filtres_Smac.WV3.B6.lambda>0);
Filtres_Smac.WV3.B6.lambda = Filtres_Smac.WV3.B6.lambda(Filtres_Smac.WV3.B6.lambda>0);
Filtres_Smac.WV3.B6.begin = Filtres_Smac.WV3.B6.lambda(find(Filtres_Smac.WV3.B6.sensi>0.1,1,'first'));
Filtres_Smac.WV3.B6.mode = Filtres_Smac.WV3.B6.lambda(find(Filtres_Smac.WV3.B6.sensi>max(Filtres_Smac.WV3.B6.sensi),1,'first'));
Filtres_Smac.WV3.B6.end = Filtres_Smac.WV3.B6.lambda(find(Filtres_Smac.WV3.B6.sensi>0.1,1,'last'));

Filtres_Smac.WV3.B7.lambda = spectralinfoVNIRWV1.Wavelengthum * 1000;
Filtres_Smac.WV3.B7.sensi = spectralinfoVNIRWV1.NIR2(Filtres_Smac.WV3.B7.lambda>0);
Filtres_Smac.WV3.B7.lambda = Filtres_Smac.WV3.B7.lambda(Filtres_Smac.WV3.B7.lambda>0);
Filtres_Smac.WV3.B7.begin = Filtres_Smac.WV3.B7.lambda(find(Filtres_Smac.WV3.B7.sensi>0.1,1,'first'));
Filtres_Smac.WV3.B7.mode = Filtres_Smac.WV3.B7.lambda(find(Filtres_Smac.WV3.B7.sensi>max(Filtres_Smac.WV3.B7.sensi),1,'first'));
Filtres_Smac.WV3.B7.end = Filtres_Smac.WV3.B7.lambda(find(Filtres_Smac.WV3.B7.sensi>0.1,1,'last'));


Filtres_Smac.WV3.B8.lambda = spectralinfoSWIRWV03.Wavelengthum * 1000;
Filtres_Smac.WV3.B8.sensi = spectralinfoSWIRWV03.SWIR1(Filtres_Smac.WV3.B8.lambda>0);
Filtres_Smac.WV3.B8.lambda  = Filtres_Smac.WV3.B8.lambda(Filtres_Smac.WV3.B8.lambda >0);
Filtres_Smac.WV3.B8.begin = Filtres_Smac.WV3.B8.lambda(find(Filtres_Smac.WV3.B8.sensi>0.1,1,'first'));
Filtres_Smac.WV3.B8.mode = Filtres_Smac.WV3.B8.lambda(find(Filtres_Smac.WV3.B8.sensi>max(Filtres_Smac.WV3.B8.sensi),1,'first'));
Filtres_Smac.WV3.B8.end = Filtres_Smac.WV3.B8.lambda(find(Filtres_Smac.WV3.B8.sensi>0.1,1,'last'));

Filtres_Smac.WV3.B9.lambda = spectralinfoSWIRWV03.Wavelengthum * 1000;
Filtres_Smac.WV3.B9.sensi = spectralinfoSWIRWV03.SWIR2(Filtres_Smac.WV3.B9.lambda>0);
Filtres_Smac.WV3.B9.lambda  = Filtres_Smac.WV3.B9.lambda(Filtres_Smac.WV3.B9.lambda >0);
Filtres_Smac.WV3.B9.begin = Filtres_Smac.WV3.B9.lambda(find(Filtres_Smac.WV3.B9.sensi>0.1,1,'first'));
Filtres_Smac.WV3.B9.mode = Filtres_Smac.WV3.B9.lambda(find(Filtres_Smac.WV3.B9.sensi>max(Filtres_Smac.WV3.B9.sensi),1,'first'));
Filtres_Smac.WV3.B9.end = Filtres_Smac.WV3.B9.lambda(find(Filtres_Smac.WV3.B9.sensi>0.1,1,'last'));

Filtres_Smac.WV3.B10.lambda = spectralinfoSWIRWV03.Wavelengthum * 1000;
Filtres_Smac.WV3.B10.sensi = spectralinfoSWIRWV03.SWIR3(Filtres_Smac.WV3.B10.lambda>0);
Filtres_Smac.WV3.B10.lambda  = Filtres_Smac.WV3.B10.lambda(Filtres_Smac.WV3.B10.lambda >0);
Filtres_Smac.WV3.B10.begin = Filtres_Smac.WV3.B10.lambda(find(Filtres_Smac.WV3.B10.sensi>0.1,1,'first'));
Filtres_Smac.WV3.B10.mode = Filtres_Smac.WV3.B10.lambda(find(Filtres_Smac.WV3.B10.sensi>max(Filtres_Smac.WV3.B10.sensi),1,'first'));
Filtres_Smac.WV3.B10.end = Filtres_Smac.WV3.B10.lambda(find(Filtres_Smac.WV3.B10.sensi>0.1,1,'last'));

Filtres_Smac.WV3.B11.lambda = spectralinfoSWIRWV03.Wavelengthum * 1000;
Filtres_Smac.WV3.B11.sensi = spectralinfoSWIRWV03.SWIR4(Filtres_Smac.WV3.B9.lambda>0);
Filtres_Smac.WV3.B11.lambda  = Filtres_Smac.WV3.B9.lambda(Filtres_Smac.WV3.B9.lambda >0);
Filtres_Smac.WV3.B11.begin = Filtres_Smac.WV3.B11.lambda(find(Filtres_Smac.WV3.B11.sensi>0.1,1,'first'));
Filtres_Smac.WV3.B11.mode = Filtres_Smac.WV3.B11.lambda(find(Filtres_Smac.WV3.B11.sensi>max(Filtres_Smac.WV3.B11.sensi),1,'first'));
Filtres_Smac.WV3.B11.end = Filtres_Smac.WV3.B11.lambda(find(Filtres_Smac.WV3.B11.sensi>0.1,1,'last'));

Filtres_Smac.WV3.B12.lambda = spectralinfoSWIRWV03.Wavelengthum * 1000;
Filtres_Smac.WV3.B12.sensi = spectralinfoSWIRWV03.SWIR5(Filtres_Smac.WV3.B12.lambda>0);
Filtres_Smac.WV3.B12.lambda  = Filtres_Smac.WV3.B12.lambda(Filtres_Smac.WV3.B12.lambda >0);
Filtres_Smac.WV3.B12.begin = Filtres_Smac.WV3.B12.lambda(find(Filtres_Smac.WV3.B12.sensi>0.1,1,'first'));
Filtres_Smac.WV3.B12.mode = Filtres_Smac.WV3.B12.lambda(find(Filtres_Smac.WV3.B12.sensi>max(Filtres_Smac.WV3.B12.sensi),1,'first'));
Filtres_Smac.WV3.B12.end = Filtres_Smac.WV3.B12.lambda(find(Filtres_Smac.WV3.B12.sensi>0.1,1,'last'));

Filtres_Smac.WV3.B13.lambda = spectralinfoSWIRWV03.Wavelengthum * 1000;
Filtres_Smac.WV3.B13.sensi = spectralinfoSWIRWV03.SWIR6(Filtres_Smac.WV3.B13.lambda>0);
Filtres_Smac.WV3.B13.lambda  = Filtres_Smac.WV3.B13.lambda(Filtres_Smac.WV3.B13.lambda >0);
Filtres_Smac.WV3.B13.begin = Filtres_Smac.WV3.B13.lambda(find(Filtres_Smac.WV3.B13.sensi>0.1,1,'first'));
Filtres_Smac.WV3.B13.mode = Filtres_Smac.WV3.B13.lambda(find(Filtres_Smac.WV3.B13.sensi>max(Filtres_Smac.WV3.B13.sensi),1,'first'));
Filtres_Smac.WV3.B13.end = Filtres_Smac.WV3.B13.lambda(find(Filtres_Smac.WV3.B13.sensi>0.1,1,'last'));

Filtres_Smac.WV3.B14.lambda = spectralinfoSWIRWV03.Wavelengthum * 1000;
Filtres_Smac.WV3.B14.sensi = spectralinfoSWIRWV03.SWIR7(Filtres_Smac.WV3.B14.lambda>0);
Filtres_Smac.WV3.B14.lambda  = Filtres_Smac.WV3.B14.lambda(Filtres_Smac.WV3.B14.lambda >0);
Filtres_Smac.WV3.B14.begin = Filtres_Smac.WV3.B14.lambda(find(Filtres_Smac.WV3.B14.sensi>0.1,1,'first'));
Filtres_Smac.WV3.B14.mode = Filtres_Smac.WV3.B14.lambda(find(Filtres_Smac.WV3.B14.sensi>max(Filtres_Smac.WV3.B14.sensi),1,'first'));
Filtres_Smac.WV3.B14.end = Filtres_Smac.WV3.B14.lambda(find(Filtres_Smac.WV3.B14.sensi>0.1,1,'last'));

Filtres_Smac.WV3.B15.lambda = spectralinfoSWIRWV03.Wavelengthum * 1000;
Filtres_Smac.WV3.B15.sensi = spectralinfoSWIRWV03.SWIR8(Filtres_Smac.WV3.B15.lambda>0);
Filtres_Smac.WV3.B15.lambda  = Filtres_Smac.WV3.B15.lambda(Filtres_Smac.WV3.B15.lambda >0);
Filtres_Smac.WV3.B15.begin = Filtres_Smac.WV3.B15.lambda(find(Filtres_Smac.WV3.B15.sensi>0.1,1,'first'));
Filtres_Smac.WV3.B15.mode = Filtres_Smac.WV3.B15.lambda(find(Filtres_Smac.WV3.B15.sensi>max(Filtres_Smac.WV3.B15.sensi),1,'first'));
Filtres_Smac.WV3.B15.end = Filtres_Smac.WV3.B15.lambda(find(Filtres_Smac.WV3.B15.sensi>0.1,1,'last'));
