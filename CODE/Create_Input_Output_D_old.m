function [Def_Base, Input, Output]=Create_Input_Output_D(Def_Base, Law, Class,Debug)
%% Création de la base des entrées et sorties du RT
% Simulations GEOSAIL+SMAC (si RhoTOA)
% Marie et Fred 03/01/2006
% Modif Fred Septembre 2007
% Modif Fred Septembre 2009
% Richard July 2019

%% Initialisations
Nb_Sims = size(Law.LAI,1); % Nombre de simulations
Band_Name=fieldnames(Def_Base.Sensi_Capteur);% récupération des noms des bandes du capteur
Nb_Bandes = size(Band_Name,1); % nombre de bandes utilisées
Var_Name = Def_Base.Var_out; % les variables à estimer
Law.Rel_Azimuth=Law.Sun_Azimuth-Law.View_Azimuth; % Azimuth relatif
Coef_Spe = coefspe; % chargement des coefs specifiques de PROSPECT
Sol_Irr=irradiance(0:5:75,400:2400,0.23,0.25); % la LUT pour l'éclairement solaire entre 0° et 75°
Law.Cw=Law.Cdm./(1-Law.Cw_Rel); % on créé la variable Cw

%% cluster laws to identify blocks of input for training
if (Debug)
disp(['Clustering laws for Class ' num2str(Class)])
end

