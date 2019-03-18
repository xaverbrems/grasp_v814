function detector_efficiency_callbacks(to_do)

global displayimage
global status_flags
global inst_params
global grasp_handles
global grasp_data

if nargin <1; to_do = ''; end

index = data_index(99); %Find the index to the detector efficiency worksheet

%***** Retrieve as-displayed data *****
%This should be fully corrected for solid angle, paralax etc using the usual calibration options
for det = 1:inst_params.detectors
    detno=num2str(det);
    data.(['det' detno]) = displayimage.(['data' detno]);
    error.(['det' detno]) = displayimage.(['error' detno]);
    mask.(['det' detno]) = displayimage.(['mask' detno]);
    pixel_list.(['det' detno]) = reshape(data.(['det' detno]),numel(data.(['det' detno])),1);
    mask_list.(['det' detno]) = reshape(mask.(['det' detno]),numel(mask.(['det' detno])),1);
    pixel_list_masked.(['det' detno]) = pixel_list.(['det' detno])(mask_list.(['det' detno])==1);
    %Calculate the mean intensity for the flat scatterer for each detector pannel
    det_mean.(['det' detno]) = sum(pixel_list_masked.(['det' detno]))/numel(pixel_list_masked.(['det' detno]));
    det_mean_units = displayimage.units;
    warning off
    pixel_list_masked_mean.(['det' detno]) = pixel_list_masked.(['det' detno]) / det_mean.(['det' detno]);
    warning on
end

%Update the mean intensity display in the Det Eff window

set(grasp_handles.window_modules.detector_efficiency.cal_average_value,'string',num2str(det_mean.(['det' num2str(status_flags.display.active_axis)])));
set(grasp_handles.window_modules.detector_efficiency.cal_average_units,'string',displayimage.units);


