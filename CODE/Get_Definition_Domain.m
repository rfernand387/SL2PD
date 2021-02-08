function domain = Get_Definition_Domain(Data)
%  produces a coded definition domain for data
%  Computes N-dimensional histogram of data and codes non-zero bins\
%  using decile-1.  Then concatenates codes in a single number.
%
%  e.g. For N=2 , it would compute a 10x10 histogram.  If bin (1,3) was
% non zero it would add the code 20 to the domain.
%
% limited to 10 input bands
%
% Richard Fernandes 2020
% define edges of deciles

% get N d histogram
[M N] = size(Data);
[count edges mid loc] = histcn(Data, 0:0.1:1);
switch N
    case 1
        [i1] = ind2sub(size(count),find(count>0));    
        domain = i1*10^0;
    case 2
        [i1,i2] = ind2sub(size(count),find(count>0));    
        domain = i1*10^0+i2*(10^1);
    case 3 
        [i1,i2,i3] = ind2sub(size(count),find(count>0));    
        domain = i1*10^0+i2*(10^1)+i3*(10^2);
    case 4
        [i1,i2,i3,i4] = ind2sub(size(count),find(count>0));    
        domain = i1*10^0+i2*(10^1)+i3*(10^2)+i4*(10^3); 
    case 5
        [i1,i2,i3,i4,i5] = ind2sub(size(count),find(count>0));    
        domain = i1*10^0+i2*(10^1)+i3*(10^2)+i4*(10^3)+i5*(10^4);  
    case 6
        [i1,i2,i3,i4,i5,i6] = ind2sub(size(count),find(count>0));    
        domain = i1*10^0+i2*(10^1)+i3*(10^2)+i4*(10^3)+i5*(10^4)+i6*(10^4);    
    case 7
        [i1,i2,i3,i4,i5,i6,i7] = ind2sub(size(count),find(count>0));    
        domain = i1*10^0+i2*(10^1)+i3*(10^2)+i4*(10^3)+i5*(10^4)+i6*(10^4)+i7*(10^6);    
    case 8
        [i1,i2,i3,i4,i5,i6,i7,i8] = ind2sub(size(count),find(count>0));    
        domain = i1*10^0+i2*(10^1)+i3*(10^2)+i4*(10^3)+i5*(10^4)+i6*(10^5)+i7*(10^6)+i8*(10^7);   
    case 9
        [i1,i2,i3,i4,i5,i6,i7,i8,i9] = ind2sub(size(count),find(count>0));    
        domain = i1*10^0+i2*(10^1)+i3*(10^2)+i4*(10^3)+i5*(10^4)+i6*(10^5)+i7*(10^6)+i8*(10^7)+(i9*10^8);  
    case 10
        [i1,i2,i3,i4,i5,i6,i7,i8,i9,i10] = ind2sub(size(count),find(count>0));    
        domain = i1*10^0+i2*(10^1)+i3*(10^2)+i4*(10^3)+i5*(10^4)+i6*(10^5)+i7*(10^6)+i8*(10^7)+(i9*10^8)+i10*(10^9);   
    otherwise
         print("Truncating domain to first 8 input bands")
        [i1,i2,i3,i4,i5,i6,i7,i8,i9,i10] = ind2sub(size(count),find(count>0));    
        domain = i1*10^0+i2*(10^1)+i3*(10^2)+i4*(10^3)+i5*(10^4)+i6*(10^4)+i7*(10^6)+i8*(10^7)+(i9*10^8)+i10*(10^9); 
end
return






