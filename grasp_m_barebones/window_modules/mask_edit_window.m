function mask_edit_window

global grasp_env
global grasp_handles
global status_flags

%***** Open Mask Editor Window *****

%Delete old window if it exists
if ishandle(grasp_handles.window_modules.mask_edit.window)
    delete(grasp_handles.window_modules.mask_edit.window);
end

%tool_callbacks('rescale');  %Reset the current display
zoom off; %Switch off zoom mode
%Set the Display Options 'mask' check to on.
status_flags.display.mask.check = 1;

%fig_position = [grasp_env.screen.grasp_main_actual_position(1), grasp_env.screen.grasp_main_actual_position(2)*0.5,   320*grasp_env.screen.screen_scaling(1)   240*grasp_env.screen.screen_scaling(2)];
fig_position = ([0.43, 0.47, 0.12, 0.35]).* grasp_env.screen.screen_scaling;
grasp_handles.window_modules.mask_edit.window = figure(....
    'units','normalized',....
    'Position',fig_position,....
    'Name','Mask Editor' ,....
    'NumberTitle', 'off',....
    'Tag','mask_edit_window',....
    'color',grasp_env.background_color,...
    'menubar','none',....
    'resize','on',....
    'closerequestfcn','mask_edit_callbacks(''close'');closereq');

handle = grasp_handles.window_modules.mask_edit.window;

%Mask Point
uicontrol(handle,'units','normalized','Position',[0.01,0.85,0.15,0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text','String','Point:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.window_modules.mask_edit.pointx = uicontrol(handle,'units','normalized','Position',[0.20,0.85,0.2,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.mask_window.point(1)),'HorizontalAlignment','left','Tag','point_mask_x','Visible','on','CallBack','mask_edit_callbacks(''point_edit'',''x'');');
grasp_handles.window_modules.mask_edit.pointy = uicontrol(handle,'units','normalized','Position',[0.45,0.85,0.2,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.mask_window.point(2)),'HorizontalAlignment','left','Tag','point_mask_y','Visible','on','CallBack','mask_edit_callbacks(''point_edit'',''y'');');
uicontrol(handle,'units','normalized','Position',[0.75,0.85,0.06,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','+','Tag','point_mask_add','Visible','on','Value',0,'CallBack','mask_edit_callbacks(''point'',0)');
uicontrol(handle,'units','normalized','Position',[0.83,0.85,0.06,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','-','Tag','point_mask_remove','Visible','on','Value',0,'CallBack','mask_edit_callbacks(''point'',1)');

%Mask Line
uicontrol(handle,'units','normalized','Position',[0.01,0.75,0.15,0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text','String','Lines:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.window_modules.mask_edit.line = uicontrol(handle,'units','normalized','Position',[0.20,0.75,0.45,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',status_flags.mask_window.lines,'HorizontalAlignment','left','Tag','line_mask','Visible','on','callback','mask_edit_callbacks(''lines_edit'');');
uicontrol(handle,'units','normalized','Position',[0.75,0.75,0.06,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','+','Tag','line_mask_add','Visible','on','Value',0,'CallBack','mask_edit_callbacks(''line'',0)');
uicontrol(handle,'units','normalized','Position',[0.83,0.75,0.06,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','-','Tag','line_mask_remove','Visible','on','Value',0,'CallBack','mask_edit_callbacks(''line'',1)');

%Mask Box
uicontrol(handle,'units','normalized','Position',[0.01,0.65,0.15,0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text','String','Box:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.window_modules.mask_edit.boxx1 = uicontrol(handle,'units','normalized','Position',[0.20,0.65,0.1,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.mask_window.box(1)),'HorizontalAlignment','left','Tag','box_mask_xmin','Visible','on','callback','mask_edit_callbacks(''box_edit'',''x1'');');
grasp_handles.window_modules.mask_edit.boxx2 = uicontrol(handle,'units','normalized','Position',[0.32,0.65,0.1,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.mask_window.box(2)),'HorizontalAlignment','left','Tag','box_mask_xmax','Visible','on','callback','mask_edit_callbacks(''box_edit'',''x2'');');
grasp_handles.window_modules.mask_edit.boxy1 = uicontrol(handle,'units','normalized','Position',[0.44,0.65,0.1,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.mask_window.box(3)),'HorizontalAlignment','left','Tag','box_mask_ymin','Visible','on','callback','mask_edit_callbacks(''box_edit'',''y1'');');
grasp_handles.window_modules.mask_edit.boxy2 = uicontrol(handle,'units','normalized','Position',[0.56,0.65,0.1,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.mask_window.box(4)),'HorizontalAlignment','left','Tag','box_mask_ymax','Visible','on','callback','mask_edit_callbacks(''box_edit'',''y2'');');
uicontrol(handle,'units','normalized','Position',[0.75,0.65,0.06,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','+','Tag','box_mask_add','Visible','on','Value',0,'CallBack','mask_edit_callbacks(''box'',0)');
uicontrol(handle,'units','normalized','Position',[0.83,0.65,0.06,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','-','Tag','box_mask_remove','Visible','on','Value',0,'CallBack','mask_edit_callbacks(''box'',1)');

%Mask Circle
%find current beam centre
uicontrol(handle,'units','normalized','Position',[0.01,0.55,0.15,0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text','String','Circle:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.window_modules.mask_edit.cx = uicontrol(handle,'units','normalized','Position',[0.20,0.55,0.14,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.mask_window.circle(1)),'HorizontalAlignment','left','Tag','circle_mask_cx','Visible','on','callback','mask_edit_callbacks(''circle_edit'',''cx'');');
grasp_handles.window_modules.mask_edit.cy = uicontrol(handle,'units','normalized','Position',[0.36,0.55,0.14,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.mask_window.circle(2)),'HorizontalAlignment','left','Tag','circle_mask_cy','Visible','on','callback','mask_edit_callbacks(''circle_edit'',''cy'');');
grasp_handles.window_modules.mask_edit.radius = uicontrol(handle,'units','normalized','Position',[0.52,0.55,0.14,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.mask_window.circle(3)),'HorizontalAlignment','left','Tag','circle_mask_radius','Visible','on','callback','mask_edit_callbacks(''circle_edit'',''cr'');');
uicontrol(handle,'units','normalized','Position',[0.75,0.55,0.06,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','+','Tag','circle_mask_add','Visible','on','Value',0,'CallBack','mask_edit_callbacks(''circle'',0)');
uicontrol(handle,'units','normalized','Position',[0.83,0.55,0.06,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','-','Tag','circle_mask_remove','Visible','on','Value',0,'CallBack','mask_edit_callbacks(''circle'',1)');

%Sketch Mask
uicontrol(handle,'units','normalized','Position',[0.25,0.05,0.5,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','Sketch','HorizontalAlignment','center','Tag','sketch_mask_button','Visible','on','CallBack','mask_edit_callbacks(''sketch'',0)');
%Clear Mask
uicontrol(handle,'units','normalized','Position',[0.1,0.2,0.3,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','Clear','HorizontalAlignment','center','Tag','mask_clear','Visible','on',...
    'CallBack','mask_edit_callbacks(''clear_mask'');');
%Grab Beam Centre
uicontrol(handle,'units','normalized','Position',[0.6,0.2,0.3,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','Grab Centre','HorizontalAlignment','center','Tag','cm_grab_mask','Visible','on',...
    'CallBack','mask_edit_callbacks(''grab_cm'');');

