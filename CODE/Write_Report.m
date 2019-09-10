function Create_Report(Def_Base,NNT_Archi,NNT,Input,Output)
% Ecriture du rapport pour assurer la traçabilité des différents réseaux créés
% M .Weiss & Fred , Decembre 2005

fid=fopen(fullfile(Def_Base.Report_Dir,[Def_Base.Name '.htm']),'wt'); % ouverture du fichier htm

NNT_Output=fieldnames(NNT_Archi);
Nb_Band = length(Def_Base.Bandes_Utiles); % Nombre de bandes utilisées
Nb_Sims = length(Output.(NNT_Output{1})); % Nombre de simulations
Nb_Ang = length(Def_Base.Angles); % nombre d'angles
Nb_Atmo = 0;
if isfield(Input,'Atmos')
    Nb_Atmo = size(Input.Atmos,2);
end
Nb_Inputs = Nb_Band+Nb_Ang+Nb_Atmo;

Refs = ['Rho_' Def_Base.Toc_Toa];


%%% En-tête du fichier
fprintf(fid,'%s\n','<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">');
fprintf(fid,'%s\n','<html>');
fprintf(fid,'%s\n','<head>');
fprintf(fid,'%s\n',['<title>' Def_Base.Name '</title>']);
fprintf(fid,'%s\n','<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">');
fprintf(fid,'%s\n\n','</head>');
fprintf(fid,'%s\n','<body>');

%%% Titre du document
fprintf(fid,'%s\n',['<p align="center"><font face="Arial"><strong><font color="#990000" size="8">' Def_Base.Name '</font></strong></font></p>']);
fprintf(fid,'%s\n','<p align="center">&nbsp;</p>');

%%% 1. Building the learning database
fprintf(fid,'%s\n','<p align="left"><font color="#000080"><strong><font size="6" face="Arial">1.   Building the learning data base</font></strong></font> </p>');

%%% 1.1 Sensor characterization
fprintf(fid,'%s\n','<blockquote>');
fprintf(fid,'%s\n','<p align="left"><font color="#000080"><strong><font size="4" face="Arial">     1.1 Sensor characterization</font></strong></font></p>');
fprintf(fid,'%s\n','<p align="left"><font color="#000080"><font size="3" face="Arial">1.1.1     Spectral Sensitivity</font></font></p>');
fprintf(fid,'%s\n','<p align="left"><img src="Sensi_spec.png"  border="1" width="85%" ></p>');
fprintf(fid,'%s\n','<p align="left"><font color="#000080" size="3"><font face="Arial">1.1.2     Noise</font></font></p>');
fprintf(fid,'%s\n','<table width="50%" border="1" bordercolor="#006600">');
fprintf(fid,'%s\n','<tr> ');
Nom_Capteur=Def_Base.Capteur;
fprintf(fid,'%s\n',['<td colspan="3"><div align="center"><font color="#990000"><font face="Arial"> ' Nom_Capteur '</font></div></td>']);
fprintf(fid,'%s\n','</tr>');
fprintf(fid,'%s\n','<tr>');
fprintf(fid,'%s\n','<td width="40%">&nbsp;</td>');
fprintf(fid,'%s\n','<td width="30%"><div align="center"><font color="#990000"><font face="Arial">Noise Std</font></div></td>');
fprintf(fid,'%s\n','<td width="30%"><div align="center"><font color="#990000"><font face="Arial">Noise Bias</font></div></td>');
fprintf(fid,'%s\n','</tr>');
for iband = 1:Nb_Band
    fprintf(fid,'%s\n','<tr>');
    fprintf(fid,'%s\n',['<td><div align="center"><font color="#990000"><font face="Arial">' Def_Base.Bandes_Utiles{iband} '</font></td>']);
    fprintf(fid,'%s\n',['<td><div align="center"><font face="Arial"> ' num2str(Def_Base.Bruit_Bandes.Std(iband)) '</td>']);
    fprintf(fid,'%s\n',['<td><div align="center"><font face="Arial"> ' num2str(Def_Base.Bruit_Bandes.Biais(iband)) '</td>']);
    fprintf(fid,'%s\n','</tr>');
end
fprintf(fid,'%s\n','</table>');

%%% 1.2 Structure du couvert
fprintf(fid,'%s\n','<p>&nbsp;</p>');
fprintf(fid,'%s\n','<p align="left"><font color="#000080"><strong><font size="4" face="Arial">1.2     Canopy structure</font></strong></font></p>');
fprintf(fid,'%s\n','<table width="95%" border="1" bordercolor="#006600">');
fprintf(fid,'%s\n','<tr>');
fprintf(fid,'%s\n','<td width="30%"><font color="#990000">&nbsp;</font></td>');
fprintf(fid,'%s\n','<td width="10%"><font color="#990000"><font face="Arial">Min</font></td>');
fprintf(fid,'%s\n','<td width="10%"><font color="#990000"><font face="Arial">Max</font></td>');
fprintf(fid,'%s\n','<td width="10%"><font color="#990000"><font face="Arial">Mean</font></td>');
fprintf(fid,'%s\n','<td width="10%"><font color="#990000"><font face="Arial">Std</font></td>');
fprintf(fid,'%s\n','<td width="10%"><font color="#990000"><font face="Arial">NbClass</font></td>');
fprintf(fid,'%s\n','<td width="10%"><font color="#990000"><font face="Arial">Law</font></td>');
fprintf(fid,'%s\n','</tr>');
fprintf(fid,'%s\n','<tr>');
fprintf(fid,'%s\n','<td><font color="#990000"><font face="Arial">Leaf Area Index (m²/m²)</font></td>');
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.LAI.Min) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.LAI.Max) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.LAI.Mean) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.LAI.Std) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.LAI.Nb_Classe) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' Def_Base.Var.LAI.Distribution '</td>']);
fprintf(fid,'%s\n','</tr>');
fprintf(fid,'%s\n','<tr>');
fprintf(fid,'%s\n','<td><font color="#990000"><font face="Arial">Average Leaf inclination Angle (&deg;)</font></td>');
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.ALA.Min) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.ALA.Max) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.ALA.Mean) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.ALA.Std) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.ALA.Nb_Classe) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' Def_Base.Var.ALA.Distribution '</td>']);
fprintf(fid,'%s\n','</tr><font face="Arial">');
fprintf(fid,'%s\n','<tr>');
fprintf(fid,'%s\n','<td><font color="#990000">Hot Spot parameter (HotS)</font></td>');
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.HotS.Min) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.HotS.Max) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.HotS.Mean) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.HotS.Std) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.HotS.Nb_Classe) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' Def_Base.Var.HotS.Distribution '</td>']);
fprintf(fid,'%s\n','</tr>');
fprintf(fid,'%s\n','<tr>');
fprintf(fid,'%s\n','<td><font color="#990000">Mixed Pixels (vCover)</font></td>');
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.vCover.Min) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.vCover.Max) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.vCover.Mean) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.vCover.Std) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.vCover.Nb_Classe) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' Def_Base.Var.vCover.Distribution '</td>']);
fprintf(fid,'%s\n','</tr>');
fprintf(fid,'%s\n','</table>');
fprintf(fid,'%s\n','<p align="left"><font face="Arial"><img src="Law_App_Struct.png"  border="1" width="95%"></p>');

