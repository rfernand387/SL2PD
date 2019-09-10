function  a=azimut(quant,hrtu,min,lat,long)
% CALCUL DE L'ANGLE AZIMUTAL SOLAIRE  azimut(quantiŠme,heureTU,min,lat,long)
% parametres d'entr‚e: ce sont soit des vecteurs (tous doivent avoir la mˆme
% dimension) ou des scalaires.lat et long sont en degr‚s et peuvent ˆtre
% positifs ou n‚gatifs.
% Le r‚sultat final est en radian.
conv=pi/180.;
tu=hrtu+min./60.;
a1=(1.00554.*quant-2.*pi).*conv;
a2=(1.93946.*quant+23.35089).*conv;
et=-7.6782.*sin(a1)-10.09176.*sin(a2);
while long <0., long=long+360., end;
tsv=tu+long./15.+et./60.-12.;
ah=15..*tsv.*conv;
delta=23.4856.*sin(conv.*(0.9683.*quant-78.00878)).*conv;
lat=lat.*conv;
z=pi/2.-asin(sin(lat).*sin(delta)+cos(lat).*cos(delta).*cos(ah));
sina=cos(delta).*sin(ah)./cos(pi/2.-z);
cosa=(1.-sina.^2.).^.5;
a=atan(sina./cosa);
ca=(-cos(lat).*sin(delta)+sin(lat).*cos(delta).*cos(ah))./cos(pi./2.-z);
a=pi+a;
s=size(a);
for i=1:s(1,1)
if ((ca(i)<0) & (a(i)<pi));
a(i)=pi-a(i);
end
if ((ca(i)<0) & (a(i)>pi));
a(i)=3*pi-a(i);
end
end