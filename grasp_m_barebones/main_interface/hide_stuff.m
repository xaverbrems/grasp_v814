function hide_stuff

global status_flags
global grasp_data
global grasp_handles
global displayimage
global inst_params

%Shows or Hides various selectors, buttons, check-boxes etc depending on
%what is needed

%Auto Mask Threshold 
if status_flags.display.mask.auto_check ==1
    visible = 'on'; else visible = 'off'; end
set(grasp_handles.figure.auto_mask_threshold,'visible',visible,'string',num2str(status_flags.display.mask.auto_threshold));


%Depth max min
if status_flags.selector.depth_range_chk ==1; visible = 'on';
else visible = 'off'; end
set(grasp_handles.figure.dpth_range_chk,'value',status_flags.selector.depth_range_chk);
set(grasp_handles.figure.depth_range_min,'visible',visible);
set(grasp_handles.figure.depth_range_max,'visible',visible);
   
%Set data type above depth indicator
set(grasp_handles.figure.dpth_type,'string',displayimage.data_type);

%Software tube calibration
%set(grasp_handles.figure.detcal_chk,'value',status_flags.calibration.soft_det_cal);

%Manual Z-Scale
if status_flags.display.manualz.check==1; status = 'on'; else status = 'off'; end
set(grasp_handles.figure.manualz_min,'string', num2str(status_flags.display.manualz.min),'visible',status);
set(grasp_handles.figure.manualz_max,'string', num2str(status_flags.display.manualz.max),'visible',status);

%***** Get current displayed worksheet type *****
index = data_index(status_flags.selector.fw);
wks_type = grasp_data(index).type;

%Beam centre objects
if wks_type == 7 || wks_type == 8 || wks_type == 10 || wks_type == 99 || wks_type == 30 || wks_type == 31; status = 'off';
else status = 'on'; end
hide_gui('beamcentre','visible',status);
hide_gui('beamcentre','enable',status);


if isempty(inst_params.filename.lead_string); status = 'off'; else status = 'on'; end
set(grasp_handles.figure.data_lead,'visible',status,'string',inst_params.filename.lead_string);
set(grasp_handles.figure.data_lead_text,'visible',status);

if isempty(inst_params.filename.extension_string); status = 'off'; else status = 'on'; end
set(grasp_handles.figure.data_ext,'visible',status,'string',inst_params.filename.extension_string);


% %Extra gui for D16
% if strcmp(grasp_env.inst,'d16') || strcmp(grasp_env.inst,'d16_128'); status = 'on';
% else status = 'off'; end
status = 'off';
set(grasp_handles.figure.beamcentre_ctheta,'visible',status);
set(grasp_handles.figure.beamcentre_ctheta_text,'visible',status);

% %Extra gui for D22 or D33 rawdata
% if (strcmp(grasp_env.inst_option,'D33_Instrument_Comissioning') ||  strcmp(grasp_env.inst_option,'D33') ||  strcmp(grasp_env.inst_option,'Red_d22'));  status = 'on'; else status = 'off'; end
% set(grasp_handles.figure.raw_tube_data_chk,'visible',status);
% if status_flags.fname_extension.raw_tube_data_load ==0; status = 'off'; end
% set(grasp_handles.figure.detcal_chk_text,'visible',status);
% set(grasp_handles.figure.detcal_chk,'visible',status);


%Update grouped hidden worksheet number & depth
hide_gui('number_selectors_hide');
hide_gui('depth_selectors_hide');


%Worksheet objects
if wks_type == 7  || wks_type == 107 || wks_type == 99 || wks_type == 30 || wks_type == 31; %i.e. Det_eff or Masks
    hide_gui('background_wks','visible','off');
    hide_gui('cadmium_wks','visible','off');
    hide_gui('transmission','visible','off');
    hide_gui('dataload','enable','off');
    hide_gui('mask','enable','off');


elseif wks_type == 6 || wks_type == 8 || wks_type == 10 || wks_type == 11 || wks_type == 106; %i.e. Direct Beam

    hide_gui('background_wks','visible','off');
    hide_gui('cadmium_wks','visible','off');
    hide_gui('transmission','visible','off');
    hide_gui('dataload','enable','on');
    hide_gui('mask','enable','off');
    hide_gui('calibrate','enable','on');
    
elseif wks_type == 4 || wks_type == 9 || wks_type == 104;%i.e. Transmission Ts

    hide_gui('foreground_wks','visible','on');
    hide_gui('background_wks','visible','on');
    hide_gui('cadmium_wks','visible','off');
    hide_gui('ts','visible','on');
    hide_gui('ts','enable','on');
    hide_gui('te','visible','on');
    hide_gui('te','enable','off');
    hide_gui('trans_calc','enable','on');
    hide_gui('dataload','enable','on');
    hide_gui('mask','enable','off');
    hide_gui('calibrate','enable','on');
    hide_gui('subtract','visible','off');

elseif wks_type == 5 || wks_type == 105;%i.e. Transmission Te

    hide_gui('foreground_wks','visible','on');
    hide_gui('background_wks','visible','on');
    hide_gui('cadmium_wks','visible','off');
    hide_gui('ts','visible','on');
    hide_gui('ts','enable','off');
    hide_gui('te','visible','on');
    hide_gui('te','enable','on');
    hide_gui('trans_calc','enable','on');
    hide_gui('dataload','enable','on');
    hide_gui('mask','enable','off');
    hide_gui('calibrate','enable','on');
    hide_gui('subtract','visible','off');

elseif wks_type == 3 || wks_type == 103;  %Cadmium

    hide_gui('foreground_wks','visible','on');
    hide_gui('background_wks','visible','off');
    hide_gui('cadmium_wks','visible','off');
    hide_gui('transmission','visible','off');
    hide_gui('dataload','enable','on');
    hide_gui('mask','enable','on');
    hide_gui('calibrate','enable','off');
    hide_gui('subtract','visible','off');

    
elseif wks_type == 20 || wks_type == 21;  %2D Fit Results and Residual

    hide_gui('background_wks','visible','off');
    hide_gui('cadmium_wks','visible','off');
    hide_gui('transmission','visible','off');
    hide_gui('dataload','enable','off');
    hide_gui('mask','enable','off');
    
elseif wks_type == 22 || wks_type == 23;  %2D Fit Results and Residual
    
    hide_gui('cadmium_wks','visible','off');
    



    
    
else %Display All selectors

    hide_gui('worksheet','visible','on');
    hide_gui('dataload','enable','on');
    hide_gui('calibrate','enable','on');
    hide_gui('mask','enable','on');
    hide_gui('ts','visible','on');
    hide_gui('ts','enable','on');
    hide_gui('te','visible','on');
    hide_gui('te','enable','on');
    hide_gui('trans_calc','visible','off');

end


