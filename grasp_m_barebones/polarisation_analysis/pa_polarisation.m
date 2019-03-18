function polarisation = pa_polarisation(i00,i10,i11,i01)

%based on Krycka Pol-Corr J. Appl. Cryst. (2012). 45, 546–553

%Check if errors exist
if length(i00) <2; i00(2) = 0; end
if length(i10) <2; i10(2) = 0; end
if length(i11) <2; i11(2) = 0; end
if length(i01) <2; i01(2) = 0; end

% Flipping Ratio (FR) of polarizer and analyser
[polarisation.fr_phi, polarisation.err_fr_phi] = err_divide(i00(1),i00(2),i01(1),i01(2));
% Flipping Ratio (FR) of polarizer, flipper and analyser
[polarisation.fr_f, polarisation.err_fr_f] = err_divide(i11(1),i11(2),i10(1),i10(2));

%combined polarisation of analyzer and polarizer: polarisation.phi = (i00-i01)/(i00+i01);
[temp1,temp2] = err_sub(i00(1),i00(2),i01(1),i01(2));
[temp3,temp4] = err_add(i00(1),i00(2),i01(1),i01(2));

[polarisation.phi, polarisation.err_phi] = err_divide(temp1,temp2,temp3,temp4);

%polarisation of flipper: polarisation.pf = (i11-i10)/(i11+i10)/polarisation.phi;
[temp1,temp2] = err_sub(i11(1),i11(2),i10(1),i10(2));
[temp3,temp4] = err_add(i11(1),i11(2),i10(1),i10(2));
[temp3,temp4] = err_multiply(temp3,temp4,polarisation.phi,polarisation.err_phi);
% [temp1,temp2] = err_sub(i11(1),i11(2),i10(1),i10(2));
% [temp3,temp4] = err_sub(i00(1),i00(2),i01(1),i01(2));

[polarisation.pf, polarisation.err_pf] = err_divide(temp1,temp2,temp3,temp4);




