function update_window_options

%Updates any active elements in any of the options windows

global grasp_handles
global status_flags
global grasp_data
global displayimage

if ishandle(grasp_handles.window_modules.radial_average.window) %i.e. Radial Average window is open
    radial_average_callbacks;
end

%Detector efficiency calculator window
if ishandle(grasp_handles.window_modules.detector_efficiency.window); %i.e detector efficiency window is open
    detector_efficiency_callbacks('average'); %just updates which buttons are availaible and displayed average
end

%Calibration options window
if ishandle(grasp_handles.window_modules.calibration.beam.wks)
    %Build direct beam selector
    beam_sheets = [6,8]; %Direct Beam, I0 Beam Intensity
    beam_selector_str = {};
    for n = 1:length(beam_sheets)
        index = data_index(beam_sheets(n));
        beam_selector_str{n} = grasp_data(index).name;
    end
    value = find(beam_sheets==status_flags.calibration.beam_worksheet);
    set(grasp_handles.window_modules.calibration.beam.wks,'string',beam_selector_str,'userdata',beam_sheets,'value',value,'callback','calibration_callbacks(''direct_beam_selector'');');
end

if ishandle(grasp_handles.window_modules.calibration.det_eff_nmbr)
    %Build detector efficiency map selector
    index = data_index(99);
    efficiency_selector_str = {};
    for n = 1:grasp_data(index).nmbr
        efficiency_selector_str{n} = num2str(n);
    end
    if isfield(status_flags.calibration,'det_eff_nmbr')
        value = status_flags.calibration.det_eff_nmbr;
    else value = 1; %for compatibility with older graspv6 projects
    end
  
    set(grasp_handles.window_modules.calibration.det_eff_nmbr,'string',efficiency_selector_str,'value',value,'callback','calibration_callbacks(''det_eff_selector'');');
end

if ishandle(grasp_handles.window_modules.calibration.water.cal_scalar_value)
    index = data_index(99);
    set(grasp_handles.window_modules.calibration.water.cal_scalar_value,'string',num2str(grasp_data(index).mean_intensity1{status_flags.calibration.det_eff_nmbr}));
    set(grasp_handles.window_modules.calibration.water.cal_scalar_units,'string',grasp_data(index).mean_intensity_units1{status_flags.calibration.det_eff_nmbr});
    set(grasp_handles.window_modules.calibration.water.cal_xsection,'string',num2str(grasp_data(index).calibration_xsection{status_flags.calibration.det_eff_nmbr}));
end
    


if ishandle(grasp_handles.window_modules.calibration.beam.nmbr)
    set(grasp_handles.window_modules.calibration.beam.nmbr,'string',num2str(status_flags.calibration.beam_number));
end

if ishandle(grasp_handles.window_modules.calibration.beam.dpth)
    index = data_index(status_flags.calibration.beam_worksheet);
    dpth_sum_allow = grasp_data(index).sum_allow;
    depth = status_flags.calibration.beam_depth- dpth_sum_allow;
    if depth >0
        depth_str = num2str(depth);
    else
        depth_str = 'sum';
    end
    set(grasp_handles.window_modules.calibration.beam.dpth,'string',depth_str);
end

%calibration window sample thickness
if ishandle(grasp_handles.window_modules.calibration.window)
    thickness = current_thickness;
    set(grasp_handles.window_modules.calibration.waterbeam.thickness,'string',num2str(thickness))
   
end

%calibration window sample illumination
if ishandle(grasp_handles.window_modules.calibration.window)
    set(grasp_handles.window_modules.calibration.waterbeam.sample_illumination,'string',num2str(status_flags.calibration.sample_illumination))
   
end


%Update sectors
if ishandle(grasp_handles.window_modules.sector.window); sector_callbacks; end

%Update sector boxes
if ishandle(grasp_handles.window_modules.sector_box.window); sector_box_callbacks; end

%Update strips
if ishandle(grasp_handles.window_modules.strips.window); strips_callbacks; end

%Update boxes
if ishandle(grasp_handles.window_modules.box.window); box_callbacks; end

%Update XtraPlot
if ishandle(grasp_handles.window_modules.xtraplot.window); xtraplot_callbacks; end
    
