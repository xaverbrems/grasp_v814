function [result,err] = err_multiply(a,da,b,db)

%Main Function
result = a.*b;

%Error Combination
err = sqrt((b.*b).*(da.*da) + (a.*a).*(db.*db));

