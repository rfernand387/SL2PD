function [LAI, ALA]=Miller_Lang(Po,sig_Po,Teta)
% Calcul du LAI par la méthode de Miller approximée par Lang
% INPUT
% Po    : [N,1] fraction de trous pour N angles zenithaux
% sig_Po: [N,1] ecart type de la fraction de trous pour chaque angle
% Teta  : [N,1] angles zenithaux (en radians)
% OUTPUT
% LAI   : LAI estimé
% ALA   : ALA estimé (en degrés) estimé d'après Welles et Norman (1991)
% Fred 21/03/2007

I=find(Po.*sig_Po > 0);% on recherche les cas ou Po ou sig_Po sont non nuls
P=mmpolyfit(Teta(I),-cos(Teta(I)).*log(Po(I)),1,'weight',1./(sig_Po(I)).^2); % ajustement lineaire pondéré par les incertitudes sur les Po (1/variance)
LAI=2.*(sum(P)); % calcul du LAI
% Calcul du ALA en ajustant G(Teta)=-cos(Teta).*log(Po(Teta))./L  avec Teta (en radian)entre 25° et 65°
I=find(Teta*180/pi>25 & Teta*180/pi<65); % on sélectionne les angles
P=mmpolyfit(Teta(I),-cos(Teta(I)).*log(Po(I))./LAI,1,'weight',1./(sig_Po(I)).^2); % on ajuste
ALA=56.81964+46.84833.*P(2)-64.6213.*P(2).^2-158.6914.*P(2).^3+522.0626.*P(2).^4+1008.149.*P(2).^5; % ajustement de Welles et Norman

