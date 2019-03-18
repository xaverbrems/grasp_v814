function output_figure(to_do)

if nargin<1; to_do = 'main'; end


global grasp_handles
global grasp_env
global inst_params
global status_flags
global displayimage

global axis1

%***** Open New Figure Window *****
fig_position = ([0.15, 0.2, 0.28*3.5/2, 0.35*3.5/2]).*grasp_env.screen.screen_scaling;

% print_fig_handle = figure(...
%     'menubar','none',...
%     'toolbar','none',....
%     'name','Page Layout Print',....
%     'units','normalized',....
%     'Position',fig_position,....
%     'paperorientation','landscape',....
%     'NumberTitle', 'off',....
%     'color',grasp_env.background_color,....
%     'papertype','A4',....
%     'Resize','on');

%print_fig_handle = figure('paperorientation','landscape','units','normalized','position',fig_position);
print_fig_handle = figure('paperorientation','landscape','menubar','none','toolbar','none','units','normalized','Position',fig_position);

%'paperposition',[0.02139 0.030265 0.95768 0.94035],....
%Create 2nd Axis to write text
axis2 = axes;
set(axis2,'units','normalized','position',[0.0,0,1,1],'xtick',[],'ytick',[],'xcolor',grasp_env.background_color,'ycolor',grasp_env.background_color);

