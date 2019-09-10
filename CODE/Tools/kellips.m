function kel=kellips(ala,ts)
%KELLIPS(ala,ts) : MODELE COEFFICIENT D'EXTINCTION POUR UNE DISTRIBUTION ELLIPSOIDALE.
% Kellips=G(ts)./cos(ts); G(ts) est la fonction de projection
% ala  : angle moyen d'inclinaison des feuilles (en degres)
% ts : angle zenithal solaire (en radians)
% Fred il y a tres longtemps...
 
 
%% initialisation des valeurs
if ala>89; ala=89; end
if ala <1; ala=1; end
kel=0;
tgs=tan(ts+10e-20);

%% calcul de la distribution des inclinaison foliaires
excent=exp(-1.6184e-5.*ala.^3+2.1145e-3.*ala.^2-1.2390e-1.*ala+3.2491);
tlref=[5 15 25 35 45 55 64 72 77 79 81 83 85 87 89];
alpha1=[10 20 30 40 50 60 68 76 78 80 82 84 86 88 90];
alpha2=[0 alpha1(1,1:14)];
ff=zeros(15,0);
%% calcul des frequences relatives
tlref=tlref'*pi/180;
alpha1=alpha1'*pi/180;
alpha2=alpha2'*pi/180;
x1=excent./sqrt(1+excent.^2..*tan(alpha1).^2);
x2=excent./sqrt(1+excent.^2..*tan(alpha2).^2);
   if excent == 1
      ff=abs(cos(alpha1)-cos(alpha2));
   else
     a1=excent./sqrt(abs(1-excent.^2));
     a12=a1 .^2;
     x12=x1 .^2;
     x22=x2 .^2;
     a1px1=sqrt(a12+x12);
     a1px2=sqrt(a12+x22);
     a1mx1=sqrt(a12-x12);
     a1mx2=sqrt(a12-x22);
       if excent >1
         ff=x1.*a1px1+a12.*log(x1+a1px1);
         ff=abs(ff-(x2.*a1px2+a12.*log(x2+a1px2)));
       else
         ff=x1.*a1mx1+a12.*asin(x1./a1);
         ff=abs(ff-(x2.*a1mx2+a12.*asin(x2./a1)));
       end
    end
ff=ff./sum(ff);

%% boucle sur les classes d'angle
for i=1:15
       tl=tlref(i);
       snl=sin(tl);
       csl=cos(tl);
       tgl=tan(tl);
       % calcul de betas
          bs=pi;
          f= ((tl + ts) > pi/2);
          bs=f.*acos(-1../(tgs.*tgl))+((f==0).*bs);
       % calcul du coefficients d'extinction
       sks=((bs-pi*0.5).*csl+sin(bs).*tgs.*snl).*2./pi;
       kel=kel+sks*ff(i);
end

