function [result,err] = err_ln(a,da)

%Main Function
result = log(a); %Natural Ln

%Error Combination
err = sqrt( 1./(a.*a).*(da.*da));


