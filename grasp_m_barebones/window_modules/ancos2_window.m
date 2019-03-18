function ancos2_window

global grasp_env
global grasp_handles
global status_flags

%***** Open Ancos2 Window *****

if ishandle(grasp_handles.window_modules.ancos2.window)
    delete(grasp_handles.window_modules.ancos2.window);
end

fig_position = ([0.43, 0.1, 0.12, 0.35]).* grasp_env.screen.screen_scaling;
grasp_handles.window_modules.ancos2.window = figure(....
    'units','normalized',....
    'Position',fig_position,....
    'Name','Ancos2',....
    'NumberTitle', 'off',....
    'Tag','ancos2_window',....
    'color',grasp_env.background_color,....
    'menubar','none',....
    'resize','off',....
    'closerequestfcn','ancos2_callbacks(''ancos2_window_close'');closereq;');
figure_handle = grasp_handles.window_modules.ancos2.window;

   %Ancos2 Do it
   grasp_handles.window_modules.ancos2.ancos2_button = uicontrol(figure_handle,'units','normalized','Position',[0.05 0.85 0.3 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','Ancos2-It!','HorizontalAlignment','Center','Tag','ancos2_button','Visible','on','CallBack','ancos2_callbacks(''ancos2_it'');');

   %Graphic Display
   uicontrol(figure_handle,'units','normalized','Position',[0.5 0.85 0.4 0.03],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Graphic Display:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
   grasp_handles.window_modules.ancos2.graphic_display = uicontrol(figure_handle,'units','normalized','Position',[0.85 0.85 0.1 0.03],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','Tag','ac2_graphic_display','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],'value',status_flags.analysis_modules.ancos2.graphic_display,...
       'callback','ancos2_callbacks(''graphic_display'');');
   
   %Plot Options
   uicontrol(figure_handle,'units','normalized','Position',[0.05 0.75 0.9 0.03],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Plot:   Offset:    Amplitude:   Phase:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
   grasp_handles.window_modules.ancos2.plot_offset = uicontrol(figure_handle,'units','normalized','Position',[0.2 0.70 0.1 0.03],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],'value',status_flags.analysis_modules.ancos2.plot_offset,'callback','ancos2_callbacks(''plot_offset'');');
   grasp_handles.window_modules.ancos2.plot_amplitude = uicontrol(figure_handle,'units','normalized','Position',[0.3 0.70 0.1 0.03],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],'value',status_flags.analysis_modules.ancos2.plot_amplitude,'callback','ancos2_callbacks(''plot_amplitude'');');
   grasp_handles.window_modules.ancos2.plot_phase = uicontrol(figure_handle,'units','normalized','Position',[0.4 0.70 0.1 0.03],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],'value',status_flags.analysis_modules.ancos2.plot_phase,'callback','ancos2_callbacks(''plot_phase'');');
   
   uicontrol(figure_handle,'units','normalized','Position',[0.05 0.65 0.9 0.03],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Plot together:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
   grasp_handles.window_modules.ancos2.plot_together = uicontrol(figure_handle,'units','normalized','Position',[0.25 0.65 0.1 0.03],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],'value', status_flags.analysis_modules.ancos2.plot_off_amp_together,'callback','ancos2_callbacks(''plot_together'');');
   
   
   %Ancos2 binning paramters 
   uicontrol(figure_handle,'units','normalized','Position',[0.05 0.5 0.4 0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Anulus (pxl):','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
   
   %Start
   uicontrol(figure_handle,'units','normalized','Position',[0.35 0.6 0.16 0.03],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','center','Style','text','String','Start:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
   grasp_handles.window_modules.ancos2.start_radius = uicontrol(figure_handle,'units','normalized','Position',[0.35 0.5 0.16 0.03],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.analysis_modules.ancos2.start_radius),'HorizontalAlignment','right','Tag','ac2_start_radius','Visible','on','callback','ancos2_callbacks(''start'');');
   
   %End
   uicontrol(figure_handle,'units','normalized','Position',[0.53 0.6 0.15 0.03],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','center','Style','text','String','End:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
   grasp_handles.window_modules.ancos2.end_radius = uicontrol(figure_handle,'units','normalized','Position',[0.53 0.5 0.15 0.03],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.analysis_modules.ancos2.end_radius),'HorizontalAlignment','right','Tag','ac2_end_radius','Visible','on','callback','ancos2_callbacks(''end'');');
   
   %Width
   uicontrol(figure_handle,'units','normalized','Position',[0.77 0.6 0.15 0.03],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','center','Style','text','String','Width:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
   grasp_handles.window_modules.ancos2.radius_width = uicontrol(figure_handle,'units','normalized','Position',[0.77 0.5 0.15 0.03],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.analysis_modules.ancos2.radius_width),'HorizontalAlignment','right','Tag','ac2_radius_width','Visible','on','callback','ancos2_callbacks(''width'');');
   
   %Step
   uicontrol(figure_handle,'units','normalized','Position',[0.77 0.4 0.15 0.03],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','center','Style','text','String','Step:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
   grasp_handles.window_modules.ancos2.radius_step = uicontrol(figure_handle,'units','normalized','Position',[0.77 0.3 0.15 0.03],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.analysis_modules.ancos2.radius_step),'HorizontalAlignment','right','Tag','ac2_radius_step','Visible','on','callback','ancos2_callbacks(''step'');');
   
   %Lock Fit Phase Angle
   uicontrol(figure_handle,'units','normalized','Position',[0.053 0.3 0.4 0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Phase Lock:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
   grasp_handles.window_modules.ancos2.phase_lock_check = uicontrol(figure_handle,'units','normalized','Position',[0.35 0.3 0.1 0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','Tag','ac2_lock_cos_phase','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],'value',status_flags.analysis_modules.ancos2.phase_lock,...
       'callback','ancos2_callbacks(''phase_lock'');');
   grasp_handles.window_modules.ancos2.phase_lock_angle = uicontrol(figure_handle,'units','normalized','Position',[0.53 0.3 0.15 0.03],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.analysis_modules.ancos2.phase_angle),'HorizontalAlignment','right','Tag','ac2_phase','Visible','off','callback','ancos2_callbacks(''phase_angle'');');
   
   
   %Sector Plotting Colour
   sector_color_list_string = {'(none)','white','black','red','green','blue','cyan','magenta','yellow'};
   for n = 1:length(sector_color_list_string);
       if strcmp(status_flags.analysis_modules.ancos2.color,sector_color_list_string{n})
           value = n;
       end
   end
   uicontrol('units','normalized','Position',[0.053,0.1,0.4,0.1],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Colour:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
   grasp_handles.window_modules.ancos2.color = uicontrol('units','normalized','Position',[0.35,0.1,0.3,0.1],'HorizontalAlignment','center','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','Popup','Tag','ancos2_colour',...
       'String',sector_color_list_string,'CallBack','ancos2_callbacks(''color'');','Value',value);

%Update the schematic annuli
ancos2_callbacks;