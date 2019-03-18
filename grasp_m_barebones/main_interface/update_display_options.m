function update_display_options

%Updates the display option checkboxes etc.
%depending on status_flags

global status_flags
global grasp_handles
global grasp_data


%Update Figure Display option checkboxes
set(grasp_handles.figure.logz_chk,'value',status_flags.display.log);
set(grasp_handles.figure.image_chk,'value',status_flags.display.image);
set(grasp_handles.figure.contour_chk,'value',status_flags.display.contour);
set(grasp_handles.figure.smooth_chk,'value',status_flags.display.smooth.check);
set(grasp_handles.figure.back_chk,'value',status_flags.selector.b_check);
set(grasp_handles.figure.cad_chk,'value',status_flags.selector.c_check);
set(grasp_handles.figure.beamcentre_lock_chk,'value',status_flags.beamcentre.cm_lock);
set(grasp_handles.figure.mask_chk,'value',status_flags.display.mask.check);
set(grasp_handles.figure.auto_mask_chk,'value',status_flags.display.mask.auto_check);
set(grasp_handles.figure.trans_tslock_chk,'value',status_flags.transmission.ts_lock);
set(grasp_handles.figure.thickness_lock_chk,'value',status_flags.thickness.thickness_lock);
set(grasp_handles.figure.trans_telock_chk,'value',status_flags.transmission.te_lock);
set(grasp_handles.figure.beamcentre_lock_chk,'value',status_flags.beamcentre.cm_lock);
%set(grasp_handles.figure.detcal_chk,'value',status_flags.calibration.d22_soft_det_cal);
set(grasp_handles.figure.calibrate_chk,'value',status_flags.calibration.calibrate_check);
set(grasp_handles.figure.pa_correction_chk,'value',status_flags.pa_correction.calibrate_check);

%set(grasp_handles.figure.rotate_chk,'value',status_flags.display.rotate.check);
% if status_flags.display.rotate.check ==1; status = 'on'; else status = 'off'; end
% set(grasp_handles.figure.rotate_angle,'visible',status);


%Update dynamic menus

%Normalisation parameter option
%Correct for sum-worksheets
    if status_flags.selector.fd == 1
        dpth = 1;
    else
        dpth = status_flags.selector.fd - grasp_data(status_flags.selector.fw).sum_allow;
    end
%string = rot90(fieldnames(grasp_data(status_flags.selector.fw).params1{status_flags.selector.fn}{status_flags.selector.fd-grasp_data(status_flags.selector.fw).sum_allow}));
index = data_index(status_flags.selector.fw);
string = rot90(fieldnames(grasp_data(index).params1{status_flags.selector.fn}{dpth}));

value = find(strcmp(string,status_flags.analysis_modules.boxes.parameter));
if isempty(value); value = 1; end
%Delete old menu item
delete(grasp_handles.menu.data.normalization.param);
grasp_handles.menu.data.normalization.param = uimenu(grasp_handles.menu.data.normalization.root,'label','Parameter: #','tag','data_norm');
for n = 1:length(string)
    grasp_handles.menu.data.normalization.param_list(n) = uimenu(grasp_handles.menu.data.normalization.param,'label',string{n},'tag','data_norm','userdata',string{n},'callback','data_menu_callbacks(''param_normalization'');');
end



