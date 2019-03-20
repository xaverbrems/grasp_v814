function output = box_callbacks(to_do,option)

if nargin<2; option = ''; end
if nargin<1; to_do = ''; end
output = [];

global status_flags
global grasp_handles
global displayimage
global grasp_data
global inst_params
global gs_grasp_box_data


%global box_intensities

switch to_do
    
    case 'update_box_mask'
        [~] = box_callbacks('build_the_masks'); %Only called here to update the box mask worksheet
        if status_flags.selector.fw == 30; grasp_update; end %Update the display if showing the sector mask
        
    case 'retrieve_box_coords'
        %Retrieves the box coords from the status_flags structure
        %and modifies them if necessary according to q-lock - or other box
        %moving features

        %find current beam centre
        cm = current_beam_centre;

        coords = status_flags.analysis_modules.boxes.(['coords' num2str(option)]); %where option is the box number
        %Rebuild Masks if necessary (i.e. for Q-lock with wavelength)
        if status_flags.analysis_modules.boxes.q_lock_chk  == 1
            %Modify coordinates according to wavelength and reference wavelength
            lambda_ref = status_flags.analysis_modules.boxes.q_lock_wav_ref;
            lambda_now = displayimage.params1.wav;
            
            
            if status_flags.analysis_modules.boxes.q_lock_box_size_chk  == 0
                %Simple box movement - box gets larger as it goes out
                %R1 = (coords(1) * lambda_now/lambda_ref); %new outer radius
                %R2 = (coords(2) * lambda_now/lambda_ref); %new inner radius
                if coords(1) ~=0
                    delta_x1 = (coords(1)-cm.det1.cm_pixels(1)) * lambda_now/lambda_ref;
                    coords(1) = delta_x1 + cm.det1.cm_pixels(1);
                end
                if coords(2) ~=0
                    delta_x2 = (coords(2)-cm.det1.cm_pixels(1)) * lambda_now/lambda_ref;
                    coords(2) = delta_x2 + cm.det1.cm_pixels(1);
                end
                if coords(3) ~=0
                    delta_y1 = (coords(3)-cm.det1.cm_pixels(2)) * lambda_now/lambda_ref;
                    coords(3) = delta_y1 + cm.det1.cm_pixels(2);
                end
                if coords(4) ~=0
                    delta_y2 = (coords(4)-cm.det1.cm_pixels(2)) * lambda_now/lambda_ref;
                    coords(4) = delta_y2 + cm.det1.cm_pixels(2);
                end
                
                
            elseif status_flags.analysis_modules.boxes.q_lock_box_size_chk == 1
                %'Constant' box size 
                x_width = coords(2)-coords(1); y_width = coords(4)-coords(3);
                delta_mean_x = (((coords(1)+coords(2))/2) - cm.det1.cm_pixels(1)) * lambda_now/lambda_ref;
                delta_mean_y = (((coords(4)+coords(3))/2) - cm.det1.cm_pixels(2)) * lambda_now/lambda_ref;
                if coords(1) ~=0
                    coords(1) = delta_mean_x + cm.det1.cm_pixels(1) - x_width/2;
                end
                if coords(2) ~=0
                    coords(2) = delta_mean_x + cm.det1.cm_pixels(1) + x_width/2;
                end
                if coords(3) ~=0
                    coords(3) = delta_mean_y + cm.det1.cm_pixels(2) - y_width/2;
                end
                if coords(4) ~=0
                    coords(4) = delta_mean_y + cm.det1.cm_pixels(2) + y_width/2;
                end
            end
        end
        
        if status_flags.analysis_modules.boxes.t2t_lock_chk ==1
            
            %Modify coordinates according to omega_2b angle and reference omega_2b angle
            angle_ref = status_flags.analysis_modules.boxes.(['t2t_lock_angle_ref' num2str(option)]);
            angle_now = displayimage.params1.omega_2b;
            delta_2theta = 2*(angle_now - angle_ref); %This is the required angular shift of the box
            
            if coords(1) ~=0 && coords(2) ~=0
                if coords(1) < cm.det1.cm_pixels(1)
                    
                else
                    delta_2theta = -delta_2theta;
                end
                
                x1_angle = displayimage.qmatrix1(1,round(coords(1)),7);
                x1_angle = x1_angle + delta_2theta;
                %Find the cloeset pixel this corresponds to on the detector
                temp = find(displayimage.qmatrix1(1,:,7)>=x1_angle);
                x1 = displayimage.qmatrix1(1,temp(1),1);
                
                x2_angle = displayimage.qmatrix1(1,round(coords(2)),7);
                x2_angle = x2_angle + delta_2theta;
                %Find the cloeset pixel this corresponds to on the detector
                temp = find(displayimage.qmatrix1(1,:,7)>=x2_angle);
                x2 = displayimage.qmatrix1(1,temp(1),1);
                
                
                %if status_flags.analysis_modules.boxes.t2t_lock_box_size_chk == 1; %Scale sector opening with box position
                %    coords(4) = coords(4) * mean(coords(1),coords(2))/mean(R1,R2);
                %    
                %end
                coords(1) = x1;
                coords(2) = x2;
            end
            
        end
        output = round(coords);
        return
        
       
    case 'q_lock_box_size_chk'
        status_flags.analysis_modules.boxes.q_lock_box_size_chk = get(gcbo,'value');
        box_callbacks;
        
    case 'q_lock_chk'
        status_flags.analysis_modules.boxes.q_lock_chk = get(gcbo,'value');
        status_flags.analysis_modules.boxes.t2t_lock_chk = 0;
        box_callbacks;
        
    case 't2t_lock_box_size_chk'
        status_flags.analysis_modules.boxes.t2t_lock_box_size_chk = get(gcbo,'value');
        box_callbacks;
        
    case 't2t_lock_chk'
        status_flags.analysis_modules.boxes.t2t_lock_chk = get(gcbo,'value');
        status_flags.analysis_modules.boxes.q_lock_chk = 0;
        box_callbacks;
       
        
    case 'scan_box_check'
        box = get(gcbo,'userdata');
        status_flags.analysis_modules.boxes.scan_boxes_check(box) = get(gcbo,'value');
        
    case 'x1'
        box = get(gcbo,'userdata');
        boxno=num2str(box);
        temp = str2num(get(gcbo,'string'));
        if not(isempty(temp))
            coords = getfield(status_flags.analysis_modules.boxes,['coords' boxno]);
            coords(1) = temp;
            status_flags.analysis_modules.boxes = setfield(status_flags.analysis_modules.boxes,['coords' boxno],coords);
        end
        status_flags.analysis_modules.boxes.q_lock_wav_ref = displayimage.params1.wav;
        status_flags.analysis_modules.boxes.(['t2t_lock_angle_ref' boxno]) = displayimage.params1.omega_2b;
        box_callbacks('update_box_mask'); %Update box mask worksheet
        
    case 'x2'
        box = get(gcbo,'userdata');
        boxno=num2str(box);
        temp = str2num(get(gcbo,'string'));
        if not(isempty(temp))
            coords = getfield(status_flags.analysis_modules.boxes,['coords' boxno]);
            coords(2) = temp;
            status_flags.analysis_modules.boxes = setfield(status_flags.analysis_modules.boxes,['coords' boxno],coords);
        end
        status_flags.analysis_modules.boxes.q_lock_wav_ref = displayimage.params1.wav;
        status_flags.analysis_modules.boxes.(['t2t_lock_angle_ref' num2str(box)]) = displayimage.params1.omega_2b;
        box_callbacks('update_box_mask'); %Update box mask worksheet
        
    case 'y1'
        box = get(gcbo,'userdata');
        boxno=num2str(box);
        temp = str2num(get(gcbo,'string'));
        if not(isempty(temp))
            coords = getfield(status_flags.analysis_modules.boxes,['coords' boxno]);
            coords(3) = temp;
            status_flags.analysis_modules.boxes = setfield(status_flags.analysis_modules.boxes,['coords' boxno],coords);
        end
        status_flags.analysis_modules.boxes.q_lock_wav_ref = displayimage.params1.wav;
        status_flags.analysis_modules.boxes.(['t2t_lock_angle_ref' num2str(box)]) = displayimage.params1.omega_2b;
        box_callbacks('update_box_mask'); %Update box mask worksheet
        
    case 'y2'
        box = get(gcbo,'userdata');
        boxno=num2str(box);
        temp = str2num(get(gcbo,'string'));
        if not(isempty(temp))
            coords = getfield(status_flags.analysis_modules.boxes,['coords' boxno]);
            coords(4) = temp;
            status_flags.analysis_modules.boxes = setfield(status_flags.analysis_modules.boxes,['coords' boxno],coords);
        end
        status_flags.analysis_modules.boxes.q_lock_wav_ref = displayimage.params1.wav;
        status_flags.analysis_modules.boxes.(['t2t_lock_angle_ref' num2str(box)]) = displayimage.params1.omega_2b;
        box_callbacks('update_box_mask'); %Update box mask worksheet

    case 'clear_box'
        box = get(gcbo,'userdata');
        boxno=num2str(box);
        coords =[0,0,0,0,1]; %Empty box coordinates.  5th coordinate is the detector number
        status_flags.analysis_modules.boxes = setfield(status_flags.analysis_modules.boxes,['coords' boxno],coords);
        status_flags.analysis_modules.boxes.q_lock_wav_ref = displayimage.params1.wav;
        status_flags.analysis_modules.boxes.(['t2t_lock_angle_ref' num2str(box)]) = displayimage.params1.omega_2b;
        box_callbacks('update_box_mask'); %Update box mask worksheet

    case 'clear_all'
        for box = 1:6
            boxno=num2str(box);
            coords = [0,0,0,0,1]; %Empty box coordinates
            status_flags.analysis_modules.boxes = setfield(status_flags.analysis_modules.boxes,['coords' boxno],coords);
        end
        status_flags.analysis_modules.boxes.q_lock_wav_ref = displayimage.params1.wav;
        status_flags.analysis_modules.boxes.(['t2t_lock_angle_ref' boxno]) = displayimage.params1.omega_2b;
        box_callbacks('update_box_mask'); %Update box mask worksheet
        
    case 'parameter'
        string = get(grasp_handles.window_modules.box.parameter,'string');
        value = get(grasp_handles.window_modules.box.parameter,'value');
        status_flags.analysis_modules.boxes.parameter = string{value};
       
    case 'box_color'
        color_string = get(grasp_handles.window_modules.box.box_color,'string');
        position = get(grasp_handles.window_modules.box.box_color,'value');
        color = color_string{position};
        status_flags.analysis_modules.boxes.box_color = color;

    case 'grab_coords'
        box = get(gcbo,'userdata');
        det = status_flags.display.active_axis;
        detno=num2str(det);
        ax_lims = current_axis_limits;
        ax_lims = ax_lims.(['det' detno]).pixels;
        status_flags.analysis_modules.boxes = setfield(status_flags.analysis_modules.boxes,['coords' num2str(box)],[ax_lims, det]);
        
        %Keep a record of the scan-box reference omega_2b angle
        status_flags.analysis_modules.boxes.scan_boxes_angle0(box) = displayimage.(['params' detno]).omega_2b;
        status_flags.analysis_modules.boxes.q_lock_wav_ref = displayimage.(['params' detno]).wav;
        status_flags.analysis_modules.boxes.(['t2t_lock_angle_ref' num2str(box)]) = displayimage.(['params' detno]).omega_2b;
        
        box_callbacks('update_box_mask'); %Update box mask worksheet

    case 'close'
        %Delete old boxes
        temp = ishandle(grasp_handles.window_modules.box.sketch_handles);
        delete(grasp_handles.window_modules.box.sketch_handles(temp));
        grasp_handles.window_modules.box.sketch_handles = [];
        grasp_handles.window_modules.box.window = [];
        return


    case 'sum_box_chk'
        status_flags.analysis_modules.boxes.sum_box_chk = not(status_flags.analysis_modules.boxes.sum_box_chk);
        
    case 'box_nrm_chk'
        status_flags.analysis_modules.boxes.box_nrm_chk = not(status_flags.analysis_modules.boxes.box_nrm_chk);
        
    case 'build_the_masks'
        
        
        %NEED TO INCLUDE USER AND INSTRUMENT MASKS HERE!
        
        box_masks = []; box_number = []; active_boxes = [];
        %Make empty sum_masks for all detectors
        for det = 1:inst_params.detectors
            detno=num2str(det);
            sum_mask.(['det' detno]) = zeros(inst_params.(['detector' detno]).pixels(2),inst_params.(['detector' detno]).pixels(1));
        end
        
        box_history = ['Box Coordinates:  x1 x2 y1 y2'];
        %Make logical box masks only for valid boxes
        for box = 1:6
            %            coords = status_flags.analysis_modules.boxes.(['coords' num2str(box)]);
            coords = box_callbacks('retrieve_box_coords',box);
            %disp(['Box ' num2str(box) ' coordinates ' num2str(coords(1:4)) ' on detector ' num2str(coords(5))]);
            det = coords(5); %Detector number we are dealing with
            detno=num2str(det);
            box_masks.(['box' num2str(box)]) = zeros(inst_params.(['detector' detno]).pixels(2),inst_params.(['detector' detno]).pixels(1));
            %box_area = (coords(2)-coords(1)+1)*(coords(4)-coords(3)+1);
            
            if find(coords == 0) %ignore if any of the coordinates are zero
            else
                active_boxes = [active_boxes, box];
                box_masks.(['box' num2str(box)])(coords(3):coords(4),coords(1):coords(2)) = 1;
                %Include Current Mask conditions in the box
                %Apply the Mask to the image only if Sample, Empty or Cadmium or PA scattering worksheets
                if (displayimage.type >=1 && displayimage.type <=3) || (displayimage.type >=10 && displayimage.type <=19)|| displayimage.type == 22 || displayimage.type == 23
                    box_masks.(['box' num2str(box)]) = box_masks.(['box' num2str(box)]).*displayimage.(['mask' num2str(det)]);
                end
                box_history =  [box_history, {[num2str(coords(1)) ' ' num2str(coords(2)) ' ' num2str(coords(3)) ' ' num2str(coords(4))]}];
            end
            sum_mask.(['det' detno]) = or(sum_mask.(['det' detno]),box_masks.(['box' num2str(box)]));
        end
        
        for det = 1:inst_params.detectors
            detno=num2str(det);
            sum_mask.(['det' detno]) = double(sum_mask.(['det' detno])); %Otherwise it comes out as a logical
            
            %Copy Box (sum) mask into Box mask worksheet
            index = data_index(30); %index to sector mask worksheet
            grasp_data(index).(['data' detno]){1} = sum_mask.(['det' detno]);
        end
        %disp(['Active Boxes are:  ' num2str(active_boxes)]);
        
        output.box_mask =  box_masks;
        output.active_boxes = active_boxes;
        output.sum_mask = sum_mask;
        output.box_history = box_history;
        
        
    case 'box_it'
        %Turn off updating
        remember_display_params_status = status_flags.command_window.display_params; %Turn off command window parameter update for the boxing
        if strcmp(status_flags.analysis_modules.boxes.display_refresh,'on')
            status_flags.command_window.display_params=1; status_flags.display.refresh = 1;
        else
            status_flags.command_window.display_params=0; status_flags.display.refresh = 0;
        end
        
        masks = box_callbacks('build_the_masks');
        box_masks = masks.box_mask;
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
       
        
        disp(['Extracting Box intensities through depth']);
        box_intensities = [];
        message_handle = grasp_message(['Extracting Box intensities Depth: ' num2str(dstart) ' to ' num2str(dend)]);
        
        for n = dstart:dend
            status_flags.selector.fd = n+grasp_data(index).sum_allow;
            main_callbacks('depth_scroll'); %Scroll all linked depths and update
            
