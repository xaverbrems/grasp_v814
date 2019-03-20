function output = sector_box_callbacks(to_do,option)

if nargin<2; option = ''; end
if nargin<1; to_do = ''; end
output = []; %dummy, empty output variable

global status_flags
global grasp_handles
global displayimage
global grasp_data
global inst_params
global grasp_env
global gs_grasp_box_data

%global box_intensities

switch to_do
    
    case 'retrieve_box_coords'
        %Retrieves the sector box coords from the status_flags structure
        %and modifies them if necessary according to q-lock - or other box
        %moving features
        
        coords = status_flags.analysis_modules.sector_boxes.(['coords' num2str(option)]); %where option is the box number
        %Rebuild Masks if necessary (i.e. for Q-lock with wavelength)
        if status_flags.analysis_modules.sector_boxes.q_lock_chk  == 1 
            %Modify coordinates according to wavelength and reference wavelength
            lambda_ref = status_flags.analysis_modules.sector_boxes.q_lock_wav_ref;
            lambda_now = displayimage.params1.wav;
            
            if status_flags.analysis_modules.sector_boxes.q_lock_box_size_chk  == 0
                %Simple box movement - box gets larger as it goes out
                R1 = (coords(1) * lambda_now/lambda_ref); %new outer radius
                R2 = (coords(2) * lambda_now/lambda_ref); %new inner radius
            elseif status_flags.analysis_modules.sector_boxes.q_lock_box_size_chk == 1
                %'Constant' box size - keep delta radius constant and scale opening angle
                mean_radius = (coords(1) + coords(2))/2;
                delta_r = coords(1) - coords(2);
                mean_radius = mean_radius * lambda_now/lambda_ref;
                R1  = mean_radius + delta_r /2;
                R2 = mean_radius - delta_r /2;
                dtheta = (coords(4) * lambda_ref/lambda_now); %scale box opening angle
                coords(4) = dtheta;
            end
            coords(1) = R1; coords(2) = R2; 
        end
        
        if status_flags.analysis_modules.sector_boxes.t2t_lock_chk ==1 
            
            %Modify coordinates according to omega_2b angle and reference omega_2b angle
            angle_ref = status_flags.analysis_modules.sector_boxes.(['t2t_lock_angle_ref' num2str(option)]);
            angle_now = displayimage.params1.omega_2b;
            delta_2theta = 2*(angle_now - angle_ref); %This is the required angular shift of the box
            
            if coords(1) ~=0 && coords(2) ~=0
                if coords(3) < 180 && coords(3) >0
                    
                else
                    delta_2theta = -delta_2theta;
                end
                
                R1_angle = displayimage.qmatrix1(1,round(coords(1)),7);
                R1_angle = R1_angle + delta_2theta;
                %Find the cloeset pixel this corresponds to on the detector
                temp = find(displayimage.qmatrix1(1,:,7)>=R1_angle);
                R1 = displayimage.qmatrix1(1,temp(1),1);
            
                R2_angle = displayimage.qmatrix1(1,round(coords(2)),7);
                R2_angle = R2_angle + delta_2theta;
                %Find the cloeset pixel this corresponds to on the detector
                temp = find(displayimage.qmatrix1(1,:,7)>=R2_angle);
                R2 = displayimage.qmatrix1(1,temp(1),1);

                
                if status_flags.analysis_modules.sector_boxes.t2t_lock_box_size_chk == 1; %Scale sector opening with box position
                    coords(4) = coords(4) * mean(coords(1),coords(2))/mean(R1,R2);
                    
                end                           
                coords(1) = R1;
                coords(2) = R2;
            end
            
            
            
            
        end
        output = coords;
        return
                                
        
    case 'q_lock_box_size_chk'
        status_flags.analysis_modules.sector_boxes.q_lock_box_size_chk = get(gcbo,'value');
        sector_box_callbacks;
    
    case 'q_lock_chk'
        status_flags.analysis_modules.sector_boxes.q_lock_chk = get(gcbo,'value');
        status_flags.analysis_modules.sector_boxes.t2t_lock_chk = 0;
        sector_box_callbacks;
        
    case 't2t_lock_box_size_chk'
        status_flags.analysis_modules.sector_boxes.t2t_lock_box_size_chk = get(gcbo,'value');
        sector_box_callbacks;
    
    case 't2t_lock_chk'
        status_flags.analysis_modules.sector_boxes.t2t_lock_chk = get(gcbo,'value');
        status_flags.analysis_modules.sector_boxes.q_lock_chk = 0;
        sector_box_callbacks;
        
    case 'show_sector_mask_chk'
        status_flags.analysis_modules.sector_boxes.show_sector_mask_chk = get(gcbo,'value');
        
    case 'r1'
        box = get(gcbo,'userdata');
        temp = str2double(get(gcbo,'string'));
        if not(isempty(temp))
            coords = status_flags.analysis_modules.sector_boxes.(['coords' num2str(box)]);
            coords(1) = temp;
            status_flags.analysis_modules.sector_boxes.(['coords' num2str(box)])=coords;
        end
        %Store reference wavelength in case of q-lock
        status_flags.analysis_modules.sector_boxes.q_lock_wav_ref = displayimage.params1.wav;
        status_flags.analysis_modules.sector_boxes.(['t2t_lock_angle_ref' num2str(box)]) = displayimage.params1.omega_2b;
        
    case 'r2'
        box = get(gcbo,'userdata');
        temp = str2double(get(gcbo,'string'));
        if not(isempty(temp))
            coords = status_flags.analysis_modules.sector_boxes.(['coords' num2str(box)]);
            coords(2) = temp;
            status_flags.analysis_modules.sector_boxes.(['coords' num2str(box)])=coords;
        end
        %Store reference wavelength in case of q-lock
        status_flags.analysis_modules.sector_boxes.q_lock_wav_ref = displayimage.params1.wav;
        status_flags.analysis_modules.sector_boxes.(['t2t_lock_angle_ref' num2str(box)]) = displayimage.params1.omega_2b;
        
    case 'theta'
        box = get(gcbo,'userdata');
        temp = str2double(get(gcbo,'string'));
        if not(isempty(temp))
            coords = status_flags.analysis_modules.sector_boxes.(['coords' num2str(box)]);
            coords(3) = temp;
            status_flags.analysis_modules.sector_boxes.(['coords' num2str(box)])=coords;
        end
        %Store reference wavelength in case of q-lock
        status_flags.analysis_modules.sector_boxes.q_lock_wav_ref = displayimage.params1.wav;
        status_flags.analysis_modules.sector_boxes.(['t2t_lock_angle_ref' num2str(box)]) = displayimage.params1.omega_2b;

    case 'delta_theta'
        box = get(gcbo,'userdata');
        temp = str2double(get(gcbo,'string'));
        if not(isempty(temp))
            coords = status_flags.analysis_modules.sector_boxes.(['coords' num2str(box)]);
            coords(4) = temp;
            status_flags.analysis_modules.sector_boxes.(['coords' num2str(box)])=coords;
        end
        %Store reference wavelength in case of q-lock
        status_flags.analysis_modules.sector_boxes.q_lock_wav_ref = displayimage.params1.wav;
        status_flags.analysis_modules.sector_boxes.(['t2t_lock_angle_ref' num2str(box)]) = displayimage.params1.omega_2b;
        
    case 'gamma'
        box = get(gcbo,'userdata');
        temp = str2double(get(gcbo,'string'));
        if not(isempty(temp))
            coords = status_flags.analysis_modules.sector_boxes.(['coords' num2str(box)]);
            coords(5) = temp;
            status_flags.analysis_modules.sector_boxes.(['coords' num2str(box)])=coords;
        end
        %Store reference wavelength in case of q-lock
        status_flags.analysis_modules.sector_boxes.q_lock_wav_ref = displayimage.params1.wav;
        
    case 'gamma_angle'
        box = get(gcbo,'userdata');
        temp = str2double(get(gcbo,'string'));
        if not(isempty(temp))
            coords = status_flags.analysis_modules.sector_boxes.(['coords' num2str(box)]);
            coords(6) = temp;
            status_flags.analysis_modules.sector_boxes.(['coords' num2str(box)])=coords;
        end
        %Store reference wavelength in case of q-lock
        status_flags.analysis_modules.sector_boxes.q_lock_wav_ref = displayimage.params1.wav;
        
    case 'clear_box'
        box = get(gcbo,'userdata');
        coords = [0,0,0,0,1,0]; %Empty box coordinates
        status_flags.analysis_modules.sector_boxes.(['coords' num2str(box)])=coords;
        %Store reference wavelength in case of q-lock
        status_flags.analysis_modules.sector_boxes.q_lock_wav_ref = displayimage.params1.wav;

    case 'clear_all'
        for box = 1:6
            coords = [0,0,0,0,1,0]; %Empty box coordinates
            status_flags.analysis_modules.sector_boxes.(['coords' num2str(box)])=coords;
        end
        %Store reference wavelength in case of q-lock
        status_flags.analysis_modules.sector_boxes.q_lock_wav_ref = displayimage.params1.wav;
        
    case 'parameter'
        string = get(grasp_handles.window_modules.sector_box.parameter,'string');
        value = get(grasp_handles.window_modules.sector_box.parameter,'value');
        status_flags.analysis_modules.sector_boxes.parameter = string{value};
     
    case 'box_color'
        color_string = get(grasp_handles.window_modules.sector_box.box_color,'string');
        position = get(grasp_handles.window_modules.sector_box.box_color,'value');
        color = color_string{position};
        status_flags.analysis_modules.sector_boxes.box_color = color;
        
    case 'grab_coords'
        box = get(gcbo,'userdata');
        coords(1) = status_flags.analysis_modules.sectors.outer_radius;
        coords(2) = status_flags.analysis_modules.sectors.inner_radius;
        %coords(3) = status_flags.analysis_modules.sectors.theta;
        coords(4) = status_flags.analysis_modules.sectors.delta_theta;
        coords(5) = status_flags.analysis_modules.sectors.anisotropy;
        coords(6) = status_flags.analysis_modules.sectors.anisotropy_angle;
        
        for n = 1:status_flags.analysis_modules.sectors.mirror_sectors %loop though the number of mirror sectors
            coords(3) = status_flags.analysis_modules.sectors.theta + (360/status_flags.analysis_modules.sectors.mirror_sectors)* (n-1);
            status_flags.analysis_modules.sector_boxes.(['coords' num2str(box+(n-1))])=coords;
        end
        %Store reference wavelength in case of q-lock
        status_flags.analysis_modules.sector_boxes.q_lock_wav_ref = displayimage.params1.wav;
        status_flags.analysis_modules.sector_boxes.(['t2t_lock_angle_ref' num2str(box)]) = displayimage.params1.omega_2b;
        
    case 'close'
        
        %Delete old boxes
        temp = ishandle(grasp_handles.window_modules.sector_box.sketch_handles);
        delete(grasp_handles.window_modules.sector_box.sketch_handles(temp));
        grasp_handles.window_modules.sector_box.sketch_handles = [];
        grasp_handles.window_modules.sector_box.window = [];
        %Turn off the Use Sector in Radial Average
        status_flags.analysis_modules.radial_average.sector_mask_chk =0;
        if isfield(grasp_handles.window_modules.radial_average,'sector_mask_chk')
            if ishandle(grasp_handles.window_modules.radial_average.sector_mask_chk)
                set(grasp_handles.window_modules.radial_average.sector_mask_chk,'value',status_flags.analysis_modules.radial_average.sector_mask_chk);
            end
        end
        return
        
        
    case 'sum_box_chk'
        status_flags.analysis_modules.sector_boxes.sum_box_chk = not(status_flags.analysis_modules.sector_boxes.sum_box_chk);
        
    case 'box_nrm_chk'
        status_flags.analysis_modules.sector_boxes.box_nrm_chk = not(status_flags.analysis_modules.sector_boxes.box_nrm_chk);
       
    case 'build_the_masks'
        
        box_mask = []; active_boxes = [];
        %Make empty sum_masks for all detectors
        for det = 1:inst_params.detectors
            detno=num2str(det);
            sum_mask.(['det' detno]) = zeros(inst_params.(['detector' detno]).pixels(2),inst_params.(['detector' detno]).pixels(1));
        end
        box_history = ['Sector Box Coordinates:  R1 R2 Theta DTheta g gTheta'];
        %Make logical box masks only for valid boxes
        for box = 1:6
            %coords = status_flags.analysis_modules.sector_boxes.(['coords' num2str(box)]);
            coords = sector_box_callbacks('retrieve_box_coords',box);
            %disp(['SectorBox ' num2str(box) ' coordinates ' num2str(coords)]);
            if (coords(1) ~= coords(2)) && (coords(4) ~=0)
                active_boxes = [active_boxes, box];
                box_mask.(['box' num2str(box)]) = sector_callbacks('build_sector_mask', [coords(1),coords(2),coords(3),coords(4),1,coords(5),coords(6)]);
                
                %Add to the sum mask
                for det = 1:inst_params.detectors
                    detno=num2str(det);
                    sum_mask.(['det' detno]) = or(sum_mask.(['det' detno]),box_mask.(['box' num2str(box)]).(['det' detno]));
                end
                box_history =  [box_history, {[num2str(coords(1)) ' ' num2str(coords(2)) ' ' num2str(coords(3)) ' ' num2str(coords(4)) ' ' num2str(coords(5)) ' ' num2str(coords(6))]}];
            end
        end
        %Convert sum_mask_logical to double
        for det = 1:inst_params.detectors
            detno=num2str(det);
            sum_mask.(['det' detno]) = double(sum_mask.(['det' detno])); %Otherwise it comes out as a logical
        end
        
        if status_flags.analysis_modules.sector_boxes.show_sector_mask_chk ==1
            for det = 1:inst_params.detectors
                detno=num2str(det);
                figure;
                pcolor(box_mask.box1.(['det' detno]));
            end
        end
        
        %disp(['Active Boxes are:  ' num2str(active_boxes)]);
        
        output.box_mask =  box_mask;
        output.active_boxes = active_boxes;
        output.sum_mask = sum_mask;
        output.box_history = box_history;
        

    case 'box_it'
       tic
        %Turn off command window parameter update for the boxing
        remember_display_params_status = status_flags.command_window.display_params;
        if strcmp(status_flags.analysis_modules.sector_boxes.display_refresh,'on')
            status_flags.command_window.display_params=1; status_flags.display.refresh = 1;
        else
            status_flags.command_window.display_params=0; status_flags.display.refresh = 0;
        end
                    
        masks = sector_box_callbacks('build_the_masks');
        box_mask = masks.box_mask;
        active_boxes = masks.active_boxes;
        n_boxes = length(active_boxes);
        sum_mask = masks.sum_mask;
        box_history = masks.box_history;
        
        %Churn through the depth and extract box-sums
        index = data_index(status_flags.selector.fw);
        foreground_depth = status_flags.selector.fdpth_max - grasp_data(index).sum_allow;
        depth_start = status_flags.selector.fd; %remember the initial foreground depth
        
        %Check if using depth max min
        if status_flags.selector.depth_range_chk == 1
            if status_flags.selector.depth_range_min > foreground_depth
                dstart = 1;
            else
                dstart = status_flags.selector.depth_range_min;
            end
            if status_flags.selector.depth_range_max > foreground_depth
                dend = foreground_depth;
            else
                dend = status_flags.selector.depth_range_max;
            end
        else
            dstart = 1; dend = foreground_depth;
        end
        
        disp(['Extracting SectorBox intensities through depth']);
        box_intensities = [];
        message_handle = grasp_message(['Extracting Sector Box intensities Depth: ' num2str(dstart) ' to ' num2str(dend)]);
        
        for n = dstart:dend
            status_flags.selector.fd = n+grasp_data(index).sum_allow;
            main_callbacks('depth_scroll'); %Scroll all linked depths and update
            
