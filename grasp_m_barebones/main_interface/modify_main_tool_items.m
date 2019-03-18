function modify_main_tool_items(figure_handle)

global grasp_handles

%******** TOOLBAR's ***********
set(figure_handle,'toolbar','figure'); %Turn on the button bar
set(0,'showhiddenhandles','on'); %Turn on hidden handles


%Delete the buttons we don't want.
%     'figToolAxis'
%     'Plottools.PlottoolsOn'
%     'Plottools.PlottoolsOff'
%     'Annotation.InsertLegend'
%     'DataManager.Linking'
%     'Exploration.Brushing'
%     'Exploration.DataCursor'
%     'Standard.NewFigure'
%     'figToolTitle'
%     'Annotation.InsertColorbar'
%     'figToolRender'
%     'figToolQaxes'
%     'figToolxylim'
%     'Exploration.Pan'
%     'Exploration.Rotate'
%     'figToolRescale'
%     'Exploration.ZoomOut'
%     'Exploration.ZoomIn'
%     'Standard.EditPlot'
%     'Standard.PrintFigure'
%     'Standard.SaveFigure'
%     'Standard.FileOpen'

% i = findobj(figure_handle,'tag','figToolAxis');delete(i);
i = findobj(figure_handle,'tag','Plottools.PlottoolsOn');delete(i);
i = findobj(figure_handle,'tag','Plottools.PlottoolsOff');delete(i);
i = findobj(figure_handle,'tag','Annotation.InsertLegend');delete(i);
i = findobj(figure_handle,'tag','DataManager.Linking');delete(i);
i = findobj(figure_handle,'tag','Exploration.Brushing');delete(i);
i = findobj(figure_handle,'tag','Exploration.DataCursor');delete(i);
i = findobj(figure_handle,'tag','Standard.NewFigure');delete(i);
% i = findobj(figure_handle,'tag','Exploration.Pan');delete(i);
i = findobj(figure_handle,'tag','Exploration.Rotate');delete(i);

% i = findobj(figure_handle,'tag','Exploration.ZoomOut');delete(i);
% i = findobj(figure_handle,'tag','Exploration.ZoomIn');delete(i);
% i = findobj(figure_handle,'tag','Standard.EditPlot');delete(i);
% i = findobj(figure_handle,'tag','Standard.PrintFigure');delete(i);
% i = findobj(figure_handle,'tag','Standard.SaveFigure');delete(i);
% i = findobj(figure_handle,'tag','Standard.FileOpen');delete(i);




%Modify colorbar tool
i = findobj(figure_handle,'tag','Annotation.InsertColorbar');
set(i,'clickedcallback','menu_callbacks(''show_color_bar'');');

%Modify Pan tool
%i = findobj(figure_handle,'tag','Exploration.Pan');

%3D Figure Rotate (modify existing tool)
grasp_handles.toolbar.rotate_3d = findobj(figure_handle,'tag','Exploration.Rotate');

%Open
grasp_handles.toolbar.fopen = findobj(figure_handle,'tag','Standard.FileOpen');
set(grasp_handles.toolbar.fopen,'clickedcallback','file_menu(''open'');','tooltipstring','Open Project');
%Save
grasp_handles.toolbar.fsave = findobj(figure_handle,'tag','Standard.SaveFigure');
set(grasp_handles.toolbar.fsave,'clickedcallback','file_menu(''save'');','tooltipstring','Save Project');
%Print
grasp_handles.toolbar.printfig = findobj(figure_handle,'tag','Standard.PrintFigure');
set(grasp_handles.toolbar.printfig,'clickedcallback','file_menu_image_export(''prn'');','tooltipstring','Quick-Print Image');

%**** Add aditional buttons to the toolbar menu.
%Rescale
icon = load('rescale');
grasp_handles.toolbar.rescale = uipushtool('tag','figToolRescale','CData',icon.icon,'ToolTipString','Rescale','ClickedCallback','tool_callbacks(''rescale'');');

%Title
icon = load('title');
grasp_handles.toolbar.title = uipushtool('tag','figToolTitle','CData',icon.icon,'ToolTipString','Title On/Off','ClickedCallback','menu_callbacks(''show_hide_title'');');

%Axis & Axis Box
icon = load('show_axes');
grasp_handles.toolbar.axis_axisbox = uipushtool('tag','figToolAxis','CData',icon.icon,'ToolTipString','Axis & Axis Box On/Off','ClickedCallback','menu_callbacks(''show_graph_axes'');menu_callbacks(''show_axis_box'');');


%Manual xylimits
icon = load('xylim');
grasp_handles.toolbar.xylims = uipushtool('tag','figToolxylim','CData',icon.icon,'separator','on','ToolTipString','Manual XY Limits','ClickedCallback','tool_callbacks(''manual_scale'');');
%q-Axes,Pixel-Axes,2theta-Axes
icon = load('q_axes');
grasp_handles.toolbar.qaxes = uipushtool('tag','figToolQaxes','CData',icon.icon,'ToolTipString','Pixel / q / 2-Theta Axes',...
    'ClickedCallback','tool_callbacks(''pixel_q_axes'');');
%Render
icon = load('render');
grasp_handles.toolbar.render = uipushtool('tag','figToolRender','CData',icon.icon,'ToolTipString','Toggle Plot Render',...
    'ClickedCallback','tool_callbacks(''toggle_image_render'');');

%set(0,'ShowHiddenHandles','off');

%Re-order tool items
tool_tags = {....
    'Standard.FileOpen',....
    'Standard.SaveFigure',....
    'Standard.PrintFigure',....
    'Standard.EditPlot',....
    'Exploration.ZoomIn',....
    'Exploration.ZoomOut',....
    'figToolRescale',....
    'Exploration.Pan',....
    'figToolxylim',....
    'figToolQaxes',....
    'figToolRender',....
    'figToolAxis',....
    'Annotation.InsertColorbar',....
    'figToolTitle',....
    };

for n = 1:length(tool_tags)
    handle = findobj(figure_handle,'tag',tool_tags{n});
    if ishandle(handle)
        uistack(handle,'top')
    else
        disp(['No handle for ' tool_tags{n}])
    end
end

    
    
    
    
    
