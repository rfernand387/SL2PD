function [Def_Base, Input, Output]=Create_Input_Output_D(Def_Base, Law, Class,Debug)
%% Cr�ation de la base des entr�es et sorties du RT
% Simulations GEOSAIL+SMAC (si RhoTOA)
% Marie et Fred 03/01/2006
% Modif Fred Septembre 2007
% Modif Fred Septembre 2009
% Richard July 2019

%% Initialisations
Nb_Sims = size(Law.LAI,1); % Nombre de simulations
Band_Name=fieldnames(Def_Base.Sensi_Capteur);% r�cup�ration des noms des bandes du capteur
Nb_Bandes = size(Band_Name,1); % nombre de bandes utilis�es
Var_Name = Def_Base.Var_out; % les variables � estimer
Law.Rel_Azimuth=Law.Sun_Azimuth-Law.View_Azimuth; % Azimuth relatif
Coef_Spe = coefspe; % chargement des coefs specifiques de PROSPECT
Sol_Irr=irradiance(0:5:75,400:2400,0.23,0.25); % la LUT pour l'�clairement solaire entre 0� et 75�
Law.Cw=Law.Cdm./(1-Law.Cw_Rel); % on cr�� la variable Cw

%% cluster laws to identify blocks of input for training
if (Debug)
    disp(['Clustering laws for Class ' num2str(Class)])
end

% Clustering in block of 50,000 samples sorted by LAI, 
% defaulted as all unique but target is clusters of 100 sims each
[temp sortindex] = sort(Law.LAI);
Input.Cats = 1:length(sortindex);
for block = 1:50000:length(sortindex)
    blockdata = sortindex(block:min(length(sortindex),(block+50000-1)));
    nclus = ceil(length(blockdata)/100);
