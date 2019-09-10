%% Transformation structure validation
% Fred 30/07/2007

Band={'b001_460'
      'b002_670'
      'b003_810'
      'b004_1640'};

load('D:\Home\DATA\NNT_new\DATA\Data_Valid\BELMANIP_CYCL_VGT_V3_L3A1_Sinus_2000_2003_13Dec2006.mat')
Data=CYCL_VGT_V3_L3A;
for isite = 1:length(Data) % Boucle sur les sites
        dum=zeros(9,size(Data(isite).Doy,2),4);
        for d=1:size(Data(isite).Doy,2)
            dum(:,d,:)=cell2mat(Data(isite).x33.Rho(d));
        end
    for iband=1:size(Band,1)
            Data(isite).x33.Rho.(Band{iband})=reshape(dum(:,:,iband),9,size(Data(isite).Doy,2));
    end
    if isfield(Data(isite).x33,{'Angles'})
        Data(isite).x33.Angles=cell2mat(Data(isite).x33.Angles);
    else
        Data(isite).x33.Angles=[];
    end
end