%%% 1.3 Propriétés optiques des feuilles
fprintf(fid,'%s\n','<p align="left"><font color="#000080"><strong><font size="4" face="Arial">1.3     Leaf optical properties</font></strong></font></p>');
fprintf(fid,'%s\n','<table width="95%" border="1" bordercolor="#006600">');
fprintf(fid,'%s\n','<tr> ');
fprintf(fid,'%s\n','<td width="30%"><font color="#990000"><font face="Arial">&nbsp;</font></td>');
fprintf(fid,'%s\n','<td width="10%"><font color="#990000"><font face="Arial">Min</font></td>');
fprintf(fid,'%s\n','<td width="10%"><font color="#990000"><font face="Arial">Max</font></td>');
fprintf(fid,'%s\n','<td width="10%"><font color="#990000"><font face="Arial">Mean</font></td>');
fprintf(fid,'%s\n','<td width="10%"><font color="#990000"><font face="Arial">Std</font></td>');
fprintf(fid,'%s\n','<td width="10%"><font color="#990000"><font face="Arial">NbClass</font></td>');
fprintf(fid,'%s\n','<td width="10%"><font color="#990000"><font face="Arial">Law</font></td>');
fprintf(fid,'%s\n','</tr>');
fprintf(fid,'%s\n','<tr>');
fprintf(fid,'%s\n','<td><font color="#990000"><font face="Arial">Chlorophyll Content (<font face="Symbol">m</font>g/cm²)</font></td>');
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cab.Min) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cab.Max) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cab.Mean) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cab.Std) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cab.Nb_Classe) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' Def_Base.Var.Cab.Distribution '</td>']);
fprintf(fid,'%s\n','</tr>');
fprintf(fid,'%s\n','<tr>');
fprintf(fid,'%s\n','<td><font face="Arial"><font color="#990000">Dry matter content (g/cm²)</font></td>');
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cdm.Min) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cdm.Max) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cdm.Mean) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cdm.Std) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cdm.Nb_Classe) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' Def_Base.Var.Cdm.Distribution '</td>']);
fprintf(fid,'%s\n','</tr>');
fprintf(fid,'%s\n','<tr>');
fprintf(fid,'%s\n','<td><font face="Arial"><font color="#990000">Relative water content </td>');
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cw_Rel.Min) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cw_Rel.Max) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cw_Rel.Mean) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cw_Rel.Std) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cw_Rel.Nb_Classe) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' Def_Base.Var.Cw_Rel.Distribution '</td>']);
fprintf(fid,'%s\n','</tr>');
fprintf(fid,'%s\n','<tr>');
fprintf(fid,'%s\n','<td><font face="Arial"><font color="#990000">Brown Pigment index</td>');
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cbp.Min) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cbp.Max) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cbp.Mean) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cbp.Std) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Cbp.Nb_Classe) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' Def_Base.Var.Cbp.Distribution '</td>']);
fprintf(fid,'%s\n','</tr>');
fprintf(fid,'%s\n','<tr>');
fprintf(fid,'%s\n','<td><font face="Arial"><font color="#990000">Mesophyll structure (N)</td>');
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.N.Min) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.N.Max) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.N.Mean) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.N.Std) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.N.Nb_Classe) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' Def_Base.Var.N.Distribution '</td>']);
fprintf(fid,'%s\n','</tr>');
fprintf(fid,'%s\n','<tr>');
fprintf(fid,'%s\n','</table>');
fprintf(fid,'%s\n','<p><font face="Arial"><img src="Law_App_Leaf.png"  border="1" width="95%"></p>');

%%% 1.4 Propriétés optiques du sol
fprintf(fid,'%s\n','<p align="left"><strong><font color="#000080" size="4" face="Arial">1.4 Soil optical properties</font></strong></p>');
fprintf(fid,'%s\n',['<p align="center"><font color="#006600" ><font face="Arial"> Spectra loaded from file : ' Def_Base.R_Soil.File '</font></strong></p>']);
fprintf(fid,'%s\n','  <p align="center"><img src="Soil_Spectra.png"  border="1" width="85%"> </p>');
fprintf(fid,'%s\n','<table width="95%" border="1" bordercolor="#006600">');
fprintf(fid,'%s\n','<tr> ');
fprintf(fid,'%s\n','<td width="30%"><font face="Arial"><font color="#990000">&nbsp;</font></td>');
fprintf(fid,'%s\n','<td width="10%"><font face="Arial"><font color="#990000">Min</font></td>');
fprintf(fid,'%s\n','<td width="10%"><font face="Arial"><font color="#990000">Max</font></td>');
fprintf(fid,'%s\n','<td width="10%"><font face="Arial"><font color="#990000">Mean</font></td>');
fprintf(fid,'%s\n','<td width="10%"><font face="Arial"><font color="#990000">Std</font></td>');
fprintf(fid,'%s\n','<td width="10%"><font face="Arial"><font color="#990000">NbClass</font></td>');
fprintf(fid,'%s\n','<td width="10%"><font face="Arial"><font color="#990000">Law</font></td>');
fprintf(fid,'%s\n','</tr>');
fprintf(fid,'%s\n','<tr>');
fprintf(fid,'%s\n','<td><font face="Arial"><font color="#990000">Brightness Factor</td>');
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Bs.Min) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Bs.Max) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Bs.Mean) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Bs.Std) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Bs.Nb_Classe) '</td>']);
fprintf(fid,'%s\n',['<td><font face="Arial">' Def_Base.Var.Bs.Distribution '</td>']);
fprintf(fid,'%s\n','</tr>');
fprintf(fid,'%s\n','<tr>');
fprintf(fid,'%s\n','</table>');
fprintf(fid,'%s\n','  <p align="center"><img src="Law_App_Soil.png"  border="1" width="65%"></p>');