%             %Rebuild Masks if necessary (i.e. for Q-lock with wavelength)
%             if status_flags.analysis_modules.sector_boxes.q_lock_chk  == 1 || status_flags.analysis_modules.sector_boxes.t2t_lock_chk ==1;
%                 masks = sector_box_callbacks('build_the_masks');
%                 box_mask = masks.box_mask;
%                 active_boxes = masks.active_boxes;
%                 sum_mask = masks.sum_mask;
%                 box_history = masks.box_history;
%         
%             end
                        
            %Get the box intensities
            
            %***** Summed Boxes *****
            if status_flags.analysis_modules.sector_boxes.sum_box_chk == 1
                n_boxes = 1;
                %Loop though the detectors each with their sum mask
                %Note: this is different to Square Boxes as Sector Boxes are allowed to span between detectors
                box_pixels = 0; box_sum = 0; box_sum_error = 0;
                for det = 1:inst_params.detectors
                    detno=num2str(det);
                    %All boxes summed
                    box_pixels = box_pixels + sum(sum(sum_mask.(['det' detno])));
                    box_sum = box_sum + sum(sum(displayimage.(['data' detno]).* sum_mask.(['det' detno])));
                    box_sum_error = sqrt(box_sum_error.^2 + (sum(sum((displayimage.(['error' detno]).*sum_mask.(['det' detno])).^2))));
                    parameter = displayimage.(['params' detno]).([status_flags.analysis_modules.sector_boxes.parameter]);
                end
                %Normalise if required
                if status_flags.analysis_modules.sector_boxes.box_nrm_chk ==1
                    box_sum = box_sum / box_pixels; box_sum_error = box_sum_error / box_pixels;
                end
                box_sum_list = [parameter, box_sum, box_sum_error]; %Accumulate the sum list
                
                %Note: In the case of summed boxes the parameter will come from the last detector panel parameters
                %Since most parameters are the same for each panel (except e.g TOF wavelength) this shouldn't be a problem in most cases

            %***** Individual Boxes *****
            else
                box_sum_list = [];
                for m = 1:n_boxes
                    box = active_boxes(m);
                    %Loop though the detectors
                    %Note: this is different to Square Boxes as Sector Boxes are allowed to span between detectors
                    box_pixels = 0; box_sum = 0; box_sum_error = 0;
                    for det = 1:inst_params.detectors
                        detno=num2str(det);
                        mask = box_mask.(['box' num2str(box)]).(['det' detno]);
                        box_pixels = box_pixels + sum(sum(box_mask.(['box' num2str(box)]).(['det' detno])));
                        box_sum = box_sum + sum(sum(displayimage.(['data' detno]) .* mask));
                        box_sum_error = sqrt(box_sum_error.^2 + sum(sum(   ((displayimage.(['error' detno]) .* mask).^2)  )));
                    end
                    %Normalise if required
                    if status_flags.analysis_modules.sector_boxes.box_nrm_chk ==1
                        box_sum = box_sum / box_pixels;
                        box_sum_error = box_sum_error / box_pixels;
                    end
                    parameter = displayimage.(['params' detno]).([status_flags.analysis_modules.sector_boxes.parameter]);
                    box_sum_list = [box_sum_list, parameter, box_sum, box_sum_error];
                end
            end
            
            box_intensities = [box_intensities; [n, box_sum_list]];
        end
        
        %Dislplay results on screen
        disp(' ');
        header_str = repmat(['Parameter(' num2str(status_flags.analysis_modules.sector_boxes.parameter) '),     Counts,     Err_Counts,      '],1,n_boxes);
        header_str = ['Depth #,     ', header_str];
        disp(header_str);
        l = size(box_intensities);
        for n = 1:l(1)
            disp_string = [];
            for m = 1:l(2)
                disp_string = [disp_string num2str(box_intensities(n,m),'%3.3g') '   ' char(9)];
            end
            disp(disp_string);
        end
        disp(' ');

        
        %Reset Grasp update, Selector and command window updating
        status_flags.command_window.display_params = remember_display_params_status;
        status_flags.display.refresh = 1;
        status_flags.selector.fd = depth_start;
        main_callbacks('depth_scroll'); %Scroll all linked depths and update
        delete(message_handle);
        grasp_update;
        
        
        
        %***** Plot Box intensity vs. parameter ****
        l = size(box_intensities);
        plotdata = box_intensities(:,2:l(2));
        column_format = repmat('xye',1,n_boxes);
        if status_flags.analysis_modules.sector_boxes.box_nrm_chk ==1; y_string = ' \\ Pixel'; else y_string = []; end
        
        plot_params = struct(....
            'plot_type','plot',....
            'plot_data',plotdata,....
            'column_format',column_format,....
            'hold_graph','off',....
            'plot_title',['Box Sum'],....
            'x_label',(['Parameter ' status_flags.analysis_modules.sector_boxes.parameter]),....
            'y_label',['Box ' displayimage.units y_string],....
            'legend_str',['SectorBox#' num2str(displayimage.params1.numor)],....
            'params',displayimage.params1,....
            'export_data',plotdata,....
            'export_column_format',column_format,....
            'column_labels',[status_flags.analysis_modules.sector_boxes.parameter char(9) 'I' char(9) 'Err_I']);
        
        local_history = displayimage.history; %This will actually be the history of the last file
        local_history = [local_history, {['***** Analysis *****']}];
        local_history = [local_history, {['Sector Box Intensity vs. Parameter ' num2str(status_flags.analysis_modules.boxes.parameter)]}];
        local_history = [local_history, box_history];
        plot_params.history = local_history;

        if not(strcmp(option,'plot_off'))
            grasp_plot2(plot_params); %Plot
        end
        
        %Store plot data for grasp script to use
        gs_grasp_box_data = plotdata;
