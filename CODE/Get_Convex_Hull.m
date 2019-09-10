function convex_hull = Get_Convex_Hull(Data,Tolerance,Step)
%  estimates approximate convex hull of Data
%
% Najib Djamai  2019

%% Domaine en Réflectance
Extreme=zeros(2,size(Data,2));
Extreme(1,:)=max(min(Data)-Tolerance,0); % on evite que le minimum étendu par la tolérance soit négatif
Extreme(2,:)=max(Data)+Tolerance;
Nb_Cas=length(Data);
CL=ceil((Data-repmat(Extreme(1,:),Nb_Cas,1))./repmat(Extreme(2,:)-Extreme(1,:),Nb_Cas,1).*Step);
UCL=0;
for ii=1:size(CL,2),
    UCL=UCL+CL(:,ii)*(100^(ii-1));
end;
UCL=unique(UCL);

%%
convex_hull.data=UCL;
convex_hull.N_classes=Step;
convex_hull.Tolerance=Tolerance;
convex_hull.Extreme=Extreme;

return