%%% 1.5 Conditions d'observation
fprintf(fid,'%s\n','<p align="left"><strong><font color="#000080" size="4" face="Arial">1.5   Conditions of observation</font></strong></p>');
switch  Def_Base.Obs.Configur % cas ou on ne considere qu'une seule condition d'observation

    case 'Single date, Location, configuration'
        Def_Base.Obs.View_Zenith;
        Def_Base.Obs.Sun_Zenith;
        Def_Base.Obs.Sun_Azimuth
        Def_Base.Obs.View_Azimuth
        Def_Base.Obs.Day
        Def_Base.Obs.Lat
        Def_Base.Obs.Lon
        if isfield(Def_Base.Obs,'Year')
            toto = datestr(Def_Base.Obs.Day+datenum(Def_Base.Obs.Year-1,12,31));
        else
            toto = datestr(Def_Base.Obs.Day+datenum(2002,12,31));
        end
        fprintf(fid,'%s\n',['<p align="center"><font face="Arial"><font color="#006600" > Single date :  #' toto ', day of the year ' Def_Base.Obs.Day ' </font></strong></p>']);
        %% une seule location
        fprintf(fid,'%s\n',['<p align="center"><font face="Arial"><font color="#006600" > Single location : Latitude = ' num2str(Def_Base.Obs.Lat) '&deg;, Longitude = ' num2str(Def_Base.Obs.Lon) '&deg;</font></strong></p>']);
        %% Si une seule ou plusieurs configuration
        fprintf(fid,'%s\n','<table width="75%" border="1" bordercolor="#006600">');
        fprintf(fid,'%s\n','<tr> ');
        fprintf(fid,'%s\n','<td width="25%"><font color="#990000"><font face="Arial">View Zenith <font face="Symbol">q</font>v (&deg;)</font></td>');
        fprintf(fid,'%s\n','<td width="25%"><font color="#990000"><font face="Arial">View Azimuth <font face="Symbol">f</font>v (&deg;)</font></td>');
        fprintf(fid,'%s\n','<td width="25%"><font color="#990000"><font face="Arial">Sun Zenith <font face="Symbol">q</font>s (&deg;)</font></td>');
        fprintf(fid,'%s\n','<td width="25%"><font color="#990000"><font face="Arial">Sun Azimuth <font face="Symbol">f</font>s (&deg;)</font></td>');
        fprintf(fid,'%s\n','</tr>');
        fprintf(fid,'%s\n','<tr>');
        fprintf(fid,'%s\n',['<td><font face="Arial"><p align="center">' num2str(Def_Base.Obs.View_Zenith*180/pi,4) '</td>']);
        fprintf(fid,'%s\n',['<td><font face="Arial"><p align="center">' num2str(Def_Base.Obs.View_Azimuth*180/pi,4) '</td>']);
        fprintf(fid,'%s\n',['<td><font face="Arial"><p align="center">' num2str(Def_Base.Obs.Sun_Zenith*180/pi,4) '</td>']);
        fprintf(fid,'%s\n',['<td><font face="Arial"><p align="center">' num2str(Def_Base.Obs.Sun_Azimuth*180/pi,5) '</td>']);
        fprintf(fid,'%s\n','<tr>');
        fprintf(fid,'%s\n','</table>');

    case 'Single date, Location, Multiple configurations' % Cas ou on utilise des cartes d'angles de zenith et d'azimuth de visée
        %         fprintf(fid,'%s\n','<p align="left"><strong><font color="#000080" size="4" face="Arial"> Multiple dates, locations & configurations</font></strong></p>');
        %         fprintf(fid,'%s\n','<table width="75%" border="1" bordercolor="#006600">');
        %         fprintf(fid,'%s\n','<tr> ');
        %         fprintf(fid,'%s\n','<td width="10%"><font color="#990000">Min</font></td>');
        %         fprintf(fid,'%s\n','<td width="10%"><font color="#990000">Max</font></td>');
        %         fprintf(fid,'%s\n','<td width="10%"><font color="#990000">Law</font></td>');
        %         fprintf(fid,'%s\n','</tr>');
        %         fprintf(fid,'%s\n','<tr>');
        %         fprintf(fid,'%s\n','<td><font color="#990000">Day of the year  Year ' int2str(Def_Base.Obs.Year) '</td>');
        %         fprintf(fid,'%s\n',['<td>' num2str(Def_Base.Obs.Day.Min) '</td>']);
        %         fprintf(fid,'%s\n',['<td>' num2str(Def_Base.Obs.Day.Max) '</td>']);
        %         fprintf(fid,'%s\n',['<td>uniform</td>']);
        %         fprintf(fid,'%s\n','</tr>');
        %         fprintf(fid,'%s\n','<tr>');
        %         fprintf(fid,'%s\n','<td><font color="#990000">Latitude (&deg;)</td>');
        %         fprintf(fid,'%s\n',['<td>' num2str(Def_Base.Obs.Lat.Min) '</td>']);
        %         fprintf(fid,'%s\n',['<td>' num2str(Def_Base.Obs.Lat.Max) '</td>']);
        %         fprintf(fid,'%s\n',['<td>uniform</td>']);
        %         fprintf(fid,'%s\n','</tr>');
        %         fprintf(fid,'%s\n','<tr>');
        %         fprintf(fid,'%s\n','<td><font color="#990000">Longitude (&deg;)</td>');
        %         fprintf(fid,'%s\n',['<td>' num2str(Def_Base.Obs.Lon.Min) '</td>']);
        %         fprintf(fid,'%s\n',['<td>' num2str(Def_Base.Obs.Lon.Max) '</td>']);
        %         fprintf(fid,'%s\n',['<td>uniform</td>']);
        %         fprintf(fid,'%s\n','</tr>');
        %         fprintf(fid,'%s\n','<tr>');
        %         fprintf(fid,'%s\n','</table>');
    case 'Multiple dates, locations & single configuration'
        %         fprintf(fid,'%s\n','<p align="left"><strong><font color="#000080" size="4" face="Arial"> Multiple dates, locations & configurations</font></strong></p>');
        %         fprintf(fid,'%s\n','<table width="75%" border="1" bordercolor="#006600">');
        %         fprintf(fid,'%s\n','<tr> ');
        %         fprintf(fid,'%s\n','<td width="10%"><font color="#990000">Min</font></td>');
        %         fprintf(fid,'%s\n','<td width="10%"><font color="#990000">Max</font></td>');
        %         fprintf(fid,'%s\n','<td width="10%"><font color="#990000">Law</font></td>');
        %         fprintf(fid,'%s\n','</tr>');
        %         fprintf(fid,'%s\n','<tr>');
        %         fprintf(fid,'%s\n','<td><font color="#990000">Day of the year  Year ' int2str(Def_Base.Obs.Year) '</td>');
        %         fprintf(fid,'%s\n',['<td>' num2str(Def_Base.Obs.Day.Min) '</td>']);
        %         fprintf(fid,'%s\n',['<td>' num2str(Def_Base.Obs.Day.Max) '</td>']);
        %         fprintf(fid,'%s\n',['<td>uniform</td>']);
        %         fprintf(fid,'%s\n','</tr>');
        %         fprintf(fid,'%s\n','<tr>');
        %         fprintf(fid,'%s\n','<td><font color="#990000">Latitude (&deg;)</td>');
        %         fprintf(fid,'%s\n',['<td>' num2str(Def_Base.Obs.Lat.Min) '</td>']);
        %         fprintf(fid,'%s\n',['<td>' num2str(Def_Base.Obs.Lat.Max) '</td>']);
        %         fprintf(fid,'%s\n',['<td>uniform</td>']);
        %         fprintf(fid,'%s\n','</tr>');
        %         fprintf(fid,'%s\n','<tr>');
        %         fprintf(fid,'%s\n','<td><font color="#990000">Longitude (&deg;)</td>');
        %         fprintf(fid,'%s\n',['<td>' num2str(Def_Base.Obs.Lon.Min) '</td>']);
        %         fprintf(fid,'%s\n',['<td>' num2str(Def_Base.Obs.Lon.Max) '</td>']);
        %         fprintf(fid,'%s\n',['<td>uniform</td>']);
        %         fprintf(fid,'%s\n','</tr>');
        %         fprintf(fid,'%s\n','<tr>');
        %         fprintf(fid,'%s\n','</table>');
    case 'Multiple dates, locations & configurations' % utilisation de l'orbitographie
        fprintf(fid,'%s\n','<p align="left"><strong><font color="#000080" size="4" face="Arial"> Multiple dates, locations & configurations</font></strong></p>');
        fprintf(fid,'%s\n','<table width="65%" border="1" bordercolor="#006600">');
        fprintf(fid,'%s\n','<tr> ');
        fprintf(fid,'%s\n','<td width="30%"><font color="#990000"><font face="Arial">&nbsp;</font></td>');
        fprintf(fid,'%s\n','<td width="10%"><font color="#990000">Min</font></td>');
        fprintf(fid,'%s\n','<td width="10%"><font color="#990000">Max</font></td>');
        fprintf(fid,'%s\n','<td width="10%"><font color="#990000">Law</font></td>');
        fprintf(fid,'%s\n','</tr>');
        fprintf(fid,'%s\n','<tr>');
        fprintf(fid,'%s\n',['<td><font color="#990000">Day of the year  Year ' int2str(Def_Base.Obs.Year) '</td>']);
        fprintf(fid,'%s\n',['<td>' num2str(Def_Base.Obs.Day.Min) '</td>']);
        fprintf(fid,'%s\n',['<td>' num2str(Def_Base.Obs.Day.Max) '</td>']);
        fprintf(fid,'%s\n',['<td>uniform</td>']);
        fprintf(fid,'%s\n','</tr>');
        fprintf(fid,'%s\n','<tr>');
        fprintf(fid,'%s\n','<td><font color="#990000">Latitude (&deg;)</td>');
        fprintf(fid,'%s\n',['<td>' num2str(Def_Base.Obs.Lat.Min) '</td>']);
        fprintf(fid,'%s\n',['<td>' num2str(Def_Base.Obs.Lat.Max) '</td>']);
        fprintf(fid,'%s\n',['<td>uniform</td>']);
        fprintf(fid,'%s\n','</tr>');
        fprintf(fid,'%s\n','<tr>');
        fprintf(fid,'%s\n','<td><font color="#990000">Longitude (&deg;)</td>');
        fprintf(fid,'%s\n',['<td>' num2str(Def_Base.Obs.Lon.Min) '</td>']);
        fprintf(fid,'%s\n',['<td>' num2str(Def_Base.Obs.Lon.Max) '</td>']);
        fprintf(fid,'%s\n',['<td>uniform</td>']);
        fprintf(fid,'%s\n','</tr>');
        fprintf(fid,'%s\n','<tr>');
        fprintf(fid,'%s\n','</table>');
end

