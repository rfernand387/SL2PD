function Law=Create_Law_Obs(Def_Base)
%% Sampling of orbital geometry
% Sampling is exhaustive for point locations, time intervals or
% configurations and random for ranges of each quantity.
% Fred et Marie 28/11/2005
% Modif Fred Juillet 2007
% Richard June 2019

Limit_Sun_Zenith=60; % définition de l'angle zenithal solaire maximal
Nb_Sims = Def_Base.Max_Sims;

%% Conditions d'observation
switch  Def_Base.Obs.Configur % cas ou on ne considere qu'une seule condition d'observation
    
    case 'Single date, Location, configuration'
        Law.View_Zenith  = ones(Nb_Sims,1).*Def_Base.Obs.View_Zenith;
        Law.View_Azimuth = ones(Nb_Sims,1).*Def_Base.Obs.View_Azimuth;
        if isfield(Def_Base.Obs,'Sun_Zenith')
            Law.Sun_Zenith  = ones(Nb_Sims,1).*Def_Base.Obs.Sun_Zenith;
            Law.Sun_Azimuth = ones(Nb_Sims,1).*Def_Base.Obs.Sun_Azimuth;
        else
            Law.Sun_Zenith = ones(Nb_Sims,1).*zenith(Def_Base.Obs.Day,Def_Base.Obs.Hour,Def_Base.Obs.Minute,Def_Base.Obs.Lat,Def_Base.Obs.Lon);
            Law.Sun_Azimuth = ones(Nb_Sims,1).*azimut(Def_Base.Obs.Day,Def_Base.Obs.Hour,Def_Base.Obs.Minute,Def_Base.Obs.Lat,Def_Base.Obs.Lon); % Azimuth
        end
        Law.Sun_Zenith_FAPAR = ones(Nb_Sims,1).*zenith(Def_Base.Obs.Day,Def_Base.FAPAR_Time.Hour,Def_Base.FAPAR_Time.Minute,Def_Base.Obs.Lat,0);
        Law.Dates=Def_Base.Obs.Day.*ones(Nb_Sims,1);
        
    case 'Single date, Location, Multiple configurations' % Cas ou on utilise des cartes d'angles de zenith et d'azimuth de visée
        Zen=load(Def_Base.Obs.Path_Zen);
        Azi=load(Def_Base.Obs.Path_Azi);
        Nom_Zen=fieldnames(Zen); % nom de la matrice des zenith
        Nom_Azi=fieldnames(Azi); % nom de la matrice des azimuth
        % tirage de Nb_Sims cas
        S=numel(Zen.(Nom_Zen{1}));
        I=ceil(rand(Nb_Sims,1)*S);
        Law.View_Zenith=Zen.(Nom_Zen{1})(I);
        Law.Sun_Zenith  = ones(Nb_Sims,1).*Def_Base.Obs.Sun_Zenith;
        Law.View_Azimuth = Def_Base.Obs.View_Azimuth.*ones(Nb_Sims,1); % Azimuth
        Law.Sun_Azimuth = Azi.(Nom_Azi{1})(I); % Azimuth
        Law.Sun_Zenith_FAPAR = ones(Nb_Sims,1).*zenith(Def_Base.Obs.Day,Def_Base.FAPAR_Time.Hour,Def_Base.FAPAR_Time.Minute,Def_Base.Obs.Lat,0);
        Law.Dates=Def_Base.Obs.Day.*ones(Nb_Sims,1);
        
    case 'Multiple dates, locations & single configuration'
        struct_Orbito_Sensor; % chargement des données d'orbitographie
        Def_Base.Obs.Hour=Orbit.(Def_Base.Capteur).Heure;
        Def_Base.Obs.Minute=0;
        Law.View_Zenith = ones(Nb_Sims,1).*Def_Base.Obs.View_Zenith;
        if isfield(Def_Base.Obs,'Path_Site') % si liste de sites
            Sites=load(Def_Base.Obs.Path_Site);
            Nom_Sites=fieldnames(Sites);
            Lat_Lon=repmat(Sites.(Nom_Sites{1}),ceil(NbSims/length(Sites.Nom_Sites{1}),1));
            Lat_Lon=Lat_Lon(randperm(length(Lat_Lon)),:);
            Lat_Lon=Lat_Lon(1:Nb_Sims,:);
        else % si range of lat-lon
            Lat_Lon(:,1)=rand(Nb_Sims,1).*(Def_Base.Obs.Lat.Max-Def_Base.Obs.Lat.Min)+Def_Base.Obs.Lat.Min;
            Lat_Lon(:,2)=rand(Nb_Sims,1).*(Def_Base.Obs.Lon.Max-Def_Base.Obs.Lon.Min)+Def_Base.Obs.Lon.Min;
        end
        Dates= round(rand(Nb_Sims,1).*(Def_Base.Obs.Day.Max-Def_Base.Obs.Day.Min)+Def_Base.Obs.Day.Min);
        Law.Sun_Zenith = zenith(Dates,Def_Base.Obs.Hour,Def_Base.Obs.Minute,Lat_Lon(:,1),0);
        J=find(Law.Sun_Zenith <= Limit_Sun_Zenith*pi/180); % cas avec sun zenith <= Limit_Sun_Zenith
        I=find(Law.Sun_Zenith >  Limit_Sun_Zenith*pi/180); % cas avec sun zenith > Limit_Sun_Zenith
        if ~isempty(I) % si il y a des cas à éliminer
            K=J(randperm(size(J,1))); % on mélange les cas qui marchent
            K=K(1:size(I,1)); % on en prend autant que de cas qui marchent pas (size(I,1))
            Dates(I)=Dates(K); % on recalcule les dates
            Lat_Lon(I,:)=Lat_Lon(K,:); % on recalcule les positions
            Law.Sun_Zenith(I)=Law.Sun_Zenith(K); % on recalcule les zenith
        end
        Law.View_Azimuth = Def_Base.Obs.View_Azimuth.*ones(Nb_Sims,1); % Azimuth
        Law.Sun_Azimuth = azimut(Dates,Def_Base.Obs.Hour,Def_Base.Obs.Minute,Lat_Lon(:,1),Lat_Lon(:,2)); % Azimuth
        Law.Sun_Zenith_FAPAR= zenith(Dates,Def_Base.FAPAR_Time.Hour,Def_Base.FAPAR_Time.Minute,Lat_Lon(:,1),0);
        
    case 'Multiple Dates, Single Location and Single Configuration'
        Law.View_Zenith = ones(Nb_Sims,1).*Def_Base.Obs.View_Zenith;
        Lat_Lon(:,1)=rand(Nb_Sims,1).*Def_Base.Obs.Lat;
        Lat_Lon(:,2)=rand(Nb_Sims,1).*Def_Base.Obs.Lon;
        Dates= round(rand(Nb_Sims,1).*(Def_Base.Obs.Day.Max-Def_Base.Obs.Day.Min)+Def_Base.Obs.Day.Min);
        Law.Sun_Zenith = zenith(Dates,Def_Base.Obs.Hour,Def_Base.Obs.Minute,Lat_Lon(:,1),0);
        J=find(Law.Sun_Zenith <= Limit_Sun_Zenith*pi/180); % cas avec sun zenith <= Limit_Sun_Zenith
        I=find(Law.Sun_Zenith > Limit_Sun_Zenith*pi/180); % cas avec sun zenith > Limit_Sun_Zenith
        if ~isempty(I) % si il y a des cas à éliminer
            K=J(randperm(size(J,1))); % on mélange les cas qui marchent
            K=K(1:size(I,1)); % on en prend autant que de cas qui marchent pas (size(I,1))
            Dates(I)=Dates(K); % on recalcule les dates
            Law.Sun_Zenith(I)=Law.Sun_Zenith(K); % on recalcule les zenith
        end
        Law.View_Azimuth = Def_Base.Obs.View_Azimuth.*ones(Nb_Sims,1); % Azimuth
        Law.Sun_Azimuth = azimut(Dates,Def_Base.Obs.Hour,Def_Base.Obs.Minute,Lat_Lon(:,1),Lat_Lon(:,2)); % Azimuth
        Law.Sun_Zenith_FAPAR= zenith(Dates,Def_Base.FAPAR_Time.Hour,Def_Base.FAPAR_Time.Minute,Lat_Lon(:,1),0);
        Law.Dates=Dates;
        
    case  'Multiple dates, locations & configurations'
        if isfield(Def_Base.Obs,'Day')% utilisation de l'orbitographie
            if isfield(Def_Base.Obs,'Path_Site')
                Sites=load(Def_Base.Obs.Path_Site);
                Nom_Sites=fieldnames(Sites);
            end
