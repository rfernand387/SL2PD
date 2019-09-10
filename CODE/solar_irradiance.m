function [Input Output]=Create_Input_Output_Albedo(Def_Base, Law, NNT_Archi) 
% Création de la base des entrées et sorties du RT
% Simulations SAIL+SMAC (si RhoTOA)
% Marie et Fred 03/01/2006

% 
% Nb_Sims = size(Law.LAI,1); % Nombre de simulations
% Band_Name=fieldnames(Def_Base.Sensi_Capteur);% récupération des noms des bandes du capteur
% Nb_Bandes = size(Band_Name,1); % nombre de bandes utilisées
% Var_Out=fieldnames(NNT_Archi); % les variables à estimer

%% pour calcul éclairement
L0=0;
UMODEL=2;            %(user's model)
AEROMODEL=1;         %(Aerosols models)
L1=0;                %(Next value is AERO.OPT.thick .550um)
THICK=0.2347;           %(AerO.optical thick)
TARGETh=0;          %(target altitute in km)
SENSORh=-1000.0;
L2=-2;                %(user's Wlinf-Wlsup )
WLINF=0.400;         %(Wlinf_Wlsup)
WLSUP=2.400;
L3=0;                %(Homogeneous case)
L4=0;                %(Idirectionnal Effects )
L5=0;                %(next value is reflectance)
TARGETf=0.26;        %(target reflectance)
ENVIf=0.26;          %(environmental reflectance)
BRDF=-2;             %(No atmospheric correction for BRDF)



% %% Calcul des Coefs spec, de la réflectance du sol pour les longueurs d'onde du capteur en concatenant les bandes
% dum = coefspe; % chargement des coefs specifiques de PROSPECT
% Coef_Spe=[];
% 
% % réflectance du sol pour les bandes du capteur considéré
% R_Soil_Capteur = [];
% for iband=1:Nb_Bandes % boucle sur les bandes
%     Coef_Spe = cat(1,Coef_Spe,interp1(dum(:,1),dum,Def_Base.Sensi_Capteur.(Band_Name{iband}).Lambda));
%     R_Soil_Capteur = cat(1,R_Soil_Capteur,interp1(Def_Base.R_Soil.Lambda,Def_Base.R_Soil.Refl,Def_Base.Sensi_Capteur.(Band_Name{iband}).Lambda));
% end
% % réflectance du sol pour le spectre solaire
% R_Soil_Spectre = interp1(Def_Base.R_Soil.Lambda,Def_Base.R_Soil.Refl,400:2400);
% 
% % Calcul des Coefs spec et la réflectance du sol pour les longueurs d'onde du fAPAR en concatenant aussi aux bandes du capteur
% Lambda_fAPAR=[400:10:700]';
% Coef_Spe = cat(1,Coef_Spe,interp1(dum(:,1),dum,Lambda_fAPAR));
% R_Soil_Capteur = cat(1,R_Soil_Capteur,interp1(Def_Base.R_Soil.Lambda,Def_Base.R_Soil.Refl,Lambda_fAPAR));
% if min(Def_Base.R_Soil.Lambda)>400
%     warndlg('The provided soil spectra are not suitable for fAPAR computation, wavelength between 400 & 700nm are required')
% end
% clear dum
% % On génère aussi le fichier Coef_SMAC des coefficients SMAC pour les bandes considérées si version 'TOA'
% if strcmp(Def_Base.Toc_Toa,'Toa')
%     Coef_SMAC=[];
%     for iband=1:Nb_Bandes % boucle sur les bandes
%         Coef_SMAC=cat(2,Coef_SMAC,Def_Base.Sensi_Capteur.(Band_Name{iband}).Smac.Cont);
%     end
% end
% 
% %% %%%%%%%%%%%%%%%% SIMULATIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% h=waitbar(0,'Simulating reflectances,...');
% % initialisations des Input
%     Input.Rho_Toc=zeros(Nb_Sims,Nb_Bandes);
%     if strcmp(Def_Base.Toc_Toa,'Toa')
%         Input.Rho_Toa=zeros(Nb_Sims,Nb_Bandes);
%     end
%     % les Output
%     for i=1:size(Var_Out,1)
%         if ~strcmp(Var_Out{i},'Multi')
%             Output.(Var_Out{i})=zeros(Nb_Sims,1);
%         end
%     end
% 
% for isim=1:Nb_Sims
%     if mod(isim,1000)==0
%         waitbar(isim/Nb_Sims,h);
%     end
% 
%     % propriétés des feuilles
%     Ktot = (Coef_Spe(:,4)*Law.Cab(isim) + Coef_Spe(:,5)*(Law.Cdm(isim)*Law.Cw_Rel(isim)/(1-Law.Cw_Rel(isim))) ...
%         + Coef_Spe(:,3)*Law.Cdm(isim) + Coef_Spe(:,6)*Law.Cbp(isim))./Law.N(isim);
%     RT = noyau(Coef_Spe(:,2),Law.N(isim),Ktot,tav(59.*pi/180,Coef_Spe(:,2)));
%     % Réflectance du sol
%     Rs = Law.Bs(isim)*R_Soil_Capteur(:,Law.I_Soil(isim));
%     
%      % extraction des Lambda capteurs
%     RT_Cap=RT(1:size(RT,1)-length(Lambda_fAPAR),:);
%     Rs_Cap=Rs(1:size(Rs,1)-length(Lambda_fAPAR)); 
%     
%      % extraction des Lambda fAPAR
%     RT_fAPAR=RT(size(RT,1)-length(Lambda_fAPAR)+1:size(RT,1),:);
%     Rs_fAPAR=Rs(size(Rs,1)-length(Lambda_fAPAR)+1:size(Rs,1)); 
%     clear RT Rs
%     
%     % reflectance top of canopy pour les conditions de visée des NNT et les
%     % bandes du capteur considéré 
%     LAI_Veg=Law.LAI(isim)./Law.vCover(isim);
%     [RES dum fcov] = sail2(LAI_Veg,Law.ALA(isim),Law.HotS(isim),RT_Cap(:,1),RT_Cap(:,2),Rs_Cap,Rs_Cap,Rs_Cap,Law.View_Zenith(isim),Law.Sun_Zenith(isim),Law.Rel_Azimuth(isim),0);
%     R_Veg = Law.vCover(isim).*RES(:,1)+(1-Law.vCover(isim)).*Rs_Cap;
%     Rh_Veg = Law.vCover(isim).*dum+(1-Law.vCover(isim)).*Rs_Cap;
%     clear RES dum
%          
%     % intégration spectrale en prenant en compte la sensibilité spectrale de chaque bande
%     compt=0;
%     for iband=1:Nb_Bandes
%        Input.Rho_Toc(isim,iband)=sum(R_Veg(compt+1:compt+length(Def_Base.Sensi_Capteur.(Band_Name{iband}).Lambda)).*Def_Base.Sensi_Capteur.(Band_Name{iband}).Sensi)./sum(Def_Base.Sensi_Capteur.(Band_Name{iband}).Sensi);
%        Input.Rh_Toc(isim,iband)=sum(Rh_Veg(compt+1:compt+length(Def_Base.Sensi_Capteur.(Band_Name{iband}).Lambda)).*Def_Base.Sensi_Capteur.(Band_Name{iband}).Sensi)./sum(Def_Base.Sensi_Capteur.(Band_Name{iband}).Sensi);
%        compt=compt+length(Def_Base.Sensi_Capteur.(Band_Name{iband}).Lambda);
%     end
%     clear R_Veg Rh_Veg
%     
%     % calcul de l'albedo intégré sur le spectre
%     dum = coefspe; % chargement des coefs specifiques de PROSPECT
%     Ktot = (dum(:,4)*Law.Cab(isim) + dum(:,5)*(Law.Cdm(isim)*Law.Cw_Rel(isim)/(1-Law.Cw_Rel(isim))) ...
%         + dum(:,3)*Law.Cdm(isim) + dum(:,6)*Law.Cbp(isim))./Law.N(isim);
%     RT = noyau(dum(:,2),Law.N(isim),Ktot,tav(59.*pi/180,dum(:,2)));
%     RS_Spec = Law.Bs(isim)*R_Soil_Spectre(:,Law.I_Soil(isim));
%     clear  Ktot
%     [RES Rh dum1] = sail2(LAI_Veg,Law.ALA(isim),Law.HotS(isim),RT(:,1),RT(:,2),RS_Spec,RS_Spec,RS_Spec,Law.View_Zenith(isim),Law.Sun_Zenith(isim),Law.Rel_Azimuth(isim),0);
%     Rh=Law.vCover(isim).*Rh+(1-Law.vCover(isim)).*RS_Spec;
    
    %intégration spectrale
    % calcul de l'éclairement
    cd('.\CODE\Tools\')
    filename='6s.in';
    fid=fopen(filename,'w');
    fprintf(fid,'%d\n',L0);
%     fprintf(fid,'%5.2f %5.2f\n',Law.Sun_Zenith(isim)*180/pi,Law.Rel_Azimuth(isim)+Law.View_Azimuth(isim)*180/pi);
%     fprintf(fid,'%5.2f %5.2f\n',Law.View_Zenith(isim)*180/pi,Law.View_Azimuth(isim)*180/pi);
%     [yy mm dd]=datevec(Law.Dates(isim)+datenum(2002,12,31));
    fprintf(fid,'%5.2f %5.2f\n',30*180/pi,0);
    fprintf(fid,'%5.2f %5.2f\n',0,0);
    mm=7;
    dd=21;
    fprintf(fid,'%d %d\n',mm,dd);
    fprintf(fid,'%d\n',UMODEL);
    fprintf(fid,'%d\n',AEROMODEL);
    fprintf(fid,'%d\n',L1);
    fprintf(fid,'%5.3f\n',THICK);
    fprintf(fid,'%5.2f\n',TARGETh);
    fprintf(fid,'%5.2f\n',SENSORh);
    fprintf(fid,'%d\n',L2);
    fprintf(fid,'%5.3f %5.3f\n',WLINF,WLSUP);
    fprintf(fid,'%d\n',L3);
    fprintf(fid,'%d\n',L4);
    fprintf(fid,'%d\n',L5);
    fprintf(fid,'%5.3f\n',0.26);
    fprintf(fid,'%5.3f\n',0.25);
    fprintf(fid,'%d\n',BRDF);
    fclose(fid);
    %6s simulation
    prog_name=sprintf('!sixsv4 <6s.in >6s_whole.out');
    eval(prog_name);
    fid_6sout=fopen('6s_whole.out','r');
    x=fread(fid_6sout,'char');
    s=char(x');
    fclose(fid_6sout);
    cd('.\..\..\')
    ind1=findstr(s,'trans  down   up     albedo refl                                     *');
    ind2=findstr(s,' integrated values of  :');
    dum=s(ind1+length('trans  down   up     albedo refl                                     *'):ind2(1)-1);
    %Results generation
    dum=deblank(dum);
    s = regexprep(dum, '*', ' ') ;
    data=str2num(s);
    % Solar irradiance =
    SolIrr=(data(:,2).*data(:,3).*data(:,7).*data(:,10))';

    dum = coefspe; % chargement des coefs specifiques de PROSPECT
    Rh_int=interp1(dum(:,1),Rh,[400:2.5:2400]);
    Input.Albedo(isim) = sum(Rh_int.*SolIrr)/sum(SolIrr);
    clear dum dum1
    
    % Réflectance Toa
    if strcmp(Def_Base.Toc_Toa,'Toa')
        Input.Rho_Toa(isim,:) = smac_toc2toa(Coef_SMAC,Law.Sun_Zenith(isim),Law.View_Zenith(isim),Law.Rel_Azimuth(isim),Law.Tau550(isim),Law.H2O(isim),Law.O3(isim),Law.P(isim),Input.Rho_Toc(isim,:));
    end
    
    % fAPAR
    [RES dum] = sail2(LAI_Veg,Law.ALA(isim),Law.HotS(isim),RT_fAPAR(:,1),RT_fAPAR(:,2),Rs_fAPAR,Rs_fAPAR,Rs_fAPAR,0,Law.Sun_Zenith_FAPAR(isim),Law.Rel_Azimuth(isim),0);
    Output.FAPAR(isim,1)  = mean(Law.vCover(isim).*RES(:,2));
    % fCover
    Output.FCOVER(isim,1) = Law.vCover(isim).*fcov;
end

% Les Outputs
for i=1:size(Var_Out,1)
    switch Var_Out{i}
        case 'LAI'
            Output.LAI = Law.LAI;
        case 'ALA'
            Output.ALA = Law.ALA;
        case 'HotS'
            Output.HotS = Law.HotS;
        case 'N'
            Output.N = Law.N;
        case 'LAI_Cab'
            Output.LAI_Cab=Output.LAI.*Law.Cab;
        case 'Cab'
            Output.Cab = Law.Cab;
        case 'LAI_Cdm'
            Output.LAI_Cdm=Output.LAI.*Law.Cdm;
        case 'Cdm'
            Output.Cdm = Law.Cdm;
        case 'Cw_Rel'
            Output.Cw_Rel = Law.Cw_Rel;
        case 'LAI_Cbp'
            Output.LAI_Cbp=Output.LAI.*Law.Cbp;
        case 'Cbp'
            Output.Cbp = Law.Cbp;
        case 'Bs'
            Output.Bs = Law.Bs;
        case 'P'
            Output.P = Law.P;
        case 'Tau550'
            Output.Tau550 = Law.Tau550;
    end
end
    
% ajout des directions du soleil et de visée en entrée. Dépend de la configuration angulaire que l'on a choisie
if ~isempty(Def_Base.Angles)
    Input.Angles=[];
    for iang=1:size(Def_Base.Angles,1)
        if iang==3 ; % cas de l'azimuth relatif
            Input.Angles = cat(2,Input.Angles,cos(Law.(Def_Base.Angles{iang})));
        else
            Input.Angles = cat(2,Input.Angles,Law.(Def_Base.Angles{iang}));
        end
    end
end

close(h)


