function [R,Rh,A,FVC,fIPAR,fredPAR]=geosail(F,C,HsD,refl,tran,rs,LAI,ala,ts)
%% GEOSAIL model in the case of cylinders after Huemmrich, K. F. 2001. 
% The GeoSail model: a simple addition to the SAIL model to describe discontinuous canopy reflectance. 
% Remote Sensing of Environment, 75:423-431.
%
% INPUTS
% F    : form of the protrusions: F='cyl' for cylinders and F='con' for cones
% C    : the crown fraction
% HsD  : Height to diameter ratio of cylinders or cones
% refl   : Leaf reflectance (column vectors are accepted)
% tran   : Leaf transmittance (column vectors are accepted)
% rs   : Soil bacground reflectance (column vectors are accepted)
% LAI  : Total LAI of the canopy (local LAI LAItree=LAI/C)
% ala  : Average leaf angle inclination (using ellipsoidal distribution) (in °)
% ts   : sun zenith angle (rd)
%
% OUTPUTs
% R=nadir reflectance of the canopy
% Rh= reflectance hemispherique
% A=absorption by the canopy
% FVC= fCover= fraction de couverture végétale
%
% Fred 18/09/2007

%l=LAI./C; % le LAI local des couronnes
l=LAI;
hot=0; % pas de hot spot
to=0;
psi=0;
if l==0.0; l=0.000001;end
if to<0; to=-to; psi=psi+pi;end
a=0;
sig=0;
ks=0;
ko=0;
s=0;
ss=0;
u=0;
v=0;
w=0;
rtp=(refl+tran).*0.5;
rtm=(refl-tran).*0.5;
tgs=tan(ts);
tgo=tan(to);
cos_psi=cos(psi);
dso=sqrt(abs(tgs.^2+tgo.^2-2*tgs.*tgo.*cos_psi));
alf=1e6;
if hot>0; alf=dso./hot; end

%% calcul de la distribution des inclinaison foliaires
%
excent=exp(-1.6184e-5.*ala.^3+2.1145e-3.*ala.^2-1.2390e-1.*ala+3.2491);
tlref=[5 15 25 35 45 55 64 72 77 79 81 83 85 87 89];
alpha1=[10 20 30 40 50 60 68 76 78 80 82 84 86 88 90];
alpha2=[0 alpha1(1,1:14)];

%% calcul des frequences relatives
tlref=tlref'*pi/180;
alpha1=alpha1'*pi/180;
alpha2=alpha2'*pi/180;
x1=excent./sqrt(1+excent.^2..*tan(alpha1).^2);
x2=excent./sqrt(1+excent.^2..*tan(alpha2).^2);
   if excent == 1
      ff=abs(cos(alpha1)-cos(alpha2));
   else
     if excent==0;excent=0.000000001;end
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
       sn2l=snl.^2;
       csl=cos(tl);
       cs2l=csl.^2;
       tgl=tan(tl);
       % calcul de betas, beta0, beta1, beta2, beta3
          bs=pi;
          bo=pi;
          if ((tl + ts) > pi/2); bs=acos(-1./(tgs.*tgl));end
          if ((tl + to) > pi/2); bo=acos(-1./(tgo.*tgl));end
       bt1=abs(bs-bo);
       bt2=2*pi-bs-bo;
             if (psi < bt1)
               b1=psi;
               b2=bt1;
               b3=bt2;
             elseif (psi > bt2)
               b1=bt1;
               b2=bt2;
               b3=psi;
             else
               b1=bt1;
               b2=psi;
               b3=bt2;
             end
       % calcul des coefficients de diffusion
       fl=ff(i).*l;
       a=a+(1-rtp+rtm.*cs2l).*fl;
       sig=sig+(rtp+rtm.*cs2l).*fl;
       sks=((bs-pi*0.5).*csl+sin(bs).*tgs.*snl).*2./pi;
       sko=((bo-pi*0.5).*csl+sin(bo).*tgo.*snl).*2./pi;
       ks=ks+sks.*fl;
       ko=ko+sko.*fl;
       s=s+(rtp.*sks-rtm.*cs2l).*fl;
       ss=ss+(rtp.*sks+rtm.*cs2l).*fl;
       u=u+(rtp*sko-rtm.*cs2l).*fl;
       v=v+(rtp*sko+rtm.*cs2l).*fl;
       tsin=sn2l.*tgs.*tgo/2;
       t1=cs2l+tsin.*cos_psi;
       t2=0;    
           if b2 > 0 
              t3=tsin*2;
              if (bs == pi)||(bo == pi); t3=cs2l./(cos(bs).*cos(bo)); end
              t2=-b2.*t1+sin(b2).*(t3+cos(b1).*cos(b3).*tsin);
           end
        w=w+(refl.*t1+2*rtp.*t2/pi).*fl;
end

