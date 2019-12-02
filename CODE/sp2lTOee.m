function sp2lTOee(P,Def_Base,Results)
%% exports a table of all subnets for a given partitioning for use in GEE
if ( strcmp(P,'Single') )

tabledata = [];
for ivar=1:length(Def_Base.Var_out)
    NET =  Results.(Def_Base.Algorithm_Name).P.(Def_Base.Var_out{ivar}).NET
    netdata = [0 0 ];
    xmin = NET.inputs{1,1}.processSettings{1,1}.xmin
    xmax = NET.inputs{1,1}.processSettings{1,1}.xmax
    ymin = NET.inputs{1,1}.processSettings{1,1}.ymin
    ymax = NET.inputs{1,1}.processSettings{1,1}.ymax
    inpslope = (ymax - ymin)./(xmax-xmin);
    netdata = [netdata numel(inpslope)];
    netdata = [netdata reshape(inpslope,1,numel(inpslope))];
    inpoffset = (ymin-inpslope.*xmin - ymin);
    netdata = [netdata numel(inpoffset)];
    netdata = [netdata reshape(inpoffset,1,numel(inpoffset))]
    h1wt = NET.IW{1,1};
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
    h3wt = NET.LW{3,2};
    netdata = [netdata numel(h3wt)];
    netdata = [netdata reshape(h3wt,1,numel(h3wt))];
    h3bi = NET.b{2,1};
    netdata = [netdata numel(h3bi)];
    netdata = [netdata reshape(h3bi,1,numel(h3bi))];
    xmin = NET.outputs{1,3}.processSettings{1,1}.xmin;
    xmax = NET.outputs{1,3}.processSettings{1,1}.xmax;
    ymin = NET.outputs{1,3}.processSettings{1,1}.ymin;
    ymax = NET.outputs{1,3}.processSettings{1,1}.ymax;
    outpslope = (ymax - ymin)./(xmax-xmin);
    netdata = [netdata numel(outpslope)];
    netdata = [netdata reshape(outpslope,1,numel(outpslope))];
    outoffset = (ymin-outslope.*xmin - ymin);
    netdata = [netdata numel(outoffset)];
    netdata = [netdata reshape(outoffset,1,numel(outoffset))]
    tabledata = [tabledata ; netdata];
end
%% add a network that always selects the first partition
    netdata = [0 0 ];
    netdata = [netdata numel(inpslope)];
    netdata = [netdata reshape(inpslope,1,numel(inpslope))*0];
    netdata = [netdata numel(inpoffset)];
    netdata = [netdata reshape(inpoffset,1,numel(inpoffset))*0]
    netdata = [netdata numel(h1wt)];
    netdata = [netdata reshape(h1wt,1,numel(h1wt))*0];
    netdata = [netdata numel(h1bi)];
    netdata = [netdata reshape(h1bi,1,numel(h1bi))*0];
    netdata = [netdata numel(h2wt)];
    netdata = [netdata reshape(h2wt,1,numel(h2wt))*0];
    netdata = [netdata numel(h2bi)];
    netdata = [netdata reshape(h2bi,1,numel(h2bi))*0];
    netdata = [netdata numel(h3wt)];
    netdata = [netdata reshape(h3wt,1,numel(h3wt))*0];
    netdata = [netdata numel(h3bi)];
    netdata = [netdata reshape(h3bi,1,numel(h3bi))*0];
    netdata = [netdata numel(outpslope)];
    netdata = [netdata reshape(outpslope,1,numel(outpslope))*0];
    netdata = [netdata numel(outoffset)];
    netdata = [netdata reshape(outoffset,1,numel(outoffset))*0+1]
tabledata = [ netdata ; tabledata ]

else
end

export(mat2dataset(tabledata),'File',[Def_Base.Name '_' Def_Base.Algorithm_Name,'Delimiter',',')
return
