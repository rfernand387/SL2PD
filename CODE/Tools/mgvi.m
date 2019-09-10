function [MERIS_mgvi] = mgvi(ts,tv,ph,band2,band8,band13)

% [MERIS_mgvi] = mgvi(ts,tv,ph,band2,band8,band13)
%%% Calcul du MGVI
%%% programme codé à partir de cleui de David Béal.
%%% ts = angle zenithal solaire en radians
%%% tv = angle zénithal visée en radians
%%% ph = azimuth relatif en radians
%%% band 2,8,13 = bandes MERIS
%%% M. Weiss, décembre 2004


g=cos(ts).*cos(tv)+sin(ts).*sin(tv).*cos(ph);
G=((tan(ts)).^2+(tan(tv)).^2-2.*tan(ts).*tan(tv).*cos(ph)).^(1/2);
%%%%%%%%%%%%%%%%%%
ki=0.56192;
ti=-0.04203;
pic=0.24012;
f1=((cos(ts).*cos(tv)).^(ki-1))./((cos(ts)+cos(tv)).^(1-ki));
f2=(1-ti.^2)./((1+2.*ti.*g+ti.^2).^(3/2));
f3=1+(1-pic)./(1+G);
F44=f1.*f2.*f3;
%%%%%%%%%%%%%%%%%%
ki=0.70879;
ti=0.037;
pic=-0.46273;
f1=((cos(ts).*cos(tv)).^(ki-1))./((cos(ts)+cos(tv)).^(1-ki));
f2=(1-ti.^2)./((1+2*ti.*g+ti.^2).^(3/2));
f3=1+(1-pic)./(1+G);
F68=f1.*f2.*f3;
%%%%%%%%%%%%%%%%%%
ki=0.86523;
ti=-0.00123;
pic=0.63841;
f1=((cos(ts).*cos(tv)).^(ki-1))./((cos(ts)+cos(tv)).^(1-ki));
f2=(1-ti.^2)./((1+2.*ti.*g+ti.^2).^(3/2));
f3=1+(1-pic)./(1+G);
F86=f1.*f2.*f3;
%%%%%%%%%%%%%%%%%%
p44=band2./F44;
p68=band8./F68;
p86=band13./F86; 
b1=p44;
b2=p68;           
l1=-9.2615;l2=3.2545;l3=9.8268;l4=0.537371;l5=0.363495;l6=0.00235486;l7=0;l8=0;l9=0;l10=0;l11=0;l12=1;           
pr68=(l1.*b1.^2+l2.*b2.^2+l3.*b1.*b2+l4.*b1+l5.*b2+l6)./(l7.*b1.^2+l8.*b2.^2+l9.*b1.*b2+l10.*b1+l11.*b2+l12);
b1=p44;
b2=p86;
l1=-0.47131;l2=-0.045159;l3=-0.80707;l4=0.19812;l5=-0.00690978;l6=-0.0210847;
l7=-0.048362;l8=-0.54507;l9=-1.1027;l10=0.120625;l11=0.518928;l12=-0.198726;
pr86=(l1.*b1.^2+l2.*b2.^2+l3.*b1.*b2+l4.*b1+l5.*b2+l6)./(l7.*b1.^2+l8.*b2.^2+l9.*b1.*b2+l10.*b1+l11.*b2+l12);
b1=pr68;
b2=pr86;
l1=0;l2=0;l3=0;l4=-0.306;l5=0.255;l6=0.0045;l7=1;l8=1;l9=0;l10=0.64;l11=-0.64;l12=0.1998;
MERIS_mgvi=(l1.*b1.^2+l2.*b2.^2+l3.*b1.*b2+l4.*b1+l5.*b2+l6)./(l7.*b1.^2+l8.*b2.^2+l9.*b1.*b2+l10.*b1+l11.*b2+l12);

