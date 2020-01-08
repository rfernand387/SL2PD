function [RES]=PRO4SAIL(N,Cab,Car,Ant,Cbrown,Cw,Cm,LIDFa,LIDFb,TypeLidf,lai,q,cc,tts,tto,psi,rs)

% This version is implemented by Richard Fernandes
% It is based on PRO4SAIL but computes some absorptances and albedos using
% sail3 logic from SL2P
% cc  : vegetation cover fraction
% rs  : soil reflectance vector [sun-view, hem-view, sun-hem, bihem]
rsoil = rs(:,1);

	% This version has been implemented by Jean-Baptiste F�ret
	% Jean-Baptiste F�ret takes the entire responsibility for this version 
	% All comments, changes or questions should be sent to:

% Jean-Baptiste FERET
% UMR-TETIS, IRSTEA Montpellier
% Maison de la T�l�d�tection
% 500 rue Jean-Fracois Breton
% 34093 Montpellier cedex 5
% E-mail: jb.feret@teledetection.fr
	
%	this model PRO4SAIL is based on a version provided by
%	Wout Verhoef 
%	NLR	
%	April/May 2003,
%	original version downloadable at http://teledetection.ipgp.jussieu.fr/prosail/
%	Improved and extended version of SAILH model that avoids numerical singularities
%	and works more efficiently if only few parameters change.
% References:
% 	Verhoef et al. (2007) Unified Optical-Thermal Four-Stream Radiative
% 	Transfer Theory for Homogeneous Vegetation Canopies, IEEE TRANSACTIONS 
% 	ON GEOSCIENCE AND REMOTE SENSING, VOL. 45, NO. 6, JUNE 2007

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	LEAF OPTICAL PROPERTIES	%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LRT=prospect_DB(N,Cab,Car,Ant,Cbrown,Cw,Cm);
% drop last 100nm to comply with SL2P 
LRT = LRT(1:2001,:);
rho	=	LRT(:,2);
tau	=	LRT(:,3);

% figure,hold on
% plot(LRT(:,1),LRT(:,2))
% plot(LRT(:,1),1-LRT(:,3),'r')

%	Geometric quantities
rd=pi/180;
cts		= cos(rd*tts);
cto		= cos(rd*tto);
ctscto	= cts*cto;
tants	= tan(rd*tts);
tanto	= tan(rd*tto);
cospsi	= cos(rd*psi);
dso		= sqrt(tants*tants+tanto*tanto-2.*tants*tanto*cospsi);

%	Generate leaf angle distribution from average leaf angle (ellipsoidal) or (a,b) parameters
if (TypeLidf==1)
    [lidf,litab] = dladgen(LIDFa,LIDFb);
elseif (TypeLidf==2)
    [lidf,litab] = campbell(LIDFa);
end

