% Transform_LAI_Aleix
%Fred & Aleix Aout 2007

load('D:\Home\DATA\NNT_new\Aleix\LAI_BELMANIP.mat')
Prod_Name=fieldnames(LAI_BELMANIP(1).x33)
Info_Name=fieldnames(LAI_BELMANIP(1))
for isite=1:length(LAI_BELMANIP)
    for iprod=1:length(Prod_Name)
        if isfield(LAI_BELMANIP(isite).x33,Prod_Name{iprod})
            eval([Prod_Name{iprod} '(isite).x33.LAI.Mean=(LAI_BELMANIP(isite).x33.' Prod_Name{iprod} ')''']);
        else
           eval([Prod_Name{iprod} '(isite).x33.LAI.Mean=[]']);
        end
        for iinfo=1:length(Info_Name)-1
            if strcmp(Info_Name{iinfo},'Doy')
                        eval([Prod_Name{iprod} '(isite).Doy=LAI_BELMANIP(isite).Doy''']);
            else
                eval([Prod_Name{iprod} '(isite).' Info_Name{iinfo} '=LAI_BELMANIP(isite).' Info_Name{iinfo}]);
            end
        end
    end
end
for iprod=1:length(Prod_Name)
    save(Prod_Name{iprod},Prod_Name{iprod})
end
    
