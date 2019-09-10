function h = iscatter(x,y,i,c,m,msize)
%ISCATTER Scatter plot grouped by index vector.
%   ISCATTER(X,Y,I,C,M,msize) displays a scatter plot of X vs. Y grouped
%   by the index vector I.  
%
%   No error checking.  Use GSCATTER instead.
%
%   See also GSCATTER, GPLOTMATRIX.

%   Copyright 1993-2007 The MathWorks, Inc.
%   $Revision: 1.4.2.6 $  $Date: 2007/08/03 21:41:43 $

ni = max(i);
if (isempty(ni))
   i = ones(size(x,1),1);
   ni = 1;
end

nm = length(m);
ns = length(msize);
if ischar(c) && isvector(c)
    c = c(:);
end
nc = size(c,1);

% Now draw the plot
hh = [];
for j=1:ni
   ii = (i == j);
   hhh = line(x(ii,:), y(ii,:), ...
              'LineStyle','none', 'Color', c(1+mod(j-1,nc),:), ...
              'Marker', m(1+mod(j-1,nm)), 'MarkerSize', msize(1+mod(j-1,ns)));
   if isempty(hhh)
       hhh = NaN(max(size(x,2),size(y,2)),1);
   end
   hh = [hh; hhh'];
end

% Return the handles if desired.  They are arranged so that even if X
% or Y is a matrix, the first ni elements of hh(:) represent different
% groups, so they are suitable for use in drawing a legend.
if (nargout>0)
   h = hh(:);
end

