function [foreimage,history] = direct_beam_calibration(foreimage,history)

global inst_params
global status_flags
global grasp_data

warning off


%***** Divide by Sample By Volume *****
if  status_flags.calibration.volume_normalize_check ==1
    thickness = current_thickness;
    volume = status_flags.calibration.sample_area * thickness * status_flags.calibration.sample_illumination;
    for det = 1:inst_params.detectors
        detno=num2str(det);
        foreimage.(['data' detno]) = foreimage.(['data' detno]) / volume;
        foreimage.(['error' detno]) = foreimage.(['error' detno]) / volume;
    end
    foreimage.units = [foreimage.units '\\ cm3 '];
    %history = [history, {['Data: Divided by Volume ' num2str(volume) ' cm3']}];
    history = [history, {['Data: Divided by Volume']}];
    history = [history, {['Sample Thickness is: ' num2str(thickness) ' cm']}];    
    foreimage.scale_factor = foreimage.scale_factor / volume; %keep a track on data scaling
end

%***** Divide by pixel solid angle ******
if status_flags.calibration.solid_angle_check ==1
    for det = 1:inst_params.detectors
        detno=num2str(det);
        foreimage.(['data' detno]) =  foreimage.(['data' detno]) ./ foreimage.(['qmatrix' detno])(:,:,10);
        foreimage.(['error' detno]) =  foreimage.(['error' detno]) ./ foreimage.(['qmatrix' detno])(:,:,10);
    end
    foreimage.scale_factor = foreimage.scale_factor / mean(mean(foreimage.(['qmatrix' num2str(1)])(:,:,10))); %keep a track on data scaling
    foreimage.units = [foreimage.units '\\ \Delta\Omega '];
    history = [history, {['Solid Angle Correction:']}];
end

%***** Divide by beam flux *****
if status_flags.calibration.beam_flux_check==1
    beam_index = data_index(status_flags.calibration.beam_worksheet);
    
    %Note: at the moment the empty beam worksheet, worksheet
    %number and depth are hard-wired to correspond to the
    %foreground worksheet.  This may be changed in the future
    status_flags.calibration.beam_number = status_flags.selector.fn;
    status_flags.calibration.beam_depth = status_flags.selector.fd;
    %don't correct the depth for the sum - this is done already in retrieve data
    
    %***** Direct Beam Intensity *****
    %NOTE Empty beam intensity comes ONLY from the Rear Detector (1)
    %For D33, FRONT detector scattering data is also normalised to the
    %direct beam intensity for the REAR detector.
    
    %Retrieve direct beam data
    empty_beam = retrieve_data([beam_index, status_flags.calibration.beam_number, status_flags.calibration.beam_depth]);

    %Normalise direct beam data for deadtime, monitor & attenuator
    empty_beam = normalize_data(empty_beam);
    
    empty_beam_detector = 1; %This is the detector to use the empty beam intensity from for ALL other detectors
    detno=num2str(empty_beam_detector);
    if sum(sum(empty_beam.(['data' detno]))) ~=0 %Check if direct beam worksheet is empty otherwise don't bother with below
        
        %Divide direct beam data also by detector efficiency
        if status_flags.calibration.det_eff_check == 1
            %Retrieve the efficiency data
            index = data_index(99);
            efficiency_data = grasp_data(index).(['data' detno]){1};
            efficiency_error = grasp_data(index).(['error' detno]){1};
            %Only divide direct beam where there are valid efficiency data
            temp = find(efficiency_data~=0);
            [empty_beam.(['data' detno])(temp),empty_beam.(['error' detno])(temp)] = err_divide(empty_beam.(['data' detno])(temp),empty_beam.(['error' detno])(temp),efficiency_data(temp),efficiency_error(temp));
            
            %IS THIS BELOW A BIT DODGY?  SHOULD THESE INF's AND NAN's BE MASKED AS WELL
            %Correct all NAN's - set them to zero.
            temp = find(isnan(empty_beam.(['data' detno]))); empty_beam.(['data' detno])(temp) = 0;
            temp = find(isnan(empty_beam.(['error' detno]))); empty_beam.(['error' detno])(temp) = 0;
            %Correct all INF's - set them to zero.
            temp = find(isinf(empty_beam.(['data' detno]))); empty_beam.(['data' detno])(temp) = 0;
            temp = find(isinf(empty_beam.(['error' detno]))); empty_beam.(['error' detno])(temp) = 0;
            %history = [history, {['Data: Corrected for Detector Efficiency (doesn''t change magnitude but contains curvature correction)']}];
        end
        
        
        %Take the sum of the empty beam worksheet
        emptybeam_sum = sum(sum(empty_beam.(['data' detno])));
        emptybeam_sum_error = sqrt(sum(sum(empty_beam.(['error' detno]).^2)));
        
        %Convert to flux by dividing by beam area
        emptybeam_flux = emptybeam_sum / status_flags.calibration.sample_area;
        emptybeam_flux_error = emptybeam_sum_error / status_flags.calibration.sample_area;
        %additional \\cm2 units done later to correctly combine with volume units of cm3
        
        %***** Divide all detectors data by the single direct beam intensity *****
        for det = 1:inst_params.detectors
            detno=num2str(det);
            %Divide scattering data by emptybeam
            [foreimage.(['data' detno]), foreimage.(['error' detno])] = err_divide(foreimage.(['data' detno]), foreimage.(['error' detno]),emptybeam_flux, emptybeam_flux_error);
        end
        
        foreimage.scale_factor = foreimage.scale_factor / emptybeam_flux; %keep a track on data scaling

    end
    
    foreimage.units = strrep(foreimage.units, empty_beam.units, '');
    temp = findstr(foreimage.units,'\\ cm3');
    if not(isempty(temp));
        %Do something simple for the cm units
        foreimage.units = strrep(foreimage.units, '\\ cm3', 'cm-1');
    else
        foreimage.units = ['cm2 ' foreimage.units];
    end
    history = [history, {['Divide data by empty beam flux, I0, from worksheet: ' grasp_data(beam_index).name ' ' num2str(status_flags.calibration.beam_number) ' ' num2str(status_flags.calibration.beam_depth)]}];
    
    
end


warning on