%             h = waitbar(0,'orbito,...');
            % initialisations
            LawView_Zenith=zeros(Nb_Sims,1);
            LawSun_Zenith=zeros(Nb_Sims,1);
            LawView_Azimuth=zeros(Nb_Sims,1);
            LawSun_Azimuth=zeros(Nb_Sims,1);
            LawSun_Zenith_FAPAR=zeros(Nb_Sims,1);
            LawDates=zeros(Nb_Sims,1);
            if isfield(Def_Base.Obs,'Path_Site')
                        Lat_Lon_Initial=repmat(Sites.(Nom_Sites{1}),ceil(NbSims/length(Sites.Nom_Sites{1})),1);
            else
                Lat_Lon_Initial=0;
            end
            
            parfor i_cas = 1:Nb_Sims %% Orbito
                
                %%% On élimine les angles solaires supérieurs à 70°
                res(6)=90;
                while res(6)>=70
                    if isfield(Def_Base.Obs,'Path_Site')
%                         Lat_Lon=repmat(Sites.(Nom_Sites{1}),ceil(NbSims/length(Sites.Nom_Sites{1})),1);
                        Lat_Lon=Lat_Lon_Initial(randperm(length(Lat_Lon_Initial)),:);
                        Lat_Lon=Lat_Lon(1,:);
                    else
                        Lat_Lon(1)=rand(1,1).*(Def_Base.Obs.Lat.Max-Def_Base.Obs.Lat.Min)+Def_Base.Obs.Lat.Min;
                        Lat_Lon(2)=rand(1,1).*(Def_Base.Obs.Lon.Max-Def_Base.Obs.Lon.Min)+Def_Base.Obs.Lon.Min;
                    end
                    LawDates(i_cas,1) = rand(1).*(Def_Base.Obs.Day.Max-Def_Base.Obs.Day.Min)+Def_Base.Obs.Day.Min;
                    res = Orbito_Sensor(Def_Base.Capteur,Lat_Lon(1),Lat_Lon(2),floor(LawDates(i_cas,1)));
                    if isempty(res)
                        res(6)=90;
                    end
                end
                LawView_Zenith(i_cas,1)=res(3)*pi/180;
                LawView_Azimuth(i_cas,1)=res(2)*pi/180;
                LawSun_Zenith(i_cas,1)=res(6)*pi/180;
                LawSun_Azimuth(i_cas,1)=res(5)*pi/180;
                LawSun_Zenith_FAPAR(i_cas,1)=zenith(LawDates(i_cas,1),Def_Base.FAPAR_Time.Hour,Def_Base.FAPAR_Time.Minute,Lat_Lon(:,1),0);
