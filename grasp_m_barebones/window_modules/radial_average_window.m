function radial_average_window


global grasp_env
global grasp_handles
global status_flags


%***** Open Radial Average Window Window *****

%Delete old window if it exists
if ishandle(grasp_handles.window_modules.radial_average.window)
    delete(grasp_handles.window_modules.radial_average.window);
end

fig_position = ([0.43, 0.1, 0.12, 0.35]).* grasp_env.screen.screen_scaling;
grasp_handles.window_modules.radial_average.window = figure(....
    'units','normalized',....
    'Position',fig_position,....
    'Name','Averaging',....
    'NumberTitle', 'off',....
    'Tag','radialav_window',....
    'color',grasp_env.background_color,....
    'menubar','none',....
    'resize','on',....
    'closerequestfcn','radial_average_callbacks(''close'');closereq;');

handle = grasp_handles.window_modules.radial_average.window;



%Radial Average I vs. q Button & Bin
grasp_handles.figure.window_modules.radial_average.q_bin_context.root = uicontextmenu;
uicontrol(handle,'units','normalized','Position',[0.05 0.85 0.3 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'tooltip',['Perform ''Radial Average'' : I vs. |q|' char(10) 'Right click for bin options'],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','I vs. |q|','fontweight','bold','HorizontalAlignment','center','Tag','i_q_button','Visible','on','CallBack','radial_average_callbacks(''radial_average'',''q'');',....
    'uicontextmenu',grasp_handles.figure.window_modules.radial_average.q_bin_context.root);
grasp_handles.figure.window_modules.radial_average.q_bin_context.pixels = uimenu(grasp_handles.figure.window_modules.radial_average.q_bin_context.root,'label','Pixels','callback','radial_average_callbacks(''q_bin_pixels'');');
grasp_handles.figure.window_modules.radial_average.q_bin_context.absolute.root = uimenu(grasp_handles.figure.window_modules.radial_average.q_bin_context.root,'label','Absolute');
grasp_handles.figure.window_modules.radial_average.q_bin_context.absolute.linear = uimenu(grasp_handles.figure.window_modules.radial_average.q_bin_context.absolute.root,'label','Linear','callback','radial_average_callbacks(''q_bin_absolute'',''linear'');');
grasp_handles.figure.window_modules.radial_average.q_bin_context.absolute.log10 = uimenu(grasp_handles.figure.window_modules.radial_average.q_bin_context.absolute.root,'label','Log10','callback','radial_average_callbacks(''q_bin_absolute'',''log10'');');
grasp_handles.figure.window_modules.radial_average.q_bin_context.resolution = uimenu(grasp_handles.figure.window_modules.radial_average.q_bin_context.root,'label','Resolution','callback','radial_average_callbacks(''q_bin_resolution'');');
grasp_handles.window_modules.radial_average.q_bin_text = uicontrol(handle,'units','normalized','Position',[0.4 0.85 0.35 0.07],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text','String','','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.window_modules.radial_average.q_bin = uicontrol(handle,'units','normalized','Position',[0.8 0.85 0.16 0.06],'tooltip','','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String','1','HorizontalAlignment','center','Tag','radial_bin','Visible','on','callback','radial_average_callbacks(''q_bin'');');



%Radial Average I vs. |2Theta| Button & Bin
enable = 'on';
grasp_handles.figure.window_modules.radial_average.theta_bin_context.root = uicontextmenu;
uicontrol(handle,'units','normalized','Position',[0.05 0.73 0.3 0.05],'tooltip',['Perform ''Radial Average'' : I vs. |2' char(415) '|'  char(10) 'Right click for bin options'],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','I vs. |2th|','fontweight','bold','HorizontalAlignment','center','Tag','i_2theta_button','Visible','on','CallBack','radial_average_callbacks(''radial_average'',''2theta'');',....
    'uicontextmenu',grasp_handles.figure.window_modules.radial_average.theta_bin_context.root,'enable',enable);
grasp_handles.figure.window_modules.radial_average.theta_bin_context.pixels = uimenu(grasp_handles.figure.window_modules.radial_average.theta_bin_context.root,'label','Pixels','callback','radial_average_callbacks(''theta_bin_pixels'');');
grasp_handles.figure.window_modules.radial_average.theta_bin_context.absolute.root = uimenu(grasp_handles.figure.window_modules.radial_average.theta_bin_context.root,'label','Absolute');
grasp_handles.figure.window_modules.radial_average.theta_bin_context.absolute.linear = uimenu(grasp_handles.figure.window_modules.radial_average.theta_bin_context.absolute.root,'label','Linear','callback','radial_average_callbacks(''theta_bin_absolute'',''linear'');');
grasp_handles.figure.window_modules.radial_average.theta_bin_context.absolute.log10 = uimenu(grasp_handles.figure.window_modules.radial_average.theta_bin_context.absolute.root,'label','Log10','callback','radial_average_callbacks(''theta_bin_absolute'',''log10'');');
grasp_handles.figure.window_modules.radial_average.theta_bin_context.resolution = uimenu(grasp_handles.figure.window_modules.radial_average.theta_bin_context.root,'label','Resolution','callback','radial_average_callbacks(''theta_bin_resolution'');');
grasp_handles.window_modules.radial_average.theta_bin_text = uicontrol(handle,'units','normalized','Position',[0.4 0.73 0.35 0.07],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text','String','Radial Bin (pxl):','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.window_modules.radial_average.theta_bin = uicontrol(handle,'units','normalized','Position',[0.8 0.73 0.16 0.06],'tooltip','Re-Bin Size in the Radial Direction (pixels)','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String','1','HorizontalAlignment','center','Tag','radial_bin_2theta','Visible','on','callback','radial_average_callbacks(''theta_bin'');','enable',enable);



%Asimuthal Average Button & Bin
enable = 'on';
grasp_handles.figure.window_modules.radial_average.azimuth_bin_context.root = uicontextmenu;
uicontrol(handle,'units','normalized','Position',[0.05 0.61 0.3 0.05],'tooltip',['Perform ''Azimuthal Average'' : I vs. xi Around the Detector'  newline 'Right click for bin options'],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','pushbutton','String','I vs. xi','fontweight','bold','HorizontalAlignment','center','Tag','i_theta_button','Visible','on','CallBack','radial_average_callbacks(''radial_average'',''azimuthal'');',....
    'uicontextmenu',grasp_handles.figure.window_modules.radial_average.azimuth_bin_context.root,'enable',enable);
grasp_handles.figure.window_modules.radial_average.azimuth_bin_context.absolute = uimenu(grasp_handles.figure.window_modules.radial_average.azimuth_bin_context.root,'label','Absolute','callback','radial_average_callbacks(''azimuth_bin_absolute'');');
%grasp_handles.figure.window_modules.radial_average.azimuth_bin_context.smart = uimenu(grasp_handles.figure.window_modules.radial_average.azimuth_bin_context.root,'label','Smart','callback','radial_average_callbacks(''azimuth_bin_smart'');');
grasp_handles.window_modules.radial_average.azimuth_bin_text = uicontrol(handle,'units','normalized','Position',[0.4 0.61 0.35 0.07],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text','String','Angle Bin (deg):','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.window_modules.radial_average.azimuth_bin = uicontrol(handle,'units','normalized','Position',[0.8 0.61 0.16 0.06],'tooltip','Re-Bin Size in Angle (degrees).  Note: Min Value Depends on the Sector Minimum Radius','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String','2','HorizontalAlignment','center','Tag','angular_bin','Visible','on','callback','radial_average_callbacks(''azimuth_bin'');','enable',enable);




%Use Sector Mask.
uicontrol(handle,'units','normalized','Position',[0.25 0.49 0.5 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text','String','Use Sector Mask:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.window_modules.radial_average.sector_mask_chk = uicontrol(handle,'units','normalized','Position',[0.9 0.49 0.068 0.06],'tooltip','Use Data Defined by Sector','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','Tag','sect_mask_check','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],....
    'value',status_flags.analysis_modules.radial_average.sector_mask_chk,....
    'callback','radial_average_callbacks(''sector_mask_chk'');');

%Use Strip Mask.
uicontrol(handle,'units','normalized','Position',[0.25 0.44 0.5 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text','String','Use Strip Mask:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
grasp_handles.window_modules.radial_average.strip_mask_chk = uicontrol(handle,'units','normalized','Position',[0.9 0.44 0.068 0.06],'tooltip','Use Data Defined by Strip','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','Tag','strip_mask_check','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],....
    'value',status_flags.analysis_modules.radial_average.strip_mask_chk,....
    'callback','radial_average_callbacks(''strip_mask_chk'');');

% %Use Ellipse Mask.
% uicontrol(handle,'units','normalized','Position',[0.25 0.29 0.5 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text','String','Use Ellipse Mask:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
% grasp_handles.window_modules.radial_average.ellipse_mask_chk = uicontrol(handle,'units','normalized','Position',[0.9 0.29 0.068 0.06],'tooltip','Use Data Defined by Ellipse','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','Tag','ellipse_mask_check','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],....
%     'value',status_flags.analysis_modules.radial_average.ellipse_mask_chk,....
%     'callback','radial_average_callbacks(''ellipse_mask_chk'');');

%Single, Depth or TOF
uicontrol(handle,'units','normalized','position',[0.1 0.35 0.5 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Single     Depth     TOF','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1]);
grasp_handles.window_modules.radial_average.radio_single = uicontrol(handle,'units','normalized','position',[0.15 0.30 0.08 0.03],'tooltip','Average Current Worksheet : Number : Depth Only','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','radiobutton','Tag','rad_av_single_depth','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],....
    'callback','radial_average_callbacks(''single_radio'');');
grasp_handles.window_modules.radial_average.radio_depth = uicontrol(handle,'units','normalized','position',[0.3 0.30 0.08 0.03],'tooltip','Average Entire Depth of Current Worksheet : Number','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','radiobutton','Tag','rad_av_single_depth','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],....
    'callback','radial_average_callbacks(''depth_radio'');');
grasp_handles.window_modules.radial_average.radio_tof = uicontrol(handle,'units','normalized','position',[0.45 0.30 0.08 0.03],'tooltip','Average Entire Depth of Current Worksheet : Number','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','radiobutton','Tag','rad_av_single_depth','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],....
    'callback','radial_average_callbacks(''tof_radio'');');

%Direct to File
grasp_handles.window_modules.radial_average.direct_to_file_check = uicontrol(handle,'units','normalized','Position',[0.05 0.21 0.7 0.06],'tooltip','Output Averaging Direct to File','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],'visible','on',....
    'String','Direct to File:','value',status_flags.analysis_modules.radial_average.direct_to_file,'callback','radial_average_callbacks(''direct_to_file_check'');');

%Post-Average Statistics Filter
grasp_handles.window_modules.radial_average.post_av_stats_chk = uicontrol(handle,'units','normalized','Position',[0.05,0.05,0.7,0.06],'tooltip','Post Averaging Stats Filter','FontName',grasp_env.font,'FontSize',grasp_env.fontsize, 'Style','checkbox','String','Post-Av Stats Filter dI/I   >','HorizontalAlignment','left','Tag','post_average_stats_check','Visible','on','value',status_flags.analysis_modules.averaging_filters.post_av_stats_chk,'BackgroundColor', grasp_env.background_color,'ForegroundColor', [1 1 1],'callback','radial_average_callbacks(''post_av_stats_chk'');');
grasp_handles.window_modules.radial_average.post_av_stats = uicontrol(handle,'units','normalized','Position',[0.8,0.05,0.16,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.analysis_modules.averaging_filters.post_av_stats_threshold),'HorizontalAlignment','left','Visible','on','userdata','','CallBack','radial_average_callbacks(''post_av_stats_threshold'');');

%Pre-Average Resolution Filter dq/q

grasp_handles.window_modules.radial_average.pre_av_res_chk = uicontrol(handle,'units','normalized','Position',[0.05,0.13,0.7,0.06],'tooltip','Pre Averaging Resolution Filter','FontName',grasp_env.font,'FontSize',grasp_env.fontsize, 'Style','checkbox','String','Pre-Av Resolution Filter dq/q   >','HorizontalAlignment','left','Tag','pre_average_res_check','Visible','on','value',status_flags.analysis_modules.averaging_filters.pre_av_res_chk,'BackgroundColor', grasp_env.background_color,'ForegroundColor', [1 1 1],'callback','radial_average_callbacks(''pre_av_res_chk'');');
grasp_handles.window_modules.radial_average.pre_av_res = uicontrol(handle,'units','normalized','Position',[0.8,0.13,0.16,0.06],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.analysis_modules.averaging_filters.pre_av_res_threshold),'HorizontalAlignment','left','Visible','on','userdata','','CallBack','radial_average_callbacks(''pre_av_res_threshold'');');







% %Averaging filters window
% uicontrol(handle,'units','normalized','Position',[0.25 0.05 0.5 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text','String','Averaging Filters:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
% grasp_handles.window_modules.radial_average.averaging_filters_chk = uicontrol(handle,'units','normalized','Position',[0.9 0.05 0.068 0.06],'tooltip','Use Averaging Filters','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','Tag','averaging_filters_check','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],....
%     'value',status_flags.analysis_modules.radial_average.averaging_filters_chk,....
%     'callback','radial_average_callbacks(''averaging_filters_chk'');');








% %Depth TOF Combine
% if status_flags.analysis_modules.radial_average.single_depth_radio == 0; visible = 'off'; else visible = 'on'; end
% grasp_handles.window_modules.radial_average.depth_combine_text = uicontrol(handle,'units','normalized','Position',[0.35 0.15 0.53 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text','String','Depth (eg. TOF) Rebin:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1],'visible',visible);
% grasp_handles.window_modules.radial_average.depth_combine_check = uicontrol(handle,'units','normalized','Position',[0.90 0.15 0.068 0.05],'tooltip','Combine TOF Data to Single I vs. Q Curve','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],'visible','on',....
%     'value',status_flags.analysis_modules.radial_average.d33_tof_combine,'callback','radial_average_callbacks(''d33_tof_combine_check'');','visible',visible);
% %set(grasp_handles.window_modules.radial_average.depth_combine_check,'enable','off');

%%Frame Start & End
%if status_flags.analysis_modules.radial_average.single_depth_radio == 0; visible = 'off'; else visible = 'on'; end
%grasp_handles.window_modules.radial_average.frame_startend_text = uicontrol(handle,'units','normalized','position',[0.1 0.07 0.4 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','left','Style','text','String','Frame Start & End','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],'visible',visible);
%grasp_handles.window_modules.radial_average.frame_start = uicontrol(handle,'units','normalized','Position',[0.5 0.07 0.16 0.06],'tooltip','Depth Frame # Stat','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.analysis_modules.radial_average.depth_frame_start),'HorizontalAlignment','center','Visible',visible,'callback','radial_average_callbacks(''depth_frame_start'');');
%grasp_handles.window_modules.radial_average.frame_end = uicontrol(handle,'units','normalized','Position',[0.7 0.07 0.16 0.06],'tooltip','Depth Frame # End','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','String',num2str(status_flags.analysis_modules.radial_average.depth_frame_end),'HorizontalAlignment','center','Visible',visible,'callback','radial_average_callbacks(''depth_frame_end'');');

% %New TOF rebin
% uicontrol(handle,'units','normalized','Position',[0.63 0.01 0.25 0.05],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text','String','New TOF rebin:','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
% grasp_handles.window_modules.radial_average.new_tof_rebin_check = uicontrol(handle,'units','normalized','Position',[0.90 0.01 0.068 0.05],'tooltip','New TOF rebin','FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1,1,1],'visible','on',....
%     'value',status_flags.analysis_modules.radial_average.direct_to_file,'callback','radial_average_callbacks(''tof_iq'');');


%Refresh the window
radial_average_callbacks;
