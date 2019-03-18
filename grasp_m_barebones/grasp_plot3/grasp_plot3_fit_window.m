function grasp_plot3_fit_window

global graspplot
global graspplot_handles

%***** Open 1D Curve Fit Window *****
i = findobj('tag','grasp_plot3_curve_fit_window');
if not(isempty(i)) && ishandle(i)
    figure(i)
    
    
else
    fig_position = ([0.2750 0.1 0.27 0.82]);
    background_color = graspplot.backgroundcolor;
    font = graspplot.font;
    fontsize = graspplot.fontsize;
    
    graspplot_handles.curve_fit1d.window = figure(....
        'units','normalized',....
        'Position',fig_position,....
        'Name','Curve Fit Control',....
        'NumberTitle', 'off',....
        'Tag','grasp_plot3_curve_fit_window',....
        'color',background_color,....
        'papertype','A4',....
        'menubar','none',....
        'closerequestfcn','closereq',....
        'resize','on');
    
    %Curve Number
    uicontrol('units','normalized','Position',[0.52 0.9 0.25 0.03],'FontName',font,'FontSize',fontsize,'FontWeight','bold','HorizontalAlignment','right','Style','text','String',['Curve Number:'],'BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    graspplot_handles.curve_fit1d.curve_number = uicontrol('units','normalized','Position',[0.78 0.9 0.1 0.03],'ToolTip','Select Curve to Fit','FontName',font,'FontSize',fontsize,'HorizontalAlignment','center','Style','Popup','Tag','curve_fit_selector','Value',1,'string','1','callback','grasp_plot3_fit_callbacks(''curve_number'');');
    
    %Fit All Curves Simultaneously
    uicontrol('units','normalized','Position',[0.52 0.86 0.25 0.03],'FontName',font,'FontSize',fontsize,'FontWeight','bold','HorizontalAlignment','right','Style','text','String',['Fit All Curves:'],'BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    check = 0;
    graspplot_handles.simultaneous_curves = uicontrol('units','normalized','Position',[0.78 0.865 0.05 0.03],'ToolTip','Fit All Curves Simultaneously','FontName',font,'FontSize',fontsize,'HorizontalAlignment','center','Style','checkbox','Value',check,'BackgroundColor', background_color,'callback','grasp_plot3_fit_callbacks(''simultaneous_fit_check'');');
    
%     %Smear for Instrument Resolution
%     vis = 'off';
%     uicontrol('units','normalized','Position',[0.02 0.86 0.25 0.03],'Tag','fit_resolution_text','FontName',font,'FontSize',fontsize,'FontWeight','bold','HorizontalAlignment','right','Style','text','String',['Include Resolution:'],'BackgroundColor', background_color, 'ForegroundColor', [1 1 1],'Visible',vis);
%     vis = 'off'; end
%     check = 0; end
%     uicontrol('units','normalized','Position',[0.28 0.865 0.038,0.028],'Tag','fit_resolution_div_check','ToolTip','Enable / Disable Model Smearing to Instrument Resolution','FontName',font,'FontSize',fontsize,'HorizontalAlignment','center','Style','checkbox','Visible',vis,'value',check,'BackgroundColor', background_color,'callback','grasp_plot3_fit_callbacks(''include_resolution_check'');');
           
    %Function selector
    uicontrol('units','normalized','Position',[0.02 0.95 0.25 0.03],'FontName',font,'FontSize',fontsize,'FontWeight','bold','HorizontalAlignment','right','Style','text','String',['Fitting Function:'],'BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    val = 1;
    graspplot_handles.curve_fit1d.fn_selector = uicontrol('units','normalized','Position',[0.28 0.95 0.35 0.03],'ToolTip','Select Fitting Function','FontName',font,'FontSize',fontsize,'HorizontalAlignment','center','Style','popup','Tag','fit_function_selector','Visible','on',....
        'String',' ','value',val,'callback','grasp_plot3_fit_callbacks(''toggle_fn'');');
    
    %Simultaneous Functions Selector
    no_fun_string = '1|2|3|4';
    uicontrol('units','normalized','Position',[0.02 0.9 0.25 0.03],'FontName',font,'FontSize',fontsize,'FontWeight','bold','HorizontalAlignment','right','Style','text','String',['No. of Functions:'],'BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    val = 1;
    uicontrol('units','normalized','Position',[0.28 0.9 0.1 0.03],'ToolTip','Number of Simultaneous Functions to Fit','FontName',font,'FontSize',fontsize,'HorizontalAlignment','center','Style','popup','Tag','no_functions_selector','Visible','on',....
        'String',no_fun_string,'value',val,'callback','grasp_plot3_fit_callbacks(''number_of_fn'');');
    
    %Parameters - mainly updated in curve_fit_window_mod
    uicontrol('units','normalized','Position',[0.02 0.80 0.3 0.03],'FontName',font,'FontSize',fontsize,'FontWeight','bold','HorizontalAlignment','right','Style','text','String',['Parameters:'],'BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    uicontrol('units','normalized','Position',[0.35 0.80 0.55 0.03],'FontName',font,'FontSize',fontsize,'FontWeight','bold','HorizontalAlignment','center','Style','text','BackgroundColor', background_color, 'ForegroundColor', [1 1 1],...
        'String',['fix       value          err           group']);
    
    %Auto Guess Parameters Button
    uicontrol('units','normalized','Position',[0.05 0.02 0.2 0.03],'ToolTip','Automatically Guess Starting Parameters from Zoomed Data','String','Auto_Guess','FontName',font,'FontSize',fontsize,'Style','pushbutton','Tag','fit_auto_guess','Visible','on','CallBack','grasp_plot3_fit_callbacks(''auto_guess'',''auto_guess'');');
    %Point and Click Parameters Button
    uicontrol('units','normalized','Position',[0.275 0.02 0.2 0.03],'ToolTip','Point and Click to determine Starting Parameters','String','Point & Click','FontName',font,'FontSize',fontsize,'Style','pushbutton','Tag','fit_point_click','Visible','on','CallBack','grasp_plot3_fit_callbacks(''auto_guess'',''point_click'');');
    %Fit it Button
    uicontrol('units','normalized','Position',[0.5 0.02 0.2 0.03],'ToolTip','Fit It!','String','Fit It!','FontName',font,'FontSize',fontsize,'Style','pushbutton','Tag','fit_it_now','Visible','on','CallBack','grasp_plot3_fit_callbacks(''fit_it'');');
    %Delete Last Fit Button
    uicontrol('units','normalized','Position',[0.725 0.02 0.2 0.03],'ToolTip','Delete Last Fit Curve!','String','Del Curve','FontName',font,'FontSize',fontsize,'Style','pushbutton','Tag','delete_last_curve_fit','Visible','on',...
        'CallBack','grasp_plot3_fit_callbacks(''delete_curves'');');
    %Delete curve on/off button
    val = 0;
    uicontrol('units','normalized','Position',[0.93 0.02 0.04 0.03],'ToolTip','Delete Curve Off/On','FontName',font,'FontSize',fontsize,'Style','checkbox','value',val,'Visible','on','BackgroundColor', background_color,'CallBack','grasp_plot3_fit_callbacks(''delete_onoff_check'');');
    
    
    %Copy Params to Clipboard Button
    uicontrol('units','normalized','Position',[0.725 0.06 0.2 0.03],'ToolTip','Copy Fit Parameters to Clipboard','String','Copy to Clip','FontName',font,'FontSize',fontsize,'Style','pushbutton','Tag','fit_clipboard','Visible','on','CallBack','grasp_plot3_fit_callbacks(''copy_to_clipboard'');');
    
    
    %Build the list of fitting functions
    grasp_plot3_fit_callbacks('build_curve_number');
    grasp_plot3_fit_callbacks('build_fn_list'); %update the current list of functions
    grasp_plot3_fit_callbacks('retrieve_fn'); %update the current function
    grasp_plot3_fit_callbacks('update_curve_fit_window');
    
end