end

%Update displayed sector box window option
if status_flags.analysis_modules.sector_boxes.q_lock_chk == 1 %q-lock
    set(grasp_handles.window_modules.sector_box.q_lock_box_size,'visible','on');
    set(grasp_handles.window_modules.sector_box.t2t_lock_box_size,'visible','off');
else
    set(grasp_handles.window_modules.sector_box.q_lock_box_size,'visible','off');
    %set(grasp_handles.window_modules.sector_box.t2t_lock_box_size,'visible','off');
end
 
if status_flags.analysis_modules.sector_boxes.t2t_lock_chk == 1 %theta-2theta lock
    set(grasp_handles.window_modules.sector_box.t2t_lock_box_size,'visible','on');
    set(grasp_handles.window_modules.sector_box.q_lock_box_size,'visible','off');
else
    set(grasp_handles.window_modules.sector_box.t2t_lock_box_size,'visible','off');
end

set(grasp_handles.window_modules.sector_box.q_lock,'value',status_flags.analysis_modules.sector_boxes.q_lock_chk);
set(grasp_handles.window_modules.sector_box.t2t_lock,'value',status_flags.analysis_modules.sector_boxes.t2t_lock_chk);

   
%Update displayed parameters
for box = 1:6
    %coords = status_flags.analysis_modules.sector_boxes.(['coords' num2str(box)]);
    coords = sector_box_callbacks('retrieve_box_coords',box);
    handle = grasp_handles.window_modules.sector_box.(['coords' num2str(box)]);
    set(handle(1),'string',num2str(coords(1)));
    set(handle(2),'string',num2str(coords(2)));
    set(handle(3),'string',num2str(coords(3)));
    set(handle(4),'string',num2str(coords(4)));
    set(handle(5),'string',num2str(coords(5)));
    set(handle(6),'string',num2str(coords(6)));
    
