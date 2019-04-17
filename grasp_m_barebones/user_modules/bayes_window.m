function bayes_window

global grasp_env
global grasp_handles
global status_flags

%***** Open Mask Editor Window *****

%Delete old window if it exists
if ishandle(grasp_handles.window_modules.bayes.window)
    delete(grasp_handles.window_modules.bayes.window);
end


fig_position = ([0.43, 0.605, 0.12, 0.35]).* grasp_env.screen.screen_scaling;
grasp_handles.window_modules.bayes.window = figure(....
    'units','normalized',....
    'Position',fig_position,....
    'Name','Bayes' ,....
    'NumberTitle', 'off',....
    'Tag','bayes_window',....
    'color',grasp_env.background_color,...
    'menubar','none',....
    'resize','on',....
    'closerequestfcn','closereq');
figure_handle = grasp_handles.window_modules.bayes.window;


%input name
grasp_handles.user_modules.bayes.input_name = uicontrol(figure_handle,'units','normalized','Position',[0.32 0.7 0.16 0.07],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.user_modules.bayes.input_name),'HorizontalAlignment','right','Tag','input_name','Visible','on','callback','bayes_callbacks(''input_name'');');



bayes_callbacks;