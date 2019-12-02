function Def_Base=Read_Observations(Def_Base)
% Define sensor conditions including spectral response functions
% Fred 06/03/2007 (from Fred & Kathy 21/12/2005, modifié Marie, Novembre 2006)
% Fred 07/09/2009
% Richard June 2019

load Filtres_Smac_2019_04_17.mat % le fichier de definition spectrale des bandes


Configur = {'Single date, Location, configuration';
    'Single date, Location, Multiple configurations';
    'Multiple dates, locations & single configuration';
    'Multiple dates, locations & configurations';
    'Multiple Dates, Single Location and Single Configuration';
    'Random drawing (hot spot case eliminated)'};

Champ_x={'Sun_Zenith' 'Sun_Azimuth' 'View_Zenith' 'View_Azimuth' 'Year' 'Day' 'Hour' 'Minute' 'Lat' 'Lon'};

I_case_ordre= [1 361; 17 377; 32 392; 47 407; 62 422;77 512]; % indices des 'Selected' ou 'not selected' dans 'texte'
Line_bloc_config=[10 26 41 56 71 86]; % ligne correspondant au debut des 'blocs' de chaque configuration
degrad=[ones(1,4).*pi./180 ones(1,6)]; % conversion degre en radian pour les configurations

%% Choix du capteur
[x,y]=xlsread([Def_Base.File_XLS '.xls'],'Sensor','B1');
Def_Base.Capteur = char(y);

%% Choix des bandes
[x,y]=xlsread([Def_Base.File_XLS '.xls'],'Sensor','A3:I53');
Def_Base.Bandes_Utiles=y';
Nb_Bands=size(Def_Base.Bandes_Utiles,2); % Nombre de bandes utiles

%% Definition du Bruit et Biais
if strcmp(Def_Base.Terrain,'Simple')
Def_Base.Bruit_Bandes.AD = x(1:Nb_Bands,1); % Bruit additif dépendant des bandes
Def_Base.Bruit_Bandes.AI = x(1,2);          % Bruit additif indépendant des bandes
Def_Base.Bruit_Bandes.MD = x(1:Nb_Bands,3); % Bruit multiplicatif dépendant des bandes
Def_Base.Bruit_Bandes.MI = x(1,4);          % Bruit multiplicatif indépendant des bandes
else
Def_Base.Bruit_Bandes.AD = x(1:Nb_Bands,5); % Bruit additif dépendant des bandes
Def_Base.Bruit_Bandes.AI = x(1,6);          % Bruit additif indépendant des bandes
Def_Base.Bruit_Bandes.MD = x(1:Nb_Bands,7); % Bruit multiplicatif dépendant des bandes
Def_Base.Bruit_Bandes.MI = x(1,8);          % Bruit multiplicatif indépendant des bandes
end

%% Ajout de bruit (ou non) aux réflectances
[x,y]= xlsread([Def_Base.File_XLS '.xls'],'Sensor','D18');
Def_Base.Bruit_Bandes.Add_Noise=char(y);

%% Chargement des sensibilités spectrales du capteur+bandes considérées
for iband = 1:Nb_Bands
    Def_Base.Sensi_Capteur.(Def_Base.Bandes_Utiles{iband}).Lambda = Filtres_Smac.(Def_Base.Capteur).(Def_Base.Bandes_Utiles{iband}).lambda;
    Def_Base.Sensi_Capteur.(Def_Base.Bandes_Utiles{iband}).Sensi = Filtres_Smac.(Def_Base.Capteur).(Def_Base.Bandes_Utiles{iband}).sensi;
    %if strcmp(Def_Base.Toc_Toa,'Toa')
        Def_Base.Sensi_Capteur.(Def_Base.Bandes_Utiles{iband}).Smac.Cont = Filtres_Smac.(Def_Base.Capteur).(Def_Base.Bandes_Utiles{iband}).smac.cont;
    %end
end

%% Choix de la configuration de visée
[data_config,texte]=xlsread([Def_Base.File_XLS '.xls'],'Configuration','B9:J95'); % les valeurs numériques
I_case=strmatch('Selected',texte);% recherche du cas choisi
if isempty(I_case) % test si feuille excel non remplie
    display('No configuration was selected in Excel sheet ''Configuration''')
    return
else % si feuille excel remplie
    [i_config,J]=find(I_case_ordre==I_case); % le numéro de la configuration (I) et si valeurs numériques (J=1) ou non (J=2)
    if length(i_config)>1 % test si plusieurs config selectionnées
        display('You have selected more than one configuration in Excel sheet ''Configuration''')
        return
    else % si une seule config selectionnée
        Def_Base.Obs.Configur=char(Configur{i_config});
        %% les angles qu'il faudra générer
        switch i_config % selection des configurations
            case 3
                Def_Base.Angles = {'Sun_Zenith'};
            case 4
                Def_Base.Angles = {'View_Zenith';'Sun_Zenith';'Rel_Azimuth'};
            case 5
                Def_Base.Angles = {'Sun_Zenith'};
            case 6
                Def_Base.Angles = {'View_Zenith';'Sun_Zenith';'Rel_Azimuth'};
            otherwise
                Def_Base.Angles =[];
        end % fin selection des configurations

        %% lecture des valeurs numériques
        if J==1 % cas des valeurs numériques
            [data_config]=xlsread([Def_Base.File_XLS '.xls'],'Configuration',['C' num2str(Line_bloc_config(i_config)) ':D' num2str(Line_bloc_config(i_config)+9)]); % les valeurs numériques
            % test si feuille tableau excel bien rempli
            for i_Champ = 1: size(Champ_x,2)
                if ~isnan(data_config(i_Champ,1)) && data_config(i_Champ,1)~=999; % si il y a une valeur dans la colonnne 'min'
                    Def_Base.Obs.(Champ_x{i_Champ}).Min=data_config(i_Champ,1).*degrad(i_Champ);
                    if ~isnan(data_config(i_Champ,2)) && data_config(i_Champ,1)~=999; % si il y a une valeur dans la colonnne 'max'
                        Def_Base.Obs.(Champ_x{i_Champ}).Max=data_config(i_Champ,2).*degrad(i_Champ);
                    else
                        Def_Base.Obs.(Champ_x{i_Champ})=data_config(i_Champ,1).*degrad(i_Champ);
                    end
                end
            end
        else % cas des fichiers de définition ou configuration speciales
            if i_config==1 % c'est encore des valeurs numériques!!
                [data_config]=xlsread([Def_Base.File_XLS '.xls'],'Configuration',['H' num2str(Line_bloc_config(i_config)) ':H' num2str(Line_bloc_config(i_config)+9)]); % les valeurs numériques
                for i_Champ = 1: size(Champ_x,2)
                    if ~isnan(data_config(i_Champ,1)) && data_config(i_Champ,1)~=999; % si il y a une valeur dans la colonnne 'min'
                        Def_Base.Obs.(Champ_x{i_Champ})=data_config(i_Champ,1).*degrad(i_Champ);
                    end
                end
            else
            %% lecture des fichiers de définition
                % a completer !!!!!!!!
            end
        end % fin test valeurs numériques
    end
end % fin test remplissage feuille excel


save([Def_Base.Report_Dir '/' Def_Base.Name], 'Def_Base')