nclus = ceil(length(Law.LAI)/100);
abc = (([ Law.ALA Law.Cab Law.N Law.Cdm Law.Cw_Rel Law.Bs])');
stream = RandStream('mlfg6331_64');  % Random number stream
options = statset('UseParallel',1,'UseSubstreams',1,'Streams',stream);
Input.Cats = kmeans(abc',nclus, 'Distance','cityblock','Replicates',5,'MaxIter',1000,'Options',options  , 'Display','final');

%% Calcul des sensibilités spectrales étendues et ré-échantillonnées pour chaque bande
Sensi=zeros(length(400:2400),Nb_Bandes);
for i_band=1:Nb_Bandes
    Sensi(:,i_band)=interp1([100; Def_Base.Sensi_Capteur.(Band_Name{i_band}).Lambda; 5000], ...
        [0; Def_Base.Sensi_Capteur.(Band_Name{i_band}).Sensi; 0], (400:2400)');
    Sensi(:,i_band)=Sensi(:,i_band)./sum(Sensi(:,i_band)); % normalisation des sensibilités
end


%% On génère aussi le fichier Coef_SMAC des coefficients SMAC pour les bandes considérées si version 'TOA'
Coef_SMAC=[];
if strcmp(Def_Base.Toc_Toa,'Toa')
    for iband=1:Nb_Bandes % boucle sur les bandes
        Coef_SMAC=cat(2,Coef_SMAC,Def_Base.Sensi_Capteur.(Band_Name{iband}).Smac.Cont);
    end
end

%% initialisations des Input
Input.Rho_Toc=zeros(Nb_Sims,Nb_Bandes);
if strcmp(Def_Base.Toc_Toa,'Toa')
    Input.Rho_Toa=zeros(Nb_Sims,Nb_Bandes);
end
% les Output
for i=1:size(Var_Name,1)
    if ~strcmp(Var_Name{i},'Multi')
        Output.(Var_Name{i})=zeros(Nb_Sims,1);
    end
end

%% SIMULATIONS
% h=waitbar(0,'Simulating reflectances,...');
Rho_Toc = zeros(Nb_Sims,Nb_Bandes);
if strcmp(Def_Base.Toc_Toa,'Toa')
    Rho_Toa = zeros(Nb_Sims,Nb_Bandes);
end
FCOVER = zeros(Nb_Sims,1);
FAPAR = zeros(Nb_Sims,1);
Albedo = zeros(Nb_Sims,1);
D = zeros(Nb_Sims,1);
% switch between toa or toc , mainly the same code but done to avoid if
% statements in parallel code
if (Debug) 
    disp(['Simulating ' num2str(Nb_Sims) ' cases for Class ' num2str(Class)])
end
if strcmp(Def_Base.Toc_Toa,'Toa')
   for isim=1:Nb_Sims % boucle sur les simulations
            if strcmp(Def_Base.RTM,'sail3')
                
        %  propriétés des feuilles et du sol
        Ktot = (Coef_Spe(:,4)*Law.Cab(isim) + Coef_Spe(:,5)*Law.Cw(isim) ...
            + Coef_Spe(:,3)*Law.Cdm(isim) + Coef_Spe(:,6)*Law.Cbp(isim))./Law.N(isim);
        RT = noyau(Coef_Spe(:,2),Law.N(isim),Ktot,tav(59.*pi/180,Coef_Spe(:,2))); % reflectance et transmittance des feuilles
        Rs = repmat(Law.Bs(isim)*Def_Base.(['Class_' num2str(Class)]).R_Soil.Refl(51:2051,Law.I_Soil(isim)),1,4); %  Réflectance du sol dans le cas lambertien
        
        %  Reflectance top of canopy
        R=sail3(Law.LAI(isim),Law.ALA(isim),Law.HsD(isim),Law.Crown_Cover(isim),RT(:,1),RT(:,2),Rs,Law.View_Zenith(isim),Law.Sun_Zenith(isim),Law.Rel_Azimuth(isim));
        
        % D
        Dsail3=sail3(Law.LAI(isim),Law.ALA(isim),Law.HsD(isim),Law.Crown_Cover(isim),RT(400,1)/(RT(400,1)+RT(400,2)),RT(400,2)/(RT(400,1)+RT(400,2))-1e-4,Rs(400,:),Law.View_Zenith(isim),Law.Sun_Zenith(isim),Law.Rel_Azimuth(isim));
        D(isim,1) = Dsail3(1);
        
         %  Intégration spectrale en prenant en compte la sensibilité spectrale de chaque bande
        Rho_Toc(isim,:)= R(:,1)' * Sensi;
        
        %  Réflectance Toa  
        Rho_Toa(isim,:) = smac_toc2toa(Coef_SMAC,Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),Law.Tau550(isim),Law.H2O(isim),Law.O3(isim),Law.P(isim),Rho_Toc(isim,:));
        
        %  fCover
        % old version (bug due to missing brackets scaling crown cover
        FCOVER(isim,1) =Law.Crown_Cover(isim).*1-exp(-kellips(Law.ALA(isim),0).*Law.LAI(isim));
        % new version Richard Fernandes April 2019
        FCOVER(isim,1) =Law.Crown_Cover(isim).*(1-exp(-kellips(Law.ALA(isim),0).*Law.LAI(isim)));
        
        %  fAPAR (black-sky à 10h)
        A=sail3(Law.LAI(isim),Law.ALA(isim),Law.HsD(isim),Law.Crown_Cover(isim),RT(:,1),RT(:,2),Rs,0,Law.Sun_Zenith_FAPAR(isim),0);
        Ecl=Sol_Irr(:,round(Law.Sun_Zenith(isim)./5)+1);
        FAPAR(isim,1)  = sum(A(1:300,5).*Ecl(1:300))./sum(Ecl(1:300)); % valeur intégrée entre 400 et 700 nm
        
        %   Albedo (black-sky pour la direction de visée du satellite)
        Albedo(isim,1) = sum(R(:,3).*Ecl)/sum(Ecl); % intégration spectrale
             
            elseif strcmp(Def_Base.RTM,'FLIGHT1D')

                        %  propriétés des feuilles et du sol
                                Car = Law.Cab(isim)/4;
        Ant = 0;
        Rs = repmat(Law.Bs(isim)*Def_Base.R_Soil.Refl(51:2051,Law.I_Soil(isim)),1,4); %  Réflectance du sol dans le cas lambertien

                % LAD type for now based on mean LAD only
        LIDFb = 1;
        
        % point to flight directories and makre a temporary targetdir
                templatedir = '.\code\FLIGHTREVERSE';
        targetdirmaster = '.\code\FLIGHTTARGET1';
                targetdir = [targetdirmaster,num2str(isim)];
             mkdir([targetdir]);
                 system(['xcopy ',templatedir,' ',targetdir,'  /e /q']);
    
        %  Reflectance top of canopy done in three stages due to FLIGHT
         [ R((400:600)-399,:) D(isim,1) ] = doflightr1d(targetdir,400:600,lambdaref,Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),LIDFb,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),[Def_Base.R_Soil.Lambda(51:2051) Rs(:,1)])
        [ R((1001:1600)-399,:) x ] = doflightr1d(targetdir,1001:1600,1600,Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),LIDFb,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),[Def_Base.R_Soil.Lambda(51:2051) Rs(:,1)]);
        [ R((1601:2200)-399,:) x ] = doflightr1d(targetdir,1601:2200,2200,Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),LIDFb,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),[Def_Base.R_Soil.Lambda(51:2051) Rs(:,1)]);
          
        
         %  Intégration spectrale en prenant en compte la sensibilité spectrale de chaque bande
        Rho_Toc(isim,:)= R(:,1)' * Sensi;
        
        %  Réflectance Toa  
        Rho_Toa(isim,:) = smac_toc2toa(Coef_SMAC,Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),Law.Tau550(isim),Law.H2O(isim),Law.O3(isim),Law.P(isim),Rho_Toc(isim,:));
        
        %  fCover
        % old version (bug due to missing brackets scaling crown cover
        FCOVER(isim,1) =Law.Crown_Cover(isim).*1-exp(-kellips(Law.ALA(isim),0).*Law.LAI(isim));
        % new version Richard Fernandes April 2019
        FCOVER(isim,1) =Law.Crown_Cover(isim).*(1-exp(-kellips(Law.ALA(isim),0).*Law.LAI(isim)));
        
        %  fAPAR (black-sky à 10h)
        [ A((400:700)-399,:) x ] = doflightr1d(targetdir,400:700,700,Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),LIDFb,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith_FAPAR(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),[Def_Base.R_Soil.Lambda(51:2051) Rs(:,1)]);
        Ecl=Sol_Irr(:,round(Law.Sun_Zenith(isim)./5)+1);
        FAPAR(isim,1)  = sum(A(1:300,5).*Ecl(1:300))./sum(Ecl(1:300)); % valeur intégrée entre 400 et 700 nm
        
        %   Albedo (black-sky pour la direction de visée du satellite)
        Albedo(isim,1) = sum(R(:,3).*Ecl)/sum(Ecl); % intégration spectrale

        % clean up temporary directories
                delete([targetdir,'\*.*']);
        delete([targetdir,'\DATA\*.*']);
        delete([targetdir,'\SPEC\*.*']);
        
            elseif strcmp(Def_Base.RTM,'FLIGHT')
                
                                        %  propriétés des feuilles et du sol
                                Car = Law.Cab(isim)/4;
        Ant = 0;
        Rs = repmat(Law.Bs(isim)*Def_Base.R_Soil.Refl(51:2051,Law.I_Soil(isim)),1,4); %  Réflectance du sol dans le cas lambertien

                % LAD type for now based on mean LAD only
        LIDFb = 1;
        
        % point to flight directories and makre a temporary targetdir
                templatedir = '.\code\FLIGHTREVERSE';
        targetdirmaster = '.\code\FLIGHTTARGET1';
                targetdir = [targetdirmaster,num2str(isim)];
             mkdir([targetdir]);
                 system(['xcopy ',templatedir,' ',targetdir,'  /e /q']);
    
        %  Reflectance top of canopy done in three stages due to FLIGHT
       [ R((400:1000)-399,:) D(isim,1) ] = doflightr(targetdir,400:1000,lambdaref,Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),LIDFb,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),[Def_Base.R_Soil.Lambda(51:2051) Rs(:,1)])
        [ R((1001:1600)-399,:) x ] = doflightr(targetdir,1001:1600,1600,Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),LIDFb,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),[Def_Base.R_Soil.Lambda(51:2051) Rs(:,1)]);
        [ R((1601:2200)-399,:) x ] = doflightr(targetdir,1601:2200,2200,Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),LIDFb,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),[Def_Base.R_Soil.Lambda(51:2051) Rs(:,1)]);
          
        
         %  Intégration spectrale en prenant en compte la sensibilité spectrale de chaque bande
        Rho_Toc(isim,:)= R(:,1)' * Sensi;
        
        %  Réflectance Toa  
        Rho_Toa(isim,:) = smac_toc2toa(Coef_SMAC,Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),Law.Tau550(isim),Law.H2O(isim),Law.O3(isim),Law.P(isim),Rho_Toc(isim,:));
        
        %  fCover
        % old version (bug due to missing brackets scaling crown cover
        FCOVER(isim,1) =Law.Crown_Cover(isim).*1-exp(-kellips(Law.ALA(isim),0).*Law.LAI(isim));
        % new version Richard Fernandes April 2019
        FCOVER(isim,1) =Law.Crown_Cover(isim).*(1-exp(-kellips(Law.ALA(isim),0).*Law.LAI(isim)));
        
        %  fAPAR (black-sky à 10h)
        [ A((400:700)-399,:) x ] = doflightr(targetdir,400:700,700,Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),LIDFb,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith_FAPAR(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),[Def_Base.R_Soil.Lambda(51:2051) Rs(:,1)]);
        Ecl=Sol_Irr(:,round(Law.Sun_Zenith(isim)./5)+1);
        FAPAR(isim,1)  = sum(A(1:300,5).*Ecl(1:300))./sum(Ecl(1:300)); % valeur intégrée entre 400 et 700 nm
        
        %   Albedo (black-sky pour la direction de visée du satellite)
        Albedo(isim,1) = sum(R(:,3).*Ecl)/sum(Ecl); % intégration spectrale

        % clean up temporary directories
                delete([targetdir,'\*.*']);
        delete([targetdir,'\DATA\*.*']);
        delete([targetdir,'\SPEC\*.*']);
                
            else % PROSAIL assumed
         %  propriétés des feuilles et du sol
        Rs = repmat(Law.Bs(isim)*Def_Base.R_Soil.Refl(51:2051,Law.I_Soil(isim)),1,4); %  Réflectance du sol dans le cas lambertien
        Car = Law.Cab(isim)/4;
        Ant = 0;
        
        %  Reflectance top of canopy
        R=PRO4SAIL(Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),0,2,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),Rs);
        
        % D
        RsD = Rs(lambdaref-400,:);
        Dest=PRO4SAILD(lambdaref,Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),0,2,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),[Def_Base.R_Soil.Lambda(51:2051) Def_Base.R_Soil.Refl(51:2051,1)]);
        D(isim,1) = Dest(1);
        
         %  Intégration spectrale en prenant en compte la sensibilité spectrale de chaque bande
        Rho_Toc(isim,:)= R(:,1)' * Sensi;
        
        %  Réflectance Toa  
        Rho_Toa(isim,:) = smac_toc2toa(Coef_SMAC,Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),Law.Tau550(isim),Law.H2O(isim),Law.O3(isim),Law.P(isim),Rho_Toc(isim,:));
        
        %  fCover
        % old version (bug due to missing brackets scaling crown cover
        FCOVER(isim,1) =Law.Crown_Cover(isim).*1-exp(-kellips(Law.ALA(isim),0).*Law.LAI(isim));
        % new version Richard Fernandes April 2019
        FCOVER(isim,1) =Law.Crown_Cover(isim).*(1-exp(-kellips(Law.ALA(isim),0).*Law.LAI(isim)));
        
        %  fAPAR (black-sky à 10h)
        A=PRO4SAIL(Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),0,2,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith_FAPAR(isim),0,0,Rs);
        Ecl=Sol_Irr(:,round(Law.Sun_Zenith(isim)./5)+1);
        FAPAR(isim,1)  = sum(A(1:300,5).*Ecl(1:300))./sum(Ecl(1:300)); % valeur intégrée entre 400 et 700 nm
        
        %   Albedo (black-sky pour la direction de visée du satellite)
        Albedo(isim,1) = sum(R(:,3).*Ecl)/sum(Ecl); % intégration spectrale               
            end
        
    end % fin boucle isim