%             %Rebuild Masks if necessary (i.e. for Q-lock with wavelength)
%             if status_flags.analysis_modules.sector_boxes.q_lock_chk  == 1 || status_flags.analysis_modules.sector_boxes.t2t_lock_chk ==1;
%                 masks = box_callbacks('build_the_masks');
%                 box_masks = masks.box_mask;
%                 active_boxes = masks.active_boxes;
%                 sum_mask = masks.sum_mask;
%                 box_history = masks.box_history;
%             end
            
            %Get the box intensities
            
            %***** Summed Boxes *****
            if status_flags.analysis_modules.boxes.sum_box_chk == 1
                %Loop though the detectors each with their sum mask
                box_pixels = 0; box_sum = 0; box_sum_error = 0;
                for det = 1:inst_params.detectors
                    detno=num2str(det);
                    %All boxes summed
                    box_pixels = box_pixels + sum(sum(sum_mask.(['det' detno])));
                    box_sum = box_sum + sum(sum(displayimage.(['data' detno]).* sum_mask.(['det' detno])));
                    box_sum_error = sqrt(box_sum_error.^2 + (sum(sum((displayimage.(['error' detno]).*sum_mask.(['det' detno])).^2))));
                    parameter = displayimage.(['params' detno]).([status_flags.analysis_modules.boxes.parameter]);
                end
                %Normalise if required
                if status_flags.analysis_modules.boxes.box_nrm_chk ==1
                    box_sum = box_sum / box_pixels;  box_sum_error = box_sum_error / box_pixels;
                end
                box_sum_list = [parameter, box_sum, box_sum_error]; %Accumulate the sum list
                %Note: In the case of summed boxes the parameter will come from the last detector panel parameters
                %Since most parameters are the same for each panel (except e.g TOF wavelength) this shouldn't be a problem in most cases
                
            %***** Individual Boxes *****    
            else
                box_sum_list = [];
                for m = 1:n_boxes
                    box = active_boxes(m);
                    boxno=num2str(box);
                    coords = status_flags.analysis_modules.boxes.(['coords' boxno]);
                    detno=num2str(coords(5));
                    mask = box_masks.(['box' boxno]);
                    %Normalise if required
                    if status_flags.analysis_modules.boxes.box_nrm_chk ==1
                        box_pixels = sum(sum(mask));
                    else
                        box_pixels = 1;
                    end
                    
                    box_sum = (sum(sum(displayimage.(['data' detno]) .* mask)))/box_pixels;
                    box_sum_error = (sqrt(sum(sum((displayimage.(['error' detno]) .* mask).^2))))/box_pixels;
                    parameter = displayimage.(['params' detno]).([status_flags.analysis_modules.boxes.parameter]);
                    box_sum_list = [box_sum_list, parameter, box_sum, box_sum_error];
                end
            end

            box_intensities = [box_intensities; [n, box_sum_list]];
        end               
        
        %Dislplay results on screen
        disp(' ');
        header_str = repmat(['Parameter(' num2str(status_flags.analysis_modules.boxes.parameter) '),     Counts,     Err_Counts,      '],1,n_boxes);
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
        if status_flags.analysis_modules.boxes.box_nrm_chk ==1; y_string = ' \\ Pixel'; else y_string = []; end

        plot_params = struct(....
            'plot_type','plot',....
            'plot_data',plotdata,....
            'column_format',column_format,....
            'hold_graph','off',....
            'plot_title',['Box Sum'],....
            'x_label',(['Parameter ' status_flags.analysis_modules.boxes.parameter]),....
            'y_label',['Box ' displayimage.units y_string],....
            'legend_str',['Box#' num2str(displayimage.params1.numor)],....
            'params',displayimage.params1,....
            'export_data',plotdata,....
            'export_column_format',column_format,....
            'column_labels',[status_flags.analysis_modules.boxes.parameter char(9) 'I' char(9) 'Err_I']);
        
        local_history = displayimage.history; %This will actually be the history of the last file
        local_history = [local_history, {['***** Analysis *****']}];
        local_history = [local_history, {['Box Intensity vs. Parameter ' num2str(status_flags.analysis_modules.boxes.parameter)]}];
        local_history = [local_history, box_history];
        plot_params.history = local_history;
        
        if not(strcmp(option,'plot_off'))
            grasp_plot2(plot_params); %Plot
        end
        
        %Store plot data for grasp script to use
        gs_grasp_box_data = plotdata;
