function mask_edit_callbacks(to_do,option)

global grasp_data
global status_flags
global grasp_handles
global inst_params

%Find the index to masks in DATA, depends if Data Mask or Water Mask.
if status_flags.selector.fw >= 101 && status_flags.selector.fw <= 107; %i.e. Water data is displayed, therefore edit water mask
    mask_type = 107; %Callibration mask
else
    mask_type = 7; %Scattering Data mask
end
index = data_index(mask_type);

%Find the 'number' of the mask we are working with: Use this as Mask can have an independent number if grouping is off.
nmbr = status_flags.display.mask.number;

switch to_do

    case 'point_edit'
        value = str2num(get(gcbo,'string'));
        if not(isempty(value))
            if strcmp(option,'x')
                status_flags.mask_window.point(1) = value;
            elseif strcmp(option,'y')
                status_flags.mask_window.point(2) = value;
            end
        end
        
        
    case 'lines_edit'
        status_flags.mask_window.lines = get(gcbo,'string');
        
    case 'box_edit'
        value = str2num(get(gcbo,'string'));
        if not(isempty(value))
            if strcmp(option,'x1')
                status_flags.mask_window.box(1) = value;
            elseif strcmp(option,'x2')
                status_flags.mask_window.box(2) = value;
            elseif strcmp(option,'y1')
                status_flags.mask_window.box(3) = value;
            elseif strcmp(option,'y2')
                status_flags.mask_window.box(4) = value;
            end
        end
        
    case 'circle_edit'
        value = str2num(get(gcbo,'string'));
        if not(isempty(value))
            if strcmp(option,'cx')
                status_flags.mask_window.circle(1) = value;
            elseif strcmp(option,'cy')
                status_flags.mask_window.circle(2) = value;
            elseif strcmp(option,'cr')
                status_flags.mask_window.circle(3) = value;
            end
        end
                

    case 'sketch'

        %Switch to main figure window
        figure(grasp_handles.figure.grasp_main);
        %turn zoom and 3D rotate off
        zoom off;
        %set(grasp_handles.toolbar.rotate_3d,'state','off')
        
        endflag = 0;

        %Display Sketch On Status
        text_handle = grasp_message('Sketch Mask On!  :  ESC to Exit');

        while endflag==0

            event=waitforbuttonpress;

            if event == 0 && gcf == grasp_handles.figure.grasp_main %i.e. when mouse button was pressed, was it on the correct figure?  If not, terminate loop anyway
                point1=get(grasp_handles.displayimage.(['axis' num2str(status_flags.display.active_axis)]),'CurrentPoint');
                finalrect = rbbox;
                point2 = get(grasp_handles.displayimage.(['axis' num2str(status_flags.display.active_axis)]),'CurrentPoint');

                %Check sketch actually happend on the designated active axis
                if gca ~= grasp_handles.displayimage.(['axis' num2str(status_flags.display.active_axis)]);
                    disp('Mask Sketch Coordinates Outside of Current Axes')
                    if not(isempty(text_handle)) & ishandle(text_handle); delete(text_handle); end
                    return
                end
                
                %point1 & point2 coordinates could be in any axes:  sort into order and convert back to pixels
                xcoord = [point1(1,1),point2(1,1)]; ycoord = [point2(1,2),point1(1,2)];
                xcoord = sort(xcoord); ycoord = sort(ycoord);
                sketch_coords = current_axis_limits([xcoord,ycoord]);
                sketch_coords_pixels = round(sketch_coords.(['det' num2str(status_flags.display.active_axis)]).pixels);
                
                %Check that the sketched coordinates lie within the detector size
                if sketch_coords_pixels(1) >= 1 && sketch_coords_pixels(2) <= inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixels(1) && sketch_coords_pixels(3) >=1 && sketch_coords_pixels(4) <= inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixels(2); %Check coord were actually within the axes
                    grasp_data(index).(['data' num2str(status_flags.display.active_axis)]){nmbr}(sketch_coords_pixels(3):sketch_coords_pixels(4),sketch_coords_pixels(1):sketch_coords_pixels(2)) = option;
                    %Store sketch coordinates as box coordinates for use again
                    status_flags.mask_window.box = sketch_coords_pixels;
                    set(grasp_handles.window_modules.mask_edit.boxx1,'string',num2str(status_flags.mask_window.box(1)));
                    set(grasp_handles.window_modules.mask_edit.boxx2,'string',num2str(status_flags.mask_window.box(2)));
                    set(grasp_handles.window_modules.mask_edit.boxy1,'string',num2str(status_flags.mask_window.box(3)));
                    set(grasp_handles.window_modules.mask_edit.boxy2,'string',num2str(status_flags.mask_window.box(3)));

                    endflag = 1; %i.e. exit the loop after only one sketch
                else
                    disp('Mask Sketch Coordinates Outside of Current Axes')
                    endflag =1; %i.e. exit the loop
                end
                grasp_update
            else
                endflag =1; %i.e. exit the loop
            end
        end
        if not(isempty(text_handle)) & ishandle(text_handle); delete(text_handle); end
        %Switch back to Mask window
        figure(grasp_handles.window_modules.mask_edit.window);
        

    case 'clear_mask'
        clear_wks_nmbr(mask_type,nmbr);
        grasp_update

    case 'grab_cm'
        cm=current_beam_centre;
        cm_det1_pixels = cm.det1.cm_pixels;
        set(grasp_handles.window_modules.mask_edit.cx,'string',num2str(cm_det1_pixels(1)));
        set(grasp_handles.window_modules.mask_edit.cy,'string',num2str(cm_det1_pixels(2)));
        status_flags.mask_window.circle(1) = cm_det1_pixels(1);
        status_flags.mask_window.circle(2) = cm_det1_pixels(2);
        
        
    case 'circle'
        if status_flags.display.active_axis ==1 % Only can do circle masks for central detector1
            cx = status_flags.mask_window.circle(1);
            cy = status_flags.mask_window.circle(2);
            radius = status_flags.mask_window.circle(3);
            
            %Correct for pixel anisotropy.  Pixels are measured in x-pixels
            pixelsize_x = inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixel_size(1)/1000; %x-pixel size in m
            pixelsize_y = inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixel_size(2)/1000; %y-pixel size in m
            
            pixelsize_short=min(inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixel_size);
            pixelsize_long=max(inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixel_size);
