function grasp_plot2(plot_data,option)

%June2017:  'grasp_plot2' - an updated grasp plot for grasp.
%Now takes only a structured argument
%e.g.
%plot_data.plot_data [x, y, e, y, e ...etc]
%plot_data.column_format [xyeye]
%etc.
%Also allows plot_data to be a structure n-deep
%e.g.
%plot_data(1).plot_data
%plot_data(1).column_format
%plot_data(1).resolution_kernels
%plot_data(2).plot_data
%plot_data(2).column_format
%plot_data(2).resolution_kernels
%
%etc. so that many independent curves, e.g. TOF IQ wavelength overlap plot
%can be called at one time and not incrementally added (slow) as in the
%old grasp_plot

%***** Check for basic xy data coming in, as for plot command *****
%Convert to grasp_plot2 structure
if not(isstruct(plot_data))
    temp = plot_data;
    clear('plot_data');
    plot_data.plot_data(:,:) = [temp',option'];
end

%***** Copy parameters from Grasp_env or use new defaults *****
global grasp_env
font = grasp_env.font; fontsize = grasp_env.fontsize;
background_color = grasp_env.sub_figure_background_color;

%***** Copy parameters from status_flags or use new defaults *****
global status_flags
linestyle = status_flags.display.linestyle; linewidth = status_flags.display.linewidth; markersize = status_flags.display.markersize;

%Add some default fields to the plot_data if they don't exist already
number_plots = length(plot_data);
if not(isfield(plot_data,'plot_type')); for n = 1:number_plots; plot_data(n).plot_type = 'plot'; end; end
if not(isfield(plot_data,'plot_title')); for n = 1:number_plots; plot_data(n).plot_title = 'No Title'; end; end
if not(isfield(plot_data,'x_label')); for n = 1:number_plots; plot_data(n).x_label = 'x-axis'; end; end
if not(isfield(plot_data,'y_label')); for n = 1:number_plots; plot_data(n).y_label = 'y-axis'; end; end
if not(isfield(plot_data,'hold_graph')); for n = 1:number_plots; plot_data(n).hold_graph = 0; end; end
if not(isfield(plot_data,'legend_str')); for n = 1:number_plots; plot_data(n).legend_str = 'No Legend'; end; end
if not(isfield(plot_data,'export_data')); for n = 1:number_plots; plot_data(n).export_data = plot_data(n).plot_data; end; end
if not(isfield(plot_data,'column_format')); for n = 1:number_plots; plot_data(n).column_format = ['xy']; end; end

%***** Plot Variables *****
colors = ['w' 'r' 'c' 'm' 'y' 'g' 'b' 'w' 'y' 'm' 'c' 'r' 'g' 'b'];
symbols = ['o' 'x' '+' '*' '.' 's' 'd' 'v' '^' '<' '>' 'p' 'h' '.' 'o' 'x' '+' '*' 's' 'd' 'v' '^' '<' '>' 'p' 'h'];
number_previous_curves = 0; %for incremental colours and symbols in overplotting mode


%***** Check to see if we are over-plotting in an existing window or opening a new plot window *****
new_plot_flag = 1; %i.e. the default is to open a new plot
double_y_flag = 0; %Default(0) is single y-axis, (1) add a double-y axis


%Check if XtraPlot is trying to overplot any other grasp_plot
i = findobj('name',plot_data(1).plot_title); %See if there is an existing plot with the same title