switch to_do
    
    case 'histogram'
        %***** Plot Histogram of Detector Efficiency for current active detector pannel *****
        det = status_flags.display.active_axis; %Current active axis for multi-pannel data
        detno=num2str(det);
        [hgram,bincentre] = hist(pixel_list_masked_mean.(['det' detno]),100);
        plotdata(:,2) = hgram(:); plotdata(:,1) = bincentre(:);
        
        export_data = plotdata;
        column_labels = ['Frequency ' char(9) 'Counts [A.U] '];
        
        %Plot and Export Results
        plot_info = struct(....
            'x_label','Counts / Mean',....
            'y_label','Frequency',....
            'plot_title','Detector Efficeincy Histogram',....
            'plot_type','bar',....
            'export_data',export_data,....
            'plot_data',plotdata,....
            'column_format','xy',....
            'column_labels',column_labels,....
            'legend_str','Detector Efficiency Histogram');
        %'history', displayimage.history);
        grasp_plot2(plot_info);
        
        
        
    case 'accept'
        %Check with user that everything is correct
        button_name = questdlg(['Are you sure you have created a ''flat'' detector image?' char(10) char(10) 'This image should have the correct: Background Subtraction, Mask, Solid Angle Correction and Paralax Correction, but NOT any previous Detector Efficiency Correction.' char(10) char(10) '.....One more thing:  Why do you want to over-write the default efficiency file?'], ....
            'Are you sure?',....
            'Continue', 'Cancel', 'Cancel');
        
        switch button_name
            case 'Cancel'
                return
        end
        
        det = status_flags.display.active_axis; %Current active axis for multi-pannel data
        detno=num2str(det);
        nmbr = status_flags.selector.fn;
        
        %Check enough Det Eff worksheets exist
        if nmbr > grasp_data(index).nmbr
            add_worksheet(99);
        end
        
        
        det_mean.(['det' detno])
        
        %***** Store Efficeicny map in Det Eff Worksheet *****
        grasp_data(index).(['data' detno]){nmbr} = data.(['det' detno]) .* mask.(['det' detno]) ./ det_mean.(['det' detno]);  %Efficiency Map, fluctuating about 1.
        grasp_data(index).(['error' detno]){nmbr} = error.(['det' detno]) .* mask.(['det' detno]) ./ det_mean.(['det' detno]); %Error in Efficiency Map
        grasp_data(index).(['mean_intensity' detno]){nmbr} = det_mean.(['det' detno]);
        grasp_data(index).(['mean_intensity_units' detno]){nmbr} = det_mean_units;
        %Find Zero efficiencies and assign an value and error of 1
        %temp = find(grasp_data(index).(['data' detno]){nmbr} == 0);
        %grasp_data(index).(['error' detno]){nmbr}(temp) = 1;
        %grasp_data(index).(['data' detno]){nmbr}(temp) = 1;

        %Make efficiency map displayed in main figure
        status_flags.selector.fw = 99;
        main_callbacks('update_worksheet');
        status_flags.selector.fd =1;
        status_flags.selector.fn = nmbr;
        main_callbacks('update_number'); %Done in a different routine so can be called from elsewhere
        grasp_update

        
    case 'sketch'
        
        %Switch to main figure window
        figure(grasp_handles.figure.grasp_main);
        zoom off;
        endflag = 0;
        
        while endflag==0
            %Display Sketch On Status
            text_handle = grasp_message('Sketch Efficiency On!  :  ESC to Exit');
            
            event=waitforbuttonpress;
            
            nmbr = status_flags.selector.fn; dpth = status_flags.selector.fd;
            det=status_flags.display.active_axis;
            detno=num2str(det);
            if event == 0 && gcf == grasp_handles.figure.grasp_main %i.e. when mouse button was pressed, was it on the correct figure?  If not, terminate loop anyway
                point1=get(grasp_handles.displayimage.(['axis' detno]),'CurrentPoint');
                finalrect = rbbox;
                point2 = get(grasp_handles.displayimage.(['axis' detno]),'CurrentPoint');
                
                %Check sketch actually happend on the designated active axis
                if gca ~= grasp_handles.displayimage.(['axis' detno]);
                    disp('Detector Efficiency Sketch Coordinates Outside of Current Axes')
                    if not(isempty(text_handle)) & ishandle(text_handle); delete(text_handle); end
                    return
                end
                
                %point1 & point2 coordinates could be in any axes:  sort into order and convert back to pixels
                xcoord = [point1(1,1),point2(1,1)]; ycoord = [point2(1,2),point1(1,2)];
                xcoord = sort(xcoord); ycoord = sort(ycoord);
                sketch_coords = current_axis_limits([xcoord,ycoord]);
                sketch_coords_pixels = round(sketch_coords.(['det' detno]).pixels);
              
                %Check that the sketched coordinates lie within the detector size
                if sketch_coords_pixels(1) >= 1 && sketch_coords_pixels(2) <= inst_params.(['detector' detno]).pixels(1) && sketch_coords_pixels(3) >=1 && sketch_coords_pixels(4) <= inst_params.(['detector' detno]).pixels(2); %Check coord were actually within the axes
                    grasp_data(index).(['data' detno]){nmbr}(sketch_coords_pixels(3):sketch_coords_pixels(4),sketch_coords_pixels(1):sketch_coords_pixels(2),dpth) = 1;
                    endflag = 1; %i.e. exit the loop after only one sketch
                else
                    disp('Detector Efficiency Sketch Coordinates Outside of Current Axes')
                    endflag =1; %i.e. exit the loop
                end
                grasp_update
            else
                endflag = 1; %i.e. exit the loop
            end
            if not(isempty(text_handle)) & ishandle(text_handle); delete(text_handle); end
        end
        %Switch back to Mask window
        figure(grasp_handles.window_modules.detector_efficiency.window);
        
        
        
    case 'merge'
        %Merges detector efficiencies 1 & 2 and leaves the result in efficiency 1
        %Only do this for current active axis as usually only necessary for central detector containing the beam stop
    
        det = status_flags.display.active_axis; %Current active axis for multi-pannel data
        detno=num2str(det);
        split_line = status_flags.analysis_modules.det_eff.split_line;
        switch status_flags.analysis_modules.det_eff.split_method
            case 1
                
                det_eff1 = grasp_data(index).(['data' detno]){1};
                det_eff1_error = grasp_data(index).(['error' detno]){1};
                det_eff2 = grasp_data(index).(['data' detno]){2};
                det_eff2_error = grasp_data(index).(['error' detno]){2};
            case 2
                det_eff2 = grasp_data(index).(['data' detno]){1};
                det_eff2_error = grasp_data(index).(['error' num2str(det)]){1};
                det_eff1 = grasp_data(index).(['data' detno]){2};
                det_eff1_error = grasp_data(index).(['error' detno]){2};
            case 3
                det_eff2 = grasp_data(index).(['data' detno]){1};
                det_eff2_error = grasp_data(index).(['error' detno]){1};
                det_eff1 = grasp_data(index).(['data' detno]){2};
                det_eff1_error = grasp_data(index).(['error' detno]){2};
            case 4
                det_eff1 = grasp_data(index).(['data' detno]){1};
                det_eff1_error = grasp_data(index).(['error' detno]){1};
                det_eff2 = grasp_data(index).(['data' detno]){2};
                det_eff2_error = grasp_data(index).(['error' detno]){2};
            otherwise
                return %no other options at this time
        end
        
        image_size = size(det_eff1);
        
        if status_flags.analysis_modules.det_eff.split_method ==1 || status_flags.analysis_modules.det_eff.split_method == 2 %Left-Right
            merge_det_eff(:,1:split_line) = det_eff1(:,1:split_line);
            merge_det_eff(:,split_line+1:image_size(2)) = det_eff2(:,split_line+1:image_size(2));
            
            merge_det_eff_error(:,1:split_line) = det_eff1_error(:,1:split_line);
            merge_det_eff_error(:,split_line+1:image_size(2)) = det_eff2_error(:,split_line+1:image_size(2));
            
        elseif status_flags.analysis_modules.det_eff.split_method ==3 || status_flags.analysis_modules.det_eff.split_method == 4 %Top-Botom
            merge_det_eff(1:split_line,:) = det_eff1(1:split_line,:);
            merge_det_eff(split_line+1:image_size(1),:) = det_eff2(split_line+1:image_size(1),:);
            
            merge_det_eff_error(1:split_line,:) = det_eff1_error(1:split_line,:);
            merge_det_eff_error(split_line+1:image_size(1),:) = det_eff2_error(split_line+1:image_size(1),:);
        end            
            
        
        %Now place this back in the data array for Det Eff 1
        grasp_data(index).(['data' detno]){1} = merge_det_eff;
        grasp_data(index).(['error' detno]){1} = merge_det_eff_error;
        
        grasp_update
        
        
    case 'close'
        
        grasp_handles.window_modules.detector_efficiency.window = []; %clear the handle otherwise other windows could get deleted
        
    case 'split_line'
        str = get(gcbo,'string');
        line = str2num(str);
        if not(isempty(line))
            status_flags.analysis_modules.det_eff.split_line = line;
        end
        set(grasp_handles.window_modules.detector_efficiency.det_efficiency_split_line,'string',num2str(status_flags.analysis_modules.det_eff.split_line));
        
    case 'split_method'
        status_flags.analysis_modules.det_eff.split_method = get(gcbo,'value');
        
end

     
 
