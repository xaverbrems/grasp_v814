function grasp_2d_nexus_write(directory,numor,data)

global grasp_env
global displayimage
global inst_params

vectors = data.params1;

switch grasp_env.inst
    case 'ILL_d22'
        inst_str = 'D22';
    case 'ILL_d33'
        inst_str = 'D33';
    case 'APEX'
        inst_str = 'D33';
    case 'ILL_d11'
        inst_str = 'D11';
end

%numor is numeric:  Pad with zeros to correct length
numor_str = num2str(numor);
numor_str = pad(numor_str,6,'left','0');
numor = str2num(numor_str);


%File Name
fname = fullfile(directory,[numor_str '.nxs']);

%Check if file already exists, if so, delete first
warning off
try;delete(fname); end
warning on

disp(['Writing NEXUS data to: ' fname]);

%Run Number

h5create(fname,['/entry0/run_number'],[1]);
h5write(fname, ['/entry0/run_number'], vectors.numor);

    
%Wavelength
h5create(fname,['/entry0/' inst_str '/selector/wavelength'],[1]);
h5write(fname, ['/entry0/' inst_str '/selector/wavelength'], vectors.wav);
h5create(fname,['/entry0/' inst_str '/selector/wavelength_res'],[1]);
h5write(fname, ['/entry0/' inst_str '/selector/wavelength_res'], vectors.deltawav);

%Col
h5create(fname,['/entry0/' inst_str '/collimation/actual_position'],[1]);
h5write(fname, ['/entry0/' inst_str '/collimation/actual_position'], vectors.col);



%San & Phi
if isfield(data,'san');
    h5create(fname,['/entry0/sample/san_actual'],[1]);
    h5write(fname, ['/entry0/sample/san_actual'], vectors.san);
end
if isfield(data,'phi')
    h5create(fname,['/entry0/sample/phi_actual'],[1]);
    h5write(fname, ['/entry0/sample/phi_actual'], vectors.phi);
end
if isfield(data,'omega')
    h5create(fname,['/entry0/sample/omega_actual'],[1]);
    h5write(fname, ['/entry0/sample/omega_actual'], vectors.omega);
end


%Det2
if isfield(data,'det2')
h5create(fname,['/entry0/' inst_str '/detector/det2_actual'],[1]);
h5write(fname, ['/entry0/' inst_str '/detector/det2_actual'], vectors.det2);
h5create(fname,['/entry0/' inst_str '/detector/det2_calc'],[1]);
h5write(fname, ['/entry0/' inst_str '/detector/det2_calc'], vectors.det2_calc);
end

%Det1
if isfield(data,'det1')
h5create(fname,['/entry0/' inst_str '/detector/det1_actual'],[1]);
h5write(fname, ['/entry0/' inst_str '/detector/det1_actual'], vectors.det1);
h5create(fname,['/entry0/' inst_str '/detector/det1_calc'],[1]);
h5write(fname, ['/entry0/' inst_str '/detector/det1_calc'], vectors.det1_calc);
end

if isfield(data,'det1_panel_separation') %i.e. D33 panels.
h5create(fname,['/entry0/' inst_str '/detector/det1_panel_separation'],[1]);
h5write(fname, ['/entry0/' inst_str '/detector/det1_panel_separation'], vectors.det1_panel_separation);
h5create(fname,['/entry0/' inst_str '/detector/OxL_actual'],[1]);
h5write(fname, ['/entry0/' inst_str '/detector/OxL_actual'], vectors.oxl);
h5create(fname,['/entry0/' inst_str '/detector/OxR_actual'],[1]);
h5write(fname, ['/entry0/' inst_str '/detector/OxR_actual'], vectors.oxr);
h5create(fname,['/entry0/' inst_str '/detector/OyT_actual'],[1]);
h5write(fname, ['/entry0/' inst_str '/detector/OyT_actual'], vectors.oyt);
h5create(fname,['/entry0/' inst_str '/detector/OyB_actual'],[1]);
h5write(fname, ['/entry0/' inst_str '/detector/OyB_actual'], vectors.oyb);
end

if isfield(data,'bx') %i.e. beamstop.
h5create(fname,['/entry0/' inst_str '/beamstop/bx_actual'],[1]);
h5write(fname, ['/entry0/' inst_str '/beamstop/bx_actual'], vectors.bx);
h5create(fname,['/entry0/' inst_str '/beamstop/by_actual'],[1]);
h5write(fname, ['/entry0/' inst_str '/beamstop/by_actual'], vectors.by);
end

if isfield(data,'potr') %i.e. polariser.
h5create(fname,['/entry0/collimation/PoTr_actual_position'],[1]);
h5write(fname, ['/entry0/collimation/PoTr_actual_position'], vectors.potr);
end

