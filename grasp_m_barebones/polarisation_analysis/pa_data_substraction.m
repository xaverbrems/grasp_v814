function foreimage = pa_data_substraction(foreimage, backimage)

%This function performs the 'Standard SANS background subtraction
%The current transmission to use comes in with the foreimage

%The formula is this:

%I_real = I_sample - I_reference 

%where:
%	I_sample = spin leackage corrected scattering from sample 
%	I_back = spin leackage corrected background scattering from holder 
%	Ts = transmission of sample ONLY (i.e. sample trans / empty trans)
%	Te = transmission of empty ONLY (i.e. empty trans / direct trans)



global status_flags
global inst_params

%Loop though the detectors
for det = 1:inst_params.detectors
    detno=num2str(det);

   

    [intensity, intensity_error] = err_sub(foreimage.(['data' detno]),foreimage.(['error' detno]),backimage.(['data' detno]),backimage.(['error' detno]));%Final Foreground - Background Calculation
    foreimage.(['data' detno]) = intensity;
    foreimage.(['error' detno]) = intensity_error;
end
    



