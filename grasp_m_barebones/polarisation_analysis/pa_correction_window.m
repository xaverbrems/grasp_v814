function pa_correction_window(option) 

global grasp_env
global grasp_handles
global status_flags
global grasp_data

if nargin <1;
    option = [];
else
    status_flags.pa_correction.calibrate_check = option;
end


%***** Open pacorrection Analysis Window *****
if ishandle(grasp_handles.window_modules.pa_correction.window); delete(grasp_handles.window_modules.pa_correction.window); end

fig_position = ([0.555, 0.1, 0.12, 0.35]).* grasp_env.screen.screen_scaling;
grasp_handles.window_modules.pa_correction.window = figure(....
    'units','normalized',....
    'Position',fig_position,....
    'Name','Polarisation Correction Options' ,....
    'NumberTitle', 'off',....
    'Tag','pacorrection_window',....
    'color',grasp_env.background_color,....
    'menubar','none',....
    'resize','on',....
    'closerequestfcn','pa_correction_callbacks(''close'');closereq');

handle = grasp_handles.window_modules.pa_correction.window;

uicontrol(grasp_handles.window_modules.pa_correction.window,'units','normalized','Position',[0 0.95 1 0.04],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','center','Style','text','String','***** Data Corrections *****','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);

% %Background Substraction 
 uicontrol(grasp_handles.window_modules.pa_correction.window,'units','normalized','Position',[0.05 0.8 0.8 0.04],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Background Correction:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
 grasp_handles.window_modules.pa_correction.bck_check = uicontrol(grasp_handles.window_modules.pa_correction.window,'units','normalized','Position',[0.7 0.8 0.068 0.04],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','Tag','bck_check','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],'value',status_flags.pa_correction.bck_check,'callback','pa_correction_callbacks(''bck'')');

% %Blocked Beam
 uicontrol(grasp_handles.window_modules.pa_correction.window,'units','normalized','Position',[0.05 0.7 0.8 0.04],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Blocked Beam Correction:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
 grasp_handles.window_modules.pa_correction.cad_check = uicontrol(grasp_handles.window_modules.pa_correction.window,'units','normalized','Position',[0.7 0.7 0.068 0.04],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','Tag','cad_check','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],'value',status_flags.pa_correction.cad_check,'callback','pa_correction_callbacks(''cad'')');

%Polarisation Corrections On/Off
uicontrol(grasp_handles.window_modules.pa_correction.window,'units','normalized','Position',[0.05 0.60 0.8 0.04],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Spin-Leakage Correction:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.window_modules.pa_correction.pa_check = uicontrol(grasp_handles.window_modules.pa_correction.window,'units','normalized','Position',[0.7 0.6 0.068 0.04],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','Tag','pa_check','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],'value',status_flags.pa_correction.pa_check,'callback','pa_correction_callbacks(''pa_correction'')');

% %Sum SF cross section  On/Off
uicontrol(grasp_handles.window_modules.pa_correction.window,'units','normalized','Position',[0.05 0.50 0.8 0.04],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Sum SF cross sections:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.window_modules.pa_correction.add_check = uicontrol(grasp_handles.window_modules.pa_correction.window,'units','normalized','Position',[0.9 0.5 0.068 0.04],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','Tag','add_check','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],'value',status_flags.pa_correction.add_check,'callback','pa_correction_callbacks(''sigmaadd'')');


%Flipper Polarisation
grasp_handles.window_modules.pa_correction.flipper_text = uicontrol(handle,'units','normalized','Position',[0.05 0.40 0.8 0.04],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Flipper Polarisation:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.window_modules.pa_correction.flipper_edit = uicontrol(handle,'units','normalized','Position',[0.6 0.40 0.2 0.07],'tooltip',' ','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.pa_optimise.parameters.pf(1)),'HorizontalAlignment','center','Visible','on','callback','pa_correction_callbacks(''f_pol_edit'');');

%Supermirror Polarisation
grasp_handles.window_modules.pa_correction.polariser_text = uicontrol(handle,'units','normalized','Position',[0.05 0.20 0.8 0.07],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Supermirror Polarisation:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.window_modules.pa_correction.polariser_edit = uicontrol(handle,'units','normalized','Position',[0.6 0.20 0.2 0.07],'tooltip',' ','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.pa_optimise.parameters.p(1)),'HorizontalAlignment','center','Visible','on','callback','pa_correction_callbacks(''p_pol_edit'');');




