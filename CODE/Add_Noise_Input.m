function Input_Noise=Add_Noise_Input(Def_Base,Input,Class)
%% Bruitage des reflectances
%
% INPUT
% Def_Base  :
% Input   : Les inputs
% OUTPUT
% Input_Noise : les memes Input, mais avec reflectances bruitées
%
% Fred Novembre 2009

%% Initialisations
Ref=['Rho_' Def_Base.Toc_Toa]; % choix Toc ou Toa
%Nb_Cas=length(Input.(Ref)); % Nombre de cas
Nb_Cas=size(Input.(Ref),1); % Nombre de cas
Nb_Band=size(Input.(Ref),2); % Nombre de bandes
Input_Noise.Cats = Input.Cats;
Input_Noise.Angles = Input.Angles;


%% Bruitage des valeurs de réflectance
AI_rand = randn(Nb_Cas,1).*Def_Base.Bruit_Bandes.AI; %Création de la matrice de bruit additif indépendant
MI_rand = randn(Nb_Cas,1).*Def_Base.Bruit_Bandes.MI./100; %Création de la matrice de bruit multiplicatif indépendant
for iband = 1:Nb_Band
    Input_Noise.(Ref)(:,iband)=Input.(Ref)(:,iband).*(1+MI_rand+randn(Nb_Cas,1).*Def_Base.Bruit_Bandes.MD(iband)./100) ...
        +AI_rand+randn(Nb_Cas,1).*Def_Base.Bruit_Bandes.AD(iband); % les réflectances bruitées
end


%% Le bruitage des réflectances
% figure
% set(gcf,'defaulttextinterpreter','none')
% gplotmatrixv2(Input.(Ref),Input_Noise.(Ref)-Input.(Ref),[],'k',[],[],'on','hist',reshape(Def_Base.Bandes_Utiles,length(Def_Base.Bandes_Utiles),1))
% print([Def_Base.Report_Dir '\Class_' num2str(Class) '\Learn_Data_Base\Noise_Reflectance'],'-dpng') 
% close(gcf)