if strcmp(plot_data(1).plot_title,'XtraPlot') %Check if this is an XtraPlot coming in
    %See if there is an XtraPlot already with hold status
    if not(isempty(i)) %An XtraPlot already exists...use this if hold is on
        grasp_plot_handles = get(i(1),'userdata');
        if strcmpi(grasp_plot_handles.hold_status,'on')
            new_plot_flag = 0; %i.e. there is a plot of the same type on hold so add to it
            figure(i(1)); %Make over plotting figure the current one
            
        else
            %Then find ANY grasp_plot with a hold status on and take the latest
            j = findobj('tag','grasp_plot');  %See if ANY plot exists to over plot with XrtraPlot
            if not(isempty(j)) %i.e. at least one exists
                grasp_plot_handles = get(j(1),'userdata');
                if strcmpi(grasp_plot_handles.hold_status,'on')
                    new_plot_flag = 0; %i.e. there is a plot to overplot with a double-y axis
                    double_y_flag = 1; %i.e. generate a second y-axis when plotting below
                    figure(j(1)); %Make over plotting figure the current one
                else
                    new_plot_flag = 1; %i.e. not a plot of the same type on hold so open a new plot
                end
            end
        end
    else
        %Then find ANY grasp_plot with a hold status on and take the latest
        j = findobj('tag','grasp_plot');  %See if ANY plot exists to over plot with XrtraPlot
        if not(isempty(j)) %i.e. at least one exists
            grasp_plot_handles = get(j(1),'userdata');
            if strcmpi(grasp_plot_handles.hold_status,'on')
                new_plot_flag = 0; %i.e. there is a plot to overplot with a double-y axis
                double_y_flag = 1; %i.e. generate a second y-axis when plotting below
                figure(j(1)); %Make over plotting figure the current one
            else
                new_plot_flag = 1; %i.e. not a plot of the same type on hold so open a new plot
            end
        end
    end
elseif not(isempty(i)) %i.e. at least one exists
    grasp_plot_handles = get(i(1),'userdata');
    if strcmpi(grasp_plot_handles.hold_status,'on')
        new_plot_flag = 0; %i.e. there is a plot of the same type on hold so add to it
        figure(i(1)); %Make over plotting figure the current one
    else
        new_plot_flag = 1; %i.e. not a plot of the same type on hold so open a new plot
    end
end






%***** Open New Figure Window if required *****
if new_plot_flag ==1
    
    %Check How Many Output Windows are Already Open! - Too many crash the computer
    i = findobj('tag','grasp_plot');
    if length(i) >10
        i = warndlg('Please Close Some Grasp_Plot Windows!','Warning: Matlab Memory');
        set(i,'tag','plot_warn');
        drawnow;
        while not(isempty(i))
            i = findobj('tag','plot_warn');
            drawnow;
        end
    end
    
    
    %Open New Figure
    colordef none; %Window background
    
    try
        fig_position = grasp_env.screen.grasp_plot_default_position.*grasp_env.screen.screen_scaling;
    catch
        fig_position = [0.53, 0.48, 0.41, 0.44];
    end
    
    fig_units = 'normalized';
    
    grasp_plot_handles = [];
    grasp_plot_handles.figure = figure(....
        'units',fig_units,....
        'Position',fig_position,....
        'Name',plot_data(1).plot_title,....
        'NumberTitle', 'off',....
        'Tag','grasp_plot',....
        'color',background_color,....
        'papertype','A4',....
        'paperunits','centimeters',....
        'paperorientation','landscape',....
        'resize','on',....
        'menubar','none',....
        'toolbar','none',....
        'inverthardcopy','on',....
        'windowbuttondownfcn','grasp_plot_callbacks(''button_down'');');
    
    %'paperposition',[2 8 15 11.25],....
    
    %Modify Grasp_Plot Menu Items
    grasp_plot_handles = modify_grasp_plot_menu(grasp_plot_handles);
    %Modify Grasp_Plot Tool Items
    grasp_plot_handles = modify_grasp_plot_toolbar(grasp_plot_handles);
    drawnow; %Let the figure window finnish displaying
    
    
    %Hold Graph Checkbox - when ticked and another graph is requested it plots into the last figure.
    if strcmpi(plot_data(1).hold_graph,'on'); hold_status = 1; else hold_status = 0; end
    grasp_plot_handles.hold_status = plot_data(1).hold_graph;
    grasp_plot_handles.hold_check = uicontrol(grasp_plot_handles.figure,'units','normalized','Position',[0.9,0.93,0.1,0.06],'ToolTip',['Hold Graph: Yes(checked) / No(un-checked)' char(13) 'Next Results Output will plot in this Figure.'],...
        'FontName',font,'FontSize',fontsize,'Style','checkbox','String','Hold!','HorizontalAlignment','left','value',hold_status,'backgroundcolor',background_color,'foregroundcolor',[1 1 1],'callback','grasp_plot_callbacks(''hold_toggle'')');
    %Log and Lin Dropdown list
    %y_list_string = {'y','log10(y)','ln(y)', 'y^2', 'y^4', 'y^n', 'y*x'};
    y_list_string = {'y','log10(y)'};
    grasp_plot_handles.yscale_list = uicontrol(grasp_plot_handles.figure,'units','normalized','Position',[0.025 0.92 0.09 0.05],'FontName',font,'FontSize',fontsize,'Style','Popup','String',y_list_string,'HorizontalAlignment','left','Tag','log_button_y','Visible','on',...
        'CallBack','grasp_plot_callbacks(''y_scale'');');
    x_list_string = {'x','log10(x)'};
    grasp_plot_handles.xscale_list = uicontrol(grasp_plot_handles.figure,'units','normalized','Position',[0.88 0.005 0.1 0.05],'FontName',font,'FontSize',fontsize,'Style','Popup','String',x_list_string,'HorizontalAlignment','left','Tag','log_button_x','Visible','on',...
        'CallBack','grasp_plot_callbacks(''x_scale'');');
    %Scaling Power Box
    grasp_plot_handles.yscale_edit = uicontrol(grasp_plot_handles.figure,'units','normalized','Position',[0.120 0.9 0.08 0.08],'FontName',font,'FontSize',fontsize,'Style','edit','String','1','HorizontalAlignment','left','Tag','yscaling_power_box','Visible','off',...
        'CallBack','grasp_plot_callbacks(''y_power_scale'');');
    grasp_plot_handles.xscale_edit = uicontrol(grasp_plot_handles.figure,'units','normalized','Position',[0.89 0.12 0.03 0.08],'FontName',font,'FontSize',fontsize,'Style','edit','String','1','HorizontalAlignment','left','Tag','xscaling_power_box','Visible','off',...
        'CallBack','grasp_plot_callbacks(''x_power_scale'');');
    
    %Make a dummy graph axes
    curve_handles = []; %Store this in the axis userdata and add to it as curves are drawn
    grasp_plot_handles.axis = axes('Position',[0.1 0.1 0.75 0.8],'tag','results_axes','box','on','FontName',font,'FontSize',fontsize,'Layer','Top','TickDir','in','userdata',curve_handles);
    %set(grasp_plot_handles.axis,'YColor','black','Xcolor','black')
    
    
    %Store all the new handles in the figure's userdata
    set(grasp_plot_handles.figure,'userdata',grasp_plot_handles);
    