%                 waitbar(i_cas/Nb_Sims,h);
            end
                 Law.Dates = LawDates; rand(1).*(Def_Base.Obs.Day.Max-Def_Base.Obs.Day.Min)+Def_Base.Obs.Day.Min;
                 Law.View_Zenith=LawView_Zenith;
                Law.View_Azimuth=LawView_Azimuth;
                Law.Sun_Zenith=LawSun_Zenith;
                Law.Sun_Azimuth=LawSun_Azimuth;
                Law.Sun_Zenith_FAPAR=LawSun_Zenith_FAPAR;           
%             close(h)
        else % lecture d'un fichier
            load(Def_Base.Obs.FileData)
            if length(Point.Doy)<=Nb_Sims
                Selec = randperm(length(Point.Doy));
                Selec=Selec(1:Nb_Sims);
                Law.View_Zenith(:,1) = Point.VZA(Selec)*pi/180;
                Law.Sun_Zenith(:,1) = Point.SZA(Selec)*pi/180;
                Law.Sun_Azimuth(:,1) = Point.SAA(Selec)*pi/180;
                Law.View_Azimuth(:,1) = Point.VAA(Selec)*pi/180;
                Law.Sun_Zenith_FAPAR(:,1) = zenith(Point.Doy(Selec),Def_Base.FAPAR_Time.Hour,Def_Base.FAPAR_Time.Minute,Point.Latitude(Selec),0); % position du soleil à l'heure du calcul du
                Law.Dates=Point.Doy(Selec);
            else
                errordlg('Not enough cases in the observation file')
            end
        end
    case 'Random drawing (hot spot case eliminated)' % on sélectionne au hasard tous les angles
        %%% Angles solaires: on élimine les valeurs de zenith supérierues à
        %%% 70° (limites des hypothèses des modèles)
        for icas=1:Nb_Sims
            Law.Sun_Zenith(icas) = 90*pi/180;
            while Law.Sun_Zenith(icas)>70*pi/180
                Date = round(rand(1).*(Def_Base.Obs.Day.Max-Def_Base.Obs.Day.Min)+Def_Base.Obs.Day.Min);
                Lat  = rand(1).*(Def_Base.Obs.Lat.Max-Def_Base.Obs.Lat.Min)+Def_Base.Obs.Lat.Min;
                Lon  = rand(1).*(Def_Base.Obs.Lon.Max-Def_Base.Obs.Lon.Min)+Def_Base.Obs.Lon.Min;
                Law.Sun_Zenith(icas) = zenith(Date,Def_Base.Obs.Hour,Def_Base.Obs.Minute,Lat,Lon); % position du soleil à l'heure du calcul du
                Law.Sun_Azimuth(icas) = azimut(Date,Def_Base.Obs.Hour,Def_Base.Obs.Minute,Lat,Lon); % position du soleil à l'heure du calcul du
                Law.View_Zenith(icas) = rand(1).*(Def_Base.Obs.View_Zenith.Max-Def_Base.Obs.View_Zenith.Min)+Def_Base.Obs.View_Zenith.Min; % position du soleil à l'heure du calcul du
                Law.View_Azimuth(icas) = rand(1).*(Def_Base.Obs.View_Azimuth.Max-Def_Base.Obs.View_Azimuth.Min)+Def_Base.Obs.View_Azimuth.Min; % position du soleil à l'heure du calcul du
                % élimination des cas proches du hot spot
                if  (abs(Law.View_Zenith(icas)-Law.Sun_Zenith(icas))<=5*pi/180) && (abs(Law.View_Azimuth(icas)-Law.Sun_Azimuth(icas))<=5*pi/180) 
                    Law.Sun_Zenith(icas)=90*pi/180;
                end
            end
            Law.Sun_Zenith_FAPAR = ones(Nb_Sims,1).*zenith(Date,Def_Base.FAPAR_Time.Hour,Def_Base.FAPAR_Time.Minute,Lat,0);
        end
end
