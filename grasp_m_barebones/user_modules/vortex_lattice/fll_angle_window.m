function fll_angle_window

global grasp_env

h=findobj('Tag','fll_angle_window'); %Check to see if window is already open
if isempty(h) %i.e. if no window exists.
    fig_position = ([0.43, 0.535, 0.18, 0.2]).* grasp_env.screen.screen_scaling;
    
    figure_handle = figure(....
        'units','normalized',....
        'Position',fig_position,....
        'Name','Angle_Calculator' ,....
        'NumberTitle', 'off',....
        'Tag','fll_angle_window',....
        'Color',grasp_env.background_color,....
        'menubar','none',....
        'resize','on');
    
    %Text
    uicontrol(figure_handle,'units','normalized','Position',[0.09,0.65,0.09,0.2],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text',...
        'String','Spot 1','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
    uicontrol(figure_handle,'units','normalized','Position',[0.09,0.50,0.09,0.2],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text',...
        'String','Spot 2','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
    uicontrol(figure_handle,'units','normalized','Position',[0.002,0.38,0.18,0.2],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text',...
        'String','Beam Centre','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
    uicontrol(figure_handle,'units','normalized','Position',[0.001,0.2,0.18,0.2],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text',...
        'String','Apex Angle (Degrees)','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
    uicontrol(figure_handle,'units','normalized','Position',[0.19,0.83,0.1,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text',...
        'String','x','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
    uicontrol(figure_handle,'units','normalized','Position',[0.36,0.83,0.1,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text',...
        'String','Err x','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
    uicontrol(figure_handle,'units','normalized','Position',[0.53,0.83,0.1,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text',...
        'String','y','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
    uicontrol(figure_handle,'units','normalized','Position',[0.71,0.83,0.1,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text',...
        'String','Err y','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
    uicontrol(figure_handle,'units','normalized','Position',[0.42,0.295,0.1,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text',...
        'String','Error','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
    uicontrol(figure_handle,'units','normalized','Position',[0.88,0.83,0.1,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text',...
        'String','Capture','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
    
    %Boxes
    uicontrol(figure_handle,'units','normalized','Position',[0.22,0.76,0.13,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String','0','HorizontalAlignment','left','Tag','x1','Visible','on');
    uicontrol(figure_handle,'units','normalized','Position',[0.37,0.76,0.13,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String','0','HorizontalAlignment','left','Tag','dx1','Visible','on');
    uicontrol(figure_handle,'units','normalized','Position',[0.56,0.76,0.13,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String','0','HorizontalAlignment','left','Tag','y1','Visible','on');
    uicontrol(figure_handle,'units','normalized','Position',[0.71,0.76,0.13,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String','0','HorizontalAlignment','left','Tag','dy1','Visible','on');
    uicontrol(figure_handle,'units','normalized','Position',[0.22,0.63,0.13,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String','0','HorizontalAlignment','left','Tag','x2','Visible','on');
    uicontrol(figure_handle,'units','normalized','Position',[0.37,0.63,0.13,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String','0','HorizontalAlignment','left','Tag','dx2','Visible','on');
    uicontrol(figure_handle,'units','normalized','Position',[0.56,0.63,0.13,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String','0','HorizontalAlignment','left','Tag','y2','Visible','on');
    uicontrol(figure_handle,'units','normalized','Position',[0.71,0.63,0.13,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String','0','HorizontalAlignment','left','Tag','dy2','Visible','on');
    uicontrol(figure_handle,'units','normalized','Position',[0.22,0.50,0.13,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String','0','HorizontalAlignment','left','Tag','x0','Visible','on');
    uicontrol(figure_handle,'units','normalized','Position',[0.56,0.50,0.13,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String','0','HorizontalAlignment','left','Tag','y0','Visible','on');
    uicontrol(figure_handle,'units','normalized','Position',[0.22,0.30,0.13,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String','0','HorizontalAlignment','left','Tag','beta','Visible','on');
    uicontrol(figure_handle,'units','normalized','Position',[0.22,0.18,0.13,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String','0','HorizontalAlignment','left','Tag','beta90','Visible','on');
    uicontrol(figure_handle,'units','normalized','Position',[0.56,0.30,0.13,0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String','0','HorizontalAlignment','left','Tag','d_beta','Visible','on');
    uicontrol(figure_handle,'units','normalized','Position',[0.27 0.07 0.45 0.08],'ToolTip','','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton',...
        'string','Calculate','callback','fll_angle_callbacks(''calculate'')');
    uicontrol(figure_handle,'units','normalized','Position',[0.88 0.765 0.1 0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton',...
        'string','Load','callBack','fll_angle_callbacks(''load'',1);','userdata',1);
    uicontrol(figure_handle,'units','normalized','Position',[0.88 0.64 0.1 0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton',...
        'string','Load','callBack','fll_angle_callbacks(''load'',2);','userdata',1);
    uicontrol(figure_handle,'units','normalized','Position',[0.88 0.515 0.1 0.08],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton',...
        'string','Load','callBack','fll_angle_callbacks(''loadcm'');');
else
    figure(h)
end