%%% 1.6 Atmosphere
if strcmp(Def_Base.Toc_Toa,'Toa')
    fprintf(fid,'%s\n','<p align="left"><strong><font color="#000080" size="4" face="Arial">1.4 Atmosphere properties</font></strong></p>');
    fprintf(fid,'%s\n','<table width="95%" border="1" bordercolor="#006600">');
    fprintf(fid,'%s\n','<tr> ');
    fprintf(fid,'%s\n','<td width="30%"><font color="#990000"><font face="Arial">&nbsp;</font></td>');
    fprintf(fid,'%s\n','<td width="10%"><font color="#990000"><font face="Arial">Min</font></td>');
    fprintf(fid,'%s\n','<td width="10%"><font color="#990000"><font face="Arial">Max</font></td>');
    fprintf(fid,'%s\n','<td width="10%"><font color="#990000"><font face="Arial">Mean</font></td>');
    fprintf(fid,'%s\n','<td width="10%"><font color="#990000"><font face="Arial">Std</font></td>');
    fprintf(fid,'%s\n','<td width="10%"><font color="#990000"><font face="Arial">NbClass</font></td>');
    fprintf(fid,'%s\n','<td width="10%"><font color="#990000"><font face="Arial">Law</font></td>');
    fprintf(fid,'%s\n','</tr>');
    fprintf(fid,'%s\n','<tr>');
    fprintf(fid,'%s\n','<td><font color="#990000"><font face="Arial">Pressure (<font face="Symbol">m</font>g/cm²)</font></td>');
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.P.Min) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.P.Max) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.P.Mean) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.P.Std) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.P.Nb_Classe) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' Def_Base.Var.P.Distribution '</td>']);
    fprintf(fid,'%s\n','</tr>');
    fprintf(fid,'%s\n','<tr>');
    fprintf(fid,'%s\n','<td><font face="Arial"><font color="#990000">Aerosol optical thickness (g/cm²)</font></td>');
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Tau550.Min) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Tau550.Max) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Tau550.Mean) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Tau550.Std) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.Tau550.Nb_Classe) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' Def_Base.Var.Tau550.Distribution '</td>']);
    fprintf(fid,'%s\n','</tr>');
    fprintf(fid,'%s\n','<tr>');
    fprintf(fid,'%s\n','<td><font face="Arial"><font color="#990000">Water vapour content </td>');
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.H2O.Min) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.H2O.Max) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.H2O.Mean) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.H2O.Std) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.H2O.Nb_Classe) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' Def_Base.Var.H2O.Distribution '</td>']);
    fprintf(fid,'%s\n','</tr>');
    fprintf(fid,'%s\n','<tr>');
    fprintf(fid,'%s\n','<td><font face="Arial"><font color="#990000">Ozone</td>');
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.O3.Min) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.O3.Max) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.O3.Mean) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.O3.Std) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' num2str(Def_Base.Var.O3.Nb_Classe) '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial">' Def_Base.Var.O3.Distribution '</td>']);
    fprintf(fid,'%s\n','</tr>');
    fprintf(fid,'%s\n','<tr>');
    fprintf(fid,'%s\n','</table>');
    fprintf(fid,'%s\n','<p><font face="Arial"><img src="Law_App_Atm.png"  border="1" width="95%"></p>');
end
fprintf(fid,'%s\n','</blockquote>');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Résultats de simulation
fprintf(fid,'%s\n','<p align="left"><font color="#000080" face="Arial" size="6"><strong>2. Simulations of reflectances, fAPAR and fCover</strong></font></p>');
% 2.1 Streamlining the learning data base
fprintf(fid,'%s\n','<blockquote>');
fprintf(fid,'%s\n',['<p align="left"><font face="Arial"><strong><font color="#000080" size="4">2.1 Streamlining the Learning data base </font></strong></p>']);

% 2.1.1 LAI_fAPAR streamline
Ind_Ok = [];
fprintf(fid,'%s\n',['<p align="left"><strong><font face="Arial"><font color="#000080" size="3">2.1.1 LAI_fAPAR Streamlining </font></strong></p>']);
if isfield(Def_Base.Streamline,'LAI_fAPAR')
    fprintf(fid,'%s\n',['<p align="left"><font face="Arial"><font color="#000000" > Cases for which fAPAR is in between median(fAPAR)+- Delta are kept </font></strong></p>']);
    Delta=num2str(Def_Base.Streamline.LAI_fAPAR.Delta,'%0.6g');
    fprintf(fid,'%s\n',['<p align="left"><font face="Arial"><font color="#000000" > Delta = ' Delta '+ (50 -  ' Delta ' ).(LAI_Max - LAI)/LAI_Max </font></strong></p>']);
    fprintf(fid,'%s\n','<p align="justify"><font face="Arial"><font color="#000000"><img src="LAI_fAPAR_Streamline.png"  border="1" width="85%"></font></p>');
    fprintf(fid,'%s\n',['<p align="left"><font face="Arial"><font color="#000000" >' num2str(100-length(Output.Streamline_LAI_fAPAR)/length(Output.(NNT_Output{1}))*100,2) '% of cases have been eliminated </font></p>']);
else
    fprintf(fid,'%s\n',['<p align="left"><font face="Arial"><font color="#006600" > No Streamlining based on the Relationship between LAI and fAPAR </font></strong></p>']);
end

% 2.1.2 Reflectance Mismatch
fprintf(fid,'%s\n',['<p align="left"><strong><font face="Arial"><font color="#000080" size="3">2.1.2 Reflectance mismatch </font></strong></p>']);
if isfield(Def_Base.Streamline,'Mismatch')
    fprintf(fid,'%s\n',['<p align="left"><font face="Arial"><font color="#006600" > Spectra loaded from file : ' Def_Base.Streamline.Mismatch.File '</font></strong></p>']);
    fprintf(fid,'%s\n','<p align="left"><font color="#000000"><img src="Ref_Mismatch.png"  border="1" width="85%"></font></p>');
    fprintf(fid,'%s\n',['<p align="left"><font face="Arial"><font color="#000000" >' int2str(length(Output.(NNT_Output{1}))) ' cases simulated using the PROSPECT+SAIL models.</font></p>']);
    fprintf(fid,'%s\n',['<p align="left"><font face="Arial"><font color="#000000" > Threshold used to streamline based on reflectance mismatch : ' num2str(Def_Base.Streamline.Mismatch.Threshold,'%0.6g') ';.</font></p>']);
    Ind_Ok=find(Input.Mismatch <= Def_Base.Streamline.Mismatch.Threshold); % filtrage des données par rapport à la base mesurée
    Ind_Ok=intersect(Ind_Ok,Output.Streamline_LAI_fAPAR); % filtrage par rapport à la relation LAI_fAPAR
    Nb_Sims=size(Ind_Ok,1);
    fprintf(fid,'%s\n',['<p align="left"><font face="Arial"><font color="#000000" >' num2str(100-Nb_Sims/length(Output.(NNT_Output{1}))*100,2) '% of cases have been eliminated by Streamline + Reflectance mismatch</font></p>']);
else
    fprintf(fid,'%s\n',['<p align="left"><font face="Arial"><font color="#006600" > No Strealining based on the Reflectance mismatch </font></strong></p>']);
end

% 2.2 Histogrammes des réflectances dans chacune des bandes
fprintf(fid,'%s\n',['<p align="left"><strong><font face="Arial"><font color="#000080" size="4">2.2 Reflectance histograms</font></strong></p>']);
file_histo=dir(fullfile(Def_Base.Report_Dir,'Valid_Histo_In*.png'));
for ifile=1:size(file_histo,1)
    fprintf(fid,'%s\n',['<p align="justify"><font color="#000000"><img src="' file_histo(ifile).name '"  border="1" width="85%"></font></p>']);
end

% 2.3 Output Histograms
fprintf(fid,'%s\n',['<p align="left"><strong><font face="Arial"><font color="#000080" size="4">2.3 Output histograms</font></strong></p>']);
fprintf(fid,'%s\n','<p align="justify"><font color="#000000"><img src="Hist_Var_Out.png"  border="1" width="85%"></font></p>');
fprintf(fid,'%s\n','</blockquote>');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Learning of the neural nets
fprintf(fid,'%s\n','<p align="left"><font color="#000080" face="Arial" size="6"><strong>3. Learning of the neural nets</strong></font></p>');
fprintf(fid,'%s\n','<blockquote>');

