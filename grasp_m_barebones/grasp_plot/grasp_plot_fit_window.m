function grasp_plot_fit_window

global grasp_env
global grasp_handles
global status_flags


%***** Open 1D Curve Fit Window *****
try
if ishandle(grasp_handles.window_modules.curve_fit1d.window)
    if strcmp(get(grasp_handles.window_modules.curve_fit1d.window,'tag'),'curve_fit_window')
        figure(grasp_handles.window_modules.curve_fit1d.window)
        return
    end
end
catch
end

%fig_position = [grasp_env.screen.grasp_main_actual_position(1)+grasp_env.screen.grasp_main_actual_position(3)-450*grasp_env.screen.screen_scaling(1), grasp_env.screen.grasp_main_actual_position(2)+grasp_env.screen.grasp_main_actual_position(4)-800*grasp_env.screen.screen_scaling(2),   450*grasp_env.screen.screen_scaling(1)   800*grasp_env.screen.screen_scaling(2)];
try
fig_position = ([0.2750 0.1 0.27 0.82]).*grasp_env.screen.screen_scaling;
catch
    fig_position = ([0.2750 0.1 0.27 0.82]);
end

try 
    background_color = background_color;
    font = grasp_env.font;
    fontsize = grasp_env.font_size;
catch
    background_color = [0.05,0.1,0.3];
    font = 'Arial';
    fontsize = 10;
end