if isfield(data,'flipper_rfcurrent') %i.e. flipper.
h5create(fname,['/entry0/sample/psflipper_rf_actual_current'],[1]);
h5write(fname, ['/entry0/sample/psflipper_rf_actual_current'],vectors.flipper_rfcurrent );
h5create(fname,['/entry0/sample/psflipper_rf_actual_voltage'],[1]);
h5write(fname, ['/entry0/sample/psflipper_rf_actual_voltage'], vectors.flipper_rfvoltage);
h5create(fname,['/entry0/sample/psflipper_field_actual_current'],[1]);
h5write(fname, ['/entry0/sample/psflipper_field_actual_current'], vectors.flipper_fieldcurrent);
h5create(fname,['/entry0/sample/psflipper_field_actual_voltage'],[1]);
h5write(fname, ['/entry0/sample/psflipper_field_actual_voltage'], vectors.flipper_fieldvoltage);
end

if isfield(data,'temp') %i.e. temperature.
h5create(fname,['/entry0/sample/temperature'],[1]);
h5write(fname, ['/entry0/sample/temperature'], vectors.temp);
h5create(fname,['/entry0/sample/regulation_temperature'],[1]);
h5write(fname, ['/entry0/sample/regulation_temperature'], vectors.treg);
h5create(fname,['/entry0/sample/setpoint_temperature'],[1]);
h5write(fname, ['/entry0/sample/setpoint_temperature'], vectors.tset);
end

if isfield(data,'field') %i.e. magnet.
h5create(fname,['/entry0/sample/field_actual'],[1]);
h5write(fname, ['/entry0/sample/field_actual'], vectors.field);
end

if isfield(data,'ps1_i') %i.e. magnet.
h5create(fname,['/entry0/sample/ps1_current'],[1]);
h5write(fname, ['/entry0/sample/ps1_current'], vectors.ps1_i);
h5create(fname,['/entry0/sample/ps1_voltage'],[1]);
h5write(fname, ['/entry0/sample/ps1_voltage'], vectors.ps1_v);
end

%Lockin Amplifier
if isfield(data,'lockin_x')
h5create(fname,['/entry0/sample/lockin_actual_X1'],[1]);
h5write(fname, ['/entry0/sample/lockin_actual_X1'], vectors.lockin_x);
h5create(fname,['/entry0/sample/lockin_actual_Y1'],[1]);
h5write(fname, ['/entry0/sample/lockin_actual_Y1'], vectors.lockin_y);
h5create(fname,['/entry0/sample/lockin_actual_mag'],[1]);
h5write(fname, ['/entry0/sample/lockin_actual_mag'], vectors.lockin_mag);
h5create(fname,['/entry0/sample/lockin_actual_phase'],[1]);
h5write(fname, ['/entry0/sample/lockin_actual_phase'], vectors.lockin_phase);
end

%Loop though the number of detectors
for det = 1:inst_params.detectors
    detno=num2str(det);
    %Data Size
    data_size = size(data.(['data' detno]));
    %mask
    mask_data= reshape(data.(['mask' detno]),[1 data_size]);
    h5create(fname,['/entry0/data' detno '/mask' detno],[1, data_size]);
    h5write(fname, ['/entry0/data' detno '/mask' detno], mask_data);
    %Intensity
    det_data = reshape(data.(['data' detno]),[1 data_size]).*mask_data;
    h5create(fname,['/entry0/data' detno '/data' detno],[1, data_size]);
    h5write(fname, ['/entry0/data' detno '/data' detno], det_data);
    
    %Intensity Error
    err_det_data = reshape(data.(['error' detno]),[1 data_size]).*mask_data;
    h5create(fname,['/entry0/data' detno '/err_intensity' detno],[1, data_size]);
    h5write(fname, ['/entry0/data' detno '/err_intensity' detno], err_det_data);

    %Mod q
    mod_q_data = reshape(data.(['qmatrix' detno])(:,:,5),[1 data_size]);
    h5create(fname,['/entry0/data' detno '/mod_q' detno],[1, data_size]);
    h5write(fname, ['/entry0/data' detno '/mod_q' detno], mod_q_data);
    
    %qx
    qx_data = reshape(data.(['qmatrix' detno])(:,:,3),[1 data_size]);
    h5create(fname,['/entry0/data' detno '/qx' detno],[1, data_size]);
    h5write(fname, ['/entry0/data' detno '/qx' detno], qx_data);
    
    %qy
    qy_data = reshape(data.(['qmatrix' detno])(:,:,4),[1 data_size]);
    h5create(fname,['/entry0/data' detno '/qy' detno],[1, data_size]);
    h5write(fname, ['/entry0/data' detno '/qy' detno], qy_data);
    
    %qangle
    qangle_data = reshape(data.(['qmatrix' detno])(:,:,6),[1 data_size]);
    h5create(fname,['/entry0/data' detno '/qangle' detno],[1, data_size]);
    h5write(fname, ['/entry0/data' detno '/qangle' detno], qangle_data);

    
end