%% les entrées
fprintf(fid,'%s\n','<p align="left"><strong><font color="#000080" face="Arial" size="4">3.1 Inputs </font></strong></p>');

%% Normalisation des entrées
fprintf(fid,'%s\n','<p align="left"><font color="#000080"><font size="3" face="Arial">3.1.a Normalisation </font></strong></p>');
fprintf(fid,'%s\n','<p align="left"><font color="#000000"><font face="Arial"> Normalisation of inputs   : Input_Norm =  2* (Input-Min)/(Max-Min)-1 </font></p>');
fprintf(fid,'%s\n','<div align="center"></div>');
fprintf(fid,'%s\n','<table width="60%" border="1" bordercolor="#006600">');
fprintf(fid,'%s\n','<tr >');
fprintf(fid,'%s\n','<td width="25%"><font face="Arial">&nbsp;</td>');
fprintf(fid,'%s\n','<td width="25%"><font face="Arial"><div align="center"><font color="#990000">Variable</font></div></td>');
fprintf(fid,'%s\n','<td width="25%"><font face="Arial"><div align="center"><font color="#990000">Min_Normalisation</font></div></td>');
fprintf(fid,'%s\n','<td width="25%"><font face="Arial"><div align="center"><font color="#990000">Max_Normalisation</font></div></td>');
fprintf(fid,'%s\n','</tr>');
fprintf(fid,'%s\n','<tr> ');
fprintf(fid,'%s\n',['<td rowspan="' int2str(Nb_Inputs) '"><font color="#990000">Inputs</font></td>']);
for iang = 1:Nb_Ang % Les Angles
    fprintf(fid,'%s\n',['<td><font face="Arial"><font color="#990000">' Def_Base.Angles{iang} '</font></td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial"><div align="center">' num2str(NNT.Norm_Input_Min(iang),'%0.6g') '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial"><div align="center">' num2str(NNT.Norm_Input_Max(iang),'%0.6g') '</td>']);
    fprintf(fid,'%s\n','</tr>');
end
for iband = 1:Nb_Band % Les Bandes
    fprintf(fid,'%s\n',['<td><font face="Arial"><font color="#990000">' Def_Base.Bandes_Utiles{iband} '</font></td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial"><div align="center">' num2str(NNT.Norm_Input_Min(Nb_Ang+iband),'%0.6g') '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial"><div align="center">' num2str(NNT.Norm_Input_Max(Nb_Ang+iband),'%0.6g') '</td>']);
    fprintf(fid,'%s\n','</tr>');
end
if isfield(Input,'Atmos')
    for iatmo = 1: Nb_Atmo  %% atmosphere ..................
        fprintf(fid,'%s\n',['<td><font face="Arial"><font color="#990000">' Def_Base.Atmos{iatmo} '</font></td>']);
        fprintf(fid,'%s\n',['<td><font face="Arial"><div align="center">' num2str(NNT.Norm_Input_Min(Nb_Band+Nb_Ang+iatmo),'%0.6g') '</td>']);
        fprintf(fid,'%s\n',['<td><font face="Arial"><div align="center">' num2str(NNT.Norm_Input_Max(Nb_Band+Nb_Ang+iatmo),'%0.6g') '</td>']);
        fprintf(fid,'%s\n','</tr>');
    end
end
fprintf(fid,'%s\n','</table>');
fprintf(fid,'%s\n','</tr>');
fprintf(fid,'%s\n','</tr>');

%% extrem cases
fprintf(fid,'%s\n','<p align="left"><font color="#000080"><font size="3" face="Arial">3.1.b Management of Extreme cases :Input out of range</font></strong></p>');
fprintf(fid,'%s\n','<p align="left"><font face="Arial"><font color="#000000">Flags for ''Input Out of Range'' should be raized if one of the input measured value is below the ''Input_Min'' or above the  ''Input_Max'' values,</font></p>');
fprintf(fid,'%s\n','<div align="center"></div>');
fprintf(fid,'%s\n','<table width="60%" border="1" bordercolor="#006600">');
fprintf(fid,'%s\n','<tr >');
fprintf(fid,'%s\n','<td width="25%">&nbsp;</td>');
fprintf(fid,'%s\n','<td width="25%"><font face="Arial"><div align="center"><font color="#990000">Band</font></div></td>');
fprintf(fid,'%s\n','<td width="25%"><font face="Arial"><div align="center"><font color="#990000">Input_Min</font></div></td>');
fprintf(fid,'%s\n','<td width="25%"><font face="Arial"><div align="center"><font color="#990000">Input_Max</font></div></td>');
fprintf(fid,'%s\n','</tr>');
fprintf(fid,'%s\n','<tr> ');
fprintf(fid,'%s\n',['<td rowspan="' int2str(Nb_Inputs) '"><font face="Arial"><font color="#990000">Inputs</font></td>']);
for iang = 1:Nb_Ang
    fprintf(fid,'%s\n',['<td><font face="Arial"><font color="#990000">' Def_Base.Angles{iang} '</font></td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial"><div align="center">' num2str(NNT.Norm_Input_Min(iang)-0.01,'%0.6g') '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial"><div align="center">' num2str(NNT.Norm_Input_Max(iang)+0.01,'%0.6g') '</td>']);
    fprintf(fid,'%s\n','</tr>');
end
for iband = 1:Nb_Band
    fprintf(fid,'%s\n',['<td><font face="Arial"><font color="#990000">' Def_Base.Bandes_Utiles{iband} '</font></td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial"><div align="center">' num2str(NNT.Norm_Input_Min(Nb_Ang+iband)-0.01,'%0.6g') '</td>']);
    fprintf(fid,'%s\n',['<td><font face="Arial"><div align="center">' num2str(NNT.Norm_Input_Max(Nb_Ang+iband)+0.01,'%0.6g') '</td>']);
    fprintf(fid,'%s\n','</tr>');
end
if isfield(Input,'Atmos')
    for iatmo = 1: Nb_Atmo  %% atmosphere ..................
        fprintf(fid,'%s\n',['<td><font face="Arial"><font color="#990000">' Def_Base.Atmos{iatmo} '</font></td>']);
        fprintf(fid,'%s\n',['<td><font face="Arial"><div align="center">' num2str(NNT.Norm_Input_Min(Nb_Ang+Nb_Band+iatmo)-0.01,'%0.6g') '</td>']);
        fprintf(fid,'%s\n',['<td><font face="Arial"><div align="center">' num2str(NNT.Norm_Input_Max(Nb_Ang+Nb_Band+iatmo)+0.01,'%0.6g') '</td>']);
        fprintf(fid,'%s\n','</tr>');
    end
end
fprintf(fid,'%s\n','</tr>');
fprintf(fid,'%s\n','<tr>');
fprintf(fid,'%s\n','</table>');

%% sorties
fprintf(fid,'%s\n','<p align="left"><strong><font color="#000080" face="Arial" size="4">3.2 Output</font></strong></p>');