end

%Update displayed box window option
if status_flags.analysis_modules.boxes.q_lock_chk == 1 %q-lock
    set(grasp_handles.window_modules.box.q_lock_box_size,'visible','on');
    set(grasp_handles.window_modules.box.t2t_lock_box_size,'visible','off');
else
    set(grasp_handles.window_modules.box.q_lock_box_size,'visible','off');
    %set(grasp_handles.window_modules.box.t2t_lock_box_size,'visible','off');
end

if status_flags.analysis_modules.boxes.t2t_lock_chk == 1 %theta-2theta lock
    set(grasp_handles.window_modules.box.t2t_lock_box_size,'visible','off'); %NOT USED AT THE MOMENT
    set(grasp_handles.window_modules.box.q_lock_box_size,'visible','off');
else
    set(grasp_handles.window_modules.box.t2t_lock_box_size,'visible','off');
end
set(grasp_handles.window_modules.box.q_lock,'value',status_flags.analysis_modules.boxes.q_lock_chk);
set(grasp_handles.window_modules.box.t2t_lock,'value',status_flags.analysis_modules.boxes.t2t_lock_chk);


%Update displayed parameters
for box = 1:6
    %coords = getfield(status_flags.analysis_modules.boxes,['coords' num2str(box)]);
    coords = box_callbacks('retrieve_box_coords',box);
    handle = getfield(grasp_handles.window_modules.box,['coords' num2str(box)]);
    set(handle(1),'string',num2str(coords(1)));
    set(handle(2),'string',num2str(coords(2)));
    set(handle(3),'string',num2str(coords(3)));
    set(handle(4),'string',num2str(coords(4)));
    set(handle(5),'string',num2str(coords(5)));
    