else
    
    parfor isim=1:Nb_Sims % boucle sur les simulations
        
        %  propriétés des feuilles et du sol
        Ktot = (Coef_Spe(:,4)*Law.Cab(isim) + Coef_Spe(:,5)*Law.Cw(isim) ...
            + Coef_Spe(:,3)*Law.Cdm(isim) + Coef_Spe(:,6)*Law.Cbp(isim))./Law.N(isim);
        RT = noyau(Coef_Spe(:,2),Law.N(isim),Ktot,tav(59.*pi/180,Coef_Spe(:,2))); % reflectance et transmittance des feuilles
        Rs = repmat(Law.Bs(isim)*Def_Base.(['Class_' num2str(Class)]).R_Soil.Refl(51:2051,Law.I_Soil(isim)),1,4); %  Réflectance du sol dans le cas lambertien
        
        %  Reflectance top of canopy
        R=sail3(Law.LAI(isim),Law.ALA(isim),Law.HsD(isim),Law.Crown_Cover(isim),RT(:,1),RT(:,2),Rs,Law.View_Zenith(isim),Law.Sun_Zenith(isim),Law.Rel_Azimuth(isim));
        
        % D
        Dsail3=sail3(Law.LAI(isim),Law.ALA(isim),Law.HsD(isim),Law.Crown_Cover(isim),RT(400,1)/(RT(400,1)+RT(400,2)),RT(400,2)/(RT(400,1)+RT(400,2))-1e-4,Rs(400,:),Law.View_Zenith(isim),Law.Sun_Zenith(isim),Law.Rel_Azimuth(isim));
        D(isim,1) = Dsail3(1);
        
        %  Intégration spectrale en prenant en compte la sensibilité spectrale de chaque bande
        Rho_Toc(isim,:)= R(:,1)' * Sensi;
       
        %  fCover
        % old version (bug due to missing brackets scaling crown cover
        FCOVER(isim,1) =Law.Crown_Cover(isim).*1-exp(-kellips(Law.ALA(isim),0).*Law.LAI(isim));
        % new version Richard Fernandes April 2019
        FCOVER(isim,1) =Law.Crown_Cover(isim).*(1-exp(-kellips(Law.ALA(isim),0).*Law.LAI(isim)));
        
        %  fAPAR (black-sky à 10h)
        A=sail3(Law.LAI(isim),Law.ALA(isim),Law.HsD(isim),Law.Crown_Cover(isim),RT(:,1),RT(:,2),Rs,0,Law.Sun_Zenith_FAPAR(isim),0);
        Ecl=Sol_Irr(:,round(Law.Sun_Zenith(isim)./5)+1);
        FAPAR(isim,1)  = sum(A(1:300,5).*Ecl(1:300))./sum(Ecl(1:300)); % valeur intégrée entre 400 et 700 nm
        
        %   Albedo (black-sky pour la direction de visée du satellite)
        Albedo(isim,1) = sum(R(:,3).*Ecl)/sum(Ecl); % intégration spectrale
        
    end % fin boucle isim
end

Input.Rho_Toc = Rho_Toc;
if strcmp(Def_Base.Toc_Toa,'Toa')
    Input.Rho_Toa = Rho_Toa;
end
Output.FCOVER = FCOVER;
Output.FAPAR = FAPAR;
Output.Albedo = Albedo;
Output.D = D;
% Output.T = T;
%% Les autres Outputs
Output.LAI=Law.LAI;
for ivar=4:length(Var_Name) % boucle sur les variables de sortie
    if ( ~strcmp(Var_Name{ivar},'D') && ~strcmp(Var_Name{ivar},'T') && ~strcmp(Var_Name{ivar},'Albedo'))
        I=strfind(Var_Name{ivar},'_'); % indice du symbole de composition
        if isempty(I) % cas des variables simples
            Output.(Var_Name{ivar})=Law.(Var_Name{ivar});
        else % cas des variables composées
            Output.(Var_Name{ivar})=Law.(Var_Name{ivar}(1:I-1)).*Law.(Var_Name{ivar}(I+1:length(Var_Name{ivar})));
        end
    end
end % fin boucle ivar
% close(h)

%% ajout du cosinus des directions du soleil et de visée en entrée
Def_Base.Angles{1} = 'View_Zenith';
Def_Base.Angles{2} = 'Sun_Zenith';
Def_Base.Angles{3} = 'Rel_Azimuth';
if ~isempty(Def_Base.Angles)
    Input.Angles=[];
    for iang=1:size(Def_Base.Angles,1) %
        Input.Angles = cat(2,Input.Angles,cos(Law.(Def_Base.Angles{iang})));
        Def_Base.Angles{iang}=['cos(' Def_Base.Angles{iang} ')'];
    end
end


return