abc = (([ Law.ALA(blockdata) Law.Cab(blockdata) Law.N(blockdata) Law.Cdm(blockdata) Law.Cw_Rel(blockdata) Law.Bs(blockdata)])');
stream = RandStream('mlfg6331_64');  % Random number stream
options = statset('UseParallel',1,'UseSubstreams',1,'Streams',stream);
Input.Cats(blockdata) = block + kmeans(abc',nclus, 'Distance','cityblock','Replicates',5,'MaxIter',1000,'Options',options  , 'Display','final');
end
Input.Cats =  Input.Cats';


%% Calcul des sensibilit�s spectrales �tendues et r�-�chantillonn�es pour chaque bande
Sensi=zeros(length(400:2400),Nb_Bandes);
for i_band=1:Nb_Bandes
    Sensi(:,i_band)=interp1([100; Def_Base.Sensi_Capteur.(Band_Name{i_band}).Lambda; 5000], ...
        [0; Def_Base.Sensi_Capteur.(Band_Name{i_band}).Sensi; 0], (400:2400)');
    Sensi(:,i_band)=Sensi(:,i_band)./sum(Sensi(:,i_band)); % normalisation des sensibilit�s
end


%% On g�n�re aussi le fichier Coef_SMAC des coefficients SMAC pour les bandes consid�r�es si version 'TOA'
Coef_SMAC=[];
%if strcmp(Def_Base.Toc_Toa,'Toa')
    for iband=1:Nb_Bandes % boucle sur les bandes
        Coef_SMAC=cat(2,Coef_SMAC,Def_Base.Sensi_Capteur.(Band_Name{iband}).Smac.Cont);
    end
%end

%% initialisations des Input
Input.Rho_Toc=zeros(Nb_Sims,Nb_Bandes);
%if strcmp(Def_Base.Toc_Toa,'Toa')
Input.Rho_Toa=zeros(Nb_Sims,Nb_Bandes);
%end
% les Output
for i=1:size(Var_Name,1)
    if ~strcmp(Var_Name{i},'Multi')
        Output.(Var_Name{i})=zeros(Nb_Sims,1);
    end
end

%% SIMULATIONS
% h=waitbar(0,'Simulating reflectances,...');
Rho_Toc = zeros(Nb_Sims,Nb_Bandes);
%if strcmp(Def_Base.Toc_Toa,'Toa')
    Rho_Toa = zeros(Nb_Sims,Nb_Bandes);
%end
FCOVER = zeros(Nb_Sims,1);
FAPAR = zeros(Nb_Sims,1);
Albedo = zeros(Nb_Sims,1);
D = zeros(Nb_Sims,1);
% switch between toa or toc , mainly the same code but done to avoid if
% statements in parallel code
if (Debug)
    disp(['Simulating ' num2str(Nb_Sims) ' cases for Class ' num2str(Class)])
end
lambdaref = 799;
parfor isim=1:Nb_Sims % boucle sur les simulations
    if strcmp(Def_Base.RTM,'sail3')
        
        %  propri�t�s des feuilles et du sol
        Ktot = (Coef_Spe(:,4)*Law.Cab(isim) + Coef_Spe(:,5)*Law.Cw(isim) ...
            + Coef_Spe(:,3)*Law.Cdm(isim) + Coef_Spe(:,6)*Law.Cbp(isim))./Law.N(isim);
        RT = noyau(Coef_Spe(:,2),Law.N(isim),Ktot,tav(59.*pi/180,Coef_Spe(:,2))); % reflectance et transmittance des feuilles
        Rs = repmat(Law.Bs(isim)*Def_Base.(['Class_' num2str(Class)]).R_Soil.Refl(51:2051,Law.I_Soil(isim)),1,4); %  R�flectance du sol dans le cas lambertien
        
        %  Reflectance top of canopy
        R=sail3(Law.LAI(isim),Law.ALA(isim),Law.HsD(isim),Law.Crown_Cover(isim),RT(:,1),RT(:,2),Rs,Law.View_Zenith(isim),Law.Sun_Zenith(isim),Law.Rel_Azimuth(isim));
        
        % D
        Dsail3=sail3(Law.LAI(isim),Law.ALA(isim),Law.HsD(isim),Law.Crown_Cover(isim),RT(400,1)/(RT(400,1)+RT(400,2)),RT(400,2)/(RT(400,1)+RT(400,2))-1e-4,Rs(400,:),Law.View_Zenith(isim),Law.Sun_Zenith(isim),Law.Rel_Azimuth(isim));
        D(isim,1) = Dsail3(1);
        
        %  Int�gration spectrale en prenant en compte la sensibilit� spectrale de chaque bande
        Rho_Toc(isim,:)= R(:,1)' * Sensi;
        
        %  R�flectance Toa
        %if strcmp(Def_Base.Toc_Toa,'Toa')
            Rho_Toa(isim,:) = smac_toc2toa(Coef_SMAC,Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),Law.Tau550(isim),Law.H2O(isim),Law.O3(isim),Law.P(isim),Rho_Toc(isim,:));
        %end
        
        %  fCover
        % old version (bug due to missing brackets scaling crown cover
        FCOVER(isim,1) =Law.Crown_Cover(isim).*1-exp(-kellips(Law.ALA(isim),0).*Law.LAI(isim));
        % new version Richard Fernandes April 2019
        FCOVER(isim,1) =Law.Crown_Cover(isim).*(1-exp(-kellips(Law.ALA(isim),0).*Law.LAI(isim)));
        
        %  fAPAR (black-sky � 10h)
        A=sail3(Law.LAI(isim),Law.ALA(isim),Law.HsD(isim),Law.Crown_Cover(isim),RT(:,1),RT(:,2),Rs,0,Law.Sun_Zenith_FAPAR(isim),0);
        Ecl=Sol_Irr(:,round(Law.Sun_Zenith(isim)./5)+1);
        FAPAR(isim,1)  = sum(A(1:300,5).*Ecl(1:300))./sum(Ecl(1:300)); % valeur int�gr�e entre 400 et 700 nm
        
        %   Albedo (black-sky pour la direction de vis�e du satellite)
        Albedo(isim,1) = sum(R(:,3).*Ecl)/sum(Ecl); % int�gration spectrale
        
    elseif strcmp(Def_Base.RTM,'flight1d')
        
        %  propri�t�s des feuilles et du sol
        Car = Law.Cab(isim)/4;
        Ant = 0;
        Rs = repmat(Law.Bs(isim)*Def_Base.(['Class_' num2str(Class)]).R_Soil.Refl(51:2051,Law.I_Soil(isim)),1,4); %  R�flectance du sol dans le cas lambertien
                % LAD type for now based on mean LAD only
        LIDFb = 1;
        
        % point to flight directories and makre a temporary targetdir
        templatedir = '.\code\FLIGHTREVERSE';
        targetdirmaster = '.\code\FLIGHTTARGET0';
        targetdir = [targetdirmaster,num2str(isim)];
        mkdir([targetdir]);
        system(['xcopy ',templatedir,' ',targetdir,'  /e /q']);
        
        %  Reflectance top of canopy done in three stages due to FLIGHT
        [ R((400:600)-399,:) D(isim,1) ] = doflightr1d(targetdir,400:600,lambdaref,Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),LIDFb,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),[Def_Base.(['Class_' num2str(Class)]).R_Soil.Lambda(51:2051) Rs(:,1)])
        [ R((1001:1600)-399,:) x ] = doflightr1d(targetdir,1001:1600,1600,Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),LIDFb,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),[Def_Base.(['Class_' num2str(Class)]).R_Soil.Lambda(51:2051) Rs(:,1)]);
        [ R((1601:2200)-399,:) x ] = doflightr1d(targetdir,1601:2200,2200,Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),LIDFb,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),[Def_Base.(['Class_' num2str(Class)]).R_Soil.Lambda(51:2051) Rs(:,1)]);
        
        % For fAPAR
        
        
        %  Int�gration spectrale en prenant en compte la sensibilit� spectrale de chaque bande
        Rho_Toc(isim,:)= R(:,1)' * Sensi;
        
        %  R�flectance Toa
        %if strcmp(Def_Base.Toc_Toa,'Toa')
            Rho_Toa(isim,:) = smac_toc2toa(Coef_SMAC,Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),Law.Tau550(isim),Law.H2O(isim),Law.O3(isim),Law.P(isim),Rho_Toc(isim,:));
        %end
        
        %  fCover
        % old version (bug due to missing brackets scaling crown cover
        FCOVER(isim,1) =Law.Crown_Cover(isim).*1-exp(-kellips(Law.ALA(isim),0).*Law.LAI(isim));
        % new version Richard Fernandes April 2019
        FCOVER(isim,1) =Law.Crown_Cover(isim).*(1-exp(-kellips(Law.ALA(isim),0).*Law.LAI(isim)));
        
        %  fAPAR (black-sky � 10h)
        [ A((400:700)-399,:) x ] = doflightr1d(targetdir,400:700,700,Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),LIDFb,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith_FAPAR(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),[Def_Base.(['Class_' num2str(Class)]).R_Soil.Lambda(51:2051) Rs(:,1)]);
        Ecl=Sol_Irr(:,round(Law.Sun_Zenith(isim)./5)+1);
        FAPAR(isim,1)  = sum(A(1:300,5).*Ecl(1:300))./sum(Ecl(1:300)); % valeur int�gr�e entre 400 et 700 nm
        
        %   Albedo (black-sky pour la direction de vis�e du satellite)
        Albedo(isim,1) = sum(R(:,3).*Ecl)/sum(Ecl); % int�gration spectrale
        
        % clean up temporary directories
        delete([targetdir,'\*.*']);
        delete([targetdir,'\DATA\*.*']);
        delete([targetdir,'\SPEC\*.*']);
        
    elseif strcmp(Def_Base.RTM,'flight')
        
        %  propri�t�s des feuilles et du sol
        Car = Law.Cab(isim)/4;
        Ant = 0;
        Rs = repmat(Law.Bs(isim)*Def_Base.(['Class_' num2str(Class)]).R_Soil.Refl(51:2051,Law.I_Soil(isim)),1,4); %  R�flectance du sol dans le cas lambertien
                % LAD type for now based on mean LAD only
        LIDFb = 1;
        
        % point to flight directories and makre a temporary targetdir
        templatedir = '.\code\FLIGHTFORWARD3D';
        targetdirmaster = '.\code\FLIGHTTARGET30';
        targetdir = [targetdirmaster,num2str(isim)];
        mkdir([targetdir]);
        system(['xcopy ',templatedir,' ',targetdir,'  /e /q']);
        
        %  Reflectance top of canopy done in  stages due to FLIGHT
        [ R((400:999)-399,:) D(isim,1) ] = doflight(targetdir,400:999,lambdaref,Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),LIDFb,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),[Def_Base.(['Class_' num2str(Class)]).R_Soil.Lambda(51:2051) Rs(:,1)])
        A = R((400:699)-399,5);
        [ R((1000:1599)-399,:) x ] = doflight(targetdir,1000:1599,lambdaref,Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),LIDFb,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),[Def_Base.(['Class_' num2str(Class)]).R_Soil.Lambda(51:2051) Rs(:,1)]);
        [ R((1600:2199)-399,:) x ] = doflight(targetdir,1600:2199,lambdaref,Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),LIDFb,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),[Def_Base.(['Class_' num2str(Class)]).R_Soil.Lambda(51:2051) Rs(:,1)]);
        [ R((1801:2400)-399,:) x ] = doflight(targetdir,1801:2400,lambdaref,Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),LIDFb,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),[Def_Base.(['Class_' num2str(Class)]).R_Soil.Lambda(51:2051) Rs(:,1)]);
       
        % For fAPAR
        
        
        %  Int�gration spectrale en prenant en compte la sensibilit� spectrale de chaque bande
        Rho_Toc(isim,:)= R(:,1)' * Sensi;
        
        %  R�flectance Toa
        %if strcmp(Def_Base.Toc_Toa,'Toa')
            Rho_Toa(isim,:) = smac_toc2toa(Coef_SMAC,Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),Law.Tau550(isim),Law.H2O(isim),Law.O3(isim),Law.P(isim),Rho_Toc(isim,:));
        %end
        
        %  fCover
        % old version (bug due to missing brackets scaling crown cover
        FCOVER(isim,1) =Law.Crown_Cover(isim).*1-exp(-kellips(Law.ALA(isim),0).*Law.LAI(isim));
        % new version Richard Fernandes April 2019
        FCOVER(isim,1) =Law.Crown_Cover(isim).*(1-exp(-kellips(Law.ALA(isim),0).*Law.LAI(isim)));
        
        %  fAPAR (black-sky � 10h)
        Ecl=Sol_Irr(:,round(Law.Sun_Zenith(isim)./5)+1);
        FAPAR(isim,1)  = sum(A.*Ecl(1:300))./sum(Ecl(1:300)); % valeur int�gr�e entre 400 et 700 nm
        
        %   Albedo (black-sky pour la direction de vis�e du satellite)
        Albedo(isim,1) = sum(R(:,3).*Ecl)/sum(Ecl); % int�gration spectrale
        
        % clean up temporary directories
        try {
                rmdir(targetdir,'s')
                }
        catch
            disp([targetdir ' could not be removed ']);
        end
    else % PROSAIL assumed
        %  propri�t�s des feuilles et du sol
        Rs = repmat(Law.Bs(isim)*Def_Base.(['Class_' num2str(Class)]).R_Soil.Refl(51:2051,Law.I_Soil(isim)),1,4); %  R�flectance du sol dans le cas lambertien
        Car = Law.Cab(isim)/4;
        Ant = 0;
        
        %  Reflectance top of canopy
        R=PRO4SAIL(Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),0,2,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),Rs);
        
        % D
        RsD = Rs(lambdaref-400,:)*0;
        Dest=PRO4SAILD(lambdaref,Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),0,2,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),Rs);
        D(isim,1) = Dest(1);
        
        %  Int�gration spectrale en prenant en compte la sensibilit� spectrale de chaque bande
        Rho_Toc(isim,:)= R(:,1)' * Sensi;
        
        %  R�flectance Toa
        %if strcmp(Def_Base.Toc_Toa,'Toa')
            Rho_Toa(isim,:) = smac_toc2toa(Coef_SMAC,Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),Law.Tau550(isim),Law.H2O(isim),Law.O3(isim),Law.P(isim),Rho_Toc(isim,:));
        %end
        
        %  fCover
        % old version (bug due to missing brackets scaling crown cover
        FCOVER(isim,1) =Law.Crown_Cover(isim).*1-exp(-kellips(Law.ALA(isim),0).*Law.LAI(isim));
        % new version Richard Fernandes April 2019
        FCOVER(isim,1) =Law.Crown_Cover(isim).*(1-exp(-kellips(Law.ALA(isim),0).*Law.LAI(isim)));
        
        %  fAPAR (black-sky � 10h)
        A=PRO4SAIL(Law.N(isim),Law.Cab(isim),Car,Ant,Law.Cbp(isim),Law.Cw(isim),Law.Cdm(isim),Law.ALA(isim),0,2,Law.LAI(isim),Law.HsD(isim),Law.Crown_Cover(isim),Law.Sun_Zenith_FAPAR(isim),0,0,Rs);
        Ecl=Sol_Irr(:,round(Law.Sun_Zenith(isim)./5)+1);
        FAPAR(isim,1)  = sum(A(1:300,5).*Ecl(1:300))./sum(Ecl(1:300)); % valeur int�gr�e entre 400 et 700 nm
        
        %   Albedo (black-sky pour la direction de vis�e du satellite)
        Albedo(isim,1) = sum(R(:,3).*Ecl)/sum(Ecl); % int�gration spectrale
    end
    
end % fin boucle isim


Input.Rho_Toc = Rho_Toc;
%if strcmp(Def_Base.Toc_Toa,'Toa')
    Input.Rho_Toa = Rho_Toa;
%end
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
        else % cas des variables compos�es
            Output.(Var_Name{ivar})=Law.(Var_Name{ivar}(1:I-1)).*Law.(Var_Name{ivar}(I+1:length(Var_Name{ivar})));
        end
    end
end % fin boucle ivar
% close(h)

%% ajout du cosinus des directions du soleil et de vis�e en entr�e
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
