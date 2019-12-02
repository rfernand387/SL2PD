function Def_Base = Read_Alg_Archi(Def_Base,Debug)
% Def_Base = Read_Alg_Archi(Def_Base,Debug) defines an algorithm.
%
% Inputs
% Def_Base : parameter definitions
% Debug : Debug level, currently 0 for no debug or 1 for debug output
%
% Outputs
% Def_Base : parameter definitions , will include a new algorithm if it can
% be created.  Else, the algorithm definition is null.
% Richard July 2019

%% Parse the algorithm used and act accordingly
try
    [x,y]= xlsread([Def_Base.File_XLS '.xls'],Def_Base.Algorithm_Name,'A2');
catch
    Def_Base.Algorithm_Name = [];
    if (Debug)
        disp(['Algorithm definition not found - calibration and validation skipped']);
        return
    end
end
Def_Base.Regression.(Def_Base.Algorithm_Name).Method =char(y);

switch Def_Base.Regression.(Def_Base.Algorithm_Name).Method
    
    case {'NNT'}
        
        %% Standard backprop network
        % Lecture des valeurs
        [x,y]= xlsread([Def_Base.File_XLS '.xls'],Def_Base.Algorithm_Name,'B2:Q11');
        
        %% Variables de sortie utilisées
        Var_Choisi=find(prod(~isnan(x([1 2 4 ],:)).*1.0)==1);% le cas choisi (celui ou il n'y a pas que des NaN!)
        Def_Base.Var_out= y(1,:);
        
        %% Pour chaque variable, on propose de décrire l'architecture du réseau
        for ivar = Var_Choisi % boucle sur les variables
            if strcmp(Def_Base.Var_out{ivar},'FAPAR') % si valriable fAPAR, on regarde à quelle heure elle est estimée
                Def_Base.Regression.(Def_Base.Algorithm_Name).Var_out.(Def_Base.Var_out{ivar}).Hour = floor(x(8,ivar));
                Def_Base.Regression.(Def_Base.Algorithm_Name).Var_out.(Def_Base.Var_out{ivar}).Min = floor((x(8,ivar)-floor(x(8,ivar)))*60);
            end
            Def_Base.Regression.(Def_Base.Algorithm_Name).Var_out.(Def_Base.Var_out{ivar}).Nb_Reseau = x(1,ivar);    % Nombre de réseaux
            Nb_Hidden = x(2,ivar); % Nombre de couches cachées
            Def_Base.Regression.(Def_Base.Algorithm_Name).Var_out.(Def_Base.Var_out{ivar}).Tolerance=x(7,ivar); % tolerance
            Def_Base.Regression.(Def_Base.Algorithm_Name).Var_out.(Def_Base.Var_out{ivar}).Nb_Neurons=[];
            for icouche = 1:Nb_Hidden % boucle sur les couches
                Def_Base.Regression.(Def_Base.Algorithm_Name).Var_out.(Def_Base.Var_out{ivar}).Transfer{icouche}=char(y((icouche-1).*2+4,ivar));
                Def_Base.Regression.(Def_Base.Algorithm_Name).Var_out.(Def_Base.Var_out{ivar}).Nb_Neurons=cat(2,Def_Base.Regression.(Def_Base.Algorithm_Name).Var_out.(Def_Base.Var_out{ivar}).Nb_Neurons,x((icouche-1).*2+4,ivar));
            end
            Def_Base.Regression.(Def_Base.Algorithm_Name).Var_out.(Def_Base.Var_out{ivar}).Nb_Neurons=cat(2,Def_Base.Regression.(Def_Base.Algorithm_Name).Var_out.(Def_Base.Var_out{ivar}).Nb_Neurons,1); % on ajoute la couche de sortie
%             Def_Base.Regression.(Def_Base.Algorithm_Name).Var_out.(Def_Base.Var_out{ivar}).Transfer{Nb_Hidden+1}='purelin';
            
        end
        %% partitoning variable
        [x,y]= xlsread([Def_Base.File_XLS '.xls'],Def_Base.Algorithm_Name,'B11');
        Def_Base.Regression.(Def_Base.Algorithm_Name).Partition_Name = char(y);
        if ( isempty(Def_Base.Regression.(Def_Base.Algorithm_Name).Partition_Name) ) 
            Def_Base.Regression.(Def_Base.Algorithm_Name).Partition_Name = 'Single';
        end
                %% number of training batches
        [x,y]= xlsread([Def_Base.File_XLS '.xls'],Def_Base.Algorithm_Name,'B12');
        Def_Base.Regression.(Def_Base.Algorithm_Name).Num_Batches = x;

    otherwise
        if (Debug)
            disp('Regression algorithm unknown.')
        end
        status = 0;
        return
end





