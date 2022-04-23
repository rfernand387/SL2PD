function DomainCode = Input_Domain(Def_Base,Input,edges,nrep)
% identifies cells of hypercube occupied with values of rho
% does multiple realizations with noise
Ref=['Rho_' Def_Base.Toc_Toa];
data = Input.(Ref);
for n = 1:nrep
    Input_Noise=Add_Noise_Input(Def_Base,Input,1);
    data = [data ; Input_Noise.(Ref)];
end
DomainCode = Get_Definition_Domain(data,edges);
export(dataset(DomainCode),'File',[Def_Base.Name,'_domain.csv'],'delimiter',',')
return 


