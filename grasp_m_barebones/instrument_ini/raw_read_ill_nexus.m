function numor_data = raw_read_ill_nexus(fname)

global inst_params
global status_flags
global grasp_env

if strcmp(grasp_env.inst,'ILL_d22'); inst_str = 'D22';
elseif strcmp(grasp_env.inst,'ILL_d33'); inst_str = 'D33';
else strcmp(grasp_env.inst,'ILL_d11'); inst_str = 'D11';
end

param = [];   %Parameters structure to be built

%Read ILL SANS Nexus Format Data (HDF)
warning on
fileinfo=h5info(fname);
entryName =  fileinfo.Groups(1).Name; %Root folder in HDF file


%***** D22 HPLC data *****
try param.ChromatoData1 = h5read(fname,strcat(entryName,['/' inst_str '/hplc/ChromatoData1'])); catch; end
try param.ChromatoData2 = h5read(fname,strcat(entryName,['/' inst_str '/hplc/ChromatoData2'])); catch; end
try param.ChromatoData3 = h5read(fname,strcat(entryName,['/' inst_str '/hplc/ChromatoData3'])); catch; end
try param.ChromatoData4 = h5read(fname,strcat(entryName,['/' inst_str '/hplc/ChromatoData4'])); catch; end
try param.XChromato = h5read(fname,strcat(entryName,['/' inst_str '/hplc/XChromato'])); catch; end
try param.XChromatoInFraction = h5read(fname,strcat(entryName,['/' inst_str '/hplc/XChromatoInFraction'])); catch; end
try param.XChromatoInMI = h5read(fname,strcat(entryName,['/' inst_str '/hplc/XChromatoInMI'])); catch; end
try param.XChromatoInTime = h5read(fname,strcat(entryName,['/' inst_str '/hplc/XChromatoInTime'])); catch; end


%***** D22 Sample Env *****
try param.bath_res_sample_temp = h5read(fname,strcat(entryName,'/sample/bath_reservoir_sample_temperature')); catch; end
try param.bath_sample_humidity = h5read(fname,strcat(entryName,'/sample/bath_sample_humidity')); catch; end
try param.bath_sample_temperature = h5read(fname,strcat(entryName,'/sample/bath_sample_temperature')); catch; end



% %Lockin Amplifier
% try
%     param(inst_params.vectors.lockin_x) = h5read(fname,strcat(entryName,'/sample/lockin_actual_X1'));
%     param(inst_params.vectors.lockin_y) = h5read(fname,strcat(entryName,'/sample/lockin_actual_Y1'));
%     param(inst_params.vectors.lockin_mag) = h5read(fname,strcat(entryName,'/sample/lockin_actual_mag'));
%     param(inst_params.vectors.lockin_phase) = h5read(fname,strcat(entryName,'/sample/lockin_actual_phase'));
% catch
% end



%***** Read User, Sample and Environment Parameters *****
%Numor
param.numor = h5read(fname,strcat(entryName,'/run_number'));

%User Information
try
    temp1 = hdf5read(fname,strcat(entryName,'/user/name'));
    param.user = temp1.Data;
catch
    param.user = 'No Name';
end

%Date and time from start_time
try
    temp1 = hdf5read(fname,strcat(entryName,'/start_time'));
    param.start_date = temp1.Data(1:10);
    param.start_time = temp1.Data(11:18);
catch
    param.start_date = [];
    param.start_time = [];
end
try
    temp1 = hdf5read(fname,strcat(entryName,'/end_time'));
    param.end_date = temp1.Data(1:10);
    param.end_time = temp1.Data(11:18);
catch
    param.end_date = [];
    param.end_time = [];
end

%Acquisition Time
try param.aq_time = h5read(fname,strcat(entryName,'/duration')); %Seconds
catch; param.aq_time =1; end

%Subtitle
try
    temp1 = hdf5read(fname,strcat(entryName,'/sample_description'));
    param.subtitle = temp1.Data;
catch
    param.subtitle = 'No Subtitle';
end


%***** Read Instrument configuration & Measurement parameters ******

