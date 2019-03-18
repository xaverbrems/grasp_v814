function [foreimage] = divide_data_correction(foreimage, backimage)

%This function performs the 'Divide Foreground & Background worksheets'
%Ignore cadmium worksheets
%Ignore transmission

%The formula is this:
%I_real = [I_sample / I_back]

%where:
%	I_sample = measured scattering from sample
%	I_back = background scattering from holder



global inst_params

%Loop though the detectors
for det = 1:inst_params.detectors
detno=num2str(det);
%Generate a mask of NAN points to be excluded due to divide by zero errors.
foreimage.(['nan_mask' detno]) = ones(size(foreimage.(['data' detno])));
temp = find(backimage.(['data' detno]) ==0);
foreimage.(['nan_mask' detno])(temp) = 0;

%Generate a mask of Zero foreground (numerator) points to avoid zeros
foreimage.(['zero_mask' detno]) = ones(size(foreimage.(['data' detno])));
temp = find(foreimage.(['data' detno]) ==0);
foreimage.(['zero_mask' detno])(temp) = 0;


[foreimage.(['data' detno]), foreimage.(['error' detno])] = err_divide(foreimage.(['data' detno]),foreimage.(['error' detno]),backimage.(['data' detno]),backimage.(['error' detno]));










end