end
set(grasp_handles.window_modules.box.sum_box_chk,'value',status_flags.analysis_modules.boxes.sum_box_chk);
set(grasp_handles.window_modules.box.box_nrm_chk,'value',status_flags.analysis_modules.boxes.box_nrm_chk);


%Update Dropdown list of parameters
string = rot90(fieldnames(displayimage.params1));
p_names = [];
p_values =displayimage.params1;
for p = 1:length(string)
     if isnumeric(p_values.(string{p}))
         p_names{end+1} = (string{p});
     end
end
value = find(strcmp(p_names,status_flags.analysis_modules.boxes.parameter));
if isempty(value)
    value = find(strcmp('numor',p_names));
    status_flags.analysis_modules.boxes.parameter = 'numor';
end
set(grasp_handles.window_modules.box.parameter,'string',p_names,'value',value);



%Delete old boxes
temp = ishandle(grasp_handles.window_modules.box.sketch_handles);
delete(grasp_handles.window_modules.box.sketch_handles(temp));
grasp_handles.window_modules.box.sketch_handles = [];

box_color = status_flags.analysis_modules.boxes.box_color;
if not(strcmp(box_color,'(none)'));
    if strcmp(box_color,'white'); box_color = [0.99,0.99,0.99]; end %to get around the invert hard copy problem


    for box = 1:6
        %coords = getfield(status_flags.analysis_modules.boxes,['coords' num2str(box)]);
        coords = box_callbacks('retrieve_box_coords',box);

        ax = grasp_handles.displayimage.(['axis' num2str(coords(5))]);

        %Check if using a scanning box & transform coordinates
        if status_flags.analysis_modules.boxes.scan_boxes_check(box) ==1
            angle_now = displayimage.params.omega_2b;
            angle0 = status_flags.analysis_modules.boxes.scan_boxes_angle0(box);
            coords = dynamic_box_coords(coords,angle0, angle_now);
        end

        corners(1,:) = [coords(1),coords(3)];
        corners(2,:) = [coords(1),coords(4)];
        corners(3,:) = [coords(2),coords(4)];
        corners(4,:) = [coords(2),coords(3)];
        corners(5,:) = corners(1,:); %close the box

        %Make Box vectors list
        drawvectors = [];
        for n = 1:(length(corners)-1)
            drawvectors(n,:) = [corners(n,1),corners((n+1),1),corners(n,2),corners((n+1),2)];
        end

        %Convert coordinates from pixels to q or two theta
        if strcmp(status_flags.axes.current,'q') | strcmp(status_flags.axes.current,'t')
            x_pixel_strip = displayimage.qmatrix(1,:,1);
            y_pixel_strip = displayimage.qmatrix(:,1,2);
            if strcmp(status_flags.axes.current,'q')
                %Look up q values from qmatrix
                x_axes_strip = displayimage.qmatrix(1,:,3);
                y_axes_strip = displayimage.qmatrix(:,1,4);
            elseif strcmp(status_flags.axes.current,'t')
                %Look up 2theta values from qmatrix
                x_axes_strip = displayimage.qmatrix(1,:,7);
                y_axes_strip = displayimage.qmatrix(:,1,8);
            end
            %Interpolate new co-ordinates in the current axes
            drawvectors(:,1:2) = interp1(x_pixel_strip,x_axes_strip,drawvectors(:,1:2),'spline');
            drawvectors(:,3:4) = interp1(y_pixel_strip,y_axes_strip,drawvectors(:,3:4),'spline');
        end

        %Specify z-height of the lines for the 3D plot
        %Set them to the max of the display range
        z_height = status_flags.display.z_max.det1;
        z_height = z_height * ones(size(drawvectors(:,1:2)));

        %Draw
        handles = line(drawvectors(:,1:2),drawvectors(:,3:4),z_height,'color',box_color,'linewidth',status_flags.display.linewidth,'parent',ax,'tag','strip_sketch');
        grasp_handles.window_modules.box.sketch_handles = [grasp_handles.window_modules.box.sketch_handles, handles];
    end
