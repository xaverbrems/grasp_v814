function binned_array = rebin(array,bin_edges)
%array is a n x m array.  Data is re binned relative to the first column.
%where m >4.
%Second column is value
%Third column is error in value
%Forth, fifth, sixth ..etc.  colum is another parameter rebinned averaged in the same way as the second column - used her for the delta_q resolution
%delta_q_lambda, delta_q_theta etc.
%The last column is the number of elements that went into each bin
%bin_edges is a list of the bin edges. There are bin_edges - 1 bins in total.

%Check which binning method to use.  Original CDD method is faster for few
%bins and lots of data,  new sparse method is faster for many bins

if length(bin_edges)/length(array) < 5e-5
    
    binned_array = find_binning(array,bin_edges);
    
else
    try
        binned_array = sparse_binning(array,bin_edges);
    catch %Sparse binning sometimes fails with the bin_resolution bit.  If so, use the old method
        disp('SPARSE binning failed:  Useing FIND binning')
        binned_array = find_binning(array,bin_edges);
    end
end





    function binned_array = find_binning(array,bin_edges)
        
        
        disp('Binning Version ''FIND''')
        %***** CDD's Old method used for a very long time thoughout Grasp History *****
        %Loops though bins finding points that satisfy and averaging
        [array_length,array_width] = size(array);
        if array_width<4
            array(:,4) = zeros(array_length,1);
        end
        number_bins = length(bin_edges)-1 ;
        
        %Columns are Av_x, Av_Y, Av_Err_y, Av_col4, number points used
        binned_array = zeros(number_bins-1, array_width+2); %pre-allocate
        warning off
        bin_resolution = diff(bin_edges);
        for n = 1:number_bins
            temp = find((array(:,1) >= bin_edges(n)) &  (array(:,1) < bin_edges(n+1)));
            if not(isempty(temp)) %i.e. values falling between the bin_edges have been found
                number_elements = length(temp);
                
                binned_array(n,1) = sum(array(temp,1)) / number_elements; %x_position is the average of all x's gone into the bin
                binned_array(n,2) = sum(array(temp,2)) / number_elements;
                %Weighted average on statistical quality
                %binned_array(m,2) = sum(array(temp,2).*(array(temp,3)./array(temp,2))) / sum((array(temp,3)./array(temp,2)));
                
                binned_array(n,3) = sqrt( sum(array(temp,3).^2)) / number_elements;
                
                for column = 4:array_width
                    binned_array(n,column) = sum(array(temp,column)) / number_elements;
                end
                binned_array(n,array_width+1) = bin_resolution(n); %Bin resolution FWHM TOPHAT
                binned_array(n,array_width+2) = number_elements; %Nu. elements used in averaging
            end
        end
        warning on
        %strip the zero rows from the binned array (if there are any)
        temp = sum(binned_array,2)~=0;
        binned_array = binned_array(temp,:);
        %***** End CDD's old method *****
        
    end
end


function binned_array = sparse_binning(array,bin_edges)



%***** NEW rebinning method based upon the bindata.m and bindata2.m methods *****
%***** NO LOOPING! *****
%***** Implimented in Grasp 6th December 2017 *****
%***** x10 faster ******
%By Patrick Mineault
%Refs: https://xcorr.net/?p=3326
%      http://www-pord.ucsd.edu/~matlab/bin.htm
%See:  https://xcorr.net/2013/12/23/fast-1d-and-2d-data-binning-in-matlab/

disp('Binning Version ''SPARSE''')
binned_array = [];

[array_length,array_width] = size(array);
if array_width<4
    array(:,4) = zeros(array_length,1);
end
%Columns are Av_x, Av_Y, Av_Err_y, Av_col4, number points used
%binned_array = zeros(number_bins, array_width+2); %pre-allocate
bin_resolution = diff(bin_edges);
[~,whichedge] = histc(array(:,1),bin_edges');
bins = min(max(whichedge,1),length(bin_edges)-1);

xpos = ones(size(bins,1),1);
ns = sparse(bins,xpos,1);

%Average q
qsum = sparse(bins,xpos,array(:,1));
binned_array(:,1) = full(qsum)./(full(ns));

%Intensity (mean)
Isum = sparse(bins,xpos,array(:,2));
binned_array(:,2) = full(Isum)./(full(ns));

%Error (Added in quadriture)
Esum = sqrt(sparse(bins,xpos,array(:,3).^2));
binned_array(:,3) = full(Esum)./(full(ns));

%All additional columns to average
for column = 4:array_width
    colsum = sparse(bins,xpos,array(:,column));
    binned_array(:,column) = full(colsum)./full(ns);
end

%Bin resolution
binned_array(:,array_width+1) = bin_resolution; %Bin resolution FWHM TOPHAT
binned_array(:,array_width+2) = ns; %Nu. elements used in averaging
%***** End New rebinning method *****
binned_array = binned_array(isfinite(binned_array(:,1)),:);
binned_array = sortrows(binned_array);

end
