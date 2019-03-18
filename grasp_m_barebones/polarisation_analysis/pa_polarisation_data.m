function [foreimage] = pa_polarisation_data(foreimage, backimage)

%This function performs the calculation of the Polarisation of the
%scattered neutrons


%The formula is this:
%P = [(I_fore-I_back) / (I_fore+I_back)]





global inst_params

%Loop though the detectors
for det = 1:inst_params.detectors
 detno=num2str(det);
% %Generate a mask of NAN points to be excluded due to divide by zero errors.
% foreimage.(['nan_mask' detno]) = ones(size(foreimage.(['data' detno])));
% temp = find(backimage.(['data' detno]) =0);
% foreimage.(['nan_mask' detno])(temp) = 0;
% 
% %Generate a mask of Zero foreground (numerator) points to avoid zeros
% foreimage.(['zero_mask' detno]) = ones(size(foreimage.(['data' detno])));
% temp = find(foreimage.(['data' detno]) =0);
% foreimage.(['zero_mask' detno])(temp) = 0;

[a,err_a] = err_sub(foreimage.(['data' detno]),foreimage.(['error' detno]),backimage.(['data' detno]),backimage.(['error' detno]));
[b,err_b] = err_add(foreimage.(['data' detno]),foreimage.(['error' detno]),backimage.(['data' detno]),backimage.(['error' detno]));

[foreimage.(['data' detno]), foreimage.(['error' detno])] = err_divide(a,err_a,b,err_b);



end

