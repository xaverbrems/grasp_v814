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
uicontrol(figure_handle,'units','normalized','Position',[0.05 0.85 0.4 0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Input name:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.input_name = uicontrol(figure_handle,'units','normalized','Position',[0.37 0.85 0.4 0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.user_modules.bayes.input_name),'HorizontalAlignment','right','Tag','input_name','Visible','on','callback','bayes_callbacks(''input_name'');');

%input index
uicontrol(figure_handle,'units','normalized','Position',[0.05 0.75 0.4 0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','input index:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.input_index = uicontrol(figure_handle,'units','normalized','Position',[0.37 0.75 0.16 0.07],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.user_modules.bayes.input_index),'HorizontalAlignment','right','Tag','input_index','Visible','on','callback','bayes_callbacks(''input_index'');');

%output index
uicontrol(figure_handle,'units','normalized','Position',[0.05 0.65 0.4 0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','output index:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.output_index = uicontrol(figure_handle,'units','normalized','Position',[0.37 0.65 0.16 0.07],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.user_modules.bayes.output_index),'HorizontalAlignment','right','Tag','output_index','Visible','on','callback','bayes_callbacks(''output_index'');');

%spot x
uicontrol(figure_handle,'units','normalized','Position',[0.05 0.55 0.4 0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Spot x:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.spot_x = uicontrol(figure_handle,'units','normalized','Position',[0.32 0.55 0.16 0.07],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.user_modules.bayes.spot_x),'HorizontalAlignment','right','Tag','spot_x','Visible','on','callback','bayes_callbacks(''spot_x'');');

%spot y
uicontrol(figure_handle,'units','normalized','Position',[0.55 0.55 0.4 0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Spot y:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.spot_y = uicontrol(figure_handle,'units','normalized','Position',[0.82 0.55 0.16 0.07],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.user_modules.bayes.spot_y),'HorizontalAlignment','right','Tag','spot_y','Visible','on','callback','bayes_callbacks(''spot_y'');');

%eta0
uicontrol(figure_handle,'units','normalized','Position',[0.05 0.45 0.4 0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','eta 0:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.eta0 = uicontrol(figure_handle,'units','normalized','Position',[0.32 0.45 0.16 0.07],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.user_modules.bayes.eta0),'HorizontalAlignment','right','Tag','eta0','Visible','on','callback','bayes_callbacks(''eta0'');');


%san offset
uicontrol(figure_handle,'units','normalized','Position',[0.05 0.35 0.4 0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','san offset:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.sanoffset = uicontrol(figure_handle,'units','normalized','Position',[0.32 0.35 0.16 0.07],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.user_modules.bayes.sanoffset),'HorizontalAlignment','right','Tag','sanoffset','Visible','on','callback','bayes_callbacks(''sanoffset'');');

%phi offset
uicontrol(figure_handle,'units','normalized','Position',[0.05 0.25 0.4 0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','phi offset:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.phioffset = uicontrol(figure_handle,'units','normalized','Position',[0.32 0.25 0.16 0.07],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.user_modules.bayes.phioffset),'HorizontalAlignment','right','Tag','phioffset','Visible','on','callback','bayes_callbacks(''phioffset'');');


%rocktype
rock_type_list = {'san','phi'};
   for n = 1:length(rock_type_list);
       if strcmp(status_flags.user_modules.bayes.rock_type,rock_type_list{n})
           value = n;
       end
   end
uicontrol('units','normalized','Position',[0.053,0.15,0.4,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','rock type:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.rock_type = uicontrol('units','normalized','Position',[0.35,0.13,0.22,0.1],'HorizontalAlignment','center','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','Popup','Tag','rock_type',...
       'String',rock_type_list,'CallBack','bayes_callbacks(''rock_type'');','Value',value);

   
%boxing_type
boxing_type_list = {'(none)','sectors','sector_boxes'};
   for n = 1:length(boxing_type_list);
       if strcmp(status_flags.user_modules.bayes.boxing_type,boxing_type_list{n})
           value = n;
       end
   end
uicontrol('units','normalized','Position',[0.053,0.05,0.4,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','box type:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.boxing_type = uicontrol('units','normalized','Position',[0.35,0.03,0.35,0.1],'HorizontalAlignment','center','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','Popup','Tag','boxing_type',...
       'String',boxing_type_list,'CallBack','bayes_callbacks(''boxing_type'');','Value',value);   

%run bayes   
grasp_handles.user_modules.bayes.run_bayes_button = uicontrol(figure_handle,'units','normalized','Position',[0.05 0.00 0.5 0.07],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','run_bayes!','HorizontalAlignment','Center','Tag','run_bayes_button','Visible','on','CallBack','bayes_callbacks(''run_bayes'');');

bayes_callbacks;