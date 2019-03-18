function [result,err] = err_divide(a,da,b,db)

%Main Function
result = a./b;

%Error Combination
err = sqrt( 1./(b.*b).*(da.*da) + (a.*a)./(b.*b.*b.*b).*(db.*db) );

