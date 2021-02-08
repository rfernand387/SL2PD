%% Import data from text file
% Script for importing data from the following text file:
%
%    filename: E:\SL2PDFLIGHT_FOREST\Data\BOREAS_UND_REFL_304\data\rss19_understory_refl.dat
%
% Auto-generated by MATLAB on 06-Mar-2020 12:46:22
clear
addpath(genpath('.\CODE'));
addpath(genpath('.\DATA'));

%% Setup the Import Options
opts = delimitedTextImportOptions("NumVariables", 18);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["SITE_NAME", "SUB_SITE", "START_DATE", "START_TIME", "END_DATE", "END_TIME", "INSTRUMENT", "SOLAR_AZ_ANG", "SOLAR_ZEN_ANG", "ILLUMINATION_CONDTN", "TARGET_DESCR", "NUM_OBS", "WAVELENGTH", "MEAN_REFL", "STD_ERR_REFL", "COMMENTS", "CRTFCN_CODE", "REVISION_DATE"];
opts.VariableTypes = ["categorical", "categorical", "datetime", "double", "datetime", "double", "double", "double", "double", "categorical", "categorical", "double", "double", "double", "double", "categorical", "categorical", "datetime"];
opts = setvaropts(opts, 3, "InputFormat", "dd-MMM-yyyy");
opts = setvaropts(opts, 5, "InputFormat", "dd-MMM-yyyy");
opts = setvaropts(opts, 18, "InputFormat", "dd-MMM-yyyy");
opts = setvaropts(opts, 7, "TrimNonNumeric", true);
opts = setvaropts(opts, 7, "ThousandsSeparator", ",");
opts = setvaropts(opts, [1, 2, 10, 11, 16, 17], "EmptyFieldRule", "auto");
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
rss19understoryrefl = readtable("E:\SL2PDFLIGHT_FOREST\Data\BOREAS_UND_REFL_304\data\rss19_understory_refl.dat", opts);


%% Clear temporary variables
clear opts


%% extract summer only
rss19summer = rss19understoryrefl(find(month(rss19understoryrefl.START_DATE)>4),:);

%% find number of unique spectra and make an array to fit them all between 400nm and 2400nm
Speclist = unique(rss19summer.START_TIME);
Numb_Spec = length(Speclist);
Lambda = 350:2500;
Spec = zeros(Numb_Spec,length(Lambda));


%% interpolate average spectra of each plot
for n=1:Numb_Spec
    
    %% get the spectra 
    spec = rss19summer(find(rss19summer.START_TIME==Speclist(n)),:);
    
    %% average spectra
    lambda = sort(unique(spec.WAVELENGTH));
    rho = zeros(length(lambda),1);
    for k = 1:length(lambda)
        rho(k) = mean(spec{find(spec.WAVELENGTH==lambda(k)),'MEAN_REFL'});
    end
        
    Spec(n,:) = interp1(lambda*1000,rho,Lambda,'pchip',0)/100;
end

%% extrapolate spectra using high, medium and low moisture content
% and add to spectra library
load Soil_Sentinel2
Cw = [ 0.01 0.02 0.03 0.04];
for n = 1:Numb_Spec
    rho_NIR = mean(Spec(n,find((Lambda>824).*(Lambda<876))));
            Cm = 0.0;
        delta = 1;
        while (delta>0.01)
        Cm = Cm + 0.001
        LRT=prospect_DB(4,40,10,0,0,Cw(2),Cm);
        
        %compare reflectance between 825nm and 875nm
        prospect_NIR = mean(LRT(find((LRT(:,1)>824).*(LRT(:,1)<876)),2));
        
        delta = abs(prospect_NIR - rho_NIR) 
        end
        Drymatter(n) = Cm;
    for k = 1:length(Cw)
        % simulate spectra for this Cw 
        LRT=prospect_DB(1.5,40,10,0,0,Cw(k),Cm);
        Spectra = zeros(2151,1);
        Spectra((350:401)-349) =  Spec(n,find((Lambda==402))) + Spectra((350:401)-349);
        Spectra((402:849)-349) = Spec(n,find((Lambda>401).*(Lambda<850)));
        Spectra((850:900)-349) = 0.5*Spec(n,(850:900)-399)' + 0.5*LRT((850:900)-399,2);
        Spectra((901:2500)-349) = LRT((901:2500)-399,2);

        R_Soil.Refl = [ R_Soil.Refl Spectra];
    end
end
save Soil_Boreal R_Soil



        