switch to_do
    case 'main'
        
        %Copy Figure to New Print Figure Window
        
        %Calcualte total display width & height required to display detectors
        detectors_width = 0; detectors_height = 0;
        horz_detectors = 0; vert_detectors = 0;
        for det = 1:inst_params.detectors
            if strcmp(inst_params.(['detector' num2str(det)]).view_position, 'centre') || strcmp(inst_params.(['detector' num2str(det)]).view_position, 'left') || strcmp(inst_params.(['detector' num2str(det)]).view_position, 'right')
                detectors_width = detectors_width + inst_params.(['detector' num2str(det)]).pixels(1) .* inst_params.(['detector' num2str(det)]).pixel_size(1);
                horz_detectors = horz_detectors + 1;
            end
            if strcmp(inst_params.(['detector' num2str(det)]).view_position, 'centre') || strcmp(inst_params.(['detector' num2str(det)]).view_position, 'top') || strcmp(inst_params.(['detector' num2str(det)]).view_position, 'bottom')
                detectors_height = detectors_height + inst_params.(['detector' num2str(det)]).pixels(2) .* inst_params.(['detector' num2str(det)]).pixel_size(2);
                vert_detectors = vert_detectors + 1;
            end
        end
        
        %Total page position avaialible for plots
        page = [0.045   0.43    0.36    0.51]; %normalised units
        detector_display_gap = [0.03 0.03]; %Horz, vert separation of different detector displays
        horz_width_per_mm = (page(3) - detector_display_gap(1)*(horz_detectors-1)) / detectors_width;
        vert_width_per_mm = (page(4) - detector_display_gap(2)*(vert_detectors-1)) / detectors_height;
        
        for det = 1:inst_params.detectors
            
            %clim = get(grasp_handles.plot_info.axis,'clim');%This is trying to overcome the blank page that sometimes appears with Loged images
            %climmode = get(grasp_handles.plot_info.axis,'climmode');%This is trying to overcome the blank page that sometimes appears with Loged images
            
            if det == 1
                axis1 = copyobj([grasp_handles.displayimage.(['axis' num2str(det)]),grasp_handles.displayimage.colorbar],print_fig_handle);
                set(get(axis1(1),'children'),'buttondownfcn','');
            else
                axis1 = copyobj([grasp_handles.displayimage.(['axis' num2str(det)])],print_fig_handle);
                set(get(axis1(1),'children'),'buttondownfcn','');
                
            end
            switch inst_params.(['detector' num2str(det)]).view_position
                case 'centre'
                    
                    %Calculate plot screen coordinates
                    det_width = inst_params.(['detector' num2str(det)]).pixels(1) .* inst_params.(['detector' num2str(det)]).pixel_size(1);
                    plot_width = det_width * horz_width_per_mm;
                    det_height = inst_params.(['detector' num2str(det)]).pixels(2) .* inst_params.(['detector' num2str(det)]).pixel_size(2);
                    plot_height = det_height * vert_width_per_mm;
                    plot_horz_position = page(1) + page(3)/2 - plot_width/2;
                    plot_vert_position = page(2) + page(4)/2 - plot_height/2;
                    
                    %                 %Copy colorbar
                    %                 color_bar =copyobj(grasp_handles.displayimage.colorbar,print_fig_handle,'legacy');
                    %                 set(color_bar,'units', 'normalized','position', [0.44, plot_vert_position, 0.015, plot_height]);
                    %                 %h = get(axis1(2),'ylabel');set(h,'rotation',270); %turn the colorbar axis label around
                    
                case 'left'
                    %Calcualte plot screen coordinates
                    det_width = inst_params.(['detector' num2str(det)]).pixels(1) .* inst_params.(['detector' num2str(det)]).pixel_size(1);
                    plot_width = det_width * horz_width_per_mm;
                    det_height = inst_params.(['detector' num2str(det)]).pixels(2) .* inst_params.(['detector' num2str(det)]).pixel_size(2);
                    plot_height = det_height * vert_width_per_mm;
                    plot_horz_position = page(1);
                    plot_vert_position = page(2) + page(4)/2 - plot_height/2;
                    
                case 'right'
                    %Calcualte plot screen coordinates
                    det_width = inst_params.(['detector' num2str(det)]).pixels(1) .* inst_params.(['detector' num2str(det)]).pixel_size(1);
                    plot_width = det_width * horz_width_per_mm;
                    det_height = inst_params.(['detector' num2str(det)]).pixels(2) .* inst_params.(['detector' num2str(det)]).pixel_size(2);
                    plot_height = det_height * vert_width_per_mm;
                    plot_horz_position = page(1) + page(3) - plot_width;
                    plot_vert_position = page(2) + page(4)/2 - plot_height/2;
                    
                case 'top'
                    %Calcualte plot screen coordinates
                    det_width = inst_params.(['detector' num2str(det)]).pixels(1) .* inst_params.(['detector' num2str(det)]).pixel_size(1);
                    plot_width = det_width * horz_width_per_mm;
                    det_height = inst_params.(['detector' num2str(det)]).pixels(2) .* inst_params.(['detector' num2str(det)]).pixel_size(2);
                    plot_height = det_height * vert_width_per_mm;
                    plot_horz_position = page(1) + page(3)/2 - plot_width/2;
                    plot_vert_position = page(2) + page(4) - plot_height;
                    
                case 'bottom'
                    %Calcualte plot screen coordinates
                    det_width = inst_params.(['detector' num2str(det)]).pixels(1) .* inst_params.(['detector' num2str(det)]).pixel_size(1);
                    plot_width = det_width * horz_width_per_mm;
                    det_height = inst_params.(['detector' num2str(det)]).pixels(2) .* inst_params.(['detector' num2str(det)]).pixel_size(2);
                    plot_height = det_height * vert_width_per_mm;
                    plot_horz_position = page(1) + page(3)/2 - plot_width/2;
                    plot_vert_position = page(2);
            end
            set(axis1(1),'position',[plot_horz_position    plot_vert_position    plot_width    plot_height]);
            if det ==1
                %Adjust the colorbar position
                colorbar_handle = findobj(print_fig_handle,'type','colorbar');
                if not(isempty(colorbar_handle))
                    current_position = get(colorbar_handle,'position');
                    set(colorbar_handle,'position',[0.4410 0.4300 0.0150 0.5000]);
                end
                
            end
            

        end
        
        
        %Set same colormap
        colormap(status_flags.color.map);
        
        %Subtitle
        subtitle = get(grasp_handles.figure.subtitle,'string');
        text(0.05,0.97,[subtitle],'fontsize',grasp_env.fontsize,'fontname',grasp_env.font);
        
            gx = 0.02; gy = 0.40; dy = 0.018; dx = 0.13; text_font = grasp_env.fontsize*0.9; %Group Coords
        %Any Plotted Contours
        i = findobj('tag','contour_display_check');
        if get(i,'value') == 1 %i.e. there are contours
            text(gx,gy,'Contour Levels','fontsize',text_font,'interpreter','none','fontname',grasp_env.font); gy=gy-dy;
            nn = 1;
            while nn <= length(status_flags.contour.current_levels_list)
                contours_string = [num2str(status_flags.contour.current_levels_list(nn),'%0.6g')];
                nn = nn+1;
                for m = 1:3
                    if nn <= length(status_flags.contour.current_levels_list)
                        contours_string = [contours_string ', ' num2str(status_flags.contour.current_levels_list(nn),'%0.6g')];
                        nn = nn +1;
                    end
                end
                text(gx,gy,contours_string,'fontsize',text_font,'fontname',grasp_env.font); gy=gy-dy;
            end
            gy = gy - dy;
        end
        
        %Place 2D Curve Fit History on Figure
        if isfield(displayimage,'fit2d_history')
            gx = 0.02; gy = 0.40; dy = 0.018; dx = 0.24; text_font = grasp_env.fontsize*0.9; %Group Coords
            for nn = 1:length(displayimage.fit2d_history)
                gy = gy - dy;
                text(gx,gy,[displayimage.fit2d_history{nn}],'fontsize',text_font,'interpreter','none','fontname',grasp_env.font);
            end
        end
        
        plot_info = displayimage; %used down below to print history
        plot_info.params = displayimage.params1;
        
    case 'sub'
        
        %Copy Figure to New Print Figure Window
        i = findobj('tag','grasp_plot');
        if not(isempty(i));
            plot_info = get(i(1),'userdata');
            axis1 = copyobj([plot_info.axis,plot_info.legend_handle],print_fig_handle,'legacy');
            set(axis1(1),'position',[0.06 0.5 0.4 0.45]);
            curve_handles = get(axis1(1),'userdata');
            % axis1 = copyobj(plot_info.legend_handle,print_fig_handle,'legacy');
            set(axis1(2),'position',[0.32    0.9    0.1    0.03]);
            
            %Place 1D Curve Fit History on Figure
            n_curves = length(curve_handles);
            gx = 0.02; gy0 = 0.40; dy = 0.018; dx = 0.15; text_font = grasp_env.fontsize*0.9; %Group Coords
            for n = 1:n_curves
                plot_info = get(curve_handles{n}(1),'userdata');
                if isfield(plot_info,'fit1d_history');
                    gy = gy0;
                    text(gx,gy,['Curve #' num2str(n)],'fontsize',text_font,'interpreter','none','fontname',grasp_env.font);
                    gy = gy - dy;
                    for nn = 1:length(plot_info.fit1d_history)
                        gy = gy - dy;
                        text(gx,gy,[plot_info.fit1d_history{nn}],'fontsize',text_font,'interpreter','none','fontname',grasp_env.font);
                    end
                    gx=gx+dx;
                    gy = gy0;
                end
            end
            
            
            %             if isfield(plot_info,'fit1d_history');
            %             for nn = 1:length(plot_info.fit1d_history)
            %                 gy = gy - dy;
            %                 text(gx,gy,[plot_info.fit1d_history{nn}],'fontsize',text_font,'interpreter','none','fontname',grasp_env.font);
            %             end
            %         end
            
            
            
            %
            %
            %             plot_children_axes = findobj(i(1),'tag','grasp_plot');
            %             axis1 = copyobj(plot_children_axes,print_fig_handle);
            %
            %             misc_handles = findobj(axis1,'fontsize',grasp_env.fontsize); set(misc_handles,'fontsize',grasp_env.fontsize*font_scaler);
            %             title_handle = get(axis1,'title'); set(title_handle,'fontsize',grasp_env.fontsize*font_scaler);
            %
            %             i = findobj(print_fig_handle,'tag','plot_child');
            %             i = flipud(i);
            %             data_params = get(i(1),'userdata');
            %             params = data_params(1).params;
            %             parsub = (data_params(1).parsub);
            %             data_hist = data_params.history;
            %
            %             %Find any copied curve fits and change their tag so they don't get deleted with curve fit
            %             i = findobj(print_fig_handle,'tag','plot_fit_child');
            %             set(i,'tag','plot_fit_child_print_fig');
            %
            %             %Add or update legend
            %             children = findobj(axis1,'tag','plot_child');
            %             str = [];
            %             for n = 1:length(children)
            %                 udata = get(children(length(children)-(n-1)),'userdata');
            %                 str{n}  = [num2str(n) ': '  udata.legend_str(1,:)];
            %             end
            %             legend(flipud(children),str);
            %             set(axis1,'position',[0.08 0.55 0.33 0.4]); %Re-position axis
            %
            %
            %
            
            
        end
        
        