%% calcul des variables intermediaires
m=sqrt(a.^2-sig.^2);
h1=(a+m)./sig;
h2=1../h1;
cks=ks.^2-m.^2;
cko=ko.^2-m.^2;
co=(v.*(ko-a)-u.*sig)./cko;
cs=(ss.*(ks-a)-s.*sig)./cks;
do=(-u.*(ko+a)-v.*sig)./cko;
ds=(-s.*(ks+a)-ss.*sig)./cks;
ho=(s.*co+ss.*do)./(ko+ks);

%% calcul des reflectances et transmittances d'une strate.
tss=exp(-ks);
too=exp(-ko);
g=h1.*exp(m)-h2.*exp(-m);
rdd=(exp(m)-exp(-m))./g;
tdd=(h1-h2)./g;
rsd=cs.*(1-tss.*tdd)-ds.*rdd;
tsd=ds.*(tss-tdd)-cs.*tss.*rdd;
%rdo=co.*(1-too.*tdd)-do.*rdd;
tdo=do.*(too-tdd)-co.*too.*rdd;
rsod=ho.*(1-tss.*too)-co.*tsd.*too-do.*rsd;

%% calcul du terme hot-spot;
sumint=0;
if alf==0
   tsstoo=tss;
   sumint=(1-tss)./ks;
else
   fhot=sqrt(ko.*ks);
     x1=0;
     y1=0;
     f1=1;
     fint=(1-exp(-alf)).*.05;
        for istep=1:20
           if istep < 20
              x2=-log(1-istep.*fint)./alf;
           else
              x2=1;
           end
           y2=-(ko+ks).*x2+fhot.*(1-exp(-alf.*x2))./alf;
           f2=exp(y2);
           sumint=sumint+(f2-f1).*(x2-x1)./(y2-y1);
           x1=x2;
           y1=y2;
           f1=f2;
        end
    tsstoo=f1;
end
rsos=w.*sumint;
rso=rsos+rsod;

%% calcul des reflectances directionnelles-hemispheriques- (Rdh) et bidirectionnelle (Rdd);
xo=1-rs(:,4).*rdd;
Rdh = rsd + (tss.*rs(:,3)+tsd.*rs(:,4)).*tdd./xo;
Rdd  =rso+tsstoo.*rs(:,1) +((tss.*rs(:,3)+tsd.*rs(:,4)).*tdo+(tsd+tss.*rs(:,3).*rdd).*rs(:,2).*too)./xo;


%% Adaptations GEOSAIL
Cs=0;
switch F
    case 'cyl'
        Nu=HsD.*tan(ts);
    case 'con'
        tan_psi=1/(2*HsD);
        if tan(ts )> tan_psi;
            Beta=acos(tan_psi./tan(ts));
            Nu=(tan(Beta)-Beta)./pi;
            Cs=Beta./pi;
        else
            Nu=0;
        end
end

%% Reflectance
S=1-C-(1-C).^(Nu+1); % Shadowed fraction
B=1-C-S; % illuminated background
tcan=tss+tsd; % transmittance du couvert (direct+diffus)
R=C.*(1-Cs).*Rdd...          % illuminated canopy
    +C.*Cs.*Rdd.*tcan...     % shadowed canopy
    +S.*rs(:,2).*tcan...         % shadowed soil
    +B.*rs(:,1);                 % illuminated soil

%% interception hemispherique par le couvert
teta=1:89'.*pi/180;
switch F
    case 'cyl'
        Nu=HsD.*tan(teta);
    case 'con'
        Nu=zeros(length(teta),1);
        i=find(tan(teta)>tan_psi);
        Beta(i)=acos(tan_psi./tan(teta(i)));
        Nu(i)=(tan(Beta(i))-Beta(i))./pi;
end

%% Absorption
Sh=1-C-(1-C).^(Nu+1); % Shadowed fraction
ID=mean(C+Sh); % Diffuse interception
A=min(ones(length(refl),1), (1-tcan).*(C+S+B.*rs(:,3).*ID+S.*rs(:,2).*tcan.*ID)+C.*(rs(:,3).*tcan-Rdh)); % calcul du fAPAR;

%% taux de couverture
K=kellips(ala,0); % coefficient d'extinction
FVC=C.*(1-exp(-K.*l));  % ici on suppose que le calcul est le meme pour les cylindres et les cones!! (c'est sans doute un peu grossier pour les cones, 
                    %   mais on ne va pas s'embeter pour des cones!)
%% fIPAR
fIPAR=(C+S).*(1-exp(-kellips(ala,ts).*l));

%% autre calcul du fAPAR
Rh=C.*Rdh+S.*tcan.*ID.*rs(:,3)+B.*rs(:,3).*ID;% Reflectance hemispherique du couvert
As=(1-rs(:,3)).*(C.*tcan+S.*tcan+B);% absorption par le sol
fredPAR=1-Rh-As;



