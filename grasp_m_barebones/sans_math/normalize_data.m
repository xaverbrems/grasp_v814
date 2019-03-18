function foreimage = normalize_data(foreimage)

%Performs all data normalisation to monitor, time etc.
%Performs deadtime correction
%Performs auto attenuator correction


global status_flags
global inst_params
history = [];

%***** Deadtime correction - should be done before any normalisation *****
%formula is real_count_rate = measured_count_rate / (1 - Tau*measured_count_rate)
if strcmp(status_flags.deadtime.status,'on')
    exposure_time = foreimage.params1.ex_time;

    %Loop though detectors
    for det = 1:inst_params.detectors
        detno=num2str(det);
        det_params = inst_params.(['detector' detno]);
        
        if strcmpi(det_params.type,'tube')
            %Tube-by-tube deadtime correction
            if exposure_time ~=0
                %Determine which dimension the tubes are from the dimensions of the deadtime array
                [~, dim] = max(size(det_params.dead_time));
                if dim == 1 %Horizontal tubes
                    tube_rate = double(sum(foreimage.(['data' detno]),2) / exposure_time);
                    dead_scale = 1./ (1- det_params.dead_time .* tube_rate); %vector
                    [~, dead_scale_matrix] = meshgrid(1:det_params.pixels(1),dead_scale);
                    
                    foreimage.(['data' detno]) = foreimage.(['data' detno]) .* dead_scale_matrix;
                    foreimage.(['error' detno]) = foreimage.(['error' detno]) .* dead_scale_matrix;
                    history = [history, {['Det: ' detno ' : Applying Deadtime Correction per (horizontal) Tube: 1/[1-tau/detector_rate], tau = ' num2str(det_params.dead_time(1)) ' (seconds)']}];
                    foreimage.scale_factor = foreimage.scale_factor * dead_scale(1); %keep a track on data scaling
                    
                else %Vertical tubes
                    tube_rate = double(sum(foreimage.(['data' detno]),1) / exposure_time);
                    dead_scale = 1./ (1- det_params.dead_time .* tube_rate); %vector
                    dead_scale_matrix = meshgrid(dead_scale,1:det_params.pixels(2));
                    foreimage.(['data' detno]) = foreimage.(['data' detno]) .* dead_scale_matrix;
                    foreimage.(['error' detno]) = foreimage.(['error' detno]) .* dead_scale_matrix;
                    history = [history, {['Det: ' detno ' : Applying Deadtime Correction per (vertical) Tube: 1/[1-tau/detector_rate], tau = ' num2str(det_params.dead_time(1)) ' (seconds)']}];
                    foreimage.scale_factor = foreimage.scale_factor * dead_scale(1); %keep a track on data scaling
                    
                end
            else
                history = [history, {['Det: ' num2str(det) ' : CANNOT Apply Deadtime Correction: Time Parameter = 0']}];
            end
            
        elseif strcmpi(det_params.type,'multiwire')
            %Global detector deadtime correction
            if exposure_time ~=0
                %Single volume detectors - deadtime done on global count rate across detector
                det_rate = double(sum(sum(foreimage.(['data' detno]))) / exposure_time);
                dead_scale = 1/ (1- det_params.dead_time(1)*det_rate);
                foreimage.(['data' detno]) = foreimage.(['data' detno]) .* dead_scale;
                foreimage.(['error' detno]) = foreimage.(['error' detno]) .* dead_scale;
                history = [history, {['Det: ' detno ' : Applying Deadtime Correction per Detector: 1/[1-tau/detector_rate], tau = ' num2str(det_params.dead_time(1)) ' (seconds)']}];
                
                foreimage.scale_factor = foreimage.scale_factor * dead_scale; %keep a track on data scaling
                
            else
                history = [history, {['Det: ' num2str(det) ' : CANNOT Apply Deadtime Correction: Time Parameter = 0']}];
            end
        end
    end
    
else
    history = [history, {['No Deadtime Correction']}];
end
%End Deadtime correction


