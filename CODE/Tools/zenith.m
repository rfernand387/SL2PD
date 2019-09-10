function z=zenith(quant,hrtu,min,lat,long)
% CALCUL DE L'ANGLE ZENITHAL SOLAIRE  zenith(quantieme,heureTU,min,lat,long)
% parametres d'entree: ce sont soit des vecteurs (tous doivent avoir la meme
% dimension) ou des scalaires.lat et long sont en degres et peuvent etre
% positifs ou negatifs.
% Le resultat final est en radian.
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
if cos(z) <0 ; z=pi/2;end;