grasp_handles.window_modules.curve_fit1d.window = figure(....
        'units','normalized',....
        'Position',fig_position,....
        'Name','Curve Fit Control',....
        'NumberTitle', 'off',....
        'Tag','curve_fit_window',....
        'color',background_color,....
        'papertype','A4',....
        'menubar','none',....
        'closerequestfcn','closereq',....
        'resize','on');

    %Curve Number
    uicontrol('units','normalized','Position',[0.52 0.9 0.25 0.03],'FontName',font,'FontSize',fontsize,'FontWeight','bold','HorizontalAlignment','right','Style','text','String',['Curve Number:'],'BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    grasp_handles.window_modules.curve_fit1d.curve_number = uicontrol('units','normalized','Position',[0.78 0.9 0.1 0.03],'ToolTip','Select Curve to Fit','FontName',font,'FontSize',fontsize,'HorizontalAlignment','center','Style','Popup','Tag','curve_fit_selector','Value',1,'string','1','callback','grasp_plot_fit_callbacks(''curve_number'');');
    
    %Fit All Curves Simultaneously
    uicontrol('units','normalized','Position',[0.52 0.86 0.25 0.03],'FontName',font,'FontSize',fontsize,'FontWeight','bold','HorizontalAlignment','right','Style','text','String',['Fit All Curves:'],'BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    try; check = status_flags.fitter.simultaneous_check; catch check = 0; end
    grasp_handles.window_modules.simultaneous_curves = uicontrol('units','normalized','Position',[0.78 0.865 0.05 0.03],'ToolTip','Fit All Curves Simultaneously','FontName',font,'FontSize',fontsize,'HorizontalAlignment','center','Style','checkbox','Value',check,'BackgroundColor', background_color,'callback','grasp_plot_fit_callbacks(''simultaneous_fit_check'');');
    
    %Smear for Instrument Resolution
    try vis = status_flags.fitter.res1d_option; catch vis = 'off'; end
    uicontrol('units','normalized','Position',[0.02 0.86 0.25 0.03],'Tag','fit_resolution_text','FontName',font,'FontSize',fontsize,'FontWeight','bold','HorizontalAlignment','right','Style','text','String',['Include Resolution:'],'BackgroundColor', background_color, 'ForegroundColor', [1 1 1],'Visible',vis);
    try vis = status_flags.fitter.res1d_option; catch vis = 'off'; end
    try check = status_flags.fitter.include_res_check; catch check = 0; end
    uicontrol('units','normalized','Position',[0.28 0.865 0.038,0.028],'Tag','fit_resolution_div_check','ToolTip','Enable / Disable Model Smearing to Instrument Resolution','FontName',font,'FontSize',fontsize,'HorizontalAlignment','center','Style','checkbox','Visible',vis,'value',check,'BackgroundColor', background_color,'callback','grasp_plot_fit_callbacks(''include_resolution_check'');');

    %Resolution control centre button
   %uicontrol('units','normalized','Position',[0.32 0.865 0.03,0.015],'ToolTip','Open Resolution Control Centre','FontName',font,'FontSize',fontsize,'HorizontalAlignment','center','Style','pushbutton','string','','Visible',status_flags.fitter.res1d_option,'callback','resolution_control_window;');
    
    
    %Function selector
    uicontrol('units','normalized','Position',[0.02 0.95 0.25 0.03],'FontName',font,'FontSize',fontsize,'FontWeight','bold','HorizontalAlignment','right','Style','text','String',['Fitting Function:'],'BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    try val = status_flags.fitter.fn1d; catch val = 1; end
    grasp_handles.window_modules.curve_fit1d.fn_selector = uicontrol('units','normalized','Position',[0.28 0.95 0.35 0.03],'ToolTip','Select Fitting Function','FontName',font,'FontSize',fontsize,'HorizontalAlignment','center','Style','popup','Tag','fit_function_selector','Visible','on',....
        'String',' ','value',val,'callback','grasp_plot_fit_callbacks(''toggle_fn'');');

    %Simultaneous Functions Selector
    no_fun_string = '1|2|3|4';
    uicontrol('units','normalized','Position',[0.02 0.9 0.25 0.03],'FontName',font,'FontSize',fontsize,'FontWeight','bold','HorizontalAlignment','right','Style','text','String',['No. of Functions:'],'BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    try val = status_flags.fitter.number1d; catch val = 1; end
    uicontrol('units','normalized','Position',[0.28 0.9 0.1 0.03],'ToolTip','Number of Simultaneous Functions to Fit','FontName',font,'FontSize',fontsize,'HorizontalAlignment','center','Style','popup','Tag','no_functions_selector','Visible','on',....
        'String',no_fun_string,'value',val,'callback','grasp_plot_fit_callbacks(''number_of_fn'');');

    %Parameters - mainly updated in curve_fit_window_mod
    uicontrol('units','normalized','Position',[0.02 0.80 0.3 0.03],'FontName',font,'FontSize',fontsize,'FontWeight','bold','HorizontalAlignment','right','Style','text','String',['Parameters:'],'BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    uicontrol('units','normalized','Position',[0.35 0.80 0.55 0.03],'FontName',font,'FontSize',fontsize,'FontWeight','bold','HorizontalAlignment','center','Style','text','BackgroundColor', background_color, 'ForegroundColor', [1 1 1],...
        'String',['fix       value          err           group']);

    %Auto Guess Parameters Button
    uicontrol('units','normalized','Position',[0.05 0.02 0.2 0.03],'ToolTip','Automatically Guess Starting Parameters from Zoomed Data','String','Auto_Guess','FontName',font,'FontSize',fontsize,'Style','pushbutton','Tag','fit_auto_guess','Visible','on','CallBack','grasp_plot_fit_callbacks(''auto_guess'',''auto_guess'');');
    %Point and Click Parameters Button
    uicontrol('units','normalized','Position',[0.275 0.02 0.2 0.03],'ToolTip','Point and Click to determine Starting Parameters','String','Point & Click','FontName',font,'FontSize',fontsize,'Style','pushbutton','Tag','fit_point_click','Visible','on','CallBack','grasp_plot_fit_callbacks(''auto_guess'',''point_click'');');
    %Fit it Button
    uicontrol('units','normalized','Position',[0.5 0.02 0.2 0.03],'ToolTip','Fit It!','String','Fit It!','FontName',font,'FontSize',fontsize,'Style','pushbutton','Tag','fit_it_now','Visible','on','CallBack','grasp_plot_fit_callbacks(''fit_it'');');
    %Delete Last Fit Button
    uicontrol('units','normalized','Position',[0.725 0.02 0.2 0.03],'ToolTip','Delete Last Fit Curve!','String','Del Curve','FontName',font,'FontSize',fontsize,'Style','pushbutton','Tag','delete_last_curve_fit','Visible','on',...
        'CallBack','grasp_plot_fit_callbacks(''delete_curves'');');
    %Delete curve on/off button
    try status_flags.fitter.delete_curves_check; catch val = 0; end
    uicontrol('units','normalized','Position',[0.93 0.02 0.04 0.03],'ToolTip','Delete Curve Off/On','FontName',font,'FontSize',fontsize,'Style','checkbox','value',val,'Visible','on','BackgroundColor', background_color,'CallBack','grasp_plot_fit_callbacks(''delete_onoff_check'');');
    
    
    %Copy Params to Clipboard Button
    uicontrol('units','normalized','Position',[0.725 0.06 0.2 0.03],'ToolTip','Copy Fit Parameters to Clipboard','String','Copy to Clip','FontName',font,'FontSize',fontsize,'Style','pushbutton','Tag','fit_clipboard','Visible','on','CallBack','grasp_plot_fit_callbacks(''copy_to_clipboard'');');

    
    %Build the list of fitting functions
    grasp_plot_fit_callbacks('build_curve_number');
    grasp_plot_fit_callbacks('build_fn_list'); %update the current list of functions
    grasp_plot_fit_callbacks('retrieve_fn'); %update the current function
    grasp_plot_fit_callbacks('update_curve_fit_window');

