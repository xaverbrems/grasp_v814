function bayes_window

global grasp_env
global grasp_handles
global status_flags

%***** Open Mask Editor Window *****

%Delete old window if it exists
if ishandle(grasp_handles.window_modules.bayes.window)
    delete(grasp_handles.window_modules.bayes.window);
end


fig_position = ([0.1, 0.1, 0.2, 0.6]).* grasp_env.screen.screen_scaling;
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



%input name/label
uicontrol(figure_handle,'units','normalized','Position',[0.05 0.90 0.4 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Label:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.input_name = uicontrol(figure_handle,'units','normalized','Position',[0.35 0.93 0.4 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.user_modules.bayes.input_name),'HorizontalAlignment','right','Tag','input_name','Visible','on','callback','bayes_callbacks(''input_name'');');

%input index
uicontrol(figure_handle,'units','normalized','Position',[0.05 0.85 0.4 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','input index:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.input_index = uicontrol(figure_handle,'units','normalized','Position',[0.35 0.85 0.16 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.user_modules.bayes.input_index),'HorizontalAlignment','right','Tag','input_index','Visible','on','callback','bayes_callbacks(''input_index'');');

%output index
uicontrol(figure_handle,'units','normalized','Position',[0.05 0.75 0.4 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','output index:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.output_index = uicontrol(figure_handle,'units','normalized','Position',[0.35 0.75 0.16 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.user_modules.bayes.output_index),'HorizontalAlignment','right','Tag','output_index','Visible','on','callback','bayes_callbacks(''output_index'');');

%spot x
uicontrol(figure_handle,'units','normalized','Position',[0.05 0.65 0.4 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Spot x:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.spot_x = uicontrol(figure_handle,'units','normalized','Position',[0.35 0.65 0.16 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.user_modules.bayes.spot_x),'HorizontalAlignment','right','Tag','spot_x','Visible','on','callback','bayes_callbacks(''spot_x'');');

%spot y
uicontrol(figure_handle,'units','normalized','Position',[0.55 0.65 0.4 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Spot y:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.spot_y = uicontrol(figure_handle,'units','normalized','Position',[0.82 0.65 0.16 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.user_modules.bayes.spot_y),'HorizontalAlignment','right','Tag','spot_y','Visible','on','callback','bayes_callbacks(''spot_y'');');

%eta0
uicontrol(figure_handle,'units','normalized','Position',[0.05 0.55 0.4 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','eta 0:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.eta0 = uicontrol(figure_handle,'units','normalized','Position',[0.35 0.55 0.16 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.user_modules.bayes.eta0),'HorizontalAlignment','right','Tag','eta0','Visible','on','callback','bayes_callbacks(''eta0'');');


%san offset
uicontrol(figure_handle,'units','normalized','Position',[0.05 0.45 0.4 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','san offset:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.sanoffset = uicontrol(figure_handle,'units','normalized','Position',[0.35 0.45 0.16 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.user_modules.bayes.sanoffset),'HorizontalAlignment','right','Tag','sanoffset','Visible','on','callback','bayes_callbacks(''sanoffset'');');

%phi offset
uicontrol(figure_handle,'units','normalized','Position',[0.05 0.35 0.4 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','phi offset:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.phioffset = uicontrol(figure_handle,'units','normalized','Position',[0.35 0.35 0.16 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.user_modules.bayes.phioffset),'HorizontalAlignment','right','Tag','phioffset','Visible','on','callback','bayes_callbacks(''phioffset'');');


%rocktype
rock_type_list = {'san','phi'};
   for n = 1:length(rock_type_list);
       if strcmp(status_flags.user_modules.bayes.rock_type,rock_type_list{n})
           value = n;
       end
   end
uicontrol('units','normalized','Position',[0.053,0.25,0.4,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','rock type:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.rock_type = uicontrol('units','normalized','Position',[0.35,0.24,0.22,0.1],'HorizontalAlignment','center','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','Popup','Tag','rock_type',...
       'String',rock_type_list,'CallBack','bayes_callbacks(''rock_type'');','Value',value);

   
%boxing_type
boxing_type_list = {'(none)','sectors','sector_boxes'};
   for n = 1:length(boxing_type_list);
       if strcmp(status_flags.user_modules.bayes.boxing_type,boxing_type_list{n})
           value = n;
       end
   end
uicontrol('units','normalized','Position',[0.053,0.2,0.4,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','box type:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.boxing_type = uicontrol('units','normalized','Position',[0.35,0.19,0.35,0.1],'HorizontalAlignment','center','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','Popup','Tag','boxing_type',...
       'String',boxing_type_list,'CallBack','bayes_callbacks(''boxing_type'');','Value',value);   


%shape
shape_list = {'gaussian','lorentzian'};
if strcmp(status_flags.user_modules.bayes.shape, 'g')
    value = 1;
elseif strcmp(status_flags.user_modules.bayes.shape, 'l')
    value = 2;
end

uicontrol('units','normalized','Position',[0.053,0.15,0.4,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','shape:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.shape = uicontrol('units','normalized','Position',[0.35,0.125,0.35,0.1],'HorizontalAlignment','center','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','Popup','Tag','shape',...
       'String',shape_list,'CallBack','bayes_callbacks(''shape'');','Value',value);    

%Nonsensfactor slider
% adapt so the slider is from left (=low) to right(=high)
nonsensefactor = 1 - status_flags.user_modules.bayes.nonsensefactor
tooltip_string = ['set nonsensefactor: mask unmeasured regions' char(13) newline...
                    'left: no masking, right: high masking']
uicontrol('units','normalized','Position',[0.053,0.1,0.4,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Nonsensefactor:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.user_modules.bayes.nonsensefactor = uicontrol('units','normalized','Position',[0.35,0.15,0.35,0.03],'ToolTip',tooltip_string,'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','slider','Tag','nonsense_slider', 'CallBack','bayes_callbacks(''nonsensefactor'');','Value',nonsensefactor);   

   
%run bayes   
grasp_handles.user_modules.bayes.run_bayes_button = uicontrol(figure_handle,'units','normalized','Position',[0.05 0.02 0.5 0.07],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','run_bayes!','HorizontalAlignment','Center','Tag','run_bayes_button','Visible','on','CallBack','bayes_callbacks(''run_bayes'');');

bayes_callbacks;