% angular distance, compensation of shadow length
	%	Calculate geometric factors associated with extinction and scattering 
	%	Initialise sums
	ks	= 0;
	ko	= 0;
	bf	= 0;
	sob	= 0;
	sof	= 0;

	%	Weighted sums over LIDF
    na=length(litab);
	for i=1:na
		ttl = litab(i);	% leaf inclination discrete values
		ctl = cos(rd*ttl);
		%	SAIL volume scattering phase function gives interception and portions to be 
		%	multiplied by rho and tau
		[chi_s,chi_o,frho,ftau]=volscatt(tts,tto,psi,ttl);

		%********************************************************************************
		%*                   SUITS SYSTEM COEFFICIENTS 
		%*
		%*	ks  : Extinction coefficient for direct solar flux
		%*	ko  : Extinction coefficient for direct observed flux
		%*	att : Attenuation coefficient for diffuse flux
		%*	sigb : Backscattering coefficient of the diffuse downward flux
		%*	sigf : Forwardscattering coefficient of the diffuse upward flux
		%*	sf  : Scattering coefficient of the direct solar flux for downward diffuse flux
		%*	sb  : Scattering coefficient of the direct solar flux for upward diffuse flux
		%*	vf   : Scattering coefficient of upward diffuse flux in the observed direction
		%*	vb   : Scattering coefficient of downward diffuse flux in the observed direction
		%*	w   : Bidirectional scattering coefficient
		%********************************************************************************

		%	Extinction coefficients
		ksli = chi_s./cts;
		koli = chi_o./cto;

		%	Area scattering coefficient fractions
		sobli	= frho*pi/ctscto;
		sofli	= ftau*pi/ctscto;
		bfli	= ctl*ctl;
		ks	= ks+ksli*lidf(i);
		ko	= ko+koli*lidf(i);
		bf	= bf+bfli*lidf(i);
		sob	= sob+sobli*lidf(i);
		sof	= sof+sofli*lidf(i);
    end
	%	Geometric factors to be used later with rho and tau
	sdb	= 0.5*(ks+bf);
	sdf	= 0.5*(ks-bf);
	dob	= 0.5*(ko+bf);
	dof	= 0.5*(ko-bf);
	ddb	= 0.5*(1.+bf);
	ddf	= 0.5*(1.-bf);

	%	Here rho and tau come in
	sigb= ddb.*rho+ddf.*tau;
	sigf= ddf.*rho+ddb.*tau;
	att	= 1-sigf;
	m2  = (att+sigb).*(att-sigb);
	m2(m2<=0)=0;
	m   =sqrt(m2);

	sb  = sdb.*rho+sdf.*tau;
	sf	= sdf.*rho+sdb.*tau;
	vb	= dob.*rho+dof.*tau;
	vf	= dof.*rho+dob.*tau;
	w	= sob.*rho+sof.*tau;

	%	Here the LAI comes in
	%   Outputs for the case LAI = 0
	if (lai<0)
		tss		= 1;
		too		= 1;
		tsstoo	= 1;
		rdd		= 0;
		tdd		= 1;
		rsd		= 0;
		tsd		= 0;
		rdo		= 0;
		tdo		= 0;
		rso		= 0;
		rsos	= 0;
		rsod	= 0;

		rddt	= rsoil;
		rsdt	= rsoil;
		rdot	= rsoil;
		rsodt	= 0*rsoil;
		rsost	= rsoil;
		rsot	= rsoil;
		return
    end

	%	Other cases (LAI > 0)
	e1		= exp(-m.*lai);
	e2		= e1.*e1;
	rinf	= (att-m)./sigb;
	rinf2	= rinf.*rinf;
	re		= rinf.*e1;
	denom	= 1.-rinf2.*e2;

	J1ks    = Jfunc1(ks,m,lai);
	J2ks    = Jfunc2(ks,m,lai);
	J1ko    = Jfunc1(ko,m,lai);
	J2ko    = Jfunc2(ko,m,lai);

    Ps  = (sf+sb.*rinf).*J1ks;
	Qs  = (sf.*rinf+sb).*J2ks;
	Pv  = (vf+vb.*rinf).*J1ko;
	Qv  = (vf.*rinf+vb).*J2ko;

	rdd	= rinf.*(1.-e2)./denom;
	tdd	= (1.-rinf2).*e1./denom;
	tsd	= (Ps-re.*Qs)./denom;
	rsd	= (Qs-re.*Ps)./denom;
	tdo	= (Pv-re.*Qv)./denom;
	rdo	= (Qv-re.*Pv)./denom;

	tss	= exp(-ks.*lai);
	too	= exp(-ko.*lai);
	z	= Jfunc3(ks,ko,lai);
	g1	= (z-J1ks.*too)./(ko+m);
	g2	= (z-J1ko.*tss)./(ks+m);
    
	Tv1 = (vf.*rinf+vb).*g1;
	Tv2 = (vf+vb.*rinf).*g2;
	T1	= Tv1.*(sf+sb.*rinf);
	T2	= Tv2.*(sf.*rinf+sb);
	T3	= (rdo.*Qs+tdo.*Ps).*rinf;

	%	Multiple scattering contribution to bidirectional canopy reflectance
	rsod = (T1+T2-T3)./(1.-rinf2);

	%	Treatment of the hotspot-effect
	alf=1e6;
	%	Apply correction 2/(K+k) suggested by F.-M. Br�on
	if (q>0)
		alf=(dso/q).*2./(ks+ko);
    end
	if (alf>200)	% inserted H. Bach 1/3/04
		alf=200;
	end
	if (alf==0)
		%	The pure hotspot - no shadow
		tsstoo = tss;
		sumint = (1-tss)/(ks.*lai);
    else
		%	Outside the hotspot
		fhot=lai.*sqrt(ko.*ks);
		%	Integrate by exponential Simpson method in 20 steps
		%	the steps are arranged according to equal partitioning
		%	of the slope of the joint probability function
		x1=0;
		y1=0;
        f1=1;
		fint=(1.-exp(-alf)).*0.05;
		sumint=0;

		for i=1:20
			if (i<20)
				x2=-log(1.-i.*fint)/alf;
            else
				x2=1;
            end
			y2=-(ko+ks).*lai.*x2+fhot.*(1.-exp(-alf.*x2))/alf;
			f2=exp(y2);
			sumint=sumint+(f2-f1).*(x2-x1)/(y2-y1);
			x1=x2;
			y1=y2;
			f1=f2;
        end
		tsstoo=f1;
    end

