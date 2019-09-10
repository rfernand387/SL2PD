function [RES]=sail3(l,ala,hot,cc,refl,tran,rs,to,ts,psi)
%% [RES]=sail3(l,ala,hot,cc,refl,tran,rs,to,ts,psi)
% l   : LAI
% ala : mean leaf inclination angle (in degres)
% hot : hot spot parameter
% cc  : vegetation cover fraction
% refl: leaf reflectance   tran: leaf transmittance
% rs  : soil reflectance vector [sun-view, hem-view, sun-hem, bihem]
% to  : view zenith angle  ts : solar zenith angle
% psi : azimutal angle difference between solar and view angles
% angles in radians except for the leaf inclination angle which is in degree
%
% RES : [refl_sun-view refl_hem-view refl_sun-hem refl_hemhem abs_sun abs_hem fCover_view]
% Ref=reflectance bidirectionnelle;
% Abs=canopy absorptance; 1-Po(to) cover fraction in the veiw direction
%

%% initialisation des valeurs
% clacul du LAI de la vegetation
l=l/cc; 
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

    %% Calcul de la distribution des inclinaison foliaires
    excent=exp(-1.6184e-5.*ala.^3+2.1145e-3.*ala.^2-1.2390e-1.*ala+3.2491);
    tlref=[5 15 25 35 45 55 64 72 77 79 81 83 85 87 89];
    alpha1=[10 20 30 40 50 60 68 76 78 80 82 84 86 88 90];
    alpha2=[0 alpha1(1,1:14)];
    % calcul des frequences relatives
    tlref=tlref'*pi/180;
    alpha1=alpha1'*pi/180;
    alpha2=alpha2'*pi/180;
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

    %% Calcul des coeffcients de diffusion
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

        %  coefficients de diffusion
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

    %% calcul des variables intermediaires
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

    %% calcul des reflectances et transmittances d''une strate.
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

    %% calcul du terme hot-spot;
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
    tsstoo=repmat(tsstoo,size(rs,1),1);
    tss=repmat(tss,size(rs,1),1);
    rsos=w.*sumint;
    rso=rsos+rsod;


    %% calcul des reflectances de la végétation;
    xo=1-rs(:,4).*rdd;
    refl_hemdir =rdo+tdd.*(rs(:,4).*tdo+rs(:,2).*too)./xo;
    refl_bidir  =rso+tsstoo.*rs(:,1) +((tss.*rs(:,3)+tsd.*rs(:,4)).*tdo+(tsd+tss.*rs(:,3).*rdd).*rs(:,2).*too)./xo;
    refl_hemhem = rdd+(tdd.*rs(:,4).*tdd)./xo;
    refl_dirhem = rsd + (tss.*rs(:,3)+tsd.*rs(:,4)).*tdd./xo;

    %% fraction de couvert dans la direction de visée pour la végétation
    fCover_view=1-too;

    %% Calcul de l'absorption pour la végétation
    abs_dir=(1-refl_dirhem-(1-rs(:,3)).*tss-(1-rs(:,4)).*(tss.*rs(:,3).*rdd+tsd)./xo);
    abs_hem=1-refl_hemhem-(1-rs(:,4)).*tdd-((1-rs(:,4)).*tdd.*rdd.*rs(:,4))./xo;
    %% les résultats
    Rsol=[rs(:,1) rs(:,2) rs(:,3) rs(:,4) zeros(size(rs,1),3)]; % vecteur propriétés comosanes sol nu
    RES = [refl_bidir refl_hemdir refl_dirhem refl_hemhem abs_dir abs_hem repmat(fCover_view,size(rs,1),1)];
    RES=RES.*cc+Rsol.*(1-cc); % correction pour le pixel composite
    
else
    RES=[rs(:,1) rs(:,2) rs(:,3) rs(:,4) zeros(size(rs,1),3)];
end
