function    [Output] = getRMSE(  Bruit_Bandes, Bruit_Angles, Perf, Toc_Toa )
%% builds database for a class by either copying or perfoming simulations
% Richard July 2019

%% initializations
Perf_names =fieldnames(Perf);
Output_names = Perf_names(find(~strcmp(Perf_names,'Input'))) ;
nOutput_names = length(Output_names);
In = [Perf.Input.(['Rho_' Toc_Toa]) Perf.Input.Angles] ;
[Nb_Sims,  dummy] = size(In);
RMSE = zeros(Nb_Sims,nOutput_names);

noiseAD = [Bruit_Bandes.AD + Bruit_Bandes.AI ;  Bruit_Angles.AD + Bruit_Angles.AI  ]  ;


%% find other sims close to each sim
parfor n = 1:Nb_Sims
    In_sim = In(n,:)';
    noise_sim = In_sim .* [Bruit_Bandes.MD + Bruit_Bandes.MI ;  Bruit_Angles.MD + Bruit_Angles.MI  ]/100 + noiseAD;
    matches = find(prod(abs(In-In_sim') < noise_sim',2)==1);
    for ivar = 1:nOutput_names
        RMSE(n,ivar) = rmse(Perf.(Output_names{ivar}).Valid(matches),  Perf.(Output_names{ivar}).Estime(matches) );
    end
    
end
for ivar = 1:nOutput_names
    Output.(Output_names{ivar}) = RMSE(:,ivar);
end
return