%Detector Distance & Motors
%Det 1 (D33 Panel Detector)
try param.det1 = (h5read(fname,strcat(entryName,['/' inst_str '/detector/det1_actual'])));catch; end %m
try param.detcalc1 = (h5read(fname,strcat(entryName,['/' inst_str '/detector/det1_calc'])));catch; end %m
try param.det1_panel_offset = (h5read(fname,strcat(entryName,['/' inst_str '/detector/det1_panel_separation'])));catch; end
try param.oxl = (h5read(fname,strcat(entryName,['/' inst_str '/detector/OxL_actual'])));catch; end
try param.oxr = (h5read(fname,strcat(entryName,['/' inst_str '/detector/OxR_actual'])));catch; end
try param.oyt = (h5read(fname,strcat(entryName,['/' inst_str '/detector/OyT_actual'])));catch; end
try param.oyb = (h5read(fname,strcat(entryName,['/' inst_str '/detector/OyB_actual'])));catch; end

%Single Detector or Det2 (D33 Rear Detector)
try param.det2 = (h5read(fname,strcat(entryName,['/' inst_str '/detector/det2_actual'])));
catch
    %Alternative name for det2
    try param.det2 = (h5read(fname,strcat(entryName,['/' inst_str '/detector/det_actual']))); catch; end %m
end

try param.detcalc2 = (h5read(fname,strcat(entryName,['/' inst_str '/detector/det2_calc'])));
catch
    %Alternative name for det2
    try param.detcalc2 = (h5read(fname,strcat(entryName,['/' inst_str '/detector/det_calc'])));
    catch
        param.detcalc = param.det2;
    end %m
end

try param.dtr = (h5read(fname,strcat(entryName,['/' inst_str '/detector/dtr_actual']))); catch; end %m
try param.dan = (h5read(fname,strcat(entryName,['/' inst_str '/detector/dan_actual']))); catch; end%m
%Compatability det parameters
param.det = param.det2; %main detector
param.detcalc = param.detcalc2;


% %Detector pixel size
% param(inst_params.vectors.pixel_x) = (h5read(fname,strcat(entryName,'/D33/detector/pixel_size_x'))); %mm
% param(inst_params.vectors.pixel_y) = (h5read(fname,strcat(entryName,'/D33/detector/pixel_size_y'))); %mm
% if param(inst_params.vectors.pixel_x) ~= inst_params.detector1.pixel_size(1); %Default Pixel X-setting
%     disp(['Modifying Pixel X size from ' num2str(inst_params.detector1.pixel_size(1)) ' to ' num2str(param(inst_params.vectors.pixel_x))]);
%     inst_params.detector1.pixel_size(1) = param(inst_params.vectors.pixel_x);
% end
% if param(inst_params.vectors.pixel_y) ~= inst_params.detector1.pixel_size(2); %Default Pixel Y-setting
%     disp(['Modifying Pixel Y size from ' num2str(inst_params.detector1.pixel_size(2)) ' to ' num2str(param(inst_params.vectors.pixel_y))]);
%     inst_params.detector1.pixel_size(2) = param(inst_params.vectors.pixel_y);
% end


%Wavelength
try
    param.wav = h5read(fname,strcat(entryName,['/' inst_str '/selector/wavelength']));
catch
    param.wav = inf;
end
try
    temp = h5read(fname,strcat(entryName,['/' inst_str '/selector/wavelength_res']));
    param.deltawav = temp/100;
catch
    disp('Wavelength resolution is not in data file: using default 0.1');
    param.deltawav = 0.1;
end
try param.sel_rpm = h5read(fname,strcat(entryName,['/' inst_str '/selector/rotation_speed'])); catch; end
try param.seltrs = h5read(fname,strcat(entryName,['/' inst_str '/selector/seltrs_actual'])); catch; end


