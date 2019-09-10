function Plot_Sol_Bandes(Def_Base,Class)
%% Edition des figures de spectres de sol et de sensibilité spactrale des bandes
% Fred 04/10/2005
% Modif Fred Aout 2007
% Modif Fred Avril 2008
% Richard June 2019

%% spectres de sol
figure
plot(Def_Base.(['Class_' num2str(Class)]).R_Soil.Lambda,Def_Base.(['Class_' num2str(Class)]).R_Soil.Refl,'linewidth',1.5)
xlabel('Wavelength (nm)')
ylabel('Soil Reflectance')
box on
print([Def_Base.Report_Dir '\Class_' num2str(Class) '\Learn_Data_Base\Soil_Spectra'],'-dpng') 
close

%% Sensibilités spectrales utilisées
figure
map=colormap;
step=floor((length(colormap)-1)/(size(Def_Base.Bandes_Utiles,2)-1));

compt=1;
for iband = 1:size(Def_Base.Bandes_Utiles,2)
    plot(Def_Base.Sensi_Capteur.(Def_Base.Bandes_Utiles{iband}).Lambda,Def_Base.Sensi_Capteur.(Def_Base.Bandes_Utiles{iband}).Sensi,'linewidth',1.5,'color',map(compt,:))
    compt=compt+step;
    hold on
end
xlabel('Wavelength (nm)')
ylabel('Spectral Sensitivity')
l=legend(Def_Base.Bandes_Utiles);
set(l,'interpreter','none')
box on
print([Def_Base.Report_Dir '\Class_' num2str(Class) '\Learn_Data_Base\Sensi_spec'],'-dpng') 
close 
