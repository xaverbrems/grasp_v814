function rundex_window

global grasp_env
global grasp_handles

%***** Open Rundex Window *****

if ishandle(grasp_handles.window_modules.rundex.window); delete(grasp_handles.window_modules.rundex.window); end

fig_position = ([0.43, 0.1, 0.12, 0.35]).* grasp_env.screen.screen_scaling;
grasp_handles.window_modules.rundex.window = figure(....
    'units','normalized',....
    'Position',fig_position,....
    'Name','Rundex' ,....
    'NumberTitle', 'off',....
    'Tag','rundex_window',....
    'color',grasp_env.background_color,....
    'menubar','none',....
    'resize','on',....
    'closerequestfcn','rundex_callbacks(''close'');closereq;');

%Numor1
uicontrol('units','normalized','Position',[0.05 0.9 0.5 0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text','String','Start Numor:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.window_modules.rundex.numor1 = uicontrol('units','normalized','Position',[0.6 0.9 0.3 0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String','000000','HorizontalAlignment','left','Tag','rundex_numor1','Visible','on');
%Numor2
uicontrol('units','normalized','Position',[0.05 0.8 0.5 0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text','String','End Numor:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.window_modules.rundex.numor2 = uicontrol('units','normalized','Position',[0.6 0.8 0.3 0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String','000000','HorizontalAlignment','left','Tag','rundex_numor2','Visible','on');
%Numor Skip
uicontrol('units','normalized','Position',[0.05 0.7 0.5 0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text','String','Skip:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.window_modules.rundex.skip = uicontrol('units','normalized','Position',[0.6 0.7 0.3 0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String','1','HorizontalAlignment','left','Tag','rundex_skip','Visible','on');
%Params
uicontrol('units','normalized','Position',[0.05 0.5 0.38 0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text','String','Additional Params:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.window_modules.rundex.params = uicontrol('units','normalized','Position',[0.45 0.15 0.5 0.50],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','List','String','','HorizontalAlignment','left','Tag','rundex_params','Visible','on','callback','rundex_callbacks(''params'');','tooltip','Select Parameters:  Multiple select holding cmd');


%Do It Button
uicontrol('units','normalized','Position',[0.20 0.05 0.6 0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','Do_It!','HorizontalAlignment','center','Tag','rundex_doit','Visible','on',...
    'CallBack','rundex_callbacks(''rundex'');');

rundex_callbacks