end

set(grasp_handles.window_modules.sector_boxes.sum_box_chk,'value',status_flags.analysis_modules.sector_boxes.sum_box_chk);
set(grasp_handles.window_modules.sector_box.box_nrm_chk,'value',status_flags.analysis_modules.sector_boxes.box_nrm_chk);



%set(grasp_handles.window_modules.sector_box.parameter,'string',num2str(status_flags.analysis_modules.sector_boxes.parameter));


%Update Dropdown list of parameters
string = rot90(fieldnames(displayimage.params1));
p_names = [];
p_values = displayimage.params1;
for p = 1:length(string)
     if isnumeric(p_values.(string{p}))
         p_names{end+1} = (string{p});
     end
end
value = find(strcmp(p_names,status_flags.analysis_modules.sector_boxes.parameter));
if isempty(value)
    value = find(strcmp('numor',p_names));
    status_flags.analysis_modules.sector_boxes.parameter = 'numor';
end
set(grasp_handles.window_modules.sector_box.parameter,'string',p_names,'value',value);




% if status_flags.analysis_modules.sector_boxes.parameter ==0; string = 'Depth';
% else
%     string = inst_params.vector_names{status_flags.analysis_modules.sector_boxes.parameter};
%     if iscell(string); %If name exists then remove it's cell nature
%         string = string{1};
%     end
%     
% end
% set(grasp_handles.window_modules.sector_box.parameter_string,'string',string);

