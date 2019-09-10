function [r_toa] = SMAC_toc2toa(Coef_SMAC,Tetas,Tetav,Phi,Taup550,uh2o,uo3,Patm,r_toc)
% [r_toa] = SMAC_toc2toa(Coef_SMAC,Tetas,Tetav,Phi,Taup550,uh2o,uo3,Patm,r_toc)
% Computation of the top of atmosphere reflectance from top of canopy reflectance values
% Coef_SMAC = [49,b] coefficients of the SMAC code for the b bands of the sensor considered
% Tetas     = [1,1]  sun zenith angle in degrees (0<Tetas<60)
% Tetav     = [1,1]  view zenith angle in degrees (0<Tetav<60)
% Phi       = [1,1]  relative azimuth angle in degrees (0<Phi<180)
% Taup550   = [1,1]  aerosol optical thickness at 550nm (O<Taup550<0.8)
% uh2o      = [1,1]  water vapour column (cm) (0<uh2o<6.5)
% uo3       = [1,1]  ozone content (dbs) (0<uo3<0.7)
% Patm      = [1,1]  atmospheric pressure (hpa)
% r_toc     = [1,b]  top of canopy reflectance for the n bands
% r_toa    = [1,b]  top of atmosphere reflectance for the n bands
%
% Adaptation matlab M.Weiss, S. Garrigues  Fevrier2002	
% Adaptation decouplage Ray-Gaz-Aer : D.BEAL, F.BARET novembre2003
% version vectorisée par Fred 26/10/2005

crd=180./pi;
cdr=pi./180;
ah2o   = Coef_SMAC(1,:);    nh2o = Coef_SMAC(2,:);    ao3  = Coef_SMAC(3,:);    no3  = Coef_SMAC(4,:);    ao2    = Coef_SMAC(5,:);
no2    = Coef_SMAC(6,:);    po2  = Coef_SMAC(7,:);    aco2 = Coef_SMAC(8,:);    nco2 = Coef_SMAC(9,:);    pco2   = Coef_SMAC(10,:);
ach4   = Coef_SMAC(11,:);   nch4 = Coef_SMAC(12,:);   pch4 = Coef_SMAC(13,:);   ano2 = Coef_SMAC(14,:);   nno2   = Coef_SMAC(15,:);
pno2   = Coef_SMAC(16,:);   aco  = Coef_SMAC(17,:);   nco  = Coef_SMAC(18,:);   pco  = Coef_SMAC(19,:);   a0s    = Coef_SMAC(20,:);
a1s    = Coef_SMAC(21,:);   a2s  = Coef_SMAC(22,:);   a3s  = Coef_SMAC(23,:);   a0T  = Coef_SMAC(24,:);   a1T    = Coef_SMAC(25,:);
a2T    = Coef_SMAC(26,:);   a3T  = Coef_SMAC(27,:);   taur = Coef_SMAC(28,:);   sr   = Coef_SMAC(29,:);   a0taup = Coef_SMAC(30,:);
a1taup = Coef_SMAC(31,:);   wo   = Coef_SMAC(32,:);   gc   = Coef_SMAC(33,:);   a0P  = Coef_SMAC(34,:);   a1P    = Coef_SMAC(35,:); 
a2P    = Coef_SMAC(36,:);   a3P  = Coef_SMAC(37,:);   a4P  = Coef_SMAC(38,:);   Rest1= Coef_SMAC(39,:);   Rest2  = Coef_SMAC(40,:);
Rest3  = Coef_SMAC(41,:); Rest4  = Coef_SMAC(42,:);   Resr1= Coef_SMAC(43,:);   Resr2= Coef_SMAC(44,:);   Resr3  = Coef_SMAC(45,:); 
Resa1  = Coef_SMAC(46,:); Resa2  = Coef_SMAC(47,:);   Resa3= Coef_SMAC(48,:);   Resa4= Coef_SMAC(49,:); 

us   = cos (Tetas.* cdr);
uv   = cos (Tetav.* cdr);
dphi = Phi.*cdr;
Peq  = Patm./1013.0;

% 1) air mass
    m =  1./us + 1./uv;

%2) aerosol optical depth in the spectral band, taup 
    taup = (a0taup) + (a1taup) .* Taup550 ;

%3) gaseous transmissions (downward and upward paths)
    to3 = 1;
    th2o= 1;
    to2 = 1;
    tco2= 1;
    tch4= 1;
    tco=1;  %david
    tno2=1; %david
    uo2  = Peq.^po2;
    uco2 = Peq.^pco2;
    uch4 = Peq.^pch4;
    uno2 = Peq.^pno2;
    uco  = Peq.^pco;

%4) if uh2o <= 0 and uo3 <= 0 no gaseous absorption is computed
    if((uh2o>0) | (uo3>0))
      to3   = exp(ao3.*(uo3.*m).^no3);
      th2o  = exp(ah2o.*(uh2o.*m).^nh2o);
      to2   = exp(ao2.*(uo2.*m).^no2);
      tco2  = exp(aco2.*(uco2.*m).^nco2);
      tch4  = exp(ach4.*(uch4.*m).^nch4);
      tno2  = exp(ano2.*(uno2.*m).^nno2);
      tco   = exp(aco.*(uco.*m).^nco);
    end

