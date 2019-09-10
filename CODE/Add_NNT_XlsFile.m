function Add_NNT_XlsFile(Def_Base,Results,Class)

Input_Name=cat(2,Def_Base.Bandes_Utiles,Def_Base.Angles');
Var=Def_Base.Var_out;
file=[Def_Base.Report_Dir '\Class_' num2str(Class) '\Algo_' Def_Base.Name];

h=waitbar(0,'Remplissage des fichiers Excel');
%for ivar=1:length(Var)
    ivar = 1
    waitbar(ivar./length(Var),h)
    xlsfile=[file '_' Var{ivar} '.xlsx']; 
    copyfile('.\DATA\Template_NNT_Description.xlsx',xlsfile)
    
    %% Feuille de la normalisation input out of range, denormalisation, output
    %% out of range
    NomFeuille = 'Normalisation';
    xlswrite(xlsfile,{'Normalisation of inputs'},NomFeuille,[char(65) int2str(1)]);
    xlswrite(xlsfile,{'X* = 2*(X-XMin)/(XMax-XMin)-1'},NomFeuille,[char(65) int2str(3)]);
    xlswrite(xlsfile,{'XMin ';'XMax'}',NomFeuille,[char(66) int2str(5)])
    xlswrite(xlsfile,Input_Name',NomFeuille,[char(65) int2str(6)])
    
    xlswrite(xlsfile,Results.(Var{ivar}).Norm_Input.xmin,NomFeuille,[char(66) int2str(6)])
    xlswrite(xlsfile,Results.(Var{ivar}).Norm_Input.xmax,NomFeuille,[char(67) int2str(6)])
    
    ligne =7+length(Input_Name);
    % xlswrite(xlsfile,{'Management of Extreme cases'},NomFeuille,[char(65) int2str(ligne)]);
    % xlswrite(xlsfile,{'Input out of range'},NomFeuille,[char(65) int2str(ligne+2)]);
    % xlswrite(xlsfile,{'Input Min';'Input Max'}',NomFeuille,[char(66) int2str(ligne+4)])
    % xlswrite(xlsfile,Input_Name,NomFeuille,[char(65) int2str(ligne+5)])
    % xlswrite(xlsfile,Results.Norm_Input.xmin-0.01,NomFeuille,[char(66) int2str(ligne+5)])
    % xlswrite(xlsfile,Results.Norm_Input.xmax+0.01,NomFeuille,[char(67) int2str(ligne+5)])
    %
    % ligne = ligne+5+4+2;
    xlswrite(xlsfile,{'Denormalisation of outputs'},NomFeuille,[char(65) int2str(ligne)]);
    xlswrite(xlsfile,{'Y = 0.5*(Y*+1)*(YMax-YMin)+YMin}'},NomFeuille,[char(65) int2str(ligne+2)]);
    xlswrite(xlsfile,{'YMin ';'YMax'}',NomFeuille,[char(66) int2str(ligne+4)])
    
    ligne = ligne +4;
    xlswrite(xlsfile,Var(ivar),NomFeuille,[char(65) int2str(ligne+1)])
    xlswrite(xlsfile,Results.(Var{ivar}).Norm_Output.xmin,NomFeuille,[char(66) int2str(ligne+1)])
    xlswrite(xlsfile,Results.(Var{ivar}).Norm_Output.xmax,NomFeuille,[char(67) int2str(ligne+1)])
    
    %% feuille Extreme Cases
    NomFeuille = 'Extreme Cases';
    ligne=1;
    xlswrite(xlsfile,{'Management of Extreme cases'},NomFeuille,[char(65) int2str(ligne)]);
    ligne=3;
    xlswrite(xlsfile,{'Output out of range'},NomFeuille,[char(65) int2str(ligne+2)]);
    xlswrite(xlsfile,{'Output_Min-Tolerance < Output < Output_Min  then Output= Output_Min  '},NomFeuille,[char(65) int2str(ligne+3)]);
    xlswrite(xlsfile,{'Output_Max < Output < Output_Max+Tolerance  then Output= Output_Max  '},NomFeuille,[char(65) int2str(ligne+4)]);
    xlswrite(xlsfile,{'Tolerance';'Output Min';'Output Max'}',NomFeuille,[char(66) int2str(ligne+6)])
    
    ligne = ligne +6;
    xlswrite(xlsfile,Var(ivar),NomFeuille,[char(65) int2str(ligne+1)])
    if strcmp(Var{ivar},'LAI')
        tolerance=0.2;
    else
        tolerance=0.05;
    end        
    xlswrite(xlsfile,tolerance,NomFeuille,[char(66) int2str(ligne+1)])
    xlswrite(xlsfile,floor(Results.(Var{ivar}).Norm_Output.xmin),NomFeuille,[char(67) int2str(ligne+1)])
    xlswrite(xlsfile,ceil(Results.(Var{ivar}).Norm_Output.xmax),NomFeuille,[char(68) int2str(ligne+1)])
    
    %% feuille comprenant les poids
    NomFeuille = 'Weights';
    xlswrite(xlsfile,Var(ivar),NomFeuille,[char(65) int2str(1)]);
    xlswrite(xlsfile,{'Layer 1'},NomFeuille,[char(65) int2str(4)]);
    Nlig = 5 ; Ncol = 2;
    xlswrite(xlsfile,Input_Name,NomFeuille,[char(64+Ncol) int2str(Nlig)]);
    
    Nlig = Nlig +1; Ncol = 1;
    for ineuron = 1:5
        xlswrite(xlsfile,{['neuron' int2str(ineuron) ]},NomFeuille,[char(64+Ncol) int2str(Nlig-1+ineuron)]);
    end
    Ncol =  2;
    xlswrite(xlsfile,Results.(Var{ivar}).NET.IW{1},NomFeuille,[char(64+Ncol) int2str(Nlig)]);
    Nlig = Nlig +5; Ncol = 1;
    xlswrite(xlsfile,{'bias'},NomFeuille,[char(64+Ncol) int2str(Nlig)]);
    Ncol = 2;
    xlswrite(xlsfile,Results.(Var{ivar}).NET.b{1}',NomFeuille,[char(64+Ncol) int2str(Nlig)]);
    Nlig = Nlig +1; Ncol = 1;
    xlswrite(xlsfile,{'Transfert Fct'},NomFeuille,[char(64+Ncol) int2str(Nlig)]);
    Ncol =  2;
    xlswrite(xlsfile,{'tansig'},NomFeuille,[char(64+Ncol) int2str(Nlig)]);
    
    for ilayer = 2:2 %%% -1
        Nlig = Nlig +2 ; Ncol = 1;
        xlswrite(xlsfile,{['Layer ' int2str(ilayer) ]},NomFeuille,[char(64+Ncol) int2str(Nlig)]);
        
        Nlig = Nlig +1; Ncol = 1;
        for ineuron = 1:1
            xlswrite(xlsfile,{['neuron' int2str(ineuron)]},NomFeuille,[char(64+Ncol) int2str(Nlig-1+ineuron)]);
        end
        Ncol =  2;
        xlswrite(xlsfile,Results.(Var{ivar}).NET.LW{ilayer,ilayer-1},NomFeuille,[char(64+Ncol) int2str(Nlig)]);
        Nlig = Nlig +1; Ncol = 1;
        xlswrite(xlsfile,{'bias'},NomFeuille,[char(64+Ncol) int2str(Nlig)]);
        Ncol = 2;
        xlswrite(xlsfile,Results.(Var{ivar}).NET.b{ilayer}',NomFeuille,[char(64+Ncol) int2str(Nlig)]);
        Nlig = Nlig +1; Ncol = 1;
        xlswrite(xlsfile,{'Transfert Fct'},NomFeuille,[char(64+Ncol) int2str(Nlig)]);
        Ncol =  2;
        xlswrite(xlsfile,{'purelin'},NomFeuille,[char(64+Ncol) int2str(Nlig)]);
    end
    
%     %% Feuille 'test cases'
%     NomFeuille = 'Test_Cases';
%     str=cell(6,5);
%     str(1,1:4) = Input_Name;
%     str(1,5) = Var(ivar);
%     
%     for icas = 1:5
%         str(icas+1,1:Nb_Inputs)=cellstr(num2str(Cases.(Var{ivar}).In(icas,:)'))';
%         str(icas+1,Nb_Inputs+1)=cellstr(num2str(Cases.(Var{ivar}).Out(icas)));
%     end
%     xlswrite(xlsfile,str,NomFeuille);
    
%% UNCERTAINTIES    
        %% Feuille de la normalisation input out of range, denormalisation, output
    %% out of range
    NomFeuille = 'Normalisation_Uncertainties';
    xlswrite(xlsfile,{'Normalisation of inputs'},NomFeuille,[char(65) int2str(1)]);
    xlswrite(xlsfile,{'X* = 2*(X-XMin)/(XMax-XMin)-1'},NomFeuille,[char(65) int2str(3)]);
    xlswrite(xlsfile,{'XMin ';'XMax'}',NomFeuille,[char(66) int2str(5)])
    xlswrite(xlsfile,Input_Name',NomFeuille,[char(65) int2str(6)])
    
    xlswrite(xlsfile,Results.(Var{ivar}).Uncertainties.Norm_Input.xmin,NomFeuille,[char(66) int2str(6)])
    xlswrite(xlsfile,Results.(Var{ivar}).Uncertainties.Norm_Input.xmax,NomFeuille,[char(67) int2str(6)])
    
    ligne =7+length(Input_Name);
    % xlswrite(xlsfile,{'Management of Extreme cases'},NomFeuille,[char(65) int2str(ligne)]);
    % xlswrite(xlsfile,{'Input out of range'},NomFeuille,[char(65) int2str(ligne+2)]);
    % xlswrite(xlsfile,{'Input Min';'Input Max'}',NomFeuille,[char(66) int2str(ligne+4)])
    % xlswrite(xlsfile,Input_Name,NomFeuille,[char(65) int2str(ligne+5)])
    % xlswrite(xlsfile,Results.Norm_Input.xmin-0.01,NomFeuille,[char(66) int2str(ligne+5)])
    % xlswrite(xlsfile,Results.Norm_Input.xmax+0.01,NomFeuille,[char(67) int2str(ligne+5)])
    %
    % ligne = ligne+5+4+2;
    xlswrite(xlsfile,{'Denormalisation of outputs'},NomFeuille,[char(65) int2str(ligne)]);
    xlswrite(xlsfile,{'Y = 0.5*(Y*+1)*(YMax-YMin)+YMin}'},NomFeuille,[char(65) int2str(ligne+2)]);
    xlswrite(xlsfile,{'YMin ';'YMax'}',NomFeuille,[char(66) int2str(ligne+4)])
    
    ligne = ligne +4;
    xlswrite(xlsfile,Var(ivar),NomFeuille,[char(65) int2str(ligne+1)])
    xlswrite(xlsfile,Results.(Var{ivar}).Uncertainties.Norm_Output.xmin,NomFeuille,[char(66) int2str(ligne+1)])
    xlswrite(xlsfile,Results.(Var{ivar}).Uncertainties.Norm_Output.xmax,NomFeuille,[char(67) int2str(ligne+1)])
    
    NomFeuille = 'Extreme Cases';
    ligne=1;
    xlswrite(xlsfile,{'Management of Extreme cases'},NomFeuille,[char(65) int2str(ligne)]);
    ligne=3;
    xlswrite(xlsfile,{'Output out of range'},NomFeuille,[char(65) int2str(ligne+2)]);
    xlswrite(xlsfile,{'Output_Min-Tolerance < Output < Output_Min  then Output= Output_Min  '},NomFeuille,[char(65) int2str(ligne+3)]);
    xlswrite(xlsfile,{'Output_Max < Output < Output_Max+Tolerance  then Output= Output_Max  '},NomFeuille,[char(65) int2str(ligne+4)]);
    xlswrite(xlsfile,{'Tolerance';'Output Min';'Output Max'}',NomFeuille,[char(66) int2str(ligne+6)])
    
    ligne = ligne +6;
    xlswrite(xlsfile,Var(ivar),NomFeuille,[char(65) int2str(ligne+1)])
    
    %% feuille comprenant les poids
    NomFeuille = 'Weights_Uncertainties';
    xlswrite(xlsfile,Var(ivar),NomFeuille,[char(65) int2str(1)]);
    xlswrite(xlsfile,{'Layer 1'},NomFeuille,[char(65) int2str(4)]);
    Nlig = 5 ; Ncol = 2;
    xlswrite(xlsfile,Input_Name,NomFeuille,[char(64+Ncol) int2str(Nlig)]);
    
    Nlig = Nlig +1; Ncol = 1;
    for ineuron = 1:5
        xlswrite(xlsfile,{['neuron' int2str(ineuron) ]},NomFeuille,[char(64+Ncol) int2str(Nlig-1+ineuron)]);
    end
    Ncol =  2;
    xlswrite(xlsfile,Results.(Var{ivar}).Uncertainties.NET.IW{1},NomFeuille,[char(64+Ncol) int2str(Nlig)]);
    Nlig = Nlig +5; Ncol = 1;
    xlswrite(xlsfile,{'bias'},NomFeuille,[char(64+Ncol) int2str(Nlig)]);
    Ncol = 2;
    xlswrite(xlsfile,Results.(Var{ivar}).Uncertainties.NET.b{1}',NomFeuille,[char(64+Ncol) int2str(Nlig)]);
    Nlig = Nlig +1; Ncol = 1;
    xlswrite(xlsfile,{'Transfert Fct'},NomFeuille,[char(64+Ncol) int2str(Nlig)]);
    Ncol =  2;
    xlswrite(xlsfile,{'tansig'},NomFeuille,[char(64+Ncol) int2str(Nlig)]);
    
    for ilayer = 2:2 %%% -1
        Nlig = Nlig +2 ; Ncol = 1;
        xlswrite(xlsfile,{['Layer ' int2str(ilayer) ]},NomFeuille,[char(64+Ncol) int2str(Nlig)]);
        
        Nlig = Nlig +1; Ncol = 1;
        for ineuron = 1:1
            xlswrite(xlsfile,{['neuron' int2str(ineuron)]},NomFeuille,[char(64+Ncol) int2str(Nlig-1+ineuron)]);
        end
        Ncol =  2;
        xlswrite(xlsfile,Results.(Var{ivar}).Uncertainties.NET.LW{ilayer,ilayer-1},NomFeuille,[char(64+Ncol) int2str(Nlig)]);
        Nlig = Nlig +1; Ncol = 1;
        xlswrite(xlsfile,{'bias'},NomFeuille,[char(64+Ncol) int2str(Nlig)]);
        Ncol = 2;
        xlswrite(xlsfile,Results.(Var{ivar}).Uncertainties.NET.b{ilayer}',NomFeuille,[char(64+Ncol) int2str(Nlig)]);
        Nlig = Nlig +1; Ncol = 1;
        xlswrite(xlsfile,{'Transfert Fct'},NomFeuille,[char(64+Ncol) int2str(Nlig)]);
        Ncol =  2;
        xlswrite(xlsfile,{'purelin'},NomFeuille,[char(64+Ncol) int2str(Nlig)]);
    end
    
%     %% Feuille DEFINITION DOMAIN
%     NomFeuille = 'Definition_Domain';
%     xlswrite(xlsfile,{'Min_Max_Bounding_Box'},NomFeuille,'A1');
%     xlswrite(xlsfile,Input_Name(1:3),NomFeuille,'B3:D3');
%     xlswrite(xlsfile,{'Min'},NomFeuille,'A4');
%     xlswrite(xlsfile,{'Max'},NomFeuille,'A5');
%     xlswrite(xlsfile,Results.Definition_Domain.Extreme,NomFeuille,'B4:D5');
%     
%     xlswrite(xlsfile,{'Grid'},NomFeuille,'A7');
%     xlswrite(xlsfile,Input_Name(1:3),NomFeuille,'A9:C9');
%     xlswrite(xlsfile,Results.Definition_Domain.Grid,NomFeuille,'A10');
%end
close(h)