end

end



function coords = dynamic_box_coords(coords,angle0, angle_now)

global displayimage

%Recalculate dynamic box mask
disp('Re-calculating dynamic box coordinates')
disp(['Old Coords:  ' num2str(coords)]);

delta_2theta = 2*(angle_now - angle0); %This is the required angular shift of the box
disp(['Box Delta 2 Theta: ' num2str(delta_2theta)]);

%Nominal box pixel centre
x_centre_pixel0 = mean([coords(1),coords(2)]);
%Nominal box angle centre
x_centre_2theta0 = mean([displayimage.qmatrix(1,coords(1),7), displayimage.qmatrix(1,coords(2),7)]);
%new box angle centre
x_centre_2theta_now = x_centre_2theta0 + delta_2theta;
%Find the cloesett pixel this corresponds to on the detector
temp = find(displayimage.qmatrix(1,:,7)>=x_centre_2theta_now);

if not(isempty(temp))
    x_centre_pixel_now = displayimage.qmatrix(1,temp(1),1);
    delta_x_coord = x_centre_pixel_now - x_centre_pixel0;
    coords(1) = floor(coords(1) + delta_x_coord);
    coords(2) = floor(coords(2) + delta_x_coord);
    disp(['New Coords:  ' num2str(coords)]);
else
    coords = [1,1,1,1]; %i.e. equivalent to a non defined box
end


end


