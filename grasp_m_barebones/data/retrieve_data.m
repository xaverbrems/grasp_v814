function output = retrieve_data(selector)

%Retrieve data is designed to sort out which data set either the foreground or subtract data menus are pointing at.
%The corresponding data is then shipped out as 'data' for subsequent operations

%OR 'selector' can also speficy a specific worksheet, e.g. [6,1,1] would
%indicate the empty beam worksheet 1, depth 1.

%***** Worksheet types *****
% 1 = sample scattering
% 2 = sample background
% 3 = sample cadmium
% 4 = sample transmission
% 5 = sample empty transmission
% 6 = sample empty beam transmission
% 7 = sample mask
% 8 = I0 Beam Intensity
% 99 = detector efficiency map

global status_flags
global grasp_data
global inst_params
global grasp_env

%Data Worksheets index
if strcmp(selector,'fore')
    index = data_index(status_flags.selector.fw);
    nmbr = status_flags.selector.fn;
    dpth = status_flags.selector.fd;
elseif strcmp(selector,'back')
    index = data_index(status_flags.selector.bw);
    nmbr = status_flags.selector.bn;
    dpth = status_flags.selector.bd;
elseif strcmp(selector,'cad')
    index = data_index(status_flags.selector.cw);
    nmbr = status_flags.selector.cn;
    dpth = status_flags.selector.cd;
elseif isnumeric(selector)
    index = selector(1); nmbr = selector(2); dpth = selector(3);
end

%Mask worksheet index
mask_number = status_flags.display.mask.number;
mask_index = data_index(7);

dpth_sum_allow = grasp_data(index).sum_allow;
real_dpth = dpth - dpth_sum_allow;
if real_dpth > grasp_data(index).dpth{nmbr}; real_dpth = 1; end

%in this way, if no depth then status_flags.selector.fd reflects the real
%worksheet depth.  If there is a depth, then need to subtract 1 from
%status_flags.selector.fd.  If the result is 0 then the sum is being
%displayed.


%Parameters that are not detector dependent
output.type = grasp_data(index).type;
output.history = [];
output.load_string = grasp_data(index).load_string{nmbr};
%Data Units
if output.type == 7
    output.units = 'Mask Data';
elseif output.type == 99
    output.units = 'Detector Efficiency';
else
    output.units = 'Counts ';
end


if real_dpth ==0  %i.e. Sum is being displayed
    output.sum_flag = 1;
    %Put the thickness into the structure based on what is stored in the SAMPLES worksheet
    %samples_index = data_index(1);
    %output.thickness = grasp_data(samples_index).thickness{nmbr}(1); %Taken from the first one in the depth
else
    output.sum_flag = 0;
%     %Put the thickness into the structure based on what is stored in the SAMPLES worksheet
%     samples_index = data_index(1);
%     %check if enough thickness' exist
%     if real_dpth > length(grasp_data(samples_index).thickness{nmbr})
%         thickness_depth = 1;
%     else
%         thickness_depth = real_dpth;
%     end
%     output.thickness = grasp_data(samples_index).thickness{nmbr}(thickness_depth);
end


