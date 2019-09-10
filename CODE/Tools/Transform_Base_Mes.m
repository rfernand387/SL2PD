% transformation de Base_Mes pour format plus facile
% Fred 17/10/2007

load('D:\Home\DATA\NNT_new\DATA\Mismatch\Mismatch_CYCL_VGT_V3_L3A.mat')
X.Band_Names=fieldnames(Base_Mes.Rho); % les noms des bandes
for i=1:length(X.Band_Names)
    X.Rho_Toc(:,i)=Base_Mes.Rho.(X.Band_Names{i})(:);
end
if isfield(Base_Mes,'Angles')
    X.Angles=Base_Mes.Angles;
end
Base_Mes=X;
save('D:\Home\DATA\NNT_new\DATA\Mismatch\Extract_CYCL_VGT_V3_L3A.mat','Base_Mes')