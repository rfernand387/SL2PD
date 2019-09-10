function [RES]=sail2(l,ala,hot,refl,tran,rs1,rs2,rs3,to,ts,psi)
%function [RES]=sail(l,ala,hot,refl,tran,rs1,rs2,rs3,to,ts,psi)
%SAIL(l,ala,hot,refl,tran,rs,to,ts,psi,skyl) : MODELE SAIL REFLECTANCE.
%
% l   : LAI
% ala  : mean leaf inclination angle
% hot : hot spot parameter
% refl: leaf reflectance   tran: leaf transmittance
% rs1,2,3  : soil reflectance (bidirectional, directional-hemispherical, bihemispherical)
% to  : view zenith angle  ts : solar zenith angle
% psi : azimutal angle difference between solar and view angles
% angles in radians except for the leaf inclination angle which is in degree
%
% RES : [refl_bidir refl_hemdir refl_dirhem refl_hemhem abs_dir abs_hem fCover_view] 
% Ref=reflectance bidirectionnelle;
% Abs=absorbtance du couvert; 1-Po(to) taux de couverture dans la direction d'observation
%
% Prise en compte de vecteurs d''angle d''observation et solaire
%
% Prise en compte de la distribution ellipsoidale des angles
% moyens d''inclinaison des feuilles dans le terme de hot spot.
% Le HotSpot est implémenté selon les modifications apportées par
% Bruno Andrieu (1997).

%-------------------initialisation des valeurs
if l>0
    nb_ang=length(to);
    ind=find(to<0);
    to(ind)=-to(ind);
    psi(ind)=psi(ind)+pi*ones(size(ind));

    ind=find(psi>=2*pi);
    while ~isempty(ind)
        ind=find(psi>=2*pi);
        psi(ind)=psi(ind)-2*pi;
    end

    ind=find(psi>pi);
    psi(ind)=2*pi-psi(ind);

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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calcul de la distribution des inclinaison foliaires
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    excent=exp(-1.6184e-5.*ala.^3+2.1145e-3.*ala.^2-1.2390e-1.*ala+3.2491);
    tlref=[5 15 25 35 45 55 64 72 77 79 81 83 85 87 89];
    alpha1=[10 20 30 40 50 60 68 76 78 80 82 84 86 88 90];
    alpha2=[0 alpha1(1,1:14)];
    ff=zeros(15,0);

    % -----------calcul des frequences relatives

    tlref=tlref'*pi/180;           %'
    alpha1=alpha1'*pi/180;         %'
    alpha2=alpha2'*pi/180;         %'
    x1=excent./sqrt(1+excent.^2..*tan(alpha1).^2);
    x2=excent./sqrt(1+excent.^2..*tan(alpha2).^2);
    if excent == 1
        ff=abs(cos(alpha1)-cos(alpha2));
    else
        a1=excent./sqrt(abs(1-excent.^2));
        a12=a1.^2;
        x12=x1.^2;
        x22=x2.^2;
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

    %----------boucle sur les classes d''angle ------------

    for i=1:15
        tl=tlref(i);
        snl=sin(tl);
        sn2l=snl.^2;
        csl=cos(tl);
        cs2l=csl.^2;
        tgl=tan(tl);

        % calcul de betas, beta0, beta1, beta2, beta3
        bs=pi*ones(size(to));
        bo=pi*ones(size(to));

        inds = find((tl + ts) > pi/2);
        bs(inds)=acos(-1./(tgs(inds).*tgl));

        indo = find((tl + to) > pi/2);
        bo(indo)=acos(-1./(tgo(indo).*tgl));

        bt1=abs(bs-bo);
        bt2=2*pi-bs-bo;

        b1=bt1;
        b2=psi;
        b3=bt2;

        ind1 = find(psi<=bt1);
        b1(ind1)=psi(ind1);
        b2(ind1)=bt1(ind1);
        b3(ind1)=bt2(ind1);

        ind2 = find (psi >= bt2);
        b1(ind2)=bt1(ind2);
        b2(ind2)=bt2(ind2);
        b3(ind2)=psi(ind2);

        % calcul des coefficients de diffusion
        fl=ff(i).*l;
        a=a+(1-rtp+rtm.*cs2l).*fl;
        sig=sig+(rtp+rtm.*cs2l).*fl;
        sks=((bs-pi*0.5).*csl+sin(bs).*tgs.*snl).*2./pi;
        sko=((bo-pi*0.5).*csl+sin(bo).*tgo.*snl).*2./pi;
        ks=ks+sks.*fl;
        ko=ko+sko.*fl;
        s=s+(rtp.*sks+rtm.*cs2l).*fl;
        ss=ss+(rtp.*sks-rtm.*cs2l).*fl;
        u=u+(rtp*sko-rtm.*cs2l).*fl;
        v=v+(rtp*sko+rtm.*cs2l).*fl;
        tsin=sn2l.*tgs.*tgo/2;
        t1=cs2l+tsin.*cos_psi;
        t2=zeros(size(t1));
        t3=zeros(size(t1));
        indb2=find(b2 > 0 );

        if ~isempty(indb2)
            t3(indb2)=tsin(indb2)*2;
            indbsbo = find((bs == pi)|(bo == pi));

            if ~isempty(indbsbo)
                t3(indbsbo)=cs2l./(cos(bs(indbsbo)).*cos(bo(indbsbo)));
            end
            t2(indb2)=-b2(indb2).*t1(indb2)+sin(b2(indb2)).*(t3(indb2)+cos(b1(indb2)).*cos(b3(indb2)).*tsin(indb2));
        end
        w=w+(refl.*t1+2*rtp.*t2/pi).*fl;
    end

    % calcul des variables intermediaires
    m=sqrt(a.^2-sig.^2);
    h1=(a+m)./sig;
    h2=1../h1;
    cks=ks.^2-m.^2;
    cko=ko.^2-m.^2;
    co=(v.*(ko-a)-u.*sig)./cko;
    cs=(s.*(ks-a)-ss.*sig)./cks;
    do=(-u.*(ko+a)-v.*sig)./cko;
    ds=(-ss.*(ks+a)-s.*sig)./cks;
    ho=(ss.*co+s.*do)./(ko+ks);

    % calcul des reflectances et transmittances d''une strate.
    tss=exp(-ks);
    too=exp(-ko);
    g=h1.*exp(m)-h2.*exp(-m);
    rdd=(exp(m)-exp(-m))./g;
    tdd=(h1-h2)./g;
    rsd=cs.*(1-tss.*tdd)-ds.*rdd;
    tsd=ds.*(tss-tdd)-cs.*tss.*rdd;
    rdo=co.*(1-too.*tdd)-do.*rdd;
    tdo=do.*(too-tdd)-co.*too.*rdd;
    rsod=ho.*(1-tss.*too)-co.*tsd.*too-do.*rsd;

    % calcul du terme hot-spot;
    sl = hot*pi/4/(1+0.357*(ala/(97-ala))^1.252).*sqrt(ko.*ks);
    alf=1e6*ones(1,nb_ang);
    if hot>0
        alf=dso./sl;
    end
    sumint=zeros(size(alf));

    tsstoo = zeros(size(tss));
    ind=find(alf==0);

    tsstoo(ind) = tss(ind);
    sumint(ind)= (1-tss(ind))./ks(ind);
    clear ind

    ind=find(alf~=0);
    if ~isempty(ind)
        fhot(ind)=(ko(ind).*ks(ind)).^0.5;
        x1=zeros(size(to(ind)));
        y1=zeros(size(to(ind)));
        f1=ones(size(to(ind)));
        fint=(1-exp(-alf)).*.05;

        for istep=1:20
            if istep < 20
                x2=-log(1-istep.*fint(ind))./alf(ind);
            else
                x2=ones(size(ind));
            end
            y2=-(ko(ind)+ks(ind)).*x2+fhot(ind)'.*(1-exp(-alf(ind).*x2))./alf(ind); %'
            f2=exp(y2);
            sumint(ind)=sumint(ind)+(f2-f1).*(x2-x1)./(y2-y1);
            x1=x2;
            y1=y2;
            f1=f2;
        end
        tsstoo(ind)=f1;
    end

    rsos=w.*sumint;
    rso=rsos+rsod;