%Chopper Parameters
try param.chopper1_phase = h5read(fname,strcat(entryName,['/' inst_str '/chopper1/phase'])); catch; end
try param.chopper1_speed = h5read(fname,strcat(entryName,['/' inst_str '/chopper1/rotation_speed'])); catch; end
try param.chopper2_phase = h5read(fname,strcat(entryName,['/' inst_str '/chopper2/phase'])); catch; end
try param.chopper2_speed = h5read(fname,strcat(entryName,['/' inst_str '/chopper2/rotation_speed'])); catch; end
try param.chopper3_phase = h5read(fname,strcat(entryName,['/' inst_str '/chopper3/phase'])); catch; end
try param.chopper3_speed = h5read(fname,strcat(entryName,['/' inst_str '/chopper3/rotation_speed'])); catch; end
try param.chopper4_phase = h5read(fname,strcat(entryName,['/' inst_str '/chopper4/phase'])); catch; end
try param.chopper4_speed = h5read(fname,strcat(entryName,['/' inst_str '/chopper4/rotation_speed'])); catch; end

tof_dist = []; %Tof distances for detectors 1-5
try tof_dist(1) = h5read(fname,strcat(entryName,['/' inst_str '/tof/tof_distance_detector1'])); catch; end
try tof_dist(2) = h5read(fname,strcat(entryName,['/' inst_str '/tof/tof_distance_detector2'])); catch; end
try tof_dist(3) = h5read(fname,strcat(entryName,['/' inst_str '/tof/tof_distance_detector3'])); catch; end
try tof_dist(4) = h5read(fname,strcat(entryName,['/' inst_str '/tof/tof_distance_detector4'])); catch; end
try tof_dist(5) = h5read(fname,strcat(entryName,['/' inst_str '/tof/tof_distance_detector5'])); catch; end
try master_spacing = h5read(fname,strcat(entryName,['/' inst_str '/tof/tof_master_pair_separation'])); catch; end


%BeamStop
try param.bx = h5read(fname,strcat(entryName,['/' inst_str '/beamstop/bx_actual'])); catch; end
try param.by = h5read(fname,strcat(entryName,['/' inst_str '/beamstop/by_actual'])); catch; end

%Attenuator position
try
    param.att_type = h5read(fname,strcat(entryName,['/' inst_str '/attenuator/position']));
catch
    param.att_type = 0; %default out
end

%Attenuation1 Value
try
    param.attenuation = h5read(fname,strcat(entryName,['/' inst_str '/attenuator/attenuation_coefficient']));
    if iscell(param.attenuation)
        param.attenuation = str2num(param.attenuation{1});
    else
        param.attenuation = double(param.attenuation);
    end
    if param.attenuation == 0; param.attenuation = 1; end
catch
    try
        param.attenuation = h5read(fname,strcat(entryName,['/' inst_str '/attenuator/attenuation_value']));
        if iscell(param.attenuation)
            param.attenuation = str2num(param.attenuation{1});
        else
            param.attenuation = double(param.attenuation);
        end
        if param.attenuation == 0; param.attenuation = 1; end
    catch
        %Patch nominal attenuation values if the actual value doesn't exist in the file
        param.attenuation = inst_params.attenuators(param.att_type+1);
    end
end

%Catch for wrong D33 attenuation being written to the file
if strcmp(inst_str,'D33')
    if param.att_type >0 %i.e. attenuator is in
        if param.attenuation <50 % check there is a sensible value if not, use defaults
            
            disp('Patching bad attenuation value in file to defaults')
            %Nominal D33 attenuation values for Att 1, 2, 3
            %112, 447, 1790
            if param.att_type == 1; param.attenuation = 112;
            elseif param.att_type ==2; param.attenuation = 447;
            elseif param.att_type ==3; param.attenuation = 1790;
            end
        end
    end
end

   

%ChopperAttenuator2
try
    param.att2= double(h5read(fname,strcat(entryName,['/' inst_str '/attenuator2/attenuation_value']))); %Absolute attenuation value - not index
    if param.att2 == 0; param.att2 = 1; end
catch
    
end


%Collimation
param.col = (h5read(fname,strcat(entryName,['/' inst_str '/collimation/actual_position']))); %m;

%Source Size
try
    temp = double((h5read(fname,strcat(entryName,['/' inst_str '/collimation/ap_size']))))/1000; %m
    param.source_ap_x = temp(1);
    param.source_ap_y = temp(2);
