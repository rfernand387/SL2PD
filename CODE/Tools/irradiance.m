function Sol_Irr=irradiance(tetas,lambda,tau550,surf_refl)
%% Calcul de l'éclairement pour une variation d'angles solaires avec 6S
% INPUT
% tetas    : [1,n] vecteur des angles zenithaux solaires en entrée (en degre)
% lambda   : [k,1] vecteur des longueurs d'onde (entre 400 et 2400nm)
% tau550   : épaisseur optique à 550nm
% surf_ref : reflectance de surface
% OUTPUT
% SolIrr=[k,n] : matrice des éclairements spectraux pour n tetas et k lambda
% Fred Septembre 2009

%% Définitions pour le calcul  de l'éclairement
L0=0;
UMODEL=2;            %(user's model)
AEROMODEL=1;         %(Aerosols models)
L1=0;                %(Next value is AERO.OPT.thick .550um)
TARGETh=0;           %(target altitute in km)
SENSORh=-1000.0;     % altitude of the sensor
L2=-2;               %(user's Wlinf-Wlsup )
WLINF=0.400;         % Lower wavelength
WLSUP=2.400;         % Longer wavelength
L3=0;                %(Homogeneous case)
L4=0;                %(Idirectionnal Effects )
L5=0;                %(next value is reflectance)
BRDF=-2;             %(No atmospheric correction for BRDF)
Sol_Irr=zeros(length(lambda),length(tetas)); % initialisation de Sol_Irr


%% calcul de l'éclairement
w_dir=cd;
cd('.\CODE\Tools')
for itetas=1:length(tetas) % boucle sur les angles solaires
    filename='6s.in';
    fid=fopen(filename,'w');
    fprintf(fid,'%d\n',L0);
    fprintf(fid,'%5.2f %5.2f\n',tetas(itetas),0);
    fprintf(fid,'%5.2f %5.2f\n',0,0);
    fprintf(fid,'%d %d\n',3,21); % date des calcul: 21 mars=solstice
    fprintf(fid,'%d\n',UMODEL);
    fprintf(fid,'%d\n',AEROMODEL);
    fprintf(fid,'%d\n',L1);
    fprintf(fid,'%5.3f\n',tau550); % THICK (AerO.optical thick)
    fprintf(fid,'%5.2f\n',TARGETh);
    fprintf(fid,'%5.2f\n',SENSORh);
    fprintf(fid,'%d\n',L2);
    fprintf(fid,'%5.3f %5.3f\n',WLINF,WLSUP);
    fprintf(fid,'%d\n',L3);
    fprintf(fid,'%d\n',L4);
    fprintf(fid,'%d\n',L5);
    fprintf(fid,'%5.3f\n',surf_refl);   %TARGETf (target reflectance)
    fprintf(fid,'%5.3f\n',surf_refl);   %ENVIf (environmental reflectance)
    fprintf(fid,'%d\n',BRDF);
    fclose(fid);
    %6s simulation
    prog_name=sprintf('!sixsv4 <6s.in >6s_whole.out');
    eval(prog_name);
    fid_6sout=fopen('6s_whole.out','r');
    x=fread(fid_6sout,'char');
    s=char(x');
    fclose(fid_6sout);
    ind1=findstr(s,'trans  down   up     albedo refl                                     *');
    ind2=findstr(s,' integrated values of  :');
    dum=s(ind1+length('trans  down   up     albedo refl                                     *'):ind2(1)-1);
    %Results generation
    dum=deblank(dum);
    s = regexprep(dum, '*', ' ') ;
    data=str2num(s);
    Sol_Irr(:,itetas)=interp1(400:2.5:2400,(data(:,2).*data(:,3).*data(:,7).*data(:,10))',lambda);% Solar irradiance
end

cd(w_dir)