%5) Total scattering transmission .*./
    ttetas = a0T + a1T.*Taup550./us + (a2T.*Peq+a3T)./(1.+us) ; 
    ttetav = a0T + a1T.*Taup550./uv + (a2T.*Peq+a3T)./(1.+uv) ;

%6) spherical albedo of the atmosphere 
    s = a0s.*Peq + a3s + a1s.*Taup550 + a2s .*(Taup550.^2) ;

%7) scattering angle cosine 
    cksi = - ( (us.*uv) + (sqrt(1. - us.*us) .* sqrt (1. - uv.*uv).*cos(dphi) ) );
    if (cksi<-1 ) 
      cksi=-1.0 ;
    end

%8) scattering angle in degree 
    ksiD = crd.*acos(cksi) ;

% 9) rayleigh atmospheric reflectance .*./ pour 6s on a delta = 0.0279 .*./
    ray_phase = 0.7190443 .* (1+(cksi.*cksi))+0.0412742;
    taurz=taur.*Peq ;
    ray_ref   = (taurz.*ray_phase)./(4..*us.*uv);
    % Residu Rayleigh
    Res_ray= Resr1 + Resr2 .* taurz.*ray_phase./(us.*uv)+Resr3 .*(taurz.*ray_phase./(us.*uv)).^2; 

% 10) aerosol atmospheric reflectance
    aer_phase = a0P + a1P.*ksiD + a2P.*ksiD.*ksiD +a3P.*ksiD.^3+ a4P.*ksiD.^4;
    ak2 = (1. - wo).*(3 - wo.*3.*gc) ;
    ak  = sqrt(ak2) ;
    e   = -3..*us.*us.*wo./(4.*(1-ak2.*us.*us));
    f   = -(1- wo).*3.*gc.*us.*us.*wo./(4.*(1-ak2.*us.*us));
    dp  = e./(3..*us)+us.*f ;
    d   = e+f;
    b   = 2.*ak ./ (3-wo.*3.*gc);
    del = exp( ak.*taup ).*(1. + b).*(1. + b) - exp(-ak.*taup).*(1. - b).*(1. - b) ;
    ww  = wo./4.;
    ss  = us ./ (1. - ak2.*us.*us) ;
    q1  = 2. + 3..*us + (1. - wo).*3..*gc.*us.*(1. + 2..*us) ;
    q2  = 2. - 3..*us - (1. - wo).*3..*gc.*us.*(1. - 2..*us) ;
    q3  = q2.*exp( -taup./us ) ;
    c1  =  ((ww.*ss) ./ del) .* ( q1.*exp(ak.*taup).*(1. + b) + q3.*(1. - b) ) ;
    c2  = -((ww.*ss) ./ del) .* (q1.*exp(-ak.*taup).*(1. - b) + q3.*(1. + b) ) ;
    cp1 =  c1.*ak ./ ( 3. - wo.*3..*gc ) ;
    cp2 = -c2.*ak ./ ( 3. - wo.*3..*gc ) ;
    z   = d - wo.*3..*gc.*uv.*dp + wo.*aer_phase./4. ;
    x   = c1 - wo.*3..*gc.*uv.*cp1 ;
    y   = c2 - wo.*3..*gc.*uv.*cp2 ;
    aa1 = uv ./ (1. + ak.*uv) ;
    aa2 = uv ./ (1. - ak.*uv) ;
    aa3 = us.*uv ./ (us + uv) ;

    aer_ref = x.*aa1.* (1. - exp( -taup./aa1 ) ) ;
    aer_ref = aer_ref + y.*aa2.*( 1. - exp( -taup ./ aa2 )  ) ;
    aer_ref = aer_ref + z.*aa3.*( 1. - exp( -taup ./ aa3 )  ) ;
    aer_ref = aer_ref ./ ( us.*uv );

    % Residu Aerosol 
    Res_aer= Resa1+Resa2.*(taup.*m.*cksi)+Resa3.*(taup.*m.*cksi).^2+Resa4.*(taup.*m.*cksi).^3;

    % Residu 6s
    tautot=taup+taurz;
    Res_6s= Rest1+Rest2.*(tautot.*m.*cksi)+Rest3.*(tautot.*m.*cksi).^2+Rest4.*(tautot.*m.*cksi).^3;

% 11) total atmospheric reflectance
    atm_ref = ray_ref - Res_ray + aer_ref - Res_aer + Res_6s;

% Gaseous Transmission
    tg      = th2o .* to3  .* to2 .* tco2 .* tch4 .* tco .* tno2;

% reflectance TOAtmo
    r_toa = tg .* (r_toc .* (atm_ref .* s - ttetas .* ttetav) - atm_ref) ./ (r_toc .* s - ones(size(r_toc)));