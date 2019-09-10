function [res] = Orbito_Sensor(Sensor,latitude,longitude,J_Day)

%function [res] = orbitomeris(latitude,longitude,J_Day)
% orbitomeris(44,5,06,09)
% input: latitude [-90°;90°]
%        longitude [0° 360°]
%        month [1 12]
%        day [1 31]
% output: res(1)=orbit number [0 500]
%         res(2)=sensor azimut [0° 360°]
%         res(3)=sensor zenith  near [0° 50°]
%         res(4)=solar time 
%         res(5)=solar azimut [0° 360°]
%         res(6)=solar zenith [0° 90°]
% NB:     REFERENCE IS NORTH AND TIME DIRECTION (solar and sensor)
% source: VEGETATION model on the web site of VEGETATION
% we don t care about year (simulation)
% we assume that the orbital cycle starts the first of january


struct_Orbito_Sensor
geom=Sensor_Dir(latitude,longitude,Orbit.(Sensor),J_Day); % calcul des orbites possibles 

% Selection of the closest orbit of the day
jjulmodcycl = mod(J_Day,Orbit.(Sensor).Duree); % numero du jour dans l'orbite
nborbitjour= 24*60/Orbit.(Sensor).Period; % nombre d'orbites par jour
Orbit_Proche = round((jjulmodcycl-1+Orbit.(Sensor).Heure./24)*nborbitjour); % numero de l'orbite potentielle
[x,I]=min(abs(Orbit_Proche-geom(:,1))); % on prend l'orbite la plus proche dans geom
res=geom(I,:);
if size(res,1)~=0
    if res(2) <= 0
        res(2)=res(2)+360; % put sensor azimut in [0:360] and switch in time direction
    end
else
    res =[];
end
