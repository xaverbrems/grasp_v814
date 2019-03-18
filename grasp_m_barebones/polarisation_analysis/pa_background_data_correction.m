function foreimage = pa_background_data_correction(foreimage, backimage,trans)

%This function performs the 'Standard SANS background subtraction
%The current transmission to use comes in with the foreimage

%The formula is this:

%I_real = [1/Ts*Te]*I_sample - [1/Te]*I_back 

%where:
%	I_sample = spin leackage corrected scattering from sample 
%	I_back = spin leackage corrected background scattering from holder 
%	Ts = transmission of sample ONLY (i.e. sample trans / empty trans)
%	Te = transmission of empty ONLY (i.e. empty trans / direct trans)

%Split in to parts for ease of error calculation;
%   c = Ts*Te;
%   d = I_sample/c;
%   e = Iback /Te;
%   I_real = d - e

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
       
   [c,err_c] = err_multiply(trans.ts,trans.err_ts,trans.te,trans.err_te); %Ts, err_Ts, Te err_Te
   [d,err_d] = err_divide(foreimage.(['data' detno]),foreimage.(['error' detno]),c,err_c);
   intensity = d;
   intensity_error = err_d;
   
    
    if status_flags.pa_correction.bck_check == 1
    [e,err_e] = err_divide(backimage.(['data' detno]),backimage.(['error' detno]),trans.te,trans.err_te); %Te err_Te
    [intensity, intensity_error] = err_sub(d,err_d,e,err_e);%Final Foreground - Background Calculation
    end
    %     %Insert Background Shifter in here
    %     i = findobj('tag','background_shifter_window');
    %     if not(isempty(i)) & flag == 1; %i.e. Only do background shift if Shifter Window is open AND it is foreground data
    %         [e,err_e,history_string] = background_shifter(d,err_d,e,err_e,history_string);
    %     end
    
    
    

    %Create new fields in the foreground structure containing the correctly subtracted intensity
    foreimage.(['data' detno]) = intensity;
    foreimage.(['error' detno]) = intensity_error;
end
    