end



%***** Loop though the plot_data structure - i.e. number of individual plot_data's , remember, might be multiple curves within each plot_data *****
for plot_data_number = 1:number_plots
    
    %Find number of previous curves from previous plot_data or previous plotting instances
    if ishandle(grasp_plot_handles.axis)
        curve_handles = get(grasp_plot_handles.axis,'userdata'); number_previous_curves = length(curve_handles);
    end
    
    %Add a second y-axis if XtraPlot is being overplotted on other data
    if double_y_flag ==1 %Plot in a double y-axis
        yyaxis(grasp_plot_handles.axis,'left');
        set(grasp_plot_handles.axis,'YColor','white')
        yyaxis(grasp_plot_handles.axis,'right')
        set(grasp_plot_handles.axis,'YColor','white')
    end
    
    
    curve_number = 1; %Curves within each plot_data
    plotdata = plot_data(plot_data_number).plot_data;
    column_format = plot_data(plot_data_number).column_format;
    plot_info = plot_data(plot_data_number);
    
    plot_info = rmfield(plot_info,'plot_data'); %Remove plot_data so next curve plotted gets new data stored in plot_data
    %Parse the column_format string
    xdata = []; ydata = []; hdata = []; edata = [];
    for col_pointer = 1:length(column_format)
        if strcmp(column_format(col_pointer),'x')  %New x-column
            xdata = plotdata(:,col_pointer);
        elseif strcmp(column_format(col_pointer),'y')
            ydata = plotdata(:,col_pointer);
            %Check if X error data is coming also
            if col_pointer < length(column_format)
                if strcmp(column_format(col_pointer+1),'h')
                    hdata = plotdata(:,col_pointer+1);
                    col_pointer = col_pointer +1;
                else
                    hdata = [];
                end
            end
            %Check if Y error data is coming also
            if col_pointer < length(column_format)
                if strcmp(column_format(col_pointer+1),'e')
                    edata = plotdata(:,col_pointer+1);
                    col_pointer = col_pointer +1;
                else
                    edata = [];
                end
            end
            
            %***** Work out the next curve colour, symbol, line style and size *****
            total_curve_number = curve_number +number_previous_curves;
            curve_colour = curve_number +number_previous_curves;
            symbol_type = curve_number +number_previous_curves;
            while curve_colour > length(colors)
                curve_colour = curve_colour - length(colors);
            end
            while symbol_type > length(symbols)
                symbol_type = symbol_type - length(symbols);
            end
            
            %**************************************************************
            
            %Re-hash the stored plot_data in the structure - needed for curve fitting etc
            plot_info.plot_data.xdat = xdata;
            plot_info.plot_data.ydat = ydata;
            plot_info.plot_data.edat = edata;
            plot_info.plot_data.hdat = hdata;
            plot_info.curve_number = total_curve_number;

            if strcmp(plot_info.plot_type,'plot') || strcmp(plot_info.plot_type,'errorbar')
                
                %Plot the data as either plot or errorbar
                if isempty(edata) %Plot only
                    
                    set(grasp_plot_handles.axis,'nextplot','add') %Same as hold on
                    plot_handle = plot(grasp_plot_handles.axis,xdata,ydata);
                    set(plot_handle,'linestyle',linestyle,'linewidth',linewidth,'color',colors(curve_colour),'marker',symbols(symbol_type),'markersize',markersize);
                    
                    %Store curve handle in axis userdata
                    curve_handles = get(grasp_plot_handles.axis,'userdata');
                    curve_handles{length(curve_handles)+1} = plot_handle;
                    set(grasp_plot_handles.axis,'userdata',curve_handles);
                    
                    %Store the plot_info in the curve userdata
                    set(plot_handle,'userdata',plot_info);
                    
                    
                else %Errorbar plot
                    
                    linespec = [linestyle colors(curve_colour) symbols(symbol_type)]; %Plot line type specification
                    set(grasp_plot_handles.axis,'nextplot','add') %Same as hold on
                    
                    if isempty(hdata)  % No horizontal error bar data then use Matlab's errorbar plot
                        
                        figure(grasp_plot_handles.figure);
                        plot_handle = errorbar(grasp_plot_handles.axis,xdata,ydata,edata,linespec);
                        
                    else  %Use the one I found online 'ploterr'

                        figure(grasp_plot_handles.figure);
                        plot_handle = xyerrorbar(xdata,ydata,hdata,edata,linespec);
                    end
                    
                    %Store curve handle in axis userdata
                    curve_handles = get(grasp_plot_handles.axis,'userdata');
                    curve_handles{length(curve_handles)+1} = plot_handle;
                    set(grasp_plot_handles.axis,'userdata',curve_handles);
                    
                    %Store the plot_info in the curve userdata
                    set(plot_handle,'userdata',plot_info,'linewidth',linewidth,'markersize',markersize);
                end
                
                
            elseif strcmp(plot_info.plot_type,'bar')
                
                set(grasp_plot_handles.axis,'nextplot','add') %Same as hold on
                figure(grasp_plot_handles.figure);
                plot_handle = bar(grasp_plot_handles.figure,'xdata',xdata,'ydata',ydata,'linestyle',linestyle,'linewidth',linewidth);
                
                %Store curve handle in axis userdata
                curve_handles = get(grasp_plot_handles.axis,'userdata');
                curve_handles{length(curve_handles)+1} = plot_handle;
                set(grasp_plot_handles.axis,'userdata',curve_handles);
                
                %Store the plot_info in the curve userdata
                set(plot_handle,'userdata',plot_info);
            end
            
            curve_number = curve_number +1;
        end
    end
end


%Now add the titles to the graph
warning off
xlabel(grasp_plot_handles.axis,plot_info.x_label);
ylabel(grasp_plot_handles.axis,plot_info.y_label);
title(grasp_plot_handles.axis,plot_info.plot_title);
warning on
%end
%****************************************************************

%General update of the plot
grasp_plot_callbacks('build_curve_tools_menu',grasp_plot_handles);
grasp_plot_callbacks('update_legend',grasp_plot_handles);
grasp_plot_menu_callbacks; %General update of menu items

