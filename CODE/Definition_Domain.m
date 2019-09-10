function [Results]=Definition_Domain(Results,Input)
% On definit une grille entre min et max avec 'Step' niveaux pour chaque bande
% Les extremes (min max) sont calculés sur la réunion des fichiers Sim et Mes
% INPUT
% Input
% OUTPUT
% Domain_Matrix
%
% Fred Janvier 2008
% Fred Avril 2008
% Fred Aout 2009
% Fred Septembre 2009 ... a completer en faisant un choix sur les bandes
% utilisées pour evaluer le domaine de definition

%% Initialisations
Tolerance=0.01; % utilisé pour les réflectances et cos(tetas)
Step=10; % Def_Base.Streamline.Step=x;
Axis_Name=Def_Base.Bandes_Utiles;
Data=Input(:,1:length(Axis_Name)); % on ne prend que les reflectances
Extreme=zeros(2,3);

%% Domaine en Réflectance
Extreme(1,:)=max(min(Data)-Tolerance,0); % on evite que le minimum étendu par la tolérance soit négatif
Extreme(2,:)=max(Data)+Tolerance;
Nb_Cas=length(Data);
X=ceil((Data-repmat(Extreme(1,:),Nb_Cas,1))./repmat(Extreme(2,:)-Extreme(1,:),Nb_Cas,1).*Step);
Grid=unique(X,'rows');
Results.Definition_Domain.Extreme=Extreme;


%% bouchage des petits trous et visualisation du domaine
Matrice=zeros(10,10,10); % la Matrice de définition
for i=1:length(Grid)
    Matrice(Grid(i,1),Grid(i,2),Grid(i,3))=1;
end
% on dilate et erode
for i_close=1:5
    se=ones(i_close,i_close,i_close);
    Matrice1=imclose(Matrice,se);
    % on transforme la matrice en coordonnées
    I=find(Matrice1==1);
    [I1,I2,I3]=ind2sub(size(Matrice1),I); % les coordonnées
    I=[I1 I2 I3];
    if i_close==2 % si on a une fermeture de 2, on garde la matrice
        Results.Definition_Domain.Grid=I;
    end
    figure(i_close+1)
    Nb_Dim=size(I,2);
    compt=1;
    for i=1:Nb_Dim-1
        for j=i+1:Nb_Dim
            subplot(ceil((Nb_Dim.^2-Nb_Dim)/2/3),3,compt)
            XY=I;
            for k=1:length(XY)
                patch([XY(k,i)-0.5 XY(k,i)+0.5 XY(k,i)+0.5 XY(k,i)-0.5], ...
                    [XY(k,j)-0.5 XY(k,j)-0.5 XY(k,j)+0.5 XY(k,j)+0.5],[0 0 0]);
            end
            xlabel(Axis_Name(i))
            ylabel(Axis_Name(j))
            axis('square')
            axis([0.5 10.5 0.5 10.5])
            compt=compt+1;
            box on
        end
    end
    print(['.\Figures\Defintion_Domain_' num2str(i_close)],'-dpng')
end
close all











