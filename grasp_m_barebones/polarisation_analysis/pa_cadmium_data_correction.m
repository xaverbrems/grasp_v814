function paimage = pa_cadmium_data_correction(paimage, cadmiumimage)

%This function performs the background noise subtraction

%The formula is this:

%I_real = I - I_cad

%where:
%	I_sample = measured scattering
%	%   I_cad = cadmium background


%Split in to parts for ease of error calculation;
%   a = (I_sample - I_cad)
%   b = (I_back - I_cad)
%   c = Ts*Te;
%   d = a/c;
%   e = b /Te;
%   I_real = d - e


global inst_params

%Loop though the detectors
for det = 1:inst_params.detectors
    detno=num2str(det);
   
    
    [intensity,intensity_error] = err_sub(paimage.(['data' detno]),paimage.(['error' detno]),cadmiumimage.(['data' detno]),cadmiumimage.(['error' detno]));
 

    %Create new fields in the foreground structure containing the correctly subtracted intensity
    paimage.(['data' detno]) = intensity;
    paimage.(['error' detno]) = intensity_error;
end
    



