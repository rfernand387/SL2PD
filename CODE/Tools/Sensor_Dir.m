function [geom] = Sensor_Dir(lat,long,Orbit,jjul)

% [geom] = Sensor_Dir(lat,long,Sensor,Orbit,jjul)
% Computes for a given geographical point ( lat, long in degrees) the satellite
% geom(:,1) : orbit number
% geom(:,2) : view azimth (degrees)
% geom(:,3) : view zenith (degrees)
% geom(:,4) : solar hour (hour)
% geom(:,5) : solar azimuth (degrees)
% geom(:,6) : solar zenith (degrees)
% Sensor correspond au capteur considéré (VGT, meris, ...)
% author: David Beal, Frederic Baret, Kathy
% date: 07/09/2005
% source: vgtdir

RT=6378.160; % Earth radius
degrad = pi/180;
geom=[]; % initialisation 
lat = lat*degrad;
long = long*degrad;
a=cos(lat)*cos(Orbit.Inclinaison);
b=sin(lat)*sin(Orbit.Inclinaison);
c=cos(lat);
d = Orbit.Beta_Alpha;
e = (RT+Orbit.Altitude)/RT;
costetamin = RT/(RT+Orbit.Altitude);
xsol = RT*(cos(lat)*cos(long));
ysol = RT*(cos(lat)*sin(long));
zsol = RT*sin(lat);
xxrep = -sin(long);yxrep=cos(long);zxrep = 0;
xyrep = -sin(lat)*cos(long);yyrep = -sin(lat)*sin(long);zyrep = cos(lat);
xzrep = cos(lat)*cos(long);yzrep = cos(lat)*sin(long);zzrep = sin(lat);
Nb_Cycles=Orbit.Duree./Orbit.Beta_Alpha;

for n=0:Nb_Cycles-1
    alphan = lat;
    beta = Orbit.Beta_0 + (alphan - n*pi * 2)*d;
    arret = 0;
    nbiter=0;
    while arret==0
        nbiter=nbiter+1;
        alpha = alphan;
        alphan = atan2(-a*sin(long-beta) + b,c*cos(long-beta));
        beta = Orbit.Beta_0 + (alphan - n* 2*pi)* d;
        if (sin(abs(alpha-alphan))<0.0001) | (nbiter>100) 
            arret = 1;
        end
    end
    alpha = alphan;
    teta = asin(sin(lat)*cos(Orbit.Inclinaison) + cos(lat)*sin(Orbit.Inclinaison)*sin(long-beta));
    scan = atan2(sin(teta),e - cos(teta));
    if ~((cos(teta)<costetamin)|((abs(scan) > Orbit.Scan)))
        lnd = atan2(sin(Orbit.Beta_0-n*pi*2*d),cos(Orbit.Beta_0-n*pi*2*d))/degrad;
        xsat = cos(alpha)*cos(beta) + cos(Orbit.Inclinaison)*sin(alpha)*sin(beta);
        ysat = cos(alpha)*sin(beta) - cos(Orbit.Inclinaison)*sin(alpha)*cos(beta);
        zsat = sin(Orbit.Inclinaison)*sin(alpha);
        longsat = atan2(ysat,xsat);
        latsat = atan2(zsat,sqrt(xsat*xsat+ysat*ysat));
        xsat = (RT+Orbit.Altitude)*xsat - xsol;
        ysat = (RT+Orbit.Altitude)*ysat - ysol;
        zsat = (RT+Orbit.Altitude)*zsat - zsol;
        xxx = xsat*xxrep+ysat*yxrep+zsat*zxrep;
        yyy = xsat*xyrep+ysat*yyrep+zsat*zyrep;
        zzz = xsat*xzrep+ysat*yzrep+zsat*zzrep;
        azsat = atan2(xxx,yyy);
        zensat = atan2(sqrt(xxx*xxx+yyy*yyy),zzz);
        hs= Orbit.Heure - (Orbit.Period*alphan/pi/120) + atan2(sin((long+n*pi*2*d-Orbit.Beta_0)),cos((long+n*pi*2*d-Orbit.Beta_0)))*12/pi;
        if abs(hs-12) < 8
            geom = cat(1,geom,[n azsat/degrad zensat/degrad hs]);
        end
    end
end


decl = declin(jjul);
decl = decl*degrad;
ahs = (geom(:,4)-12) .* 15..*degrad;
geom(:,5) = atan2(-cos(decl).*sin(ahs),cos(lat).*sin(decl)-cos(decl).*cos(ahs).*sin(lat))./degrad; % azimuth solaire
geom(:,6) = 90-asin(sin(lat).*sin(decl) + cos(lat).*cos(decl).*cos(ahs))./degrad; % zenith solaire
geom = geom(find(geom(:,6)<90),:);% on ne retient que les orbites avec angle zenithal solaire <90°
