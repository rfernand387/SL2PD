function rms=rmse(y,yy)
% function rms=rmse(y,yy)
% y = mesure, yy = estime
% y et yy vecteurs ligne ou colonne
% Calcul du Rmse 


m=max(size(y));
rms=sqrt(sum((y-yy).^2)./m);
