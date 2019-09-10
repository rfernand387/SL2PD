%% Transformation dichier DIRECT pour mettre des champs partout!!
% Fred Aout 2007
Var={'LAIeff';'LAItrue';'LAI57eff';'LAI57true';'FAPAR';'FCOVER'}
load('D:\Home\DATA\NNT_new\DATA\Data_Valid\DIRECT.mat')
for isite=1:length(DIRECT)
    for ivar=1:length(Var)
        if isempty(DIRECT(isite).x33.(Var{ivar}))
                DIRECT(isite).x33.(Var{ivar}).Mean=[];
        end
    end
end
save DIRECT DIRECT

    