%            pixel_anisotropy = pixelsize_x / pixelsize_y;
            pixel_anisotropy = pixelsize_short / pixelsize_long;
            if radius ~= 0
            if pixelsize_x<=pixelsize_y
                for y = 0:radius
                    width = sqrt((radius^2)-(y^2));
                    yy = y*pixel_anisotropy;
                    for x = 0:fix(width)
                        if floor(cy+yy) <= inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixels(2) && floor(cx+x) <= inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixels(1)
                            grasp_data(index).(['data' num2str(status_flags.display.active_axis)]){nmbr}(floor(cy+yy),floor(cx+x)) = option;
                        end
                        if ceil(cy-yy) >= 1 && floor(cx+x) <= inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixels(1)
                            grasp_data(index).(['data' num2str(status_flags.display.active_axis)]){nmbr}(ceil(cy-yy),floor(cx+x)) = option;
                        end
                        if floor(cy+yy) <= inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixels(2) && ceil(cx-x) >= 1
                            grasp_data(index).(['data' num2str(status_flags.display.active_axis)]){nmbr}(floor(cy+yy),ceil(cx-x)) = option;
                        end
                        if ceil(cy-yy) >=1 && ceil(cx-x) >=1
                            grasp_data(index).(['data' num2str(status_flags.display.active_axis)]){nmbr}(ceil(cy-yy),ceil(cx-x)) = option;
                        end
                    end
                end
            
             else    
                for x = 0:radius
                    width = sqrt((radius^2)-(x^2));
                    xx = x*pixel_anisotropy;
                    for y = 0:fix(width)
                        if floor(cx+xx) <= inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixels(1) && floor(cy+y) <= inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixels(2)
                            grasp_data(index).(['data' num2str(status_flags.display.active_axis)]){nmbr}(floor(cy+y),floor(cx+xx)) = option;
                        end
                        if ceil(cx-xx) >= 1 && floor(cy+y) <= inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixels(2)
                            grasp_data(index).(['data' num2str(status_flags.display.active_axis)]){nmbr}(floor(cy+y),ceil(cx-xx)) = option;
                        end
                        if floor(cx+xx) <= inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixels(1) && ceil(cy-y) >= 1
                            grasp_data(index).(['data' num2str(status_flags.display.active_axis)]){nmbr}(ceil(cy-y),floor(cx+xx)) = option;
                        end
                        if ceil(cx-xx) >=1 && ceil(cy-y) >=1
                            grasp_data(index).(['data' num2str(status_flags.display.active_axis)]){nmbr}(ceil(cy-y),ceil(cx-xx)) = option;
                        end
                    end
                end            
            end
            end
            grasp_update
        else
            disp('Can''t Make Circle Mask for this Detector');
        end
        

        
    case 'point'

        x_coord = status_flags.mask_window.point(1);
        y_coord = status_flags.mask_window.point(2);
        
        %Check if in range
        if x_coord >=1 && x_coord <= inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixels(1) && y_coord >= 1 && y_coord <= inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixels(2)
            grasp_data(index).(['data' num2str(status_flags.display.active_axis)]){nmbr}(y_coord,x_coord) = option;
        else
            disp('Mask Editor: Point coordinates out of range');
        end
        grasp_update

        
    case 'line'

        %Line Mask
        str2 = status_flags.mask_window.lines; 
        loop_flag = 1;
        while loop_flag == 1
            [str1,str2] = strtok(str2,',');
            if isempty(str2); loop_flag = 0; end
            find_x = findstr(str1,'x');
            if not(isempty(find_x))
                x_line = round(str2num(str1(find_x+1:length(str1))));
                if not(isempty(x_line))
                if x_line >= 1 && x_line <= inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixels(1)
                    grasp_data(index).(['data' num2str(status_flags.display.active_axis)]){nmbr}(:,x_line) = option;
                else
                    disp(['Mask Editor: X-Line coordinates out of range']);
                end
                else
                    disp('There was an error in parsing your mask x-line string');
                end
            end
            find_y = findstr(str1,'y');
            if not(isempty(find_y))
                y_line = round(str2num(str1(find_y+1:length(str1))));
                if not(isempty(y_line))
                if y_line >= 1 && y_line <= inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixels(2)
                    grasp_data(index).(['data' num2str(status_flags.display.active_axis)]){nmbr}(y_line,:) = option;
                else
                    disp(['Mask Editor: y-Line coordinates out of range']);
                end
                else
                    disp('There was an error in parsing your mask y-line string');
                end
            end
        end
        grasp_update

    case 'box'
        x1_coord = status_flags.mask_window.box(1);
        x2_coord = status_flags.mask_window.box(2);
        y1_coord = status_flags.mask_window.box(3);
        y2_coord = status_flags.mask_window.box(4);
            
        %Sort into order
        if x1_coord > x2_coord; temp = x1_coord; x1_coord = x2_coord; x2_coord = temp; end
        if y1_coord > y2_coord; temp = y1_coord; y1_coord = y2_coord; y2_coord = temp; end

        if x1_coord >= 1 && x1_coord <= inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixels(1) && x2_coord >= 1 && x2_coord <= inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixels(1) ....
                && y1_coord >= 1 && y1_coord <= inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixels(2) && y2_coord >= 1 && y2_coord <= inst_params.(['detector' num2str(status_flags.display.active_axis)]).pixels(2)
            disp('here')
            grasp_data(index).(['data' num2str(status_flags.display.active_axis)]){nmbr}(y1_coord:y2_coord,x1_coord:x2_coord) = option;
        else
            disp('Mask Editor: Box coordinates out of range');
        end
        
        grasp_update
        
    case 'close'
        
        grasp_handles.window_modules.mask_edit.window = []; %clear the handle otherwise other windows could get deleted


end

%Some general updates