% Boucles sur les variables de sorties
for ivar=1:size(NNT_Output,1)
    if strcmp(NNT_Output{ivar},'Multi')==0
        if ~isempty(NNT.(NNT_Output{ivar}).NET)
            % Paramètres de normalisation
            fprintf(fid,'%s\n',['<p align="left"><font color="#000080"><font size="3" face="Arial">3.2.' int2str(ivar) '   ' NNT_Output{ivar} '</font></font></p>']);
            fprintf(fid,'%s\n','</tr>');

            %% Dénormalisation de la sortie
            fprintf(fid,'%s\n',['<p align="left"><font color="#000080"><font size="3" face="Arial">3.2.' int2str(ivar) '.a   Denormalisation</font></font></p>']);
            fprintf(fid,'%s\n',['<p align="left"><font color="#000000"><font face="Arial"> Denormalization of ' NNT_Output{ivar} ': Output     = 0.5*(Output_Norm+1)*(Max-Min)+Min</font></p>']);
            fprintf(fid,'%s\n','<table width="60%" border="1" bordercolor="#006600">');
            fprintf(fid,'%s\n','<tr >');
            fprintf(fid,'%s\n','<td width="25%"><font face="Arial"><div align="center"><font color="#990000">Variable</font></div></td>');
            fprintf(fid,'%s\n','<td width="25%"><font face="Arial"><div align="center"><font color="#990000">Min_Normalisation</font></div></td>');
            fprintf(fid,'%s\n','<td width="25%"><font face="Arial"><div align="center"><font color="#990000">Max_Normalisation</font></div></td>');
            fprintf(fid,'%s\n','</tr>');
            fprintf(fid,'%s\n','<tr> ');
            fprintf(fid,'%s\n',['<td><font face="Arial"><font color="#990000">' NNT_Output{ivar} '</font></td>']);
            fprintf(fid,'%s\n',['<td><font face="Arial"><div align="center">' num2str(NNT.(NNT_Output{ivar}).Norm_Min,'%0.6g') '</td>']);
            fprintf(fid,'%s\n',['<td><font face="Arial"><div align="center">' num2str(NNT.(NNT_Output{ivar}).Norm_Max,'%0.6g') '</td>']);
            fprintf(fid,'%s\n','</tr>');
            fprintf(fid,'%s\n','<tr>');
            fprintf(fid,'%s\n','</table>');
            fprintf(fid,'%s\n','</tr>');

            %%% 3.x.2 Architecture
            %%%  Première couche
            fprintf(fid,'%s\n',['<p align="left"><font color="#000080"><font size="3" face="Arial">3.2.' int2str(ivar) '.b Neural network architecture </font></strong></p>']);
            fprintf(fid,'%s\n',['<p align="left"><font color="#000000"><font face="Arial"> Neural Network architecture for ' NNT_Output{ivar} '</font></p>']);

            fprintf(fid,'%s\n','<p><strong><font face="Arial"><font color="#000080">Layer #1</font></strong></p>');
            fprintf(fid,'%s\n','<table width="90%" border="1" bordercolor="#006600">');
            fprintf(fid,'%s\n','<tr> ');
            IW = NNT.(NNT_Output{ivar}).NET.IW{1};
            Nb_Neurons=size(IW,1);
            fprintf(fid,'%s\n',['<td width="' 100/(Nb_Neurons+2) '%"><div align="center"></div></td>']);
            for ineuron=1:Nb_Neurons % noms des neurones
                fprintf(fid,'%s\n',['<td><font face="Arial"><font color="#990033">L1_N' int2str(ineuron) '</font></td>']);
            end
            fprintf(fid,'%s\n','</tr>');
            fprintf(fid,'%s\n','<tr>');
            for iang = 1:Nb_Ang % ajout des angles
                fprintf(fid,'%s\n',['<td width="' 100/(Nb_Inputs+2) '%"><font size="2" face="Arial"><div align="center"><font color="#990000">W_' Def_Base.Angles{iang} '</font></div></td>']);
                for ineuron=1:Nb_Neurons
                    fprintf(fid,'%s\n',['<td><font size="2" face="Arial">' num2str(IW(ineuron,iang),'%0.5g') '</td>']);
                end
                fprintf(fid,'%s\n','</tr>');
                fprintf(fid,'%s\n','<tr>');
            end
            for iband=1:Nb_Band %nom des bandes et valeurs
                fprintf(fid,'%s\n',['<td width="' 100/(Nb_Inputs+2) '%"><font size="2" face="Arial"><div align="center"><font color="#990000">W_' Def_Base.Bandes_Utiles{iband} '</font></div></td>']);
                for ineuron=1:Nb_Neurons
                    fprintf(fid,'%s\n',['<td><font size="2" face="Arial">' num2str(IW(ineuron,Nb_Ang+iband),'%0.5g') '</td>']);
                end
                fprintf(fid,'%s\n','</tr>');
                fprintf(fid,'%s\n','<tr>');
            end
            if isfield(Input,'Atmos')
                for iatmo = 1: Nb_Atmo
                    fprintf(fid,'%s\n',['<td width="' 100/(Nb_Inputs+2) '%"><font size="2" face="Arial"><div align="center"><font color="#990000">W_' Def_Base.Atmos{iatmo} '</font></div></td>']);
                    for ineuron=1:Nb_Neurons
                        fprintf(fid,'%s\n',['<td><font size="2" face="Arial">' num2str(NNT.(NNT_Output{ivar}).NET.IW{1}(ineuron,Nb_Band+Nb_Ang+iatmo),'%0.5g') '</td>']);
                    end
                    fprintf(fid,'%s\n','</tr>');
                    fprintf(fid,'%s\n','<tr>');
                end
            end
            % biais
            fprintf(fid,'%s\n',['<td width="' 100/(Nb_Inputs+2) '%"><div align="center"><font size="2" face="Arial"><font color="#990000">Bias</font></div></td>']);
            for ineuron=1:Nb_Neurons
                fprintf(fid,'%s\n',['<td><font size="2" face="Arial">' num2str(NNT.(NNT_Output{ivar}).NET.b{1}(ineuron),'%0.5g') '</td>']);
            end
            fprintf(fid,'%s\n','</tr>');
            fprintf(fid,'%s\n','<tr>');
            fprintf(fid,'%s\n','</table>');

            %%% Boucle sur les couches suivantes
            for ilayer = 2:size(NNT_Archi.(NNT_Output{ivar}).Transfer,2)
                fprintf(fid,'%s\n','</table>');
                if ilayer == size(NNT_Archi.(NNT_Output{ivar}).Transfer,2)
                    LayerName = 'Output Layer';
                else
                    LayerName = ['Layer #' int2str(ilayer) ];
                end
                fprintf(fid,'%s\n',['<p><font face="Arial"><strong><font color="#000080">' LayerName '</font></strong></p>']);
                fprintf(fid,'%s\n','<table width="90%" border="1" bordercolor="#006600">');
                fprintf(fid,'%s\n','<tr> ');
                fprintf(fid,'%s\n',['<td width="' 100/(NNT_Archi.(NNT_Output{ivar}).Nb_Neurons(ilayer)+2) '%"><div align="center"></div></td>']);
                for ineuron=1:NNT_Archi.(NNT_Output{ivar}).Nb_Neurons(ilayer);
                    fprintf(fid,'%s\n',['<td><font size="2" face="Arial"><font color="#990033">L' int2str(ilayer) '_N' int2str(ineuron) '</font></td>']);
                end
                fprintf(fid,'%s\n','</tr>');
                fprintf(fid,'%s\n','<tr>');
                LW = NNT.(NNT_Output{ivar}).NET.LW{ilayer,ilayer-1};
                for iinput=1:NNT_Archi.(NNT_Output{ivar}).Nb_Neurons(ilayer-1);
                    fprintf(fid,'%s\n',['<td width="' 100/(NNT_Archi.(NNT_Output{ivar}).Nb_Neurons(ilayer-1)+2) '%"><font size="2" face="Arial"><div align="center"><font color="#990000">W_L' int2str(ilayer) '_N' int2str(iinput) '</font></div></td>']);
                    for ineuron=1:NNT_Archi.(NNT_Output{ivar}).Nb_Neurons(ilayer);
                        fprintf(fid,'%s\n',['<td><font size="2" face="Arial">' num2str(LW(ineuron,iinput),'%0.5g') '</td>']);
                    end
                    fprintf(fid,'%s\n','</tr>');
                    fprintf(fid,'%s\n','<tr>');
                end
                % biais
                fprintf(fid,'%s\n',['<td width="' 100/(NNT_Archi.(NNT_Output{ivar}).Nb_Neurons(ilayer-1)+2) '%"><font size="2" face="Arial"><div align="center"><font color="#990000">Bias</font></div></td>']);
                Bias = NNT.(NNT_Output{ivar}).NET.b{ilayer};
                for ineuron=1:NNT_Archi.(NNT_Output{ivar}).Nb_Neurons(ilayer);
                    fprintf(fid,'%s\n',['<td><font size="2" face="Arial">' num2str(Bias(ineuron),'%0.5g') '</td>']);
                end
                fprintf(fid,'%s\n','</tr>');
                fprintf(fid,'%s\n','<tr>');
                fprintf(fid,'%s\n','</table>');
                %% Output function
                fprintf(fid,'%s\n',['<p align="left"><font color="#990000"><font size="2" face="Arial"> Transfert function : ' NNT_Archi.(NNT_Output{ivar}).Transfer{ilayer} '</font></p>']);

                clear LW Bias
            end

            %% 3.x.3 Management of extreme cases
            fprintf(fid,'%s\n',['<p align="left"><font color="#000080"><font size="3" face="Arial">3.2.' int2str(ivar) '.c Management of Extreme cases : Output out of range</font></strong></p>']);
            fprintf(fid,'%s\n',['<p align="left"><font face="Arial"><font color="#000000">When   ' NNT_Output{ivar} ' is in between ''Output_Min-Tolerance'' and ''Output_Min''  then ' NNT_Output{ivar} '= Output_Min  </font></p>']);
            fprintf(fid,'%s\n',['<p align="left"><font face="Arial"><font color="#000000">When   ' NNT_Output{ivar} ' is in between ''Output_Max'' and ''Output_Max+Tolerance''  then ' NNT_Output{ivar} '= Output_Max  </font></p>']);
            fprintf(fid,'%s\n','<p align="left"><font face="Arial"><font color="#000000">Then the ''Output out of range'' flag should be raized</font></p>');
            fprintf(fid,'%s\n','<div align="center"></div>');
            fprintf(fid,'%s\n','<table width="60%" border="1" bordercolor="#006600">');
            fprintf(fid,'%s\n','<tr >');
            fprintf(fid,'%s\n','<td width="25%">&nbsp;</td>');
            fprintf(fid,'%s\n','<td width="33%"><font face="Arial"><div align="center"><font color="#990000">Tolerance</font></div></td>');
            fprintf(fid,'%s\n','<td width="33%"><font face="Arial"><div align="center"><font color="#990000">Output_Min</font></div></td>');
            fprintf(fid,'%s\n','<td width="335%"><font face="Arial"><div align="center"><font color="#990000">Output_Max</font></div></td>');
            fprintf(fid,'%s\n','</tr>');
            fprintf(fid,'%s\n','<tr> ');
            fprintf(fid,'%s\n',['<td><font face="Arial"><div align="center">' NNT_Output{ivar} '</td>']);
            fprintf(fid,'%s\n',['<td><font face="Arial"><div align="center">' num2str(NNT_Archi.(NNT_Output{ivar}).Tolerance,'%0.6g') '</td>']);
            fprintf(fid,'%s\n',['<td><font face="Arial"><div align="center">' num2str(NNT.(NNT_Output{ivar}).Norm_Min,'%0.6g') '</td>']);
            fprintf(fid,'%s\n',['<td><font face="Arial"><div align="center">' num2str(NNT.(NNT_Output{ivar}).Norm_Max,'%0.6g') '</td>']);
            fprintf(fid,'%s\n','</tr>');
            fprintf(fid,'%s\n','<tr> ');
            fprintf(fid,'%s\n','<tr> ');
            fprintf(fid,'%s\n','</tr>');
            fprintf(fid,'%s\n','<tr>');
            fprintf(fid,'%s\n','</table>');

            %% Theoretical performances
            fprintf(fid,'%s\n',['<p align="left"><font color="#000080"><font size="3" face="Arial">3.2.' int2str(ivar) '.d Theoretical performances</font></strong></p>']);
            fprintf(fid,'%s\n',['<p><img src="NNT_Perf_' NNT_Output{ivar} '.png"  border="1" width="95%"></p>']);
        else
            fprintf(fid,'%s\n',['<p align="left"><font color="#000080"><font size="3" face="Arial">3.2.' int2str(ivar) '   ' NNT_Output{ivar} '</font></font></p>']);
            fprintf(fid,'%s\n','</tr>');
            fprintf(fid,'%s\n',['<p align="justify"><font face="Arial"><font color="#000000" >The neural network didn''nt succeed to estimate this variable.</font></p>']);
        end
    end
