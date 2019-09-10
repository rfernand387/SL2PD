%% Transformation of Land_Cover into BELMANIP
% Fred Mai 2008

% chargement de Land_Cover
load D:\Home\DATA\NNT_new\DATA\Data_Valid\Land_Cover

Classif_Name=fieldnames(Land_Cover);
for i=1:length(Classif_Name)
    if strcmp(Classif_Name(i),'Info') % Cas ou on tombe sur 'Info'
        BELMANIP.Info=Land_Cover.Info; % Nom des sites et latitude, altitude, ....
    else
        BELMANIP.(Classif_Name{i}).Class_Name=Land_Cover.(Classif_Name{i}).Class_Name;
        BELMANIP.(Classif_Name{i}).Class_Symbol=Land_Cover.(Classif_Name{i}).Class_Symbol;
        if strcmp(Classif_Name(i),'Modis')
            X=zeros(length(Land_Cover.(Classif_Name{i}).Class),1);
            for isite=1:length(Land_Cover.(Classif_Name{i}).Class)
                X(isite,1)=mode(Land_Cover.(Classif_Name{i}).Class{isite});
            end
            BELMANIP.(Classif_Name{i}).Class=X;
            % on prend le mode des valeurs
        else
        BELMANIP.(Classif_Name{i}).Class=Land_Cover.(Classif_Name{i}).Class';
        end
    end
end
save D:\Home\DATA\NNT_new\DATA\Data_Valid\BELMANIP1 BELMANIP    
        
        