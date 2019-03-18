function place_data(numor_data, wks,nmbr,dpth_start)

global grasp_data
global inst_params
global grasp_env


%Some data manipulations:  Data types, single, double, and some additional manufacturered parametrs
for det = 1:inst_params.detectors
    detno = num2str(det);
    
    %Convert incoming data to correct (lower memory) data types
    eval(['numor_data.data' detno '=' grasp_env.data_type.data '(numor_data.data' detno ');']);
    eval(['numor_data.error' detno '=' grasp_env.data_type.error '(numor_data.error' detno ');']);
    
    %Convert incoming numeric parameters from single to double
    for frame = 1:length(numor_data.(['params' detno]))
        param_names = fieldnames(numor_data.(['params' detno]){frame});
        params = numor_data.(['params' detno]){frame};
        for p = 1:length(param_names)
            if isnumeric(params.(param_names{p}))
                params.(param_names{p}) = double(params.(param_names{p}));
            end
        end
        %Add a few 'manufactured' parameters
        params.monitor_rate = params.monitor / params.aq_time;
        params.(['det' detno '_rate']) = params.array_counts / params.aq_time;
        numor_data.(['params' detno]){frame} = params;
    end
end

%Find index to DATA
index = data_index(wks);

%Check for multi-frame data coming in, e.g. TOF, Kinetic etc.
if numor_data.n_frames >1
    disp('Multi-frame TOF or Kinetic Data')
end

%Loop through the frames
for frame = 1:numor_data.n_frames
    
    dpth = dpth_start +frame -1;
    
    disp(['Appending Worksheet: ' grasp_data(index).name '; Number: ' num2str(nmbr) '; Depth: ' num2str(dpth)]);
    
    %Check if requested depth is greater than Max allowed
    if dpth > grasp_data(index).dpth_max{nmbr}
        beep
        disp(' ');
        disp('Attemp to Exceed Maximum Worksheet Depth');
        disp('Please check computer memory and allocated more depths in grasp.ini')
        disp(' ');
        error(' ');
        return
    end

    
    
    %Check if requested depth is greater than current depth
    %If so, increase dpth parameter in Data
    current_depth = grasp_data(index).dpth{nmbr};
    
    if dpth > current_depth  %Just place the new data into matrix
        grasp_data(index).dpth{nmbr} = dpth;
        %Loop though number of detectors
        for det = 1:inst_params.detectors
            detno=num2str(det);
            grasp_data(index).(['data' detno]){nmbr}(:,:,dpth) = numor_data.(['data' detno])(:,:,frame);
            grasp_data(index).(['error' detno]){nmbr}(:,:,dpth) = numor_data.(['error' detno])(:,:,frame);
            params = numor_data.(['params' detno]){frame};
            params.depth = dpth; %Add depth as additional parameter in the list
            params = orderfields(params); %Sort into alphabetic order
            grasp_data(index).(['params' detno]){nmbr}{dpth} = params;
            
            %Check if sample thickness came is as parameter with the file
            if isfield(params,'thickness')
                %Poke thickness into the grasp_data array
                grasp_data(index).thickness{nmbr}(dpth) = params.thickness;
            end            
        end
        
    
    else %Append to existing contents
        %Loop though number of detectors
        for det = 1:inst_params.detectors
            detno=num2str(det);
            grasp_data(index).(['data' detno]){nmbr}(:,:,dpth) = grasp_data(index).(['data' detno]){nmbr}(:,:,dpth) + numor_data.(['data' detno])(:,:,frame);
            grasp_data(index).(['error' detno]){nmbr}(:,:,dpth) = sqrt ( ((grasp_data(index).(['error' detno]){nmbr}(:,:,dpth)).^2) + ((numor_data.(['error' detno])(:,:,frame)).^2)  );
            
            %Careful with parameters when appending files
            %Some parameters, e.g. monitor, need to be summed
            monitor = grasp_data(index).(['params' detno]){nmbr}{dpth}.monitor;
            ex_time = grasp_data(index).(['params' detno]){nmbr}{dpth}.ex_time;
            aq_time = grasp_data(index).(['params' detno]){nmbr}{dpth}.aq_time;
            total_array_counts = grasp_data(index).(['params' detno]){nmbr}{dpth}.array_counts;
            if isfield(grasp_data(index).(['params' detno]){nmbr}{dpth},'monitor2')
                monitor2 = grasp_data(index).(['params' detno]){nmbr}{dpth}.monitor2;
            end
            
            %Over write the parameters
            params = numor_data.(['params' detno]){frame};            
            params.depth = dpth; %Add depth as additional parameter in the list
            params = orderfields(params); %Sort into alphabetic order
            grasp_data(index).(['params' detno]){nmbr}{dpth} = params;
            
            %Check if sample thickness came is as parameter with the file
            if isfield(params,'thickness')
                %Poke thickness into the grasp_data array
                grasp_data(index).thickness{nmbr}(dpth) = params.thickness;
            end 
            
            %Modify the summed parameters, monitor, time etc.
            grasp_data(index).(['params' detno]){nmbr}{dpth}.monitor = grasp_data(index).(['params' detno]){nmbr}{dpth}.monitor + monitor;
            grasp_data(index).(['params' detno]){nmbr}{dpth}.ex_time = grasp_data(index).(['params' detno]){nmbr}{dpth}.ex_time + ex_time;
            grasp_data(index).(['params' detno]){nmbr}{dpth}.aq_time = grasp_data(index).(['params' detno]){nmbr}{dpth}.aq_time + aq_time;
            grasp_data(index).(['params' detno]){nmbr}{dpth}.array_counts = grasp_data(index).(['params' detno]){nmbr}{dpth}.array_counts + total_array_counts;
            if isfield(grasp_data(index).(['params' detno]){nmbr}{dpth},'monitor2')
                grasp_data(index).(['params' detno]){nmbr}{dpth}.monitor2 = grasp_data(index).(['params' detno]){nmbr}{dpth}.monitor2 + monitor2;
            end
        end
    end
    
    %organise data info structure
    if isfield(numor_data,'info')
        temp = (fieldnames(numor_data.info));
        for n = 1:length(temp)
            grasp_data(index).info{nmbr}.([temp{n}]){dpth} = numor_data.info.([temp{n}]);
        end
    end

    %Add a default thickness to the array if one doesn't already exist
    if dpth > length(grasp_data(index).thickness{nmbr})
        grasp_data(index).thickness{nmbr}(dpth) = 0.1; %default thickness
    end
    
    grasp_data(index).load_string{nmbr} = [numor_data.load_string];
    
end
%Set the file type for this data, e.g. Mono, TOF, Kinetic, Tof Inelastic
grasp_data(index).data_type{nmbr} = numor_data.file_type;
    
