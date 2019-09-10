% Function 'boxplot' produces a boxplot for each column of an input matrix. 
%
% Usage:   S = boxplot(X, method, olflag, notches, titleb)
%          S = boxplot(X, method, olflag, notches)
%          S = boxplot(X, method, olflag)
%          S = boxplot(X, method)
%          S = boxplot(X)
%
%    Input:
%       X:       X is either a 1 by m cell array with varying length vector
%                components, or a n by m matrix. 
%       method:  If method = 0 (default), then Q1 is computed as the median of the
%                lower half of the sorted data and Q3 is the median of the
%                upper half of the sorted data. That is, if n is even,
%                spilt the data in two halves, then take the respective
%                medians to compute the quartiles.  If n is odd, first
%                find the median, then split the data with the lower half
%                ending with the median and the upper half beginning with
%                the median.
%                If method = 1, then the quartiles are computed as follows:
%                If (n+1)/4 is an integer, then 
%                Q1 = X((n+1)/4) and Q3 = X((3(n+1)/4), 
%                otherwise ((n+1)/4 is not an integer, then 
%                Q1 = 0.25*X(floor((n+1)/4) + 0.75*X(floor((n+1)/4 +1)
%                and 
%                Q3 = 0.75*X(floor(3(n+1)/4) + 0.25*X(floor(3(n+1)/4 +1).
%                method us automatically set to 1 for datasets of length 2. 
%       olflag:  If olflag = 1 all outliers are plotted. 
%                If olflag = 0, then only the mild 
%                outliers (as defined below) are plotted.
%                'olflag = 0' is the default when this 
%                argument is not supplied. 
%       notches:  If notches = 1, then 95% confidence intervals
%                 of the median(s) are indicated by notches between 
%                    median +- 1.58(IQR/sqrt(n)
%                 If notches = 0, then notches are not drawn. (This is 
%                 the default when this argument is not suppiled.)
%       titleb   string containing title for boxplot.  If not supplied, 
%                the default title is 'boxplot'
%
%    Output:
%       S is a matrix with each length-7 column contains 
%       the min, quartile 1, median, mean, quartile 3, max, and 
%       IQR, corresponding the the data in the corresponding 
%       column of X. A boxplot is displayed for each column 
%       of X, with the mean also plotted with a + sign.
%
%    Remarks:  Mild outliers (between Quartile3 + 1.5*IQR 
%    and Quartile3+3*IQR or between Quartile1 - 1.5*IQR and 
%    Quartile1-3*IQR) as well as outliers (greater than 
%    Quartile3+3*IQR or less than Quartile1-3*IQR) are
%    identified.
%
% Author: Ernest E. Rothman. (2/20/2003) This work is licensed under a 
% Creative Commons License. See http://creativecommons.org/licenses/by-nc-sa/1.0/
% Last modified 2/29/2004.
% This function comes with absolutely no guarantees.
 
   function  S = boxplot(x, method, olflag, notches, titleb)

   
%=====================================
%==========   Check input   ==========

if (nargin > 5)
    disp('??? Error ==> boxplot')
    disp('Incorrect number of inputs')
    disp('see help boxplot for more details')
    return
elseif (nargin == 1)
    method = 0;
    olflag = 0;
    notches = 0;
    titleb = 'boxplot(s)';
elseif (nargin == 2)
    olflag = 0;
    titleb = 'boxplot(s)';
    notches = 0;
elseif ( nargin == 3 )
    notches = 0;
    titleb = 'boxplot(s)';
elseif ( nargin == 4 )
    titleb = 'boxplot(s)';
end

if (notches ~= 1 & notches ~= 0)
    disp('??? Error ==> boxplot')
    disp('Incorrect value of input no. 3')
    disp('See help boxplot for more details')
    return
end
    
if (olflag ~= 1 & olflag ~= 0)
    disp('??? Error ==> boxplot')
    disp('Incorrect value of input no. 2')
    disp('See help boxplot for more details')
    return
end 

[n, m] = size(x);  % n is the sample size of each set of data, m is the number of 
                       % sets of data. 

cellflag=iscell(x);
if (cellflag)
    n = length(x{1,1});
    nmax=n;
    nmin=n;
    for k=2:m
        lx=length(x{1,k});
        if ( nmin > lx )
            nmin = lx;
        end
        if ( nmax < lx )
            nmax = lx;
        end
    end
else 
    nmax=n;
    nmin=n;
end 
    

if (nmin < 1) 
   disp('??? Error ==> boxplot')
   disp('Length at least one set of input data is less than 1')
   return
end  


S=zeros(7,m);

methodold=method;

% Open figure window
hold on
   
%===============================================
%==========   Computational Section   ==========

mp1 = m+1;
for j =1:m
    if (cellflag)
        n= length(x{1,j});
        y = sort(x{1,j});  % Sort matrix columns
    else
        y=sort(x(:,j));
    end
    minx = y(1); % Find min
    maxx = y(n); % Find max
    
    if ( n == 1 ) 
         S(1,j) = minx;
         S(2,j) = minx;
         S(3,j) = minx;
         S(4,j) = minx;
         S(5,j) = minx;
         S(6,j) = minx;
         S(7,j) = 0; 
         scalefactor=0.4*sqrt(1/nmax);
         a = j-scalefactor;
         b = j+scalefactor;
         plot([a b], [minx minx],  'k-');
         
          % Define and set view window 
         
         lflag = 1;
         rflag = 1;
         
         continue
     elseif ( n == 2 & methodold == 0) % method 0 does not work with n = 2, so switch to method 1
         method = 1;
     end
        

    np1=n+1;
    medx = median(y);
    if (method)
        if (rem(n,2))
            medidx = np1/2;
            quart1 = median(y(1:medidx));
            quart3 = median(y(medidx:end));
        else
            nhalf=n/2;
            quart1 = median(y(1:nhalf));
            quart3 = median(y(nhalf+1:end));
        end
    else 
        nquarter = floor( 0.25*np1 );
        n3quarters = floor( 0.75*np1 );
        if ( rem(np1,4) ~= 0) 
            quart1 = 0.25*y(nquarter) + 0.75*y(nquarter+1);
            quart3 = 0.75*y(n3quarters) + 0.25*y(n3quarters+1);
        else 
            quart1 = y(nquarter);
            quart3 = y(n3quarters);
        end 
    end

    IQR=quart3-quart1;  %  Interquartile range 
  
    meany = mean(y);

    %======================================================
    %===   Assign summary statistics to output matrix   ===

    S(1,j) = minx;
    S(2,j) = quart1;
    S(3,j) = medx;
    S(4,j) = meany;
    S(5,j) = quart3;
    S(6,j) = maxx;
    S(7,j) = IQR;


    %==========================================
    %==========   Graphing Section   ==========


    % Set up 95% confidence intervals of the median for notches (if notches=1)
    if (notches)
        tmp = 1.58*IQR/sqrt(n);
        uppernotch = medx+tmp;
        lowernotch = medx-tmp;
    end


    % Compute inner and outer fences for outliers
    temp=1.5*IQR;
    RtInnerFence=quart3+temp;
    LtInnerFence=quart1-temp;
    RtOuterFence=RtInnerFence+temp;
    LtOuterFence=LtInnerFence-temp;


    % Define and set view window 
    if (~olflag)
        little = min(medx);
        big = max(medx);
    end
    lflag = 1;
    rflag = 1;
    
    yrinner = (y>RtInnerFence );
    ylinner = (y<LtInnerFence );
    if ( olflag == 0 ) 
        yrout=y(yrinner & y<RtOuterFence );
        ylout=y(ylinner & y>LtOuterFence );
        idxm=length(yrout);
        if ( length(yrout) ~= 0 & big < yrout(idxm) )
            big = yrout(idxm);
            rflag = 0;
        end
        if ( length(ylout) ~= 0 & little > ylout(1) )
            little = ylout(1);
            lflag = 0;
        end
    else
        ylout=y(ylinner);
        yrout=y(yrinner);
    end 
    maxxG = y(n-sum(yrinner)); 
    minxG = y(sum(ylinner)+1);
    
    scalefactor=0.4*sqrt(n/nmax);
    a = j-scalefactor;
    b = j+scalefactor;
    notchscale=0.6*scalefactor;
    an=j-notchscale;
    bn=j+notchscale;
    if (~notches)
        boxx=[a a b b a]; 
        boxy=[quart1 quart3 quart3 quart1 quart1];
        plot([a b], [medx medx],  'g-');
    else
        boxx=[a a an a a b b bn b b a ];
        boxy=[quart1 lowernotch medx uppernotch quart3 quart3 uppernotch medx lowernotch quart1 quart1];
        plot([an bn], [medx medx],  'g-');
    end
    plot(boxx, boxy, 'k-');
    plot([j j], [minxG quart1], 'k-');
    plot([j j], [quart3 maxxG], 'k-');
    plot([an bn], [maxxG maxxG], 'k-');
    plot([an bn], [minxG minxG], 'k-');
    plot(j,meany,'b+');    
    if (length(yrout) ~= 0) 
        plot([a b], [RtInnerFence RtInnerFence], 'r-.')
        plot(j*ones(size(yrout)), yrout,'*')
    end
    if (length(ylout) ~= 0) 
        plot([a b], [LtInnerFence LtInnerFence], 'r-.')
        plot(j*ones(size(ylout)), ylout,'*')
    end
    if (olflag == 1)
        if (length(yrout) ~= 0) 
            plot([a b], [RtOuterFence RtOuterFence], 'r-.')
        end
        if (length(ylout) ~= 0)
            plot([a b], [LtOuterFence LtOuterFence], 'r-.')
        end
    end
    
    method = methodold;  % Switch back to requested method. Don't bother to check if n = 2.
end   % End j-loop


if (rflag | olflag ) 
     big = max(S(6,:));
end
if (lflag | olflag ) 
     little = min(S(1,:));
end
if ( nmax > 1 ) 
    big = big+0.25*max(S(7,:));
    little = little-0.25*max(S(7,:));
else 
    big = big+0.25;
    little = little-0.25;     
end
axis( [0 mp1 little big] )
title(titleb)

hold off
