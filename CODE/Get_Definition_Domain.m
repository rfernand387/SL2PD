function domain = Get_Definition_Domain(Data)
%  produces a coded definition domain for data
%  Computes N-dimensional histogram of data and codes non-zero bins\
%  using decile-1.  Then concatenates codes in a single number.
%
%  e.g. For N=2 , it would compute a 10x10 histogram.  If bin (1,3) was
% non zero it would add the code 20 to the domain.
%
% Richard Fernandes 2019
% define edges of deciles

% get N d histogram
[M N] = size(Data);
[count edges mid loc] = histcn(Data, 0:0.1:1);
domain  = ind2sub(size(count),find(count>0));
return