catch
    disp('Warning:  Source size is not defined in the data file')
    try
        disp('Trying guide_size specified in instrument config as default source size (inst_params.guide_size = [x,y];')
        param.source_ap_x = inst_params.guide_size(1);
        param.source_ap_y = inst_params.guide_size(2);
        
    catch
        disp('Failed:  Using default source size of 40 x 40 mm')
        param.source_ap_x = 40e-3;
        param.source_ap_y = 40e-3;
    end
    
end

% %D22 slits
% try param(inst_params.vectors.vslit_center) = h5read(fname,strcat(entryName,['/' inst_str '/collimation/vertical_slit_center'])); catch; end
% try param(inst_params.vectors.vslit_width) = h5read(fname,strcat(entryName,['/' inst_str '/collimation/vertical_slit_width_actual'])); catch; end
% try param(inst_params.vectors.hslit_center) = h5read(fname,strcat(entryName,['/' inst_str '/collimation/horizontal_slit_center'])); catch; end
% try param(inst_params.vectors.hslit_width) = h5read(fname,strcat(entryName,['/' inst_str '/collimation/horizontal_slit_width_actual'])); catch; end


% %Collimation & Diaphragm Motors
% try param.dia1 = (h5read(fname,strcat(entryName,['/' inst_str '/collimation/Dia1_actual_position']))); catch;
% end%mm;
% try param.col1 = (h5read(fname,strcat(entryName,['/' inst_str '/collimation/Coll1_actual_position']))); catch;
% end%mm;
% try param.dia2 = (h5read(fname,strcat(entryName,['/' inst_str '/collimation/Dia2_actual_position']))); catch;
% end%mm;
% try param.col2 = (h5read(fname,strcat(entryName,['/' inst_str '/collimation/Coll2_actual_position']))); catch;
% end%mm;
% try param.dia3 = (h5read(fname,strcat(entryName,['/' inst_str '/collimation/Dia3_actual_position']))); catch;
% end%mm;
% try param.col3 = (h5read(fname,strcat(entryName,['/' inst_str '/collimation/Coll3_actual_position']))); catch;
% end%mm;
% try param.dia4 = (h5read(fname,strcat(entryName,['/' inst_str '/collimation/Dia4_actual_position']))); catch;
% end%mm;
% try param.col4 = (h5read(fname,strcat(entryName,['/' inst_str '/collimation/Coll4_actual_position']))); catch;
% end%mm;
% try param.dia5 = (h5read(fname,strcat(entryName,['/' inst_str '/collimation/Dia5_actual_position']))); catch;
% end%mm;

%Polariser Position
try param.potr = h5read(fname,strcat(entryName,['/' inst_str '/collimation/PoTr_actual_position'])); catch; end

% %Flipper Status
% try param(inst_params.vectors.flipper_rfcurrent) = h5read(fname,strcat(entryName,'/sample/psflipper_rf_actual_current')); catch; end
% try param(inst_params.vectors.flipper_rfvoltage) = h5read(fname,strcat(entryName,'/sample/psflipper_rf_actual_voltage')); catch; end
% try param(inst_params.vectors.flipper_fieldcurrent) = h5read(fname,strcat(entryName,'/sample/psflipper_field_actual_current')); catch; end
% try param(inst_params.vectors.flipper_fieldvoltage) = h5read(fname,strcat(entryName,'/sample/psflipper_field_actual_voltage')); catch; end

%Wavelength Filter Position
try param.wvtr = h5read(fname,strcat(entryName,['/' inst_str '/collimation/WvTr_actual_position'])); catch; end

%Reactor Power
try param.reactor_power = h5read(fname,strcat(entryName,'/reactor_power')); catch; end %MW

%Sample
try param.thickness = (h5read(fname,strcat(entryName,'/sample/thickness'))); catch; end%m

