function box_window

global grasp_env
global grasp_handles
global status_flags
global inst_params

%***** Open Strip Window *****
if ishandle(grasp_handles.window_modules.box.window); delete(grasp_handles.window_modules.box.window); grasp_handles.window_modules.box.window = []; end

fig_position = ([0.555, 0.1, 0.12, 0.35]).* grasp_env.screen.screen_scaling;
grasp_handles.window_modules.box.window = figure(....
    'units','normalized',....
    'Position',fig_position,....
    'Name','Boxes' ,....
    'NumberTitle', 'off',....
    'Tag','box_window',...
    'color',grasp_env.background_color,....
    'menubar','none',....
    'resize','on',....
    'windowbuttondownfcn','box_callbacks;',....
    'closerequestfcn','box_callbacks(''close'');closereq');

handle = grasp_handles.window_modules.box.window;

%Saved Boxes
if inst_params.detectors ==1;
    uicontrol(handle,'units','normalized','Position',[0.01,0.90,0.95,0.06],'FontName',grasp_env.font,'horizontalalignment','left','FontSize',grasp_env.fontsize,'Style','text','String','Box:    x1       x2        y1       y2','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
else %multilple detectors - show detector number
    uicontrol(handle,'units','normalized','Position',[0.01,0.90,0.95,0.06],'FontName',grasp_env.font,'horizontalalignment','left','FontSize',grasp_env.fontsize,'Style','text','String','Box:    x1       x2        y1       y2      Det','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
end

for box = 1:6
    ypos = 0.83 - ((box-1)*0.07);
    coords = getfield(status_flags.analysis_modules.boxes,['coords' num2str(box)]);
      
    %Coordinates
    handle1 = uicontrol(handle,'units','normalized','Position',[0.10,ypos,0.13,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(coords(1)),'HorizontalAlignment','left','Visible','on','userdata',box,'CallBack','box_callbacks(''x1'');');
    handle2 = uicontrol(handle,'units','normalized','Position',[0.24,ypos,0.13,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(coords(2)),'HorizontalAlignment','left','Visible','on','userdata',box,'CallBack','box_callbacks(''x2'');');
    handle3 = uicontrol(handle,'units','normalized','Position',[0.38,ypos,0.13,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(coords(3)),'HorizontalAlignment','left','Visible','on','userdata',box,'CallBack','box_callbacks(''y1'');');
    handle4 = uicontrol(handle,'units','normalized','Position',[0.52,ypos,0.13,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(coords(4)),'HorizontalAlignment','left','Visible','on','userdata',box,'CallBack','box_callbacks(''y2'');');
    if inst_params.detectors == 1; visible = 'off';
    else visible = 'on';end
    handle5 = uicontrol(handle,'units','normalized','Position',[0.66,ypos,0.13,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','text','String',num2str(coords(5)),'HorizontalAlignment','left','Visible',visible,'userdata',box);
    grasp_handles.window_modules.box = setfield(grasp_handles.window_modules.box,['coords' num2str(box)],[handle1, handle2, handle3, handle4, handle5]);
    
    %Grab Coords
    uicontrol(handle,'units','normalized','Position',[0.02,ypos,0.06,0.06],'tooltip','Grab Box Coordinates','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','Visible','on','Value',0,'string',num2str(box),'CallBack','box_callbacks(''grab_coords'');','userdata',box,'buttondownfcn','box_callbacks(''clear_box'');');

    %Scan Box
    %enable = 'off';
    %uicontrol(handle,'units','normalized','Position',[0.70,ypos,0.06,0.06],'tooltip','Scan Box with Angle','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','Visible','on','Value',status_flags.analysis_modules.boxes.scan_boxes_check(box),'CallBack','box_callbacks(''scan_box_check'');','userdata',box,'buttondownfcn','box_callbacks('''');','enable',enable);
end
%Clear All Boxes
ypos = 0.83 - ((7-1)*0.07);
uicontrol(handle,'units','normalized','Position',[0.02,ypos,0.06,0.06],'tooltip','Clear All Coordinates','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'string','x','Style','pushbutton','Visible','on','Value',0,'CallBack','box_callbacks(''clear_all'');','buttondownfcn','sector_box_callbacks(''clear_box'');');



%Box against parameter?
% uicontrol(handle,'units','normalized','Position',[0.15,0.4,0.20,0.06],'fontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','text','String','Parameter:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
% grasp_handles.window_modules.box.parameter = uicontrol(handle,'units','normalized','Position',[0.38,0.4,0.15,0.06],'fontname',grasp_env.font,'fontsize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.analysis_modules.boxes.parameter),'HorizontalAlignment','left','Tag','box_parameter','Visible','on','callback','box_callbacks(''parameter'');');

uicontrol(handle,'units','normalized','Position',[0.15,0.4,0.25,0.06],'fontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','text','String','Parameter:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);

value =1; string = 'dummy string';
grasp_handles.window_modules.box.parameter = uicontrol(handle,'units','normalized','Position',[0.38,0.4,0.30,0.06],'fontname',grasp_env.font,'fontsize',grasp_env.fontsize,'Style','popup','String',string,'value',value,'HorizontalAlignment','left','Tag','box_parameter','Visible','on','callback','box_callbacks(''parameter'');');
set(grasp_handles.window_modules.box.parameter,'buttondownfcn','box_callbacks;')
%grasp_handles.window_modules.box.parameter_string = uicontrol(handle,'units','normalized','Position',[0.23,0.33,0.3,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','text','tag','box_param_string','String','','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [0.2 1 0.20]);


% %Alternative drop-down parameter list
% %build parameter list popup
%     temp = size(inst_params.vector_names);
%     param_list_string = [];
%     index = 1;
%     for n = 1:temp(1);
%         if not(isempty(inst_params.vector_names{n}));
%             param_list_string{index} = [num2str(n) ' : ' inst_params.vector_names{n}{1} ];
%             index = index+1;
%         end
%     end
%     uicontrol('units','normalized','Position',[0.65,0.8,0.35,0.1],'fontname',grasp_env.font,'fontsize',grasp_env.fontsize*0.8,'Style','popup','String',param_list_string,'HorizontalAlignment','left','Tag','box_parameter','Visible','on','callback','box_callbacks(''box_parameter'');');




%%Param List
%grasp_handles.window_modules.box.param_list = uicontrol(handle,'units','normalized','Position',[0.07,0.05,0.3,0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','Param List!','HorizontalAlignment','center','Tag','param_list_button','Visible','on','CallBack','display_param_list','enable','on');
%set(grasp_handles.window_modules.box.param_list,'enable','off');
%Box It!
uicontrol(handle,'units','normalized','Position',[0.57,0.05,0.3,0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','Do It!','HorizontalAlignment','center','Tag','boxfox_button','Visible','on','callback','box_callbacks(''box_it'');');

%Sum all Boxes
grasp_handles.window_modules.box.sum_box_chk = uicontrol(handle,'units','normalized','Position',[0.65,0.41,0.35,0.06],'tooltip','Sum All Boxes','FontName',grasp_env.font,'FontSize',grasp_env.fontsize, 'Style','checkbox','String','Sum_Boxes','HorizontalAlignment','left','Tag','box_sum_check','Visible','on','value',status_flags.analysis_modules.boxes.sum_box_chk,'BackgroundColor', grasp_env.background_color,'ForegroundColor', [1 1 1],'callback','box_callbacks(''sum_box_chk'');');

%Normalise by box size
grasp_handles.window_modules.box.box_nrm_chk = uicontrol(handle,'units','normalized','position',[0.65,0.34,0.35,0.06],'tooltip','Normalise Boxes - Counts / Pixel','FontName',grasp_env.font,'FontSize',grasp_env.fontsize, 'Style','checkbox','String','Box_Norm','HorizontalAlignment','left','Tag','box_norm_check','Visible','on','value',status_flags.analysis_modules.boxes.box_nrm_chk,'BackgroundColor', grasp_env.background_color,'ForegroundColor', [1 1 1],'callback','box_callbacks(''box_nrm_chk'');');

%q-lock
grasp_handles.window_modules.box.q_lock = uicontrol('units','normalized','position',[0.05,0.23,0.44,0.06],'tooltip','Track box with q (i.e. wavelength)','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','String','Q-Lock','HorizontalAlignment','left','Visible','on','value',status_flags.analysis_modules.boxes.q_lock_chk,'callback','box_callbacks(''q_lock_chk'');','BackgroundColor', grasp_env.background_color,'ForegroundColor', [1 1 1]);
set(grasp_handles.window_modules.box.q_lock,'enable','off');

%q-lock box size lock
grasp_handles.window_modules.box.q_lock_box_size = uicontrol('units','normalized','position',[0.05,0.16,0.44,0.06],'tooltip','Scale box size with radius','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','String','Scale Box','HorizontalAlignment','left','Visible','on','value',status_flags.analysis_modules.boxes.q_lock_box_size_chk,'callback','box_callbacks(''q_lock_box_size_chk'');','BackgroundColor', grasp_env.background_color,'ForegroundColor', [1 1 1]);
set(grasp_handles.window_modules.box.q_lock_box_size,'enable','off');

%Theta-2Theta Box track
grasp_handles.window_modules.box.t2t_lock = uicontrol('units','normalized','position',[0.55,0.23,0.44,0.06],'tooltip','Track box with Theta-2Theta (i.e. sample angle)','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','String','Theta-2Theta','HorizontalAlignment','left','Visible','on','value',status_flags.analysis_modules.boxes.t2t_lock_chk,'callback','box_callbacks(''t2t_lock_chk'');','BackgroundColor', grasp_env.background_color,'ForegroundColor', [1 1 1]);
set(grasp_handles.window_modules.box.t2t_lock,'enable','off');

%Theta-2Theta box size lock
grasp_handles.window_modules.box.t2t_lock_box_size = uicontrol('units','normalized','position',[0.55,0.16,0.44,0.06],'tooltip','Scale box size with t2t','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','String','Scale Box','HorizontalAlignment','left','Visible','on','value',status_flags.analysis_modules.boxes.t2t_lock_box_size_chk,'callback','box_callbacks(''t2t_lock_box_size_chk'');','BackgroundColor', grasp_env.background_color,'ForegroundColor', [1 1 1]);
set(grasp_handles.window_modules.box.t2t_lock,'enable','off');


%Update boxes
box_callbacks;
