function ill_nexus_write(directory,numor,data,inst_name)


%numor is numeric:  Pad with zeros to correct length
numor_str = num2str(numor);
numor_str = pad(numor_str,6,'left','0');
numor = str2num(numor_str);


%File Name
fname = fullfile(directory,[numor_str '.nxs']);

disp(['Writing NEXUS data to: ' fname]);

%File mode - Mono, TOF etc.
h5create(fname,['/entry0/mode'],[1]);
h5write(fname, ['/entry0/mode'], data.mode);

%TOF Parameters
if isfield(data,'tof_params')
    h5create(fname,['/entry0/monitor1/time_of_flight'],[3]);
    h5write(fname, ['/entry0/monitor1/time_of_flight'], data.tof_params);
end
if isfield(data,'nb_pickups')
    h5create(fname,['/entry0/monitor1/nbpickup'],[1]);
    h5write(fname, ['/entry0/monitor1/nbpickup'], data.nb_pickups);
end

%Run Number
h5create(fname,['/entry0/run_number'],[1]);
h5write(fname, ['/entry0/run_number'], data.numor);

%Measurement time
h5create(fname,['/entry0/duration'],[1]);
h5write(fname, ['/entry0/duration'], data.time);

%Monitor (same as time)
mons = length(data.monitor);
h5create(fname,['/entry0/monitor1/data'],[mons]);
h5write(fname, ['/entry0/monitor1/data'], data.monitor);

%Write detector data
if data.detectors ==1
    data_size = size(data.data);
    if length(data_size) ==2
        data_size = [1, data_size];
    end
    
    det_data = data.data;
    % det_data = reshape(det_data,[1, data_size]);
    det_data = reshape(det_data,[data_size]);
        
    h5create(fname,['/entry0/data/data'],[data_size]);
    h5write(fname, ['/entry0/data/data'], det_data);
else
    %Write Detector Data
    for det = 1:data.detectors
        detno=num2str(det);
        det_data = data.(['data' detno]);
        data_size = size(det_data);
        if length(data_size) ==2
            data_size = [1, data_size];
        end
        
        
        % det_data = reshape(det_data,[1, data_size]);
        det_data = reshape(det_data,[data_size]);
        %  h5create(fname,['/entry0/data' detno '/data' detno],[1, data_size]);
        h5create(fname,['/entry0/data' detno '/data' detno],[data_size]);
        h5write(fname, ['/entry0/data' detno '/data' detno], det_data);
    end
end

%Attenuator
if isfield(data,'att')
    att = data.att;
else
    att = 0; %default: out
end
h5create(fname,['/entry0/' inst_name '/attenuator/position'],[1]);
h5write(fname, ['/entry0/' inst_name '/attenuator/position'], att);

%Attenuation
if isfield(data,'attenuation')
    attenuation = data.attenuation;
else
    attenuation = 1; %default: out
end
h5create(fname,['/entry0/' inst_name '/attenuator/attenuation'],[1]);
h5write(fname, ['/entry0/' inst_name '/attenuator/attenuation'], attenuation);

%Wavelength
if isfield(data,'wav')
    h5create(fname,['/entry0/' inst_name '/selector/wavelength'],[1]);
    h5write(fname, ['/entry0/' inst_name '/selector/wavelength'], data.wav);
    h5create(fname,['/entry0/' inst_name '/selector/wavelength_res'],[1]);
    h5write(fname, ['/entry0/' inst_name '/selector/wavelength_res'], data.dwav*100);
end

%TOF Wavelength
if isfield(data,'tof_wavs')
    for det = 1:data.detectors
        detno=num2str(det);        
        h5create(fname,['/entry0/' inst_name '/tof/tof_wavelength_detector' detno],[length(data.tof_wavs)]);
        h5write(fname, ['/entry0/' inst_name '/tof/tof_wavelength_detector' detno], data.tof_wavs);
    end
end

%TOF Distances
if isfield(data,'master_spacing')
    h5create(fname,['/entry0/' inst_name '/tof/tof_master_pair_separation'],[1]);
    h5write(fname, ['/entry0/' inst_name '/tof/tof_master_pair_separation'], data.master_spacing);
end



for det = 1:data.detectors
    detno=num2str(det);
    if isfield(data,['tof_distance_detector' detno])
        h5create(fname,['/entry0/' inst_name '/tof/tof_distance_detector' detno],[1]);
        h5write(fname, ['/entry0/' inst_name '/tof/tof_distance_detector' detno], data.(['tof_distance_detector' detno]));
    end
end


    

%Col
h5create(fname,['/entry0/' inst_name '/collimation/actual_position'],[1]);
h5write(fname, ['/entry0/' inst_name '/collimation/actual_position'], data.col);

%Source Size
h5create(fname,['/entry0/' inst_name '/collimation/ap_size'],[2]);
h5write(fname, ['/entry0/' inst_name '/collimation/ap_size'], [data.source_x, data.source_y]);


%San & Phi
if isfield(data,'san')
    h5create(fname,['/entry0/sample/san_actual'],[1]);
    h5write(fname, ['/entry0/sample/san_actual'], data.san);
end
if isfield(data,'phi')
    h5create(fname,['/entry0/sample/phi_actual'],[1]);
    h5write(fname, ['/entry0/sample/phi_actual'], data.phi);
end

%Det
if isfield(data,'det')
    h5create(fname,['/entry0/' inst_name '/detector/det_actual'],[1]);
    h5write(fname, ['/entry0/' inst_name '/detector/det_actual'], data.det);
    h5create(fname,['/entry0/' inst_name '/detector/det_calc'],[1]);
    h5write(fname, ['/entry0/' inst_name '/detector/det_calc'], data.det_calc);
end

%Det2
if isfield(data,'det2')
    h5create(fname,['/entry0/' inst_name '/detector/det2_actual'],[1]);
    h5write(fname, ['/entry0/' inst_name '/detector/det2_actual'], data.det2);
    h5create(fname,['/entry0/' inst_name '/detector/det2_calc'],[1]);
    h5write(fname, ['/entry0/' inst_name '/detector/det2_calc'], data.det2_calc);
end

%Det1
if isfield(data,'det1')
    h5create(fname,['/entry0/' inst_name '/detector/det1_actual'],[1]);
    h5write(fname, ['/entry0/' inst_name '/detector/det1_actual'], data.det1);
    h5create(fname,['/entry0/' inst_name '/detector/det1_calc'],[1]);
    h5write(fname, ['/entry0/' inst_name '/detector/det1_calc'], data.det1_calc);
    
    if isfield(data,'det1_panel_separation') %i.e. D33 panels.
        h5create(fname,['/entry0/' inst_name '/detector/det1_panel_separation'],[1]);
        h5write(fname, ['/entry0/' inst_name '/detector/det1_panel_separation'], data.det1_panel_separation);
        h5create(fname,['/entry0/' inst_name '/detector/OxL_actual'],[1]);
        h5write(fname, ['/entry0/' inst_name '/detector/OxL_actual'], data.oxl);
        h5create(fname,['/entry0/' inst_name '/detector/OxR_actual'],[1]);
        h5write(fname, ['/entry0/' inst_name '/detector/OxR_actual'], data.oxr);
        h5create(fname,['/entry0/' inst_name '/detector/OyT_actual'],[1]);
        h5write(fname, ['/entry0/' inst_name '/detector/OyT_actual'], data.oyt);
        h5create(fname,['/entry0/' inst_name '/detector/OyB_actual'],[1]);
        h5write(fname, ['/entry0/' inst_name '/detector/OyB_actual'], data.oyb);
    end
end