%Sample Motors
try param.san = (h5read(fname,strcat(entryName,'/sample/san_actual'))); catch; end%m
try param.phi = (h5read(fname,strcat(entryName,'/sample/phi_actual'))); catch; end%m
try param.sdi1 = (h5read(fname,strcat(entryName,'/sample/sdi1_actual'))); catch; end%m
try param.sdi = (h5read(fname,strcat(entryName,'/sample/sdi_actual'))); catch; end%m
try param.sdi2 = (h5read(fname,strcat(entryName,'/sample/sdi2_actual'))); catch; end%m
try param.trs = (h5read(fname,strcat(entryName,'/sample/trs_actual'))); catch; end%m
try param.sht = (h5read(fname,strcat(entryName,'/sample/sht_actual'))); catch; end%m
try param.str = (h5read(fname,strcat(entryName,'/sample/str_actual'))); catch; end%m
try param.chpos = (h5read(fname,strcat(entryName,'/sample/sample_changer_value'))); catch; end%m
try param.omega = (h5read(fname,strcat(entryName,'/sample/omega_actual')));catch; end %m
try param.TrMicro = h5read(fname,strcat(entryName,'/sample/TrMicro_actual')); catch; end
try param.TrMicro_offset = h5read(fname,strcat(entryName,'/sample/TrMicro_offset')); catch; end
try param.TrMicro_requested = h5read(fname,strcat(entryName,'/sample/TrMicro_requested')); catch; end

%Sample environment
try param.temp = (h5read(fname,strcat(entryName,'/sample/temperature'))); catch; end
try param.treg = (h5read(fname,strcat(entryName,'/sample/regulation_temperature'))); catch; end
try param.tset = (h5read(fname,strcat(entryName,'/sample/setpoint_temperature'))); catch; end
try param.bath1_temp = (h5read(fname,strcat(entryName,'/sample/bath1_regulation_temperature'))); catch; end
try param.bath1_set = (h5read(fname,strcat(entryName,'/sample/bath1_setpoint_temperature'))); catch; end
try param.bath2_temp = (h5read(fname,strcat(entryName,'/sample/bath2_regulation_temperature'))); catch; end
try param.bath2_set = (h5read(fname,strcat(entryName,'/sample/bath2_setpoint_temperature'))); catch; end
try param.bath_switch = (h5read(fname,strcat(entryName,'/sample/bath_selector_actual'))); catch; end
try param.air_temp = (h5read(fname,strcat(entryName,'/sample/air_temperature'))); catch; end
try param.rack_temp = (h5read(fname,strcat(entryName,'/sample/rack_temperature'))); catch; end

%Power Supplies  -  D22 names
try param.ps1_i = (h5read(fname,strcat(entryName,'/sample/ps1_current'))); catch; end
try param.ps1_v = (h5read(fname,strcat(entryName,'/sample/ps1_voltage'))); catch; end
try param.ps2_i = (h5read(fname,strcat(entryName,'/sample/ps2_current'))); catch; end
try param.ps2_v = (h5read(fname,strcat(entryName,'/sample/ps2_voltage'))); catch; end
try param.ps3_i = (h5read(fname,strcat(entryName,'/sample/ps3_current'))); catch; end
try param.ps3_v = (h5read(fname,strcat(entryName,'/sample/ps3_voltage'))); catch; end

%Power Supplies  -  D33 names
try param.ps1_i = (h5read(fname,strcat(entryName,'/sample/pselectromag_actual_current'))); catch; end
try param.ps1_v = (h5read(fname,strcat(entryName,'/sample/pselectromag_actual_voltage'))); catch; end
try param.ps2_i = (h5read(fname,strcat(entryName,'/sample/psflipper_field_actual_current'))); catch; end
try param.ps2_v = (h5read(fname,strcat(entryName,'/sample/psflipper_field_actual_voltage'))); catch; end
try param.ps3_i = (h5read(fname,strcat(entryName,'/sample/psflipper_rf_actual_current'))); catch; end
try param.ps3_v = (h5read(fname,strcat(entryName,'/sample/psflipper_rf_actual_voltage'))); catch; end

%Magnet
try param.field = (h5read(fname,strcat(entryName,'/sample/field_actual'))); catch; end

%Shear
try param.sheer_rate = (h5read(fname,strcat(entryName,'/sample/shearrate_actual'))); catch; end





