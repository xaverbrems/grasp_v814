function pa_supermirror = pa_supermirror_check(i00,i10,i11,i01,tpara,tanti,pf)

%Function calculates the expected supermirror polarisation for which SF channels are equal based on the determined 3He cell parameters.
%Needed to check the degree of beam depolarisation and 3He parameter refinement.

%Check if errors exist
if length(i00) <2; i00(2) = 0; end
if length(i10) <2; i10(2) = 0; end
if length(i11) <2; i11(2) = 0; end
if length(i01) <2; i01(2) = 0; end
if length(tpara) <2; tpara(2) = 0; end
if length(tanti) <2; tanti(2) = 0; end
if length(pf) <2; tanti(2) = 0; end

 % Polarisation of Supermirror
% PSM -> (I00 tpara - I01 tpara - I10 tpara - I11 tpara + I00 tanti - 
%     I01 tanti - I10 tanti + I11 tanti)/(I10 tpara - I11 tpara + 
%     I00 PF tpara + I01 PF tpara - I10 tanti - I11 tanti - I00 PF tanti - 
%     I01 PF tanti);
[temp3,temp4] = err_add(tpara(1),tpara(2),tanti(1),tanti(2));
[temp5,temp6] = err_sub(tpara(1),tpara(2),tanti(1),tanti(2));



%numerator
[temp1,temp2] = err_sub(i00(1),i00(2),i10(1),i10(2));
[temp1,temp2] = err_add(temp1,temp2,i01(1),i01(2));
[temp1,temp2] = err_sub(temp1,temp2,i11(1),i11(2));
[temp1,temp2] = err_multiply(temp1,temp2,temp5,temp6);

%denominator
[temp11,temp12]= err_sub(i00(1),i00(2),i01(1),i01(2));
[temp11,temp12]= err_multiply(temp11,temp12,pf(1),pf(2));
[temp11,temp12]= err_add(temp11,temp12,i10(1),i10(2));
[temp11,temp12]= err_sub(temp11,temp12,i11(1),i11(2));
[temp11,temp12]= err_multiply(temp11,temp12,temp3,temp4);


[pa_supermirror.p, pa_supermirror.err_p] = err_divide(temp1,temp2,temp11,temp12);