%Delete old boxes
temp = ishandle(grasp_handles.window_modules.sector_box.sketch_handles);
delete(grasp_handles.window_modules.sector_box.sketch_handles(temp));
grasp_handles.window_modules.sector_box.sketch_handles = [];

box_color = status_flags.analysis_modules.sector_boxes.box_color;
if not(strcmp(box_color,'(none)'))
    if strcmp(box_color,'white'); box_color = [0.99,0.99,0.99]; end %to get around the invert hard copy problem
    
    for det = 1:inst_params.detectors
        detno=num2str(det);
        for box = 1:6
            %coords = status_flags.analysis_modules.sector_boxes.(['coords' num2str(box)]);
            coords = sector_box_callbacks('retrieve_box_coords',box);
            
            cm = displayimage.cm.(['det' detno]);
            params = displayimage.(['params' detno]);
            
            %Find current detector distance for particular detector pannel
            det_current = params.det; %Default unless otherwise
            if strcmp(status_flags.q.det,'detcalc')
                if isfield(params,'detcalc')
                    det_current = params.detcalc;
                    
                end
            end
            
            
            %Special case for D33 panel detectors.
            if strcmp(grasp_env.inst,'ILL_d33')
                switch det
                    case 1  %Rear
                        
                        det_current = displayimage.(['params' detno]).detcalc2;
                    case 2 % Right
                        det_current = displayimage.(['params' detno]).detcalc1 + displayimage.(['params' detno]).det1_panel_offset;
                    case 3 % Left
                        det_current = displayimage.(['params' detno]).detcalc1 + displayimage.(['params' detno]).det1_panel_offset;
                    case 4 %Bottom
                        det_current = displayimage.(['params' detno]).detcalc1;
                    case 5 %Top
                        det_current = displayimage.(['params' detno]).detcalc1;
                end
            end
            
            
            %Keep a memory of the main detector(1) Det
            if det ==1; det1det = det_current; end
            
            
            %For conical radius scaling of multiple detectors
            warning off
            eff_outer_radius = coords(1) * det_current / det1det;
            eff_inner_radius = coords(2) * det_current / det1det;
            warning on
            
            
            %Default beam centres
            cx_eff = cm.cm_pixels(1);
            cy_eff = cm.cm_pixels(2);
            
            
            if strcmp(grasp_env.inst,'ILL_d33')
                switch det
                    case 1 %Rear
                        
                        cx_eff = cm.cm_pixels(1);
                        cy_eff = cm.cm_pixels(2);
                    case 2 % Right
                        cx_eff = cm.cm_pixels(1) - ((params.oxr - cm.cm_translation(1)))/inst_params.(['detector' detno]).pixel_size(1); %horizontal distance from beam centre to pixel (m)
                        cy_eff = cm.cm_pixels(2);
                    case 3 % Left
                        cx_eff = cm.cm_pixels(1) + ((params.oxl - cm.cm_translation(1)))/inst_params.(['detector' detno]).pixel_size(1); %horizontal distance from beam centre to pixel (m)
                        cy_eff = cm.cm_pixels(2);
                    case 4 %Bottom
                        cx_eff = cm.cm_pixels(1);
                        cy_eff = cm.cm_pixels(2)  + ((params.oyb - cm.cm_translation(2)))/inst_params.(['detector' detno]).pixel_size(2); %vertical distance from beam centre to pixel (m)
                    case 5 %Top
                        cx_eff = cm.cm_pixels(1);
                        cy_eff = cm.cm_pixels(2) - ((params.oyt - cm.cm_translation(2)))/inst_params.(['detector' detno]).pixel_size(2); %vertical distance from beam centre to pixel (m)
                end
            end
            
            
            
            
            
            
            
            
            %Draw new sectors
            sector_handles = circle(det,eff_outer_radius,....
                eff_inner_radius,....
                cx_eff,cy_eff,....
                coords(3)-coords(4)/2,....
                coords(3)+coords(4)/2,....
                status_flags.analysis_modules.sector_boxes.box_color,....
                coords(5),....
                coords(6));
            grasp_handles.window_modules.sector_box.sketch_handles = [grasp_handles.window_modules.sector_box.sketch_handles; sector_handles];
        end
    end
end