end

%Print Button
uicontrol(print_fig_handle,'units','normalized','Position',[0.90,0.07,0.08,0.025],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','Print','HorizontalAlignment','center','CallBack','file_menu_image_export(''prn'');');

%***** Build Menu Items *****
handle = uimenu(print_fig_handle,'label','&File');
%Export
handle2 = uimenu(handle,'label','&Export Image','callback','','separator','on','tag','file_export_image');
uimenu(handle2,'label','bmp...','callback','file_menu_image_export bmp');
uimenu(handle2,'label','jpg...','callback','file_menu_image_export jpg');
uimenu(handle2,'label','tiff...','callback','file_menu_image_export tif');
%uimenu(handle2,'label','eps...','callback','file_menu_image_export eps');
%uimenu(handle2,'label','Adobe Illustrator...','callback','file_menu_image_export ai');
%uimenu(handle2,'label','pdf...','callback','file_menu_image_export pdf');
uimenu(handle2,'label','Copy to Clipboard...','callback','file_menu_image_export clipboard');

%Print
uimenu(handle,'label','Print Set&up...','callback','filemenufcn(gcbf,''FilePrintSetup'')','tag','file_print_setup');
uimenu(handle,'label','&Print...','callback','file_menu_image_export prn','tag','file_layout_print');
%Exit
uimenu(handle,'label','&Exit','callback','set(gcf,''CloseRequestFcn'',''closereq'');closereq;','separator','on');

%Now Place text in axis2
text(0.73,0.04,[grasp_env.grasp_name ' V' grasp_env.grasp_version ' e-mail: dewhurst@ill.fr'],'fontsize',grasp_env.fontsize,'interpreter','none','fontname',grasp_env.font);


% %***** Place Descriptor Text On Figure
gx = 0.54; gy = 0.96; dy = 0.017; text_font = grasp_env.fontsize*0.9; %Group Coords

%Data History
if isfield(plot_info,'history')
    for nn = 1:length(plot_info.history)
        text(gx,gy,[plot_info.history(nn)],'fontsize',text_font,'interpreter','none','fontname',grasp_env.font,'color','white');    gy = gy - dy;
    end
end
gy = gy - dy;


%Instrument Parameters
if isfield(plot_info,'params')
    
    text(gx,gy,['***** Instrument Setup Parameters *****'],'fontsize',text_font,'interpreter','none','fontname',grasp_env.font,'color','white');
    gy = gy - dy;
    
    det_string = ['Sample-Det Dist (m): ' num2str(plot_info.params.det)];
    if isfield(plot_info.params,'dtr')
        det_string = [det_string '    DTR: ' num2str(plot_info.params.dtr)];
    end
    if isfield(plot_info.params,'dan')
        det_string = [det_string '    DAN: ' num2str(plot_info.params.dan)];
    end
    a=text(gx,gy,det_string,'fontsize',text_font,'interpreter','none','fontname',grasp_env.font,'color','white');
    gy = gy - dy;
    
    text(gx,gy,['Collimation (m): ' num2str(plot_info.params.col)],'fontsize',text_font,'interpreter','none','fontname',grasp_env.font,'color','white');
    gy = gy - dy;
    text(gx,gy,['Wavelength: ' num2str(plot_info.params.wav) ', Delta Wav: ' num2str(plot_info.params.deltawav)],'fontsize',text_font,'interpreter','none','fontname',grasp_env.font,'color','white');

    if isfield(plot_info.params,'san')
    gy = gy - dy;
    text(gx,gy,['SAN: ' num2str(plot_info.params.san) ', PHI: ' num2str(plot_info.params.phi) ' (degrees)'],'fontsize',text_font,'interpreter','none','fontname',grasp_env.font,'color','white');
    end
    
    if isfield(plot_info.params,'temp')
    gy = gy - dy;
    text(gx,gy,['Sample Temperature: ' num2str(plot_info.params.temp)],'fontsize',text_font,'interpreter','none','fontname',grasp_env.font,'color','white');
    end
    
    gy = gy - dy;
    text(gx,gy,['Total Det Counts: ' num2str(plot_info.params.array_counts)],'fontsize',text_font,'interpreter','none','fontname',grasp_env.font,'color','white');
    gy = gy - dy;
    text(gx,gy,['Total Monitor Counts: ' num2str(plot_info.params.monitor)],'fontsize',text_font,'interpreter','none','fontname',grasp_env.font,'color','white');
    gy = gy - dy;
    
end

temp = findobj(print_fig_handle,'type','text');
set(temp,'fontsize',8,'color','white')
temp = findobj(print_fig_handle,'type','axes');
set(temp,'fontsize',8)
temp = findobj(print_fig_handle,'type','colorbar');
set(temp,'fontsize',8)




