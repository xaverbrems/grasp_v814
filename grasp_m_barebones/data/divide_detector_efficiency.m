function foreimage = divide_detector_efficiency(foreimage)

global inst_params
global grasp_data
global status_flags

eff_index = data_index(99); %index to the detector efficiency worksheet
eff_number = status_flags.calibration.det_eff_nmbr;


%Loop though the detector
warning off % gonna get some Nan's and Inf's here
for det = 1:inst_params.detectors
    detno=num2str(det);
    %Divide by efficiency map
    [foreimage.(['data' detno]),foreimage.(['error' detno])] = err_divide(foreimage.(['data' detno]),foreimage.(['error' detno]),grasp_data(eff_index).(['data' detno]){eff_number},grasp_data(eff_index).(['error' detno]){eff_number});
    
    %Create a nan and inf mask for the data in case of divide by zeros in the efficiency etc.
    foreimage.(['nan_mask' detno]) = ones(size(foreimage.(['data' detno])));
    
    temp = find(isnan(foreimage.(['data' detno])));
    foreimage.(['nan_mask' detno])(temp) = 0;
    foreimage.(['data' detno])(temp) = 0;
    foreimage.(['error' detno])(temp) = 0;
    
    
    temp = find(isinf(foreimage.(['data' detno])));
    foreimage.(['nan_mask' detno])(temp) = 0;
    foreimage.(['data' detno])(temp) = 0;
    foreimage.(['error' detno])(temp) = 0;
    
end
warning on;