%	Bidirectional reflectance
%	Single scattering contribution
	rsos = w.*lai.*sumint;
%	Total canopy contribution
	rso=rsos+rsod;

%	Interaction with the soil
dn=1.-rsoil.*rdd;
% rddt: bi-hemispherical reflectance factor
rddt=rdd+tdd.*rsoil.*tdd./dn;
% rsdt: directional-hemispherical reflectance factor for solar incident flux
rsdt=rsd+(tsd+tss).*rsoil.*tdd./dn;
% rdot: hemispherical-directional reflectance factor in viewing direction    
rdot=rdo+tdd.*rsoil.*(tdo+too)./dn;
% rsot: bi-directional reflectance factor
rsodt=rsod+((tss+tsd).*tdo+(tsd+tss.*rsoil.*rdd).*too).*rsoil./dn;
rsost=rsos+tsstoo.*rsoil;
rsot=rsost+rsodt;



  %% calcul des reflectances de la v�g�tation;
    xo=1-rs(:,4).*rdd;
    refl_hemdir =rdo+tdd.*(rs(:,4).*tdo+rs(:,2).*too)./xo;
    refl_bidir  =rso+tsstoo.*rs(:,1) +((tss.*rs(:,3)+tsd.*rs(:,4)).*tdo+(tsd+tss.*rs(:,3).*rdd).*rs(:,2).*too)./xo;
    refl_hemhem = rdd+(tdd.*rs(:,4).*tdd)./xo;
    refl_dirhem = rsd + (tss.*rs(:,3)+tsd.*rs(:,4)).*tdd./xo;

    %% fraction de couvert dans la direction de vis�e pour la v�g�tation
    fCover_view=1-too;

    %% Calcul de l'absorption pour la v�g�tation
    abs_dir=(1-refl_dirhem-(1-rs(:,3)).*tss-(1-rs(:,4)).*(tss.*rs(:,3).*rdd+tsd)./xo);
    abs_hem=1-refl_hemhem-(1-rs(:,4)).*tdd-((1-rs(:,4)).*tdd.*rdd.*rs(:,4))./xo;
    %% les r�sultats
    Rsol=[rs(:,1) rs(:,2) rs(:,3) rs(:,4) zeros(size(rs,1),3)]; % vecteur propri�t�s comosanes sol nu
    RES = [refl_bidir refl_hemdir refl_dirhem refl_hemhem abs_dir abs_hem repmat(fCover_view,size(rs,1),1)];
    RES=RES.*cc+Rsol.*(1-cc); % correction pour le pixel composite