%***** Read Detector Data, Monitor and Time Slices *****
try param.array_counts = (h5read(fname,strcat(entryName,['/' inst_str '/detector/detsum']))); catch; end
try param.count_rate = (h5read(fname,strcat(entryName,['/' inst_str '/detector/detrate']))); catch; end

%***** Determine Measurement Mode, Single, Kinetic or TOF *****
try mode = h5read(fname,strcat(entryName,'/mode')); catch; mode = 0; end

switch mode
    case 0
        numor_data.file_type = 'mono';
    case 1 %tof - arranged differently to D22
        numor_data.file_type = 'tof';
        %read tof parameters
        tof_params = h5read(fname,strcat(entryName,'/monitor1/time_of_flight'));
        param.tof_width = tof_params(1); %microS
        param.tof_channels = tof_params(2);
        param.tof_delay = tof_params(3); %microS
        param.pickups = h5read(fname,strcat(entryName,'/monitor1/nbpickup'));
        param.tof_period=param.tof_width*param.tof_channels + param.tof_delay;
        try  tof_mode =  h5read(fname,strcat(entryName,['/' inst_str '/tof/tof_mode'])); ; catch; tof_mode = 0; end
    case 3    
        numor_data.file_type = 'kinetic';
        %read time slices
        slices= double(h5read(fname,strcat(entryName,'/slices')));
        frame_time = slices(1)/2; %time lapse of the first frame - added to below with subsequent frames
        param.pickups = h5read(fname,strcat(entryName,'/nbrepaint'));
    
    case 4 %inelastic tof (OLD D22 TOF Format < May 2013)
        numor_data.file_type = 'tof_inelastic';
        %read tof parameters
        tof_params = h5read(fname,strcat(entryName,'/monitor1/time_of_flight'));
        param.tof_width = tof_params(1); %microS
        param.tof_channels = tof_params(2); %microS
        param.tof_delay = tof_params(3); %microS
        param.pickups = h5read(fname,strcat(entryName,'/monitor1/nbpickup'));
        param.tof_period=param.tof_width*param.tof_channels + param.tof_delay;
    otherwise
        numor_data.file_type = 'unknown';
end
disp(['File type is ' numor_data.file_type ', mode = ' num2str(mode)]);