%% calcul des reflectances;
    xo=1-rs3.*rdd;
    Rds=rdo+tdd.*(rs3.*tdo+rs2.*too)./xo;
    Rss=rso+tsstoo.*rs1 +((tss.*rs2+tsd.*rs3).*tdo+(tsd+tss.*rs2.*rdd).*rs2.*too)./xo;
    Rdd = rdd+(tdd.*rs3.*tdd)./(1-rdd.*rs3);
    Rsd = rsd + (tss.*rs2+tsd.*rs3).*tdd./(1-rdd.*rs3);
    % reflectances directionnelle
    refl_bidir=Rss;
    refl_hemdir=Rds;
    % reflectances hemispherique
    refl_dirhem=Rsd;
    refl_hemhem=Rdd;

%% fraction de couvert dans la direction de visée
    fCover_view=1-too;

%% Calcul de l'absorption
    Tss = tss;
    Tdd = tdd./(1-rdd.*rs3);
    Tsd = (tss.*rs2.*rdd+tsd)./(1-rdd.*rs3);
    Tds = 0;
    abs_dir=(1-Rsd-(1-rs2).*Tss-(1-rs3).*Tsd);
    abs_hem=(1-Rdd-(1-rs2).*Tds-(1-rs3).*Tdd);
%% les résultats
    RES = [refl_bidir refl_hemdir refl_dirhem refl_hemhem abs_dir abs_hem fCover_view];
else
    RES=[rs1 rs2 rs2 rs3 0 0 0];
end