%Loop though the number of detectors
for det = 1:inst_params.detectors
    detno=num2str(det);
    if real_dpth ==0  %i.e. Sum is being displayed
        
        %Update Sum DATA
        output.(['data' detno]) = double(sum(grasp_data(index).(['data' detno]){nmbr},3));
        output.(['error' detno]) = double(sqrt(sum(grasp_data(index).(['error' detno]){nmbr}.^2,3)));
        output.(['params' detno]) = grasp_data(index).(['params' detno]){nmbr}{1}; %Params are taken from the first one in the depth
        output.(['raw_counts' detno]) = sum(grasp_data(index).(['data' detno]){nmbr},3);
        
        %Update Summed Parameters, eg, Total Det, Total Monitor, Time etc.
        d_max = length(grasp_data(index).params1{nmbr});
        counts_sum = 0; monitor_sum = 0; monitor2_sum = 0; aq_time_sum = 0; ex_time_sum = 0; frame_ex_time_sum = 0;
        for d = 1:d_max
            %            frame_ex_time_sum = frame_ex_time_sum + grasp_data(index).(['params' detno]){nmbr}{d}.frame_ex_time;
            counts_sum = counts_sum + grasp_data(index).(['params' detno]){nmbr}{d}.array_counts;
            monitor_sum = monitor_sum + grasp_data(index).(['params' detno]){nmbr}{d}.monitor;
            if isfield(grasp_data(index).(['params' detno]){nmbr}{d},'ex_time')
                ex_time_sum = ex_time_sum + grasp_data(index).(['params' detno]){nmbr}{d}.ex_time;
            end
            
            %if isfield(grasp_data(index),'data_type')
            %    if not(isempty(grasp_data(index).data_type))
            if isfield(grasp_data(index).(['params' detno]){nmbr}{d},'aq_time')
                
                %if strcmp(grasp_data(index).data_type{nmbr},'single frame') %Acumulate total time for many single frame files in the depth:  not for kinetic or tof
                aq_time_sum = aq_time_sum + grasp_data(index).(['params' detno]){nmbr}{d}.aq_time;
                %else
                %    aq_time_sum = grasp_data(index).(['params' detno]){nmbr}{d}.aq_time;
                %end
            end
            
            %    end
            %end
            
            if isfield(grasp_data(index).(['params' detno]){nmbr},'monitor2')
                monitor2_sum = monitor2_sum + grasp_data(index).(['params' detno]){nmbr}.monitor2;
            end
        end
        output.(['params' detno]).array_counts = counts_sum;
        output.(['params' detno]).monitor = monitor_sum;
        output.(['params' detno]).aq_time = aq_time_sum;
        output.(['params' detno]).ex_time = ex_time_sum;
        %     output.(['params' detno]).frame_ex_time = frame_ex_time_sum;
        
        if isfield(grasp_data(index).(['params' detno]){nmbr},'monitor2')
            output.(['params' detno]).monitor2 = monitor2_sum;
        end
        
        %         if isfield(grasp_data(index),'data_type');
        %             if not(isempty(grasp_data(index).data_type));
        %                 if strcmp(grasp_data(index).data_type{nmbr},'single frame'); %Acumulate total time for many single frame files in the depth:  not for kinetic or tof
        %                     output.(['params' detno])(inst_params.vectors.aq_time) = param_sum(inst_params.vectors.aq_time);
        %                 end
        %             end
        %         end
        %         output.(['params' num2str(det)])(inst_params.vectors.array_counts) = param_sum(inst_params.vectors.array_counts);
    else
        output.(['data' detno]) = double(grasp_data(index).(['data' detno]){nmbr}(:,:,real_dpth));
        output.(['error' detno]) = double(grasp_data(index).(['error' detno]){nmbr}(:,:,real_dpth));
        output.(['params' detno]) = grasp_data(index).(['params' detno]){nmbr}{real_dpth};
        output.(['raw_counts' detno]) = grasp_data(index).(['data' detno]){nmbr}(:,:,real_dpth);
    end
    
    
    %read instrument mask
                fname = ['instrument_ini' filesep 'det_mask' filesep inst_params.(['detector' detno]).imask_file];
                
                fid = fopen(fname);
                disp(['Looking for Instrument Detector Mask: ' fname]);
                if fid ~= -1 %File exists
                    fclose(fid);
                    disp(['Loading Default Instrument Mask for Detector: ' detno ' : ' fname])
                    mask_data = load([fname]);
                    data = mask_data.mask_data;
                else
                    disp(['WARNING:  No Default Instrument Mask Found for Detector: ' detno]);
                    data = ones(inst_params.(['detector' detno]).pixels(2), inst_params.(['detector' detno]).pixels(1),grasp_env.data_type.mask);
                end
    
    
    %Get instrument mask for detector
    output.(['imask' detno]) = data;
    %Get user mask for detector
    output.(['umask' detno]) = grasp_data(mask_index).(['data' detno]){mask_number}(:,:);
end

output.data_type = grasp_data(index).data_type{nmbr};



%***** Data Parameter Patcher *****
if status_flags.data.patch_check ==1 %Patch some parameters
    for det = 1:inst_params.detectors
        detno=num2str(det);
        for n = 1: status_flags.data.number_patches
            nno=num2str(n);
            %if not(isempty(status_flags.data.(['patch_parameter' nno]))) && not(isempty(status_flags.data.(['patch' nno])))
            if strcmp(status_flags.data.(['patch_parameter' nno]),'none')
                %do nothing
            else
                %Check parameter actually exists in this data
                if isfield(output.(['params' detno]),status_flags.data.(['patch_parameter' nno]))
                    %Replace or Modify
                    if status_flags.data.(['rep_mod' nno]) == 0
                        %Replace
                        output.(['params' detno]).(status_flags.data.(['patch_parameter' nno])) = status_flags.data.(['patch' nno]);
                    elseif status_flags.data.(['rep_mod' nno]) == 1
                        %Modify
                        output.(['params' detno]).(status_flags.data.(['patch_parameter' nno])) = output.(['params' detno]).(status_flags.data.(['patch_parameter' nno])) + status_flags.data.(['patch' nno]);
                    end
                end
            end
        end
    end
end

output.scale_factor = 1;  %This is the combined multiplication and division factors that happens to the foreground data though all the normalizations and processing