for det = 1:inst_params.detectors
    detno=num2str(det);
    disp(['Reading Detector #' detno ' Data']);
    %Detector Data - all frames
    numor_data.(['data' detno]) = [];
    try data = double(h5read(fname,strcat(entryName,['/data' detno '/MultiDetector' detno '_data']))); %Beginning 2018
    catch try data = double(h5read(fname,strcat(entryName,['/data' detno '/MultiDetector' detno '_linear_data']))); %Pre2018 D33 format
        catch try data = double(h5read(fname,strcat(entryName,['/data' detno '/data' detno]))); %An older format
            catch try data = double(h5read(fname,strcat(entryName,'/data/MultiDetector_linear_data'))); %Pre 2018 D22 format
                catch try data = double(h5read(fname,strcat(entryName,'/data/MultiDetector_data'))); %Beginning 2018
                    catch try data = double(h5read(fname,strcat(entryName,'/data/data'))); %The first D22 nexus format
                        catch try data = double(h5read(fname,strcat(entryName,'/data/detector_data'))); %The D11 nexus format
                            end; end; end; end; end; end; end
    
    %Patch D11 data to always upscale if necessary to 256 x 256
    if strcmp(grasp_env.inst,'ILL_d11')
        if size(data,2) == 128 && size(data,3) == 128
            disp('Upscaling to 256 x 256 Pixels')
            data =  data(:,repmat(1:end,[2 1]),repmat(1:end,[2 1]));
            data = data/4;
        end
    end
    
    temp_data_size = size(data);
    switch numor_data.file_type
        case 'mono'
            
            data = reshape(data,temp_data_size(3),temp_data_size(2),temp_data_size(1));
            data_size = size(data);
            if length(data_size) <3; data_size(3) =1; end
            numor_data.n_frames = data_size(3);
        
        case 'kinetic'
            if length(temp_data_size) == 4
                data = reshape(data,temp_data_size(1),temp_data_size(3),temp_data_size(4));
            else
                data = reshape(data,temp_data_size(1),temp_data_size(2),temp_data_size(3));
            end
            data_size = size(data);
            numor_data.n_frames = data_size(1);
            param.aq_time = param.aq_time / numor_data.n_frames;
        
        
        case 'tof'
            data = reshape(data,temp_data_size(1),temp_data_size(2),temp_data_size(3));
            data_size = size(data);
            numor_data.n_frames = data_size(1);
            
            if tof_mode == 22
                
                disp(['File type is variable TOF binning, mode = ' num2str(tof_mode)]);
                %calculate TOF wavelength
                
                vtof_time =  double(h5read(fname,strcat(entryName,['/' inst_str '/tof/chwidth_sum'])))/1e9; %s
                vtof_time_width = double(h5read(fname,strcat(entryName,['/' inst_str '/tof/chwidth_times'])));%Mikro s
                n=min(numel(vtof_time),numel(vtof_time_width))
                vtof_time=vtof_time(1:n);
                vtof_time_width=vtof_time_width(1:n);
                tof_wavs= (vtof_time-vtof_time_width/2/1e6)/tof_dist(det)*3956.04;
                
                tof_res = ones(numor_data.n_frames,1)*master_spacing/tof_dist(det);
                tof_acq_duration=param.aq_time;
                
            else
                %read tof wavelengths
                try
                    tof_wavs =  h5read(fname,strcat(entryName,['/' inst_str '/tof/tof_wavelength_detector' detno]));
                    tof_res = ones(numor_data.n_frames,1)*master_spacing/tof_dist(det);
                    param.aq_time = param.aq_time / numor_data.n_frames;
                catch
                    disp('TOF with no wavelength / time channel in data file');
                    disp('Patching Monochromatic Wavelength & Resolution for each time frame');
                    tof_wavs = ones(numor_data.n_frames,1)* param.wav;
                    tof_res = ones(numor_data.n_frames,1)* param.deltawav;
                    param.aq_time = param.aq_time / numor_data.n_frames;
                end
            end
        
        case 'tof_inelastic'
            data = reshape(data,temp_data_size(1),temp_data_size(2),temp_data_size(3));
            data_size = size(data);
            %if length(data_size) <3; data_size(3) =1; end
            numor_data.n_frames = data_size(1);
            
            %read tof wavelengths
            try
                tof_wavs =  h5read(fname,strcat(entryName,['/' inst_str '/tof/tof_wavelength_detector' detno]));
                tof_res = ones(numor_data.n_frames,1)*master_spacing/tof_dist(det);
            catch
                disp('TOF with no wavelength / time channel in data file');
                disp('Patching Monochromatic Wavelength & Resolution for each time frame');
                tof_wavs = ones(numor_data.n_frames,1)* param.wav;
                tof_res = ones(numor_data.n_frames,1)* param.deltawav;
            end
    end
    
    disp(['Number of Frames = ' num2str(numor_data.n_frames)]);
    disp('Using SQRT(I) errors')
    
    %Read Monitor Data - all frames
    try monitor = double(h5read(fname,strcat(entryName,'/monitor1/data'))); catch; monitor = 1; end
    
    %***** Loop though the frames and organize the data array as Grasp likes it *****
    numor_data.(['data' detno]) = []; numor_data.(['error' detno]) = [];
    for n = 1:numor_data.n_frames
        param.monitor = monitor(n);
        
        
        if strcmp(numor_data.file_type,'mono')
            frame_data = reshape(data(:,:,n),data_size(2),data_size(1)); %data frame
            numor_data.(['data' detno])(:,:,n) = frame_data;
            numor_data.(['error' detno])(:,:,n) = sqrt(frame_data); %errors
            param.ex_time = param.aq_time/numor_data.n_frames;
            param.elapsed_time = param.ex_time /2;
            
        elseif strcmp(numor_data.file_type,'kinetic')
            frame_data = reshape(data(n,:,:),data_size(2),data_size(3)); %data frame
            numor_data.(['data' detno])(:,:,n) = frame_data;
            numor_data.(['error' detno])(:,:,n) = sqrt(frame_data); %errors
            param.ex_time = slices(n) * param.pickups;
            if n>1; frame_time = frame_time + slices(n); end
            param.elapsed_time = frame_time;
            param.slice_time_width = slices(n);
            
        elseif strcmp(numor_data.file_type,'tof')
            frame_data = reshape(data(n,:,:),data_size(2),data_size(3)); %data frame
            numor_data.(['data' detno])(:,:,n) = frame_data;
            numor_data.(['error' detno])(:,:,n) = sqrt(frame_data); %errors
            
            param.ex_time = param.tof_width * param.pickups / 1e6; %microS to S 
            if tof_mode==22
                
            param.frame_time = vtof_time(n);
            param.slice_time_width = vtof_time_width(n);
            param.aq_time =  vtof_time_width(n)* tof_acq_duration/param.tof_period;
            else
               
            param.frame_time = (param.tof_delay + param.tof_width * (n-1) + param.tof_width/2)/1e6; %s
            param.slice_time_width = param.tof_width/1e6; 
            
            end
            param.wav = tof_wavs(n);
            param.deltawav = tof_res(n);
            param.elapsed_time = param.ex_time /2;
            
        elseif strcmp(numor_data.file_type,'tof_inelastic')
            frame_data = reshape(data(n,:,:),data_size(2),data_size(3)); %data frame
            numor_data.(['data' detno])(:,:,n) = frame_data;
            numor_data.(['error' detno])(:,:,n) = sqrt(frame_data); %errors
            param.ex_time = param.tof_width * param.pickups / 1e6; %microS to S
            param.frame_time  = (param.tof_delay + param.tof_width * (n-1) + param.tof_width/2 + status_flags.normalization.d33_tof_delay) /1e6;
            param.slice_time_width = param.tof_width/1e6;
            param.elapsed_time = param.ex_time /2;
        end
        
        param.array_counts = sum(sum(frame_data)); %Total Detector counts - all frames
        
        %Frame Parameters
        numor_data.(['params' detno]){n} = param;
    end
    
