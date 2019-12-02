function [Law,Nb_Sims]=Create_Law_Var(Def_Base,Class,Soil,Law,Nb_Sims)
% create canopy and atmosphere parameter sampling laws
% Fred et Marie 01/08/2005
% Modif Fred Avril 2008
% Modif Marie septembre 2010: ajoût de la loi log normale, modification des
% contraintes sur les lois de co-distribution
% Richard July 2019

%% Initialisations
Var_Name=fieldnames(Def_Base.(['Class_' num2str(Class)]).Var_in); % nom des variables
Nb_Var=size(Var_Name,1); % nombre de variables


%% if we are dealing with TOA we separately sample the atmosphere first
%if strcmp( Def_Base.Toc_Toa , 'Toa')
    switch (Def_Base.(['Class_' num2str(Class)]).SamplingDesign)
        case {'LH'}
            h =  lhsdesign(Nb_Sims,4);
            h = h(randperm(Nb_Sims),:);
        case {'Sobel'}
            h = net(scramble(sobolset(4),'MatousekAffineOwen'),Nb_Sims);
        case {'Halton'}
            h = net(scramble(haltonset(4),'RR2'),Nb_Sims) ;
        case  {'FullOrthog'}
            for ivar = (Nb_Var-3):Nb_Var
                Nb_Class_Var(ivar-(Nb_Var-3)+1) = Def_Base.Class_1.Var_in.(Var_Name{ivar}).Nb_Classe;
            end
            h = (fullfact([Nb_Class_Var])-1 + rand(Nb_Sims,4)) ./ Nb_Class_Var ;
        otherwise %'MonteCarlo'
            h = rand(Nb_Sims,4);
    end
    
    % sample atmosphere
    for ivar = (Nb_Var-3):Nb_Var
        ivar
        Lb = Def_Base.(['Class_' num2str(Class)]).Var_in.(Var_Name{ivar}).Lb;
        Ub = Def_Base.(['Class_' num2str(Class)]).Var_in.(Var_Name{ivar}).Ub;
        P1 = Def_Base.(['Class_' num2str(Class)]).Var_in.(Var_Name{ivar}).P1;
        P2  = Def_Base.(['Class_' num2str(Class)]).Var_in.(Var_Name{ivar}).P2;
        pd = truncate(makedist(Def_Base.(['Class_' num2str(Class)]).Var_in.(Var_Name{ivar}).Distribution,P1,P2),Lb,Ub);
        Law.(Var_Name{ivar}) = icdf(pd,h(:,ivar-(Nb_Var-3)+1));
    end
    % reduce nb vars since we dont need atmosphere to be sampled more
    Nb_Var = Nb_Var - 4;
    
%end



%% Génération de la loi pour les spectres de sols
if ( isempty(Soil))
    I_Soil=repmat(1:size(Def_Base.(['Class_' num2str(Class)]).R_Soil.Refl,2),1,ceil(Nb_Sims./size(Def_Base.(['Class_' num2str(Class)]).R_Soil.Refl,2)));
    dum=randperm(length(I_Soil));
    Law.I_Soil=I_Soil(dum(1:Nb_Sims))';
else
    Law.I_Soil = Soil + zeros(Nb_Sims,1);
end



%% define sampling scheme (for full orthog we sample brute force)
switch (Def_Base.(['Class_' num2str(Class)]).SamplingDesign)
    case {'LH'}
        h =  lhsdesign(Nb_Sims,Nb_Var);
        h = h(randperm(Nb_Sims),:);
    case {'Sobel'}
        h = net(scramble(sobolset(Nb_Var),'MatousekAffineOwen'),Nb_Sims);
    case {'Halton'}
        h = net(scramble(haltonset(Nb_Var),'RR2'),Nb_Sims) ;
    case  {'FullOrthog'}
        for ivar = 1:Nb_Var
            Nb_Class_Var(ivar) = Def_Base.Class_1.Var_in.(Var_Name{ivar}).Nb_Classe;
        end
        h = (fullfact([Nb_Class_Var])-1 + rand(Nb_Sims,Nb_Var)) ./ Nb_Class_Var ;
    otherwise %'MonteCarlo'
        h = rand(Nb_Sims,Nb_Var);
end


%% make required truncated distribution for this variable
for ivar = 1:Nb_Var
    ivar
    Lb = Def_Base.(['Class_' num2str(Class)]).Var_in.(Var_Name{ivar}).Lb;
    Ub = Def_Base.(['Class_' num2str(Class)]).Var_in.(Var_Name{ivar}).Ub;
    P1 = Def_Base.(['Class_' num2str(Class)]).Var_in.(Var_Name{ivar}).P1;
    P2  = Def_Base.(['Class_' num2str(Class)]).Var_in.(Var_Name{ivar}).P2;
    pd = truncate(makedist(Def_Base.(['Class_' num2str(Class)]).Var_in.(Var_Name{ivar}).Distribution,P1,P2),Lb,Ub);
    Law.(Var_Name{ivar}) = icdf(pd,h(:,ivar));
    
    % adjust distribution range if not LAI
    if (~strcmp(Var_Name{ivar},'LAI'))
        
        % linear interpolation >=LAI_Conv
        %define bounds as a fn of LAI
        LbLAI = 0;
        UbLAI = Def_Base.(['Class_' num2str(Class)]).Var_in.Cab.LAI_Conv;
        %new lower bound
        VarMax =  Def_Base.(['Class_' num2str(Class)]).Var_in.(Var_Name{ivar}).min(2);
        VarMin = Def_Base.(['Class_' num2str(Class)]).Var_in.(Var_Name{ivar}).min(1);
        % squeeze variable between bounds limited to LAI_Conv
        if ( VarMin < VarMax )
            LbVar = min(VarMin + (Law.LAI - LbLAI)*(VarMax-VarMin)/(UbLAI-LbLAI),VarMax);
        else
            LbVar = max(VarMin + (Law.LAI - LbLAI)*(VarMax-VarMin)/(UbLAI-LbLAI),VarMin);
        end
        
        %new upper bound
        VarMax =  Def_Base.(['Class_' num2str(Class)]).Var_in.(Var_Name{ivar}).max(2);
        VarMin = Def_Base.(['Class_' num2str(Class)]).Var_in.(Var_Name{ivar}).max(1);
        % squeeze variable between bounds limited to LAI_Conv
        if ( VarMin < VarMax )
            UbVar = min(VarMin + (Law.LAI - LbLAI)*(VarMax-VarMin)/(UbLAI-LbLAI),VarMax);
        else
            UbVar = min(VarMin + (Law.LAI - LbLAI)*(VarMax-VarMin)/(UbLAI-LbLAI),VarMin);
        end
        
        %squeeze range between bounds
        Law.(Var_Name{ivar})  = LbVar + (Law.(Var_Name{ivar}) -Lb) .* (UbVar-LbVar) ./ (Ub-Lb);
    end
end

%% Randomisation des cas simulés (pour la sélection entre les différentes bases d'apprentissage, hyper et validation)
% on laisse les angles de côtés pour garder les conditions d'écartement du
% hot spot r&élaisées dans Law_obs
I_Rand=randperm(length(Law.LAI));
for ivar=1:length(Var_Name)
    Law.(Var_Name{ivar})(1:Nb_Sims)=Law.(Var_Name{ivar})(I_Rand(1:Nb_Sims));
end

