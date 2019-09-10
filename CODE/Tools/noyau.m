function spectre=noyau(n,vai,k,t2)
% NOYAU(n,N,k,t) : calcul de valeurs de reflectance et de transmittance
% a partir d'un indice de refraction n, d'un parametre de structure vai
% et d'un coefficient d'absorption k et de la transmittivite de la premiere
% interface t2.
% n, k et t2 peuvent etre des vecteurs, mais doivent
% avoir la meme dimension (nombre de longueurs d'onde).
% En sortie, on obtient une matrice [refl tran] correspondant a la reflectance
% et la transmittance de la feuille.
%
% calcule de integral(k,inf)(x.^-1*exp(-x) dx)
 
% on tronconne le vecteur k suivant les valeurs de k
y=zeros(size(k));
 k0=find(k<=0);
         k(k0)=1;
         y(k0)=0;
 k1=find( (k>0)&(k<4));
        x = 0.5.*k(k1)-1;
        y(k1) = (((((((((((((((-3.60311230482612224e-13 ...
         .*x+3.46348526554087424e-12).*x-2.99627399604128973e-11) ...
         .*x+2.57747807106988589e-10).*x-2.09330568435488303e-9)    ...
         .*x+1.59501329936987818e-8).*x-1.13717900285428895e-7)     ...
         .*x+7.55292885309152956e-7).*x-4.64980751480619431e-6)     ...
         .*x+2.63830365675408129e-5).*x-1.37089870978830576e-4)     ...
         .*x+6.47686503728103400e-4).*x-2.76060141343627983e-3)     ...
         .*x+1.05306034687449505e-2).*x-3.57191348753631956e-2)     ...
         .*x+1.07774527938978692e-1).*x-2.96997075145080963e-1;
      y(k1) = (y(k1).*x+8.64664716763387311e-1).*x + 7.42047691268006429e-1;
      y(k1) = (y(k1) - log(k(k1)));
k2=find ((k>=4)&(k<85)); 
      x = 14.5 ./ (k(k2)+3.25) - 1.0;
      y(k2)= (((((((((((((((-1.62806570868460749e-12                   ...
         .*x-8.95400579318284288e-13).*x-4.08352702838151578e-12)   ...
         .*x-1.45132988248537498e-11).*x-8.35086918940757852e-11)   ...
         .*x-2.13638678953766289e-10).*x-1.10302431467069770e-9)    ...
         .*x-3.67128915633455484e-9).*x-1.66980544304104726e-8)     ...
         .*x-6.11774386401295125e-8).*x-2.70306163610271497e-7)     ...
         .*x-1.05565006992891261e-6).*x-4.72090467203711484e-6)     ...
         .*x-1.95076375089955937e-5).*x-9.16450482931221453e-5)     ...
         .*x-4.05892130452128677e-4).*x-2.14213055000334718e-3;
      y(k2) = ((y(k2).*x-1.06374875116569657e-2).*x-8.50699154984571871e-2).*x + ...
          9.23755307807784058e-1;
      y(k2) = (exp(-k(k2)) .* y(k2)./ k(k2));
k3=find(k>=85);
    y(k3)=0;
      k=(1-k).*exp(-k)+k.^2..*y;
%
%     calcul des reflectances et transmittances elementaires
%
%     ALLEN et al., 1969, Interaction of isotropic ligth with a compact
%     plant leaf, J. Opt. Soc. Am., Vol.59, 10:1376-1379
%     JACQUEMOUD S. and BARET F., 1990, Prospect : a model of leaf
%     optical properties spectra, Remote Sens. Environ. 34:75-91
%
 
      a1=pi/2;
      t1=tav(a1,n);
      x1=1.-t1;
      x2=t1.^2..*k.^2..*(n.^2-t1);
      x3=t1.^2..*k.*n.^2;
      x4=n.^4-k.^2..*(n.^2-t1).^2;
      x5=t2./t1;
      x6=x5.*(t1-1.)+1.-t2;
      r=x1+x2./x4;
      t=x3./x4;
      ra=x5.*r+x6;
      ta=x5.*t;
 
%
%     calcul des reflectances et transmittances correspondant N
%     couches elementaires
%
%     STOKES G.G., 1862, On the intensity of the light reflected from or
%     transmitted through a pile of plates, Proceedings of the Royal
%     Society of London, Vol.11, 545-556
%
 
      delta=(t.^2-r.^2-1).^2-4..*r.^2;
      alfa=(1.+r.^2-t.^2+sqrt(delta))./(2..*r);
      beta=(1.+r.^2-t.^2-sqrt(delta))./(2..*r);
      va=(1.+r.^2-t.^2+sqrt(delta))./(2..*r);
      I=find(beta==r);
      beta(I) = beta(I)+0.000000000000001;
      vb=sqrt(beta.*(alfa-r)./(alfa.*(beta-r)));
      vai=vai-1;
      s1=ra.*(va.*vb.^vai-va.^(-1).*vb.^(-vai))+(ta.*t-ra.*r) ...
      .*(vb.^vai-vb.^(-vai));
      s2=ta.*(va-va.^(-1.));
      s3=va.*vb.^vai-va.^(-1.).*vb.^(-vai)-r.*(vb.^vai-vb.^(-vai));
      spectre=[s1./s3 s2./s3];

