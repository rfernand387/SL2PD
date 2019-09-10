%% Transformation structure validation pour les produits
% mise en collone de toutes les données
% Fred 02/08/2007

Prod_File ={'ECO'
    'BELMANIP_BU_MODIS_V4_BELMANIP_Sinus_Oct2006'
    'BU_MODIS_V41'
    'CYCL_VGT_V31'};
Prod_Name ={'ECO'
    'BU_MODIS_V4'
    'BU_MODIS_V41'
    'CYCL_VGT_V31'};


for iprod=1:size(Prod_Name,1)
    load(['D:\Home\DATA\NNT_new\DATA\Data_Valid\',Prod_File{iprod}])
    eval(['X=' Prod_Name{iprod}]);
    for isite = 1:length(X) % Boucle sur les sites
        if isfield(X(isite),'Doy')
            if size(X(isite).Doy,1) < size(X(isite).Doy,2) % si en ligne
                X(isite).Doy=X(isite).Doy';
            end
        end
        if ~isempty(X(isite).x33)
        Var_Name=fieldnames(X(isite).x33);
            for ivar=1:size(Var_Name,1)
                Name=fieldnames(X(isite).x33.(Var_Name{ivar}));
                for iname=1:size(Name,1)
                    if size(X(isite).x33.(Var_Name{ivar}).(Name{iname}),1) < size(X(isite).x33.(Var_Name{ivar}).(Name{iname}),2) % si en ligne
                        X(isite).x33.(Var_Name{ivar}).(Name{iname})=X(isite).x33.(Var_Name{ivar}).(Name{iname})';
                    end
                end % iname
            end %ivar
        end
    end % isite
    eval([Prod_Name{iprod},'=X;']);
save(Prod_Name{iprod},Prod_Name{iprod})
end % iprod