%NOTE NEED TO CHECK WHAT HAPPENS WHEN NORMALIZING TRANSMISSION DATA TO
%SOMEHTHING OTHER THAN MON TIME OR NONE
%   beep
%   disp('***** WARNING *****');
%   disp('You are not using Monitor, Time or None for data normalisation');
%   disp('Transmissions will be calculated using MONITOR normalisation');
%   disp('(If you''ve got a problem with this then you better see Charles)');
%   disp(' ');


%***** Data normalisation *****
%Note:  all checks to normalisation validy AND the monitor & time values to
%normalise by are taken from the params1 (i.e. for the first declared detector)
switch status_flags.normalization.status
    case 'none'
        %i.e. abs counts
        divider = 1; divider_standard = 1;
        history = [history, {['Data Normalisation: NONE']}];
        
    case 'mon' %i.e. normalise data to standard monitor
        divider = foreimage.params1.monitor; divider_standard = status_flags.normalization.standard_monitor;
        if divider == 0
            if status_flags.command_window.display_params == 1
                disp(['Attempted divide by zero using this data normalisation scheme ' '''' status_flags.normalization.status '''']);
                disp('resetting divider = 1  in normalize_data.m');
            end
            divider = 1;
        else
            foreimage.units = [foreimage.units '\\ Std mon '];
            history = [history, {['Data Normalisation: Standard Monitor (' num2str(divider_standard) ') counts']}];
        end
        
    case 'mon2' %i.e. normalise data to standard monitor2
        divider = foreimage.params1.monitor2; divider_standard = status_flags.normalization.standard_monitor;
        if divider == 0
            if status_flags.command_window.display_params == 1
                disp(['Attempted divide by zero using this data normalisation scheme ' '''' status_flags.normalization.status '''']);
                disp('resetting divider = 1  in normalize_data.m');
            end
            divider = 1;
        else
            foreimage.units = [foreimage.units '\\ Std mon '];
            history = [history, {['Data Normalisation: Standard Monitor (' num2str(divider_standard) ') counts']}];
        end
        
    case 'time' %i.e. normalisation to standard time
        divider = foreimage.params1.aq_time; divider_standard = status_flags.normalization.standard_time;
        if divider == 0
            if status_flags.command_window.display_params == 1
                disp(['Attempted divide by zero using this data normalisation scheme ' '''' status_flags.normalization.status '''']);
                disp('resetting divider = 1  in normalize_data.m');
            end
            divider = 1;
        else
            foreimage.units = [foreimage.units '\\ Acq time '];
            history = [history, {['Data Normalisation: Acquisition Time (' num2str(divider_standard) ') seconds']}];
        end
        
    case 'exposure_time' %i.e. normalisation to standard time
        divider = foreimage.params1.ex_time; divider_standard = status_flags.normalization.standard_exposure_time;
        if divider == 0
            if status_flags.command_window.display_params == 1
                disp(['Attempted divide by zero using this data normalisation scheme ' '''' status_flags.normalization.status '''']);
                disp('resetting divider = 1  in normalize_data.m');
            end
            divider = 1;
        else
            foreimage.units = [foreimage.units '\\ Exp time '];
            history = [history, {['Data Normalisation: Exposure Time (' num2str(divider_standard) ') seconds']}];
        end
        
    case 'det' %i.e. detector counts
        %divider = foreimage.params1(vectors.counts); %This is the parameter block counts (not actual array counts)
        divider = foreimage.params1.array_counts;  %This is the actual array counts
        divider_standard = status_flags.normalization.standard_detector;
        if divider == 0
            if status_flags.command_window.display_params == 1
                disp(['Attempted divide by zero using this data normalisation scheme ''' status_flags.normalization.status '''']);
                disp('resetting divider = 1  in normalize_data.m');
            end
            divider = 1;
        else
            foreimage.units = [foreimage.units '\\ Det Counts Norm: ' num2str(divider_standard,'%1g')];
            history = [history, {['Data Normalisation: Total Detector (' num2str(divider_standard) ') counts']}];
        end
        
    case 'detwin' %i.e. detector counts
        detwin = status_flags.normalization.detwin; %x1,x2,y1,y1
        divider = sum(sum(foreimage.data1(detwin(3):detwin(4),detwin(1):detwin(2))));
        divider_standard = status_flags.normalization.standard_detector;
        if divider == 0
            if status_flags.command_window.display_params == 1;
                disp(['Attempted divide by zero using this data normalisation scheme ''' status_flags.normalization.status '''']);
                disp('resetting divider = 1  in normalize_data.m');
            end
            divider = 1;
        else
            foreimage.units = [foreimage.units '\\ Det Counts '];
            history = [history, {['Data Normalisation: Detector Window ' num2str(detwin) ' (' num2str(divider_standard) ') counts']}];
        end
        
    case 'parameter'
        if isfield(foreimage.params1,status_flags.normalization.param)
            %Parameter exists
            disp(['Normalizing data to chosen parameter: # ' status_flags.normalization.param])
            divider = foreimage.params1.(status_flags.normalization.param); divider_standard = 1;
        else
            %Parameter does not exist
            disp('Your chosen normalization parameter does not exist with this data')
            disp('resetting divider = 1  in normalize_data.m');
            divider = 1; divider_standard = 1;
        end
        foreimage.units = [foreimage.units '\\ Param' status_flags.normalization.param ' '];
        history = [history, {['Data Normalisation: File Parameter #  ' status_flags.normalization.param '  value ' num2str(divider_standard)]}];
end


%Loop though the detectors and apply the normalisation
for det = 1:inst_params.detectors
    detno=num2str(det);
    %Normalise the data to it's reference and up-scale by it's standard value
    if divider_standard == 0
        if status_flags.command_window.display_params == 1
            disp('Your divider standard value is set to zero')
            disp('Your data is being multiplied by zero! in normalize_data.m');
        end
    end
    foreimage.(['data' detno]) = (foreimage.(['data' detno])/divider)*divider_standard;
    foreimage.(['error' detno]) = (foreimage.(['error' detno])/divider)*divider_standard;
end
foreimage.scale_factor = (foreimage.scale_factor / divider) * divider_standard; %keep a track on data scaling


%***** Attenuation Correction *****
%Loop though the detectors and apply the attenuator correction
if strcmp(status_flags.normalization.auto_atten,'on')
    attenuator_scaler = foreimage.params1.attenuation;
    if attenuator_scaler ~= 1
        for det = 1:inst_params.detectors
            detno=num2str(det);
            foreimage.(['data' detno]) = foreimage.(['data' detno])*attenuator_scaler;
            foreimage.(['error' detno]) = foreimage.(['error' detno])*attenuator_scaler;
            history = [history, {['Attenuator1: Up-scaling data by ' num2str(attenuator_scaler)]}];
        end
        foreimage.scale_factor = foreimage.scale_factor * attenuator_scaler; %keep a track on data scaling
    else
        history = [history, {'Attenuator1: No correction applied'}];
    end
end

%Attenuator 2 - D22 & D33 chopper attenuator
if isfield(foreimage.params1,'att2')
    att2 = foreimage.params1.att2;
    if att2 >1; status = 'In'; else status = 'Out'; end
    history = [history, {['Attenuator2: is ' status]}];
    if strcmp(status_flags.normalization.auto_atten,'on')
        for det = 1:inst_params.detectors
            detno=num2str(det);
            foreimage.(['data' detno]) = foreimage.(['data' detno])*att2;
            foreimage.(['error' detno]) = foreimage.(['error' detno])*att2;
            history = [history, {['Attenuator2: Up-scaling data by ' num2str(att2)]}];
        end
        foreimage.scale_factor = foreimage.scale_factor * att2; %keep a track on data scaling
    else
            history = [history, {['Attenuator2: No correction applied']}];
    end
end

%***** Count Scaler *****
if strcmp(status_flags.normalization.count_scaler,'on')
    count_scaler = status_flags.normalization.standard_count_scaler;
    for det = 1:inst_params.detectors
        detno=num2str(det);
        foreimage.(['data' detno]) = (foreimage.(['data' detno]))*count_scaler;
        foreimage.(['error' detno]) = (foreimage.(['error' detno]))*count_scaler;
    end
    foreimage.units = [foreimage.units '*' num2str(count_scaler) ' '];
    history = [history, {['Count Scaler :  Up-scaling data by ' num2str(count_scaler)]}];
    foreimage.scale_factor = foreimage.scale_factor * count_scaler; %keep a track on data scaling
end


foreimage.history = history;

