function [SolIrr]=Spectral_irradiance(THICK,WLINF,WLSUP,mm,dd,thetas,phis,thetav,phiv)
% Spectral Irradiance as computed by the 6S code
% Fred 22/11/2010
%
% TICK: aerosol optical thickness: typical=0.23
% WLINF: minimum wavelength (µm)
% WLSUP: maximum wavelength (µm)
% mm: mois
% dd: day
% thetas: sun zenith angle (radian)
% phis: sun azimuth angle (radian)
% thetav: view zenith angle (radian)
% phiv: view azimuth angle (radian)


%% pour calcul éclairement
L0=0;
UMODEL=2;            %(user's model)
AEROMODEL=1;         %(Aerosols models)
L1=0;                %(Next value is AERO.OPT.thick .550um)
TARGETh=0;          %(target altitute in km)
SENSORh=-1000.0;
L2=-2;                %(user's Wlinf-Wlsup )
L3=0;                %(Homogeneous case)
L4=0;                %(Idirectionnal Effects )
L5=0;                %(next value is reflectance)
BRDF=-2;             %(No atmospheric correction for BRDF)

%% les entrées de 6S
filename='6s.in';
fid=fopen(filename,'w');
fprintf(fid,'%d\n',L0);
fprintf(fid,'%5.2f %5.2f\n',thetas,phis);
fprintf(fid,'%5.2f %5.2f\n',thetav,phiv);
fprintf(fid,'%d %d\n',mm,dd);
fprintf(fid,'%d\n',UMODEL);
fprintf(fid,'%d\n',AEROMODEL);
fprintf(fid,'%d\n',L1);
fprintf(fid,'%5.3f\n',THICK);
fprintf(fid,'%5.2f\n',TARGETh);
fprintf(fid,'%5.2f\n',SENSORh);
fprintf(fid,'%d\n',L2);
fprintf(fid,'%5.3f %5.3f\n',WLINF,WLSUP);
fprintf(fid,'%d\n',L3);
fprintf(fid,'%d\n',L4);
fprintf(fid,'%d\n',L5);
fprintf(fid,'%5.3f\n',0.26);
fprintf(fid,'%5.3f\n',0.25);
fprintf(fid,'%d\n',BRDF);
fclose(fid);

%% 6s simulation
prog_name=sprintf('!sixsv4 <6s.in >6s_whole.out');
eval(prog_name);
fid_6sout=fopen('6s_whole.out','r');
x=fread(fid_6sout,'char');
s=char(x');
fclose(fid_6sout);
ind1=findstr(s,'trans  down   up     albedo refl                                     *');
ind2=findstr(s,' integrated values of  :');
dum=s(ind1+length('trans  down   up     albedo refl                                     *'):ind2(1)-1);

%% Results generation
dum=deblank(dum);
s = regexprep(dum, '*', ' ') ;
data=str2num(s);
SolIrr=[(WLINF:0.0025:WLSUP)',(data(:,2).*data(:,3).*data(:,7).*data(:,10))];% Solar irradiance =