end
fprintf(fid,'%s\n','</blockquote>');

%             %% 3.x.4 Affichage des n Réseaux testés
%             fprintf(fid,'%s\n',['<p><font face="Arial"><strong><font color="#000080" size="3">3.' int2str(ivar) '.4 Root Mean Square Error obtained for the ' int2str(NNT_Archi.(NNT_Output{ivar}).Nb_Reseau) ' neural nets for ' NNT_Output{ivar} ': </font></strong></p>']);
%             fprintf(fid,'%s\n',['<p><img src="NNT_Rms_' NNT_Output{ivar} '.png" border="1" width="95%"></p>']);
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4.  Teorical results
fprintf(fid,'%s\n','<p align="left"><font color="#000080" face="Arial" size="6"><strong>4. Results on the learning database</strong></font></p>');
fprintf(fid,'%s\n','<blockquote>');

fprintf(fid,'%s\n','<p align="left"><strong><font color="#000080" face="Arial" size="4">4.1 Relationship </font></strong></p>');
%% lai / fapar relationship
if (isfield(NNT,'LAI') && ~isempty(NNT.LAI.NET)) & (isfield(NNT,'fAPAR') && ~isempty(NNT.fAPAR.NET))
    fprintf(fid,'%s\n','<p align="left"><strong><font color="#000080" face="Arial" size="4">4.1 LAI / fAPAR relationship </font></strong></p>');
    fprintf(fid,'%s\n',['<p><img src="NNT_LAI_fAPAR_App.png"  border="1" width="95%"></p>']);
    fprintf(fid,'%s\n','</tr>');
end
%% lai / fcover relationship
if (isfield(NNT,'LAI') && ~isempty(NNT.LAI.NET)) & (isfield(NNT,'fCover') && ~isempty(NNT.fCover.NET))
    fprintf(fid,'%s\n','<p align="left"><strong><font color="#000080" face="Arial" size="4">4.2 LAI / fCover relationship </font></strong></p>');
    fprintf(fid,'%s\n',['<p><img src="NNT_LAI_fCover_App.png"  border="1" width="95%"></p>']);
    fprintf(fid,'%s\n','</tr>');
end
%% fapar / fcover relationship
if (isfield(NNT,'fAPAR') && ~isempty(NNT.fAPAR.NET)) & (isfield(NNT,'fCover') && ~isempty(NNT.fCover.NET))
    fprintf(fid,'%s\n','<p align="left"><strong><font color="#000080" face="Arial" size="4">4.3 fCover / fAPAR relationship </font></strong></p>');
    fprintf(fid,'%s\n',['<p><img src="NNT_fCover_fAPAR_App.png"  border="1" width="95%"></p>']);
    fprintf(fid,'%s\n','</tr>');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 5.Validation on real data
