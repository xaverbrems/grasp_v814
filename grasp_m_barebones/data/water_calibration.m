function [foreimage,history] = water_calibration(foreimage,history)

global inst_params
global status_flags
global grasp_data

%warning off

%***** Divide by Sample By Volume *****
if  status_flags.calibration.volume_normalize_check ==1
    thickness = current_thickness;
    volume = status_flags.calibration.sample_area * thickness;
    for det = 1:inst_params.detectors
        detno=num2str(det);
        foreimage.(['data' detno]) = foreimage.(['data' detno]) / volume;
        foreimage.(['error' detno]) = foreimage.(['error' detno]) / volume;
    end
    foreimage.units = [foreimage.units '\\ cm3 '];
    history = [history, {['Data: Divided by Volume']}];
end

%***** Divide by pixel solid angle ******
if status_flags.calibration.solid_angle_check ==1
    for det = 1:inst_params.detectors
        detno=num2str(det);
        foreimage.(['data' detno]) = foreimage.(['data' detno]) ./ foreimage.(['qmatrix' detno])(:,:,10);
        foreimage.(['error' detno]) = foreimage.(['error' detno]) ./ foreimage.(['qmatrix' detno])(:,:,10);
    end
    foreimage.units = [foreimage.units '\\ \Delta\Omega '];
    history = [history, {['Solid Angle Correction:']}];
end

%***** Divide by water mean counts *****
if status_flags.calibration.scalar_check == 1
    index = data_index(99);
    for det = 1:inst_params.detectors
        detno=num2str(det);
        mean_intensity = grasp_data(index).(['mean_intensity' detno]){status_flags.calibration.det_eff_nmbr};
        mean_intensity_units = grasp_data(index).(['mean_intensity_units' detno]){status_flags.calibration.det_eff_nmbr};
        
        foreimage.(['data' detno]) = foreimage.(['data' detno]) ./ mean_intensity;
        foreimage.(['error' detno]) = foreimage.(['error' detno]) ./ mean_intensity;
    end
    foreimage.units = strrep(foreimage.units, mean_intensity_units, '');
    history = [history,{['Divide by calibration standard mean counts:' num2str(mean_intensity) ' ' mean_intensity_units]}];
end

%***** Multiply by water xsection *****
if status_flags.calibration.xsection_check == 1
    index = data_index(99);
    for det = 1:inst_params.detectors
        detno=num2str(det);
        xsection = grasp_data(index).calibration_xsection{status_flags.calibration.det_eff_nmbr};
        
        foreimage.(['data' detno]) = foreimage.(['data' detno]) .* xsection;
        foreimage.(['error' detno]) = foreimage.(['error' detno]) .* xsection;
    end
    foreimage.units = [foreimage.units 'Calibration Standard Units'];
    history = [history,{['Multipy by calibration standard X-section:' num2str(xsection) ]}];
end

    