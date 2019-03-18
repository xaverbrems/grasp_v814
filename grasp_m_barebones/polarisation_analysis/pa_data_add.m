function foreimage = pa_data_add(foreimage, backimage)

%This function performs the adds cross sections


%The formula is this:

%I_real = (I1 + I2)/2





global status_flags
global inst_params

%Loop though the detectors
for det = 1:inst_params.detectors
    detno=num2str(det);
    %Check if to use the thickness corrected transmission or just simple transmission
 %   if isfield(foreimage,['trans' num2str(det)])
  %      trans = foreimage.(['trans' num2str(det)]); %thickness corrected transmission matrix
  %  else
     %   trans = foreimage.trans; %Simple transmission scaler values
   % end
       
   
   [d,err_d] = err_add(foreimage.(['data' detno]),foreimage.(['error' detno]),backimage.(['data' detno]),backimage.(['error' detno]));
   intensity = d./2;
   intensity_error = err_d./2;
   


    %Create new fields in the foreground structure containing the correctly added intensity
    foreimage.(['data' detno]) = intensity;
    foreimage.(['error' detno]) = intensity_error;
end
    