if  ~isempty(Input.Mismatch)
    fprintf(fid,'%s\n','<p align="left"><strong><font color="#000080" face="Arial" size="6">5. Validation on actual data</font></strong></p>');
    fprintf(fid,'%s\n','<blockquote>');

    %% 5.1 lai / fapar relationship
    fprintf(fid,'%s\n','<p align="left"><strong><font color="#000080" face="Arial" size="4">5.1 LAI / fAPAR relationship </font></strong></p>');
    fprintf(fid,'%s\n','<p><img src="Valid_LAI_FAPAR.png"  border="1" width="95%"></p>');

    %% 5.2 Output cumulative histograms
    fprintf(fid,'%s\n','<p align="left"><strong><font color="#000080" face="Arial" size="4">5.2 Output Cumulative histograms</font></strong></p>');
    fprintf(fid,'%s\n','<p><img src="Valid_Histo_Out.png"  border="1" width="95%"></p>');
    %% Season
    fprintf(fid,'%s\n','<p align="left"><font color="#000080"><font size="3" face="Arial">5.2.1 Season </font></font></p>');
    fprintf(fid,'%s\n','</tr>');
    for ivar=1:size(NNT_Output,1)
        NomFile = ['Valid_' NNT_Output{ivar} '_Histo_Out_Season.png'];
        if exist(NomFile)
            fprintf(fid,'%s\n',['<p><img src="Valid_' NNT_Output{ivar} '_Histo_Out_Season.png"  border="1" width="65%"></p>']);
        end
    end
    %% Month
    fprintf(fid,'%s\n','<p align="left"><font color="#000080"><font size="3" face="Arial">5.2.2 Month </font></font></p>');
    fprintf(fid,'%s\n','</tr>');
    for ivar=1:size(NNT_Output,1)
        NomFile = ['Valid_' NNT_Output{ivar} '_Histo_Out_Month.png'];
        if exist(NomFile)
            fprintf(fid,'%s\n',['<p><img src="Valid_' NNT_Output{ivar} '_Histo_Out_Month.png"  border="1" width="85%"></p>']);
        end
    end
    %% Ecoclimap class
    fprintf(fid,'%s\n','<p align="left"><font color="#000080"><font size="3" face="Arial">5.2.3 Ecoclimap class </font></font></p>');
    fprintf(fid,'%s\n','</tr>');
    for ivar=1:size(NNT_Output,1)
        NomFile = ['Valid_' NNT_Output{ivar} '_Histo_Out_Class.png'];
        if exist(NomFile)
            fprintf(fid,'%s\n',['<p><img src="Valid_' NNT_Output{ivar} '_Histo_Out_Class.png"  border="1" width="75%"></p>']);
        end
    end

    %% 5.3 Scatter plots with other sensors
    fprintf(fid,'%s\n','<p align="left"><strong><font color="#000080" face="Arial" size="4">5.3 Scatter plots with other sensors</font></strong></p>');
    %% Season
    fprintf(fid,'%s\n','<p align="left"><font color="#000080"><font size="3" face="Arial">5.3.1 Season </font></font></p>');
    fprintf(fid,'%s\n','</tr>');
    for ivar=1:size(NNT_Output,1)
        clear toto
        toto = dir(fullfile(Def_Base.Report_Dir,['Validation*' NNT_Output{ivar} '*season*']));
        for iplot = 1:size(toto,1)
            fprintf(fid,'%s\n',['<p><img src="' toto(iplot).name '"  border="1" width="65%"></p>']);
        end
    end
    %% Month
    fprintf(fid,'%s\n','<p align="left"><font color="#000080"><font size="3" face="Arial">5.3.2 Month </font></font></p>');
    fprintf(fid,'%s\n','</tr>');
    for ivar=1:size(NNT_Output,1)
        clear toto
        toto = dir(fullfile(Def_Base.Report_Dir,['Validation*' NNT_Output{ivar} '*month*']));
        for iplot = 1:size(toto,1)
            fprintf(fid,'%s\n',['<p><img src="' toto(iplot).name '"  border="1" width="85%"></p>']);
        end
    end
    %% Class
    fprintf(fid,'%s\n','<p align="left"><font color="#000080"><font size="3" face="Arial">5.3.3 Ecoclimap class </font></font></p>');
    fprintf(fid,'%s\n','</tr>');
    for ivar=1:size(NNT_Output,1)
        clear toto
        toto = dir(fullfile(Def_Base.Report_Dir,['Validation*' NNT_Output{ivar} '*class*']));
        for iplot = 1:size(toto,1)
            fprintf(fid,'%s\n',['<p><img src="' toto(iplot).name '"  border="1" width="75%"></p>']);
        end
    end

    %% 5.4 Rmse with other sensors
    fprintf(fid,'%s\n','<p align="left"><strong><font color="#000080" face="Arial" size="4">5.4 Rmse with other sensors</font></strong></p>');
    fprintf(fid,'%s\n','</tr>');
    for ivar=1:size(NNT_Output,1)
        clear toto
        toto = dir(fullfile(Def_Base.Report_Dir,['Rms_' NNT_Output{ivar} '*']));
        for iplot = 1:size(toto,1)
            fprintf(fid,'%s\n',['<p><img src="' toto(iplot).name '"  border="1" width="75%"></p>']);
        end
    end

    %% 5.5 BoxPlots with other sensors
    fprintf(fid,'%s\n','<p align="left"><strong><font color="#000080" face="Arial" size="4">5.5 BoxPlots with other sensors</font></strong></p>');
    fprintf(fid,'%s\n','</tr>');
    for ivar=1:size(NNT_Output,1)
        clear toto
        toto = dir(fullfile(Def_Base.Report_Dir,['BoxPlots_' NNT_Output{ivar} '*']));
        for iplot = 1:size(toto,1)
            fprintf(fid,'%s\n',['<p><img src="' toto(iplot).name '"  border="1" width="75%"></p>']);
        end
    end

    %% 5.6 Direct Validation
    fprintf(fid,'%s\n','<p align="left"><strong><font color="#000080" face="Arial" size="4">5.6 Direct Validation</font></strong></p>');
    %% 5.6.1 Scatter Plots
    fprintf(fid,'%s\n','<p align="left"><font color="#000080"><font size="3" face="Arial">5.6.1 Scatter Plots </font></font></p>');
    for ivar=1:size(NNT_Output,1)
        NomFile = ['Scatter_Direct_' NNT_Output{ivar} '.png'];
        if exist(NomFile)
            fprintf(fid,'%s\n',['<p><img src="Scatter_Direct_' NNT_Output{ivar} '.png"  border="1" width="95%"></p>']);
        end
    end
    %% 5.6.2 Temporal plots
    fprintf(fid,'%s\n','<p align="left"><font color="#000080"><font size="3" face="Arial">5.6.2 Temporal plots </font></font></p>');
    clear toto
    toto = dir(fullfile(Def_Base.Report_Dir,['NNT_*_' Def_Base.Name '.png']));
    for iplot = 1:size(toto,1)
        fprintf(fid,'%s\n',['<p><img src="' toto(iplot).name '"  border="1" width="75%"></p>']);
    end

    %     % 5.2 LAI_fAPAR relationships
    %     fprintf(fid,'%s\n',['<p align="left"><strong><font color="#000080" face="Arial" size="4">5.2 LAI-fAPAR relationships for the different products</font></strong></p>']);
    %     fprintf(fid,'%s\n',['<p><img src="Valid_LAI_FAPAR.png"  border="1" width="95%"></p>']);
    %     % 5.3 Direct validation
    %     fprintf(fid,'%s\n',['<p align="left"><strong><font color="#000080" face="Arial" size="4">5.3 Direct Validation </font></strong></p>']);
    %     for ivar=1:size(NNT_Output,1)
    %         if strcmp(NNT_Output{ivar},'Multi')==0 % pour les variables autres que 'Multi'
    %             fprintf(fid,'%s\n',['<p align="left"><strong><font color="#000080" face="Arial" size="3">5.3.' num2str(ivar) ' ' NNT_Output{ivar} '</font></strong></p>']);
    %             fprintf(fid,'%s\n',['<p><img src="Valid_Scatter_Valeri_' NNT_Output{ivar} '.png"  border="1" width="95%"></p>']);
    %         end
    %     end
    %     % 5.4 Temporal profiles
    %     fprintf(fid,'%s\n',['<p align="left"><strong><font color="#000080" face="Arial" size="4">5.4 Temporal profiles </font></strong></p>']);
    %     file_profile=dir(fullfile(Def_Base.Report_Dir,['NNT_*_' char(Def_Base.Name) '.png']));
    %     for ifile=1:size(file_profile,1)
    %         fprintf(fid,'%s\n',['<p align="justify"><font color="#000000"><img src="' file_profile(ifile).name '"  border="1" width="85%"></font></p>']);
    %     end
end
fprintf(fid,'%s\n','</blockquote>');


fclose(fid);