end



%***** Time shift for Multiple detector positons in tof *****
if inst_params.detectors >1 && strcmp(numor_data.file_type,'tof')
    
    for det = 2:5
        detno=num2str(det);
        disp(['Time shifting panel #' detno ' data to match rear detector']);
        
        %Old Panel Wavs & New Panel Wavs to match the rear detector
        old_wavs = []; new_wavs = [];
        for n = 1:length(numor_data.(['params' detno]))
            old_wavs = [old_wavs, numor_data.(['params' detno]){n}.wav];
            new_wavs = [new_wavs, numor_data.params1{n}.wav];
            numor_data.(['params' detno]){n}.wav = numor_data.params1{n}.wav;
        end
        
        %Don't bother time shifting if wavs are the same
        if old_wavs ~= new_wavs
            
            %Calculate wavlength channel widths
            old_wav_width = diff(old_wavs); old_wav_width(end+1) = old_wav_width(end); %because diff leaves n-1 values
            new_wav_width = diff(new_wavs); new_wav_width(end+1) = new_wav_width(end); %because diff leaves n-1 values
            
            %Prepare data arrays for interp3
            data_size = size(numor_data.(['data' detno]));
            old_wavs = double(old_wavs); new_wavs = double(new_wavs); %need double for interp3
            [x,y,z] = meshgrid([1:data_size(2)],[1:data_size(1)],old_wavs); %pad out the wavelength matrix
            [~,~,z_new] = meshgrid([1:data_size(2)],[1:data_size(1)],new_wavs); %pad out the wavelength matrix
            V = numor_data.(['data' detno]); %The panel data
            
            %Need to normalise each fram for the new wavelength 'width' of each frame
            for n = 1:length(new_wavs)
                V(:,:,n) = V(:,:,n) * (new_wav_width(n) ./ old_wav_width(n)); %must be able to do this without a loop???
            end
            %Interpolate
            numor_data.(['data' detno]) = (interp3(x,y,z,V,x,y,z_new,'nearest',0)); %This is the raw interpolated data
            numor_data.(['error' detno]) = sqrt(numor_data.(['data' detno]));
        end
    end
end

