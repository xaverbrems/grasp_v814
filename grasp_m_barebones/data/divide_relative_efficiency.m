function foreimage = divide_relative_efficiency(foreimage)

global inst_params

%Loop though the detector
for det = 1:inst_params.detectors
    detno=num2str(det);
      
    %Divide by detector relative efficiency (relative to rear detector (det 1)
    foreimage.(['data' detno]) = foreimage.(['data' detno]) / inst_params.(['detector' detno]).relative_efficiency;
    foreimage.(['error' detno]) = foreimage.(['error' detno]) / inst_params.(['detector' detno]).relative_efficiency;
end


