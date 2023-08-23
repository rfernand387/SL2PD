function sp2lTOeeIncertitudes(P,Def_Base,ResultsIncertitudes)
%% exports a table of all subnets for a given partitioning for use in GEE
tabledata = [];
    
for ivar=1:length(Def_Base.Var_out)
    NET =  ResultsIncertitudes.(Def_Base.Algorithm_Name).(Def_Base.Validation_Name).(Def_Base.Var_out{ivar}).NET;
    netdata = [0 0 ivar 0 1];
    xmin = NET.inputs{1,1}.processSettings{1,1}.xmin;
    xmax = NET.inputs{1,1}.processSettings{1,1}.xmax;
    ymin = NET.inputs{1,1}.processSettings{1,1}.ymin;
    ymax = NET.inputs{1,1}.processSettings{1,1}.ymax;
    inpslope = (ymax - ymin)./(xmax-xmin);
    netdata = [netdata numel(inpslope)];
    netdata = [netdata reshape(inpslope,1,numel(inpslope))];
    inpoffset = (ymin-(inpslope.*xmin));
    netdata = [netdata numel(inpoffset)];
    netdata = [netdata reshape(inpoffset,1,numel(inpoffset))];
    h1wt = NET.IW{1,1}.';
    netdata = [netdata numel(h1wt)];
    netdata = [netdata reshape(h1wt,1,numel(h1wt))];
    h1bi = NET.b{1,1};
    netdata = [netdata numel(h1bi)];
    netdata = [netdata reshape(h1bi,1,numel(h1bi))];
    h2wt = NET.LW{2,1};
    netdata = [netdata numel(h2wt)];
    netdata = [netdata reshape(h2wt,1,numel(h2wt))];
    h2bi = NET.b{2,1};
    netdata = [netdata numel(h2bi)];
    netdata = [netdata reshape(h2bi,1,numel(h2bi))];
    xmin = NET.outputs{2}.processSettings{1,1}.xmin;
    xmax = NET.outputs{2}.processSettings{1,1}.xmax;
    ymin = NET.outputs{2}.processSettings{1,1}.ymin;
    ymax = NET.outputs{2}.processSettings{1,1}.ymax;
    outslope = (ymax - ymin)./(xmax-xmin);
    netdata = [netdata numel(outslope)];
    netdata = [netdata reshape(outslope,1,numel(outslope))];
    outoffset = (ymin-(outslope.*xmin));
    netdata = [netdata numel(outoffset)];
    netdata = [netdata reshape(outoffset,1,numel(outoffset))];
    tabledata = [tabledata ; netdata];
end

export(mat2dataset(tabledata),'File',[Def_Base.Name '_' Def_Base.Algorithm_Name '_' P '_0_1_incertitudes.csv'],'Delimiter',',')

return

return