function grasp_update

global status_flags
global grasp_handles
global displayimage
global grasp_env
global inst_params

%***** Get Selector Result *****
displayimage = get_selector_result;

for det = 1:inst_params.detectors
    detno=num2str(det);
    displayimage.(['image' detno]) = displayimage.(['data' detno]);  %A second copy of the displayimage data to modify, log, flip etc.
end

%***** Update Grasp GUI elements *****
update_selectors
update_display_options
update_transmissions %(and sample thickness)
update_beam_centre
%Update data summary pannel
%update_data_summary


%***** Display objects and 2D Plot - Bypass if desired ******
if status_flags.display.refresh ==1
    
    %Show / Hide GUI objects depending
    hide_stuff
    
    %Instrument and normalisation indicator
    set(grasp_handles.figure.inst_indicator,'string',grasp_env.inst);
    %Project title
    set(grasp_handles.figure.grasp_main,'Name',[grasp_env.grasp_name ' V' grasp_env.grasp_version ' - ' grasp_env.project_title]);
    %normalisation indicator
    set(grasp_handles.figure.norm_indicator,'string',['Nrm: ' status_flags.normalization.status '  Dt: ' status_flags.deadtime.status ' Tc: ' status_flags.transmission.thickness_correction]);
    %config indicator
    set(grasp_handles.figure.config_indicator,'string',['Det: ' num2str(displayimage.params1.det,'%4.1f') '  Col: ' num2str(displayimage.params1.col,'%4.1f') '  Wav: ' num2str(displayimage.params1.wav,'%4.2f')]);
    
    
    
    %***** Image processing:  Flip, Smooth, Log etc *****
    %Loop though number of detectors
    for det = 1:inst_params.detectors
        detno=num2str(det);
        %Flip u/d l/r the displayed image
        if status_flags.display.flipud == 1; displayimage.(['image' detno]) = flipud(displayimage.(['image' detno])); end
        if status_flags.display.fliplr == 1; displayimage.(['image' detno]) = fliplr(displayimage.(['image' detno])); end
        
        %Smooth displayed image
        if status_flags.display.smooth.check == 1
            displayimage.(['image' detno]) = conv2(displayimage.(['image' detno]),status_flags.display.smooth.kerneldata,'same'); %Do the convolution
        end
        
        %Log, Sqrt, Asinh,  the z-scale if required
        if status_flags.display.log ==1
            if strcmp(status_flags.display.zscale,'Log Z')
                warning off;
                displayimage.(['image' detno]) = real(log10(displayimage.(['image' detno])));
                warning on;
                temp = isinf(displayimage.(['image' detno]));
                displayimage.(['image' detno])(temp) = 0;
            elseif strcmp(status_flags.display.zscale,'Asinh Z')
                displayimage.(['image' detno]) = asinh(displayimage.(['image' detno]));
            elseif strcmp(status_flags.display.zscale,'Sqrt Z')
                displayimage.(['image' detno]) = real(sqrt(displayimage.(['image' detno])));
            end
        end
        
        %Apply the Mask to the image only if Sample, Empty or Cadmium or PA scattering worksheets
        if (displayimage.type >=1 && displayimage.type <=3) || (displayimage.type >=10 && displayimage.type <=19)|| displayimage.type == 22 || displayimage.type == 23;
            displayimage.(['image' detno]) = displayimage.(['image' detno]).* displayimage.(['mask' detno]);
            %temp = (displayimage.(['mask' detno])==0);
            %displayimage.(['image' detno])(temp) = nan;
        end
    end
    
    
    z_max_global = -inf; z_min_global = inf;
    z_max_local = []; z_min_local = [];
    %Set 2D image properties
    for det = 1:inst_params.detectors
        detno=num2str(det);
        %Check for z_max and z_min axis limits
        z_max_local.(['det' detno]) = max(max(displayimage.(['image' detno])));
        z_min_local.(['det' detno]) = min(min(displayimage.(['image' detno])));
        
        if z_max_local.(['det' detno]) > z_max_global; z_max_global = z_max_local.(['det' detno]); end
        if z_min_local.(['det' detno]) < z_min_global; z_min_global = z_min_local.(['det' detno]); end
        
        %Set the data to the 2D plots
        set(grasp_handles.displayimage.(['image' detno]),'cdata',displayimage.(['image' detno]));
        %set(grasp_handles.displayimage.(['image' detno]),'AlphaData',~isnan(displayimage.(['image' detno])))
        %image render - do image render in Grasp update so that the 0.5pixel mapping shift can be done also
        shading(grasp_handles.displayimage.(['axis' detno]),status_flags.display.render);
        
        %Set the pixel co-ord mappings depending on Pixel / q / 2theta axes
        switch status_flags.axes.current
            case 'p' %pixel axes
                
                xmapping = displayimage.(['qmatrix' detno])(:,:,1);
                ymapping = displayimage.(['qmatrix' detno])(:,:,2);
                %Axes titles
                x_label = 'Pixels'; y_label = 'Pixels';
                
            case 'q' %q-axes
                xmapping = displayimage.(['qmatrix' detno])(:,:,3);
                ymapping = displayimage.(['qmatrix' detno])(:,:,4);
                %Axes titles
                x_label = ['q_x (' char(197) '^{-1})']; y_label = ['q_y (' char(197) '^{-1})'];
                
            case 't' %2theta axes
                xmapping = displayimage.(['qmatrix' detno])(:,:,7);
                ymapping = displayimage.(['qmatrix' detno])(:,:,8);
                %Axes titles
                x_label =['2{\theta}_x (degrees)']; y_label = ['2{\theta}_y (degrees)'];
                
            case 'a' %angle-radius axes (un-wrapped)
                [xmapping,ymapping] = cart2pol(displayimage.(['qmatrix' detno])(:,:,3),displayimage.(['qmatrix' detno])(:,:,4));
                %Axes titles
                x_label =['Azimuthal Angle (degrees)']; y_label = ['q_r (' char(197) '^{-1})'];
                
        end
        
        %Set the Axis titles
        if isfield(grasp_handles.displayimage,['axis_xtitle' detno]);
            if ishandle(grasp_handles.displayimage.(['axis_xtitle' detno]));
                delete(grasp_handles.displayimage.(['axis_xtitle' detno]));
                grasp_handles.displayimage.(['axis_xtitle' detno]) = [];
            end
        end
        if isfield(grasp_handles.displayimage,['axis_ytitle' detno]);
            if ishandle(grasp_handles.displayimage.(['axis_ytitle' detno]));
                delete(grasp_handles.displayimage.(['axis_ytitle' detno]));
                grasp_handles.displayimage.(['axis_ytitle' detno]) = [];
            end
        end
        grasp_handles.displayimage.(['axis_xtitle' detno]) = xlabel(grasp_handles.displayimage.(['axis' detno]),x_label);
        grasp_handles.displayimage.(['axis_ytitle' detno]) = ylabel(grasp_handles.displayimage.(['axis' detno]),y_label);
        if det == status_flags.display.active_axis; color = grasp_env.displayimage.active_axis_color; else color = grasp_env.displayimage.inactive_axis_color; end
        set(grasp_handles.displayimage.(['axis_xtitle' num2str(det)]),'fontname',grasp_env.font,'fontsize',grasp_env.fontsize*0.9,'color',color);
        set(grasp_handles.displayimage.(['axis_ytitle' num2str(det)]),'fontname',grasp_env.font,'fontsize',grasp_env.fontsize*0.9,'color',color);
        
        %Make correction of the half-image shift for 'faceted' & 'flat' render
        if strcmp(status_flags.display.render,'faceted') || strcmp(status_flags.display.render,'flat')
            pixel_spacing_x = (xmapping(2)-xmapping(1)); xmapping = xmapping - pixel_spacing_x /2;
            pixel_spacing_y = (ymapping(2)-ymapping(1)); ymapping = ymapping - pixel_spacing_y /2;
        end
        
        %         %Rotate co-ordinate axes - original version which actually rotates the matrix
        %         [xmapping, ymapping] = meshgrid(xmapping,ymapping);
        %         if status_flags.display.rotate.check ==1; %
        %             if strcmp(status_flags.axes.current,'p'); xmapping = xmapping - displayimage.cm(1); ymapping = ymapping - displayimage.cm(2); end %offset for current beam centre for Pixel axes
        %             %Convert to Polar coords
        %             [theta,r] = cart2pol(xmapping,ymapping);
        %             %Rotate by given angle
        %             theta = theta - (status_flags.display.rotate.angle*2*pi/360);
        %             %Convert back to cartesian
        %             [xmapping,ymapping]=pol2cart(theta,r);
        %             if strcmp(status_flags.axes.current,'p'); xmapping = xmapping + displayimage.cm(1); ymapping = ymapping + displayimage.cm(2); end %Remove offset for current beam centre for Pixel axes
        %         end
        
        % %Rotate co-ordinate axes - This version simply rotates the axis frame
        % if status_flags.display.rotate.check ==1;
        %     [az,el] = view;
        % view(status_flags.display.rotate.angle,el)
        % end
        
        %Set pixel mappings to the axes
        status_flags.axes.(['xmapping' detno]) = xmapping; status_flags.axes.(['ymapping' detno]) = ymapping;
        set(grasp_handles.displayimage.(['image' detno]),'xdata',xmapping,'ydata',ymapping);
        %Set image visiblity
        if status_flags.display.image ==0; status = 'off'; else status = 'on'; end
        set(grasp_handles.displayimage.(['image' detno]),'visible',status);
        
        %Set axis visibility
        if status_flags.display.axes ==1; status = 'on'; else status = 'off'; end
        set(grasp_handles.menu.display.showaxes,'checked',status);
        set(grasp_handles.displayimage.(['axis' detno]),'visible',status);
        
    end
    
    %Set the Z-Lims & Z-Limits status_flags
    for det = 1:inst_params.detectors
        detno=num2str(det);
        if status_flags.display.manualz.check == 1; %Manual z_scale
            status_flags.display.z_min.(['det' detno]) = status_flags.display.manualz.min;
            status_flags.display.z_max.(['det' detno]) = status_flags.display.manualz.max;
        else %Auto z_scale
            if status_flags.display.grouped_z_scale == 1; %Grouped Auto z-scales between detectors
                status_flags.display.z_min.(['det' detno]) = z_min_global;
                status_flags.display.z_max.(['det' detno]) = z_max_global;
            else %Independent Auto z-scales
                status_flags.display.z_min.(['det' detno]) = z_min_local.(['det' detno]);
                status_flags.display.z_max.(['det' detno]) = z_max_local.(['det' detno]);
            end
        end
        
        %Check for bad z_scales
        if status_flags.display.z_min.(['det' detno]) == status_flags.display.z_max.(['det' detno])
            status_flags.display.z_min.(['det' detno]) = status_flags.display.z_min.(['det' detno]) - eps;
            status_flags.display.z_max.(['det' detno]) = status_flags.display.z_max.(['det' detno]) + eps;
        end
        
        %Check for Inf z_scales
        if isinf(status_flags.display.z_min.(['det' detno])); status_flags.display.z_min.(['det' detno]) = -eps; end
        if isinf(status_flags.display.z_max.(['det' detno])); status_flags.display.z_max.(['det' detno]) = +eps; end
        
        %Check for NaN z_scales
        if isnan(status_flags.display.z_min.(['det' detno])); status_flags.display.z_min.(['det' detno]) = -eps; end
        if isnan(status_flags.display.z_max.(['det' detno])); status_flags.display.z_max.(['det' detno]) = +eps; end
        
        %Set z-scales to plots
        set(grasp_handles.displayimage.(['axis' detno]),'clim',[status_flags.display.z_min.(['det' detno]) status_flags.display.z_max.(['det' detno])]);
    end
    
    %***** Contours *****
    for det = 1:inst_params.detectors
        detno=num2str(det);
        z_min = status_flags.display.z_min.(['det' detno]);
        z_max = status_flags.display.z_max.(['det' detno]);
        
        %Delete Old contours - if they exist.
        if isfield(grasp_handles.displayimage, ['contour' detno])
            if ishandle(grasp_handles.displayimage.(['contour' detno]));
                delete(grasp_handles.displayimage.(['contour' detno]));
                grasp_handles.displayimage.(['contour' detno]) = [];
            end
        end
        
        %Check if to replot contours
        if status_flags.display.contour == 1
            span = z_max - z_min;
            
            %Check to see what type of contour levels we are adding, i.e. Auto, Linear, Specific.
            if status_flags.contour.current_style ==1 %i.e. Auto contours - this now does not use matlab's own auto contours
                if status_flags.display.log == 1; %i.e. log contours
                    data_max = real(log10(z_max)); data_min = 0; span = data_max - data_min;
                end
                c_auto_levels = status_flags.contour.auto_levels(status_flags.contour.auto_levels_index); %Number of Auto Contour Levels
                c_levels = [1:(c_auto_levels+1)]; c_levels = (c_levels*span/(c_auto_levels+1))+z_min;
                if status_flags.display.log == 1; c_levels = 10.^c_levels; end %if logged, put the contours back to useful units.
                
            elseif status_flags.contour.current_style == 2 %i.e. Linear between limits
                c_levels = [status_flags.contour.contour_min:status_flags.contour.contour_interval:status_flags.contour.contour_max];
                if status_flags.contour.percent_abs == 1 %Check if these are % contours
                    c_levels = (c_levels*span/100)+z_min;
                end
                
            elseif status_flags.contour.current_style == 3 %i.e as specified by the 'manual_string'
                c_levels = str2num(status_flags.contour.contours_string);
                if status_flags.contour.percent_abs == 1 %Check if these are % contours
                    c_levels = (c_levels*span/100)+z_min;
                end
            end
            
            %Find Contour Color & Line spec
            line_spec = ['-' status_flags.contour.color];
            %Plot the new contours.
            if not(isempty(c_levels))
                hold(grasp_handles.displayimage.(['axis' detno]),'on');
                if strcmp(status_flags.contour.color,'x')
                    [~, grasp_handles.displayimage.(['contour' detno])] = contour3(grasp_handles.displayimage.(['axis' detno]),status_flags.axes.(['xmapping' detno]), status_flags.axes.(['ymapping' detno]),displayimage.(['image' detno]),c_levels);
                else
                    [~, grasp_handles.displayimage.(['contour' detno])] = contour3(grasp_handles.displayimage.(['axis' detno]),status_flags.axes.(['xmapping' detno]), status_flags.axes.(['ymapping' detno]),displayimage.(['image' detno]),c_levels,line_spec);
                end
            end
            
            %Store the current contour levels for use by other function eg. 2D curve fitting.
            status_flags.contour.current_levels_list = c_levels;
        end
    end
    
    %Set axis title (main 2d image title)
    if status_flags.display.title == 1
        axis_title_string = ['Numor: ' num2str(displayimage.params1.numor) '      Subtitle: " ' displayimage.params1.subtitle ' "'];
        set(grasp_handles.figure.subtitle ,'string',axis_title_string,'visible','on');
    else
        set(grasp_handles.figure.subtitle ,'visible','off');
    end
    
    
    %Set colorbar ylabel (units)
    set(grasp_handles.displayimage.colorbar,'fontname',grasp_env.font,'fontsize',grasp_env.fontsize,'color',grasp_env.displayimage.active_axis_color);
    h = get(grasp_handles.displayimage.colorbar,'ylabel');
    
    if status_flags.display.log ==1
        zscale_str = [status_flags.display.zscale '    ' displayimage.units];
    else
        zscale_str = [displayimage.units];
    end
    
    
    %For Bayes: set Z-axis according to normalization which was used, when Bayes was calculated and divide by Angstrom since Bayes works in q space
    
    if status_flags.selector.fw == 41 || status_flags.selector.fw == 42
        
        bayes_normalization = status_flags.user_modules.bayes.normalization;
        zscale_str = ['Integrated Intensity / ' char(197) ' (normalization: ' bayes_normalization ')' ] % char(197) is Angstrom
    elseif status_flags.selector.fw == 43     % Bayes weights are unitless
        zscale_str = ' (unitless) '
    end
    
    

    
    set(h,'string',zscale_str,'rotation',270,'fontname',grasp_env.font,'fontsize',grasp_env.fontsize,'color',grasp_env.displayimage.active_axis_color);
    %Modify position of colorbar label
    pos = get(h,'position');
    pos(1) = 5.5;
    pos(2) = (status_flags.display.z_max.det1 + status_flags.display.z_min.det1)/2; % changed minus to plus so the label is always in the midle of the colorbar
    set(h,'position',pos)
    
    
      %      main_callbacks('update_axis_cross');

%     %Update Active Axis OnOff Cross
%     temp = findobj('tag','active_axis_cross');
%     delete(temp);
%     
%     %current_axes = gca;
%     for det = 1:inst_params.detectors
%         detno=num2str(det);
%         %Delete Old Cross
%         %if isfield(grasp_handles.displayimage,['det_off_cross' num2str(det)]);
%         %    if ishandle(grasp_handles.displayimage.(['det_off_cross' num2str(det)]))
%         %        delete(grasp_handles.displayimage.(['det_off_cross' num2str(det)]));
%         %        grasp_handles.displayimage.(['det_off_cross' num2str(det)]) = [];
%         %    end
%         %end
%         
%         if status_flags.display.(['axis' detno '_onoff'])==0;
%             %Draw New Cross
%             det_size = inst_params.(['detector' detno]).pixels;
%             z_height = status_flags.display.z_max.(['det' detno]);
%             draw_vectors(1,:) = [1,1];
%             draw_vectors(2,:) = [det_size(1),det_size(2)];
%             draw_vectors(3,:) = [1,det_size(2)];
%             draw_vectors(4,:) = [det_size(1),1];
%             z_height = z_height * ones(size(draw_vectors(:,1)));
%             
%             axes(grasp_handles.displayimage.(['axis' detno]));
%             temp_handle1  = line(draw_vectors(1:2,1),draw_vectors(1:2,2),z_height(1:2,1),'color','black','linewidth',1,'tag','active_axis_cross');
%             temp_handle2 = line(draw_vectors(3:4,1),draw_vectors(3:4,2),z_height(3:4,1),'color','black','linewidth',1,'tag','active_axis_cross');
%             %grasp_handles.displayimage.(['det_off_cross' num2str(det)]) = [temp_handle1, temp_handle2];
%         end
%         
%     end
%     %axes(current_axes);
    
    
    
    
    
    %Set Colorbar max min limits
    %set(grasp_handles.displayimage.colorbar,'ylim',[z_min z_max])
    
    
    %     %Z_lims and Manual z_lims
    %     if status_flags.display.manualz.check == 0;
    %         z_lims = [min(min(displayimage.image)),max(max(displayimage.image))];
    %     else z_lims = [status_flags.display.manualz.min,status_flags.display.manualz.max];
    %         if status_flags.display.log ==1;
    %             %Correct manual limits for z-scale type (i.e. log etc.)
    %             if strcmp(status_flags.display.zscale,'Log Z'); z_lims = log10(z_lims); end
    %             if strcmp(status_flags.display.zscale,'Asinh Z'); z_lims = asinh(z_lims); end
    %             if strcmp(status_flags.display.zscale,'Sqrt Z'); z_lims = sqrt(z_lims); end
    %         end
    %     end
    %
    %     if z_lims(1) == z_lims(2); z_lims = z_lims + (0.001*z_lims).*[-1,1] + [-eps,eps];end
    %
    %     %Check of any possible Nan's or Inf's in the axis scaling
    %     temp = find(isnan(z_lims)); z_lims(temp) = 0;
    %     if isinf(z_lims(1)); z_lims(1) = -eps; end
    %     if isinf(z_lims(2)); z_lims(2) = eps; end
    %     z_lims = sort(z_lims);
    %     set(grasp_handles.displayimage.axis,'clim',z_lims);
    %
    %     %Colorbar
    %     if ishandle(grasp_handles.displayimage.colorbar);
    %         delete(grasp_handles.displayimage.colorbar);
    %         grasp_handles.displayimage.colorbar=[];
    %     end
    %     if status_flags.display.colorbar == 0; visible = 'off'; else visible = 'on'; end
    %     %Setup colorbar context menu
    %     grasp_handles.displayimage.colorbar_context.root = uicontextmenu('parent',grasp_handles.figure.grasp_main);
    %     grasp_handles.displayimage.colorbar_context.map_handles = [];
    %     for n = 1:length(status_flags.color.color_maps);
    %         callback_string = ['menu_callbacks(''palette'',''' status_flags.color.color_maps{n} ''');'];
    %         i = uimenu(grasp_handles.displayimage.colorbar_context.root,'label',status_flags.color.color_maps{n},'callback',callback_string);
    %         grasp_handles.displayimage.colorbar_context.map_handles = [grasp_handles.displayimage.colorbar_context.map_handles, i];
    %     end
    %
    %     grasp_handles.displayimage.colorbar = colorbar('vert','peer',grasp_handles.displayimage.axis); %Open a new colorbar axes
    %     set(grasp_handles.displayimage.colorbar,....
    %         'Position',[0.687 0.448 0.03 0.502],....
    %         'tag','color_bar',....
    %         'fontname',grasp_env.font,....
    %         'fontsize',grasp_env.fontsize,....
    %         'visible',visible,....
    %         'uicontextmenu',grasp_handles.displayimage.colorbar_context.root); %colorbar context menu is setup in modify_main_menu_items
    %
    %     %Colorbar axis label
    %     grasp_handles.displayimage.colorbar_axis_ytitle = get(grasp_handles.displayimage.colorbar,'ylabel');
    %     set(grasp_handles.displayimage.colorbar_axis_ytitle,'rotation',270,'string',displayimage.units,'verticalalignment','bottom','interpreter','tex','fontname',grasp_env.font,'fontsize',grasp_env.fontsize);
    %
    %
    %     %Convert colorbar labels for log, sqrt and asinh axes
    %     if status_flags.display.log ==1;
    %         color_labels_str = get(grasp_handles.displayimage.colorbar,'yticklabel');
    %         color_labels = str2num(color_labels_str);
    %         if strcmp(status_flags.display.zscale,'Log Z'); color_labels = 10.^(color_labels); end
    %         if strcmp(status_flags.display.zscale,'Asinh Z'); color_labels = sinh(color_labels); end
    %         if strcmp(status_flags.display.zscale,'Sqrt Z'); color_labels = color_labels.^2; end
    %         color_labels_str = num2str(color_labels,'%4.2g');
    %         set(grasp_handles.displayimage.colorbar,'yticklabel',color_labels_str);
    %     end
    
    
    %Update Colormap
    set_colormap
    
    %Update ticks etc in the menu items
    update_menus
    
    %Update the Main Data Summary Panel
    %update_data_summary
    
    update_window_options; %Update various Window options
   
    %Update display params in command window
    if status_flags.command_window.display_params == 1
        display_params
    end
    
    
    %Remove minor axes
    if strcmp(status_flags.display.show_minor_detectors,'off') && inst_params.detectors > 1
        for det = 2:inst_params.detectors
            detno=num2str(det);
            temp = get(grasp_handles.displayimage.(['axis' detno]),'children');
            set(temp,'visible','off');
            set(grasp_handles.displayimage.(['axis' detno]),'visible','off');
        end
        set(grasp_handles.displayimage.axis1,'position',grasp_env.displayimage.det_page);
        set(grasp_handles.displayimage.colorbar,'position',[0.7,0.43,0.015,0.5]);
        
    else
        for det = 1:inst_params.detectors
            detno=num2str(det);
            set(grasp_handles.displayimage.(['axis' detno]),'position',grasp_env.displayimage.(['det_position' detno]));
        end
        set(grasp_handles.displayimage.colorbar,'position',grasp_env.displayimage.colorbar_position);
    end
    
    
    
    
end

