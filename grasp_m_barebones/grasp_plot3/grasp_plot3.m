function grasp_plot3(varargin)

%GRASP_PLOT3:   -  Chuck's general graph plotting & tools
%
%Usage:   grasp_plot3(x,y...,'property1','value1','property2','value2')
%
%e.g. grasp_plot3(x,y)       - xy plot using default parameters
%e.g. grasp_plot3(x,y1,y2..) - xy1, xy2, ... plot using default parameters
%e.g. grasp_plot3(x,y,e,'columnformat','xye')     - xye error bar plot.  xy plot with +-e error bars
%
%
%Properties:
%Some grasp_plot3 properties are 'persistent' - i.e. once changed remain
%until specified again.  Other properties are non-persisten and are
%refreshed to defaults upon every call unless specified
%
%All properties can be refreshed to defaults
%e.g. grasp_plot3('default')
%e.g. grasp_plot3('default',x,y,....)
%
%
%Non-persistent properties
%
%'plottype', 'plot'         %Options: 'plot', 'errorbar', 'bar'
%'yaxis', 'left'            %Options: 'left', 'right'
%'columnformat', 'x,y,e'    %x = x-axis, y = y-yaxis, e = +-e-errorbar, t = time/date-x-axis
%'xlabel', 'x-axis'         %x-axis label
%'ylabel', 'y-axis'         %y-axis label
%'title', 'Plot Title'                  %Plot title
%'hold', 'off'              %Options: 'on', 'off' - hold status for graph window
%'legend', [{'Curve1'},{'Curve2'}   %Curve legends - must be cell array
%'color', 'w'               %Draw curves in specified colour, e.g. 'w','r','b' etc.
%'symbol', '.'              %Draw curves with specified symbol, e.g. '.','o','x'
%'linestyle', ':'           %Line style, e.g. ':','-','--' etc.
%'grid','on';               %Axis grid on/off
%'axlim','off';             %Show Axis Limits
%'yscale','lin';            %lin or log
%'xscale','lin';            %lin or log
%'xlims','auto';            %auto or specify values [xmin, xmax];
%'ylims','auto';            %auto or speficy values [ymin, ymax];
%
%
%Persistent properties
%
%'positon', [0.53, 0.48, 0.41, 0.44]    %Figure position on the screen
%'units', 'normalized'                  %Figure position units (e.g. 'normalized', 'pixels')
%'backgroundcolor', [0.05,0.1,0.3]      %Figure background colour [r,g,b]
%'font', 'Arial'                        %Font used for all figure text
%'fontsize', 10                         %Fontsize used for all figure text
%'linewidth', 1                         %Curve line width
%'markersize', 2                        %Curve point marker size
%'colors', ['w' 'r' 'c' 'm' ...]        %Sequence of colours to cycle though
%'symbols', ['o' 'x' '+' '*'....]       %Sequence of symbols to cycle though
%'exportdir', ['/chuck/Desktop/']       %Default save director for export figures and data
%
%
%

if nargin <1; help grasp_plot3; return; end

global graspplot
global graspplot_handles

%Initialise some persistent defaults
if isempty(graspplot) || strcmpi(varargin{1},'default')
    graspplot.position = [0.53, 0.48, 0.41, 0.44];
    graspplot.units = 'normalized';
    graspplot.backgroundcolor = [0.05,0.1,0.3];
    graspplot.font = 'Arial';
    graspplot.fontsize = 13;
    graspplot.linewidth = 1;
    graspplot.markersize = 4;
    graspplot.colors = ['w' 'r' 'c' 'm' 'y' 'g' 'b' 'w' 'y' 'm' 'c' 'r' 'g' 'b'];
    graspplot.symbols = ['o' 'x' '+' '*' '.' 's' 'd' 'v' '^' '<' '>' 'p' 'h' '.' 'o' 'x' '+' '*' 's' 'd' 'v' '^' '<' '>' 'p' 'h'];
    graspplot.exportdir = ['~' filesep];
    graspplot.fitter.fn1d = 1;
    graspplot.fitter.number1d = 1;
    graspplot.fitter.simultaneous_check = 0;
    graspplot.fitter.include_res_check =0;
    graspplot.fitter.delete_curves_check = 0;
end

%Refreshed defaults everything grasp_plot3 is called
graspplot.plottype = 'plot';
graspplot.yaxis = 'left';
graspplot.columnformat = 'xy';
graspplot.xlabel = 'x-axis';
graspplot.ylabel = 'y-axis';
graspplot.title = 'No Title';
graspplot.hold = 'off';
graspplot.legend = [{'No legend'}];
graspplot.color = [];
graspplot.symbol = [];
graspplot.linestyle = ':';
graspplot.grid = 'off';
graspplot.axlim = 'off';
graspplot.yscale = 'lin';
graspplot.xscale = 'lin';
graspplot.xlims = 'auto';
graspplot.ylims = 'auto';



if strcmpi(varargin{1} ,'default')
    if length(varargin) ==1
        return
    else
        varargin = varargin(2:end);
    end
end

%Check for user modified parameters
params = fieldnames(graspplot);
for n = 1:length(params)
    %Check for and overwrite if found graspplot parameter
    idx=find(cellfun(@(varargin) any(strcmpi(varargin,params{n})),varargin));
    if not(isempty(idx))
        graspplot.(params{n}) = varargin{idx+1};
    end
end

%Find the numeric data to plot as the first of the arguments in
numeric_columns = 0;
plotdata = [];x_counter = 0; y_counter = 0; e_counter = 0; h_counter = 0; t_counter = 0; column_format =[];
for n = 1:length(varargin)
    if isnumeric(varargin{n})
        numeric_columns = numeric_columns + 1;
        if n<= length(graspplot.columnformat)
            column= graspplot.columnformat(n);
        else
            column = graspplot.columnformat(length(graspplot.columnformat));
        end
        column_format = [column_format, column];
        if strcmpi(column,'x')
            x_counter = x_counter + 1;
            plotdata.([column num2str(x_counter)]) = varargin{n};
        end
        if strcmpi(column,'t')
            t_counter = t_counter + 1;
            plotdata.([column num2str(t_counter)]) = varargin{n};
        end
        if strcmpi(column,'y')
            y_counter = y_counter + 1;
            plotdata.([column num2str(y_counter)]) = varargin{n};
        end
        if strcmpi(column,'e')
            e_counter = e_counter + 1;
            plotdata.([column num2str(e_counter)]) = varargin{n};
        end
        if strcmpi(column,'h')
            h_counter = h_counter + 1;
            plotdata.([column num2str(h_counter)]) = varargin{n};
        end
    else
        break
    end
end


%***** Check to see if we are over-plotting in an existing window or opening a new plot window *****
new_plot_flag = 1; %i.e. the default is to open a new plot
%See if there is an existing plot with the same title
i = findobj('name',['Grasp Plot3:  ' graspplot.title]);
if not(isempty(i)) %i.e. at least one exists
    graspplot_handles = get(i(1),'userdata');
    if strcmpi(graspplot_handles.hold_status,'on')
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
    graspplot_handles.figure = figure(....
        'units',graspplot.units,....
        'Position',graspplot.position,....
        'Name',['Grasp Plot3:  ' graspplot.title],....
        'NumberTitle', 'off',....
        'Tag','grasp_plot',....
        'color',graspplot.backgroundcolor,....
        'papertype','A4',....
        'paperunits','centimeters',....
        'paperorientation','landscape',....
        'resize','on',....
        'menubar','none',....
        'toolbar','none',....
        'inverthardcopy','on',....
        'windowbuttondownfcn','grasp_plot3_callbacks(''button_down'');');
    
    %Modify Grasp_Plot Menu Items
    graspplot_handles = modify_grasp_plot3_menu(graspplot_handles);
    %Modify Grasp_Plot Tool Items
    graspplot_handles = modify_grasp_plot3_toolbar(graspplot_handles);
    drawnow; %Let the figure window finnish displaying
    
    %Hold Graph Checkbox - when ticked and another graph is requested it plots into the last figure.
    if strcmpi(graspplot.hold,'on'); hold_status = 1; else, hold_status = 0; end
    graspplot_handles.hold_status = graspplot.hold;
    graspplot_handles.hold_check = uicontrol(graspplot_handles.figure,'units','normalized','Position',[0.9,0.93,0.1,0.06],'ToolTip',['Hold Graph: Yes(checked) / No(un-checked)' char(13) 'Next Results Output will plot in this Figure.'],...
        'FontName',graspplot.font,'FontSize',graspplot.fontsize,'Style','checkbox','String','Hold','HorizontalAlignment','left','value',hold_status,'backgroundcolor',graspplot.backgroundcolor,'foregroundcolor',[1 1 1],'callback','grasp_plot3_callbacks(''hold_toggle'')');
    if strcmpi(graspplot.axlim,'on'); ax_check = 1; else, ax_check = 0; end
    graspplot_handles.show_ax_lims_check = uicontrol(graspplot_handles.figure,'units','normalized','Position',[0.9,0.88,0.1,0.06],'ToolTip',['Show/Hide Axis Limits'],...
        'FontName',graspplot.font,'FontSize',graspplot.fontsize,'Style','checkbox','String','Axis Limits','HorizontalAlignment','left','value',ax_check,'backgroundcolor',graspplot.backgroundcolor,'foregroundcolor',[1 1 1],'callback','grasp_plot3_callbacks(''ax_lim_check'')');
   

    
    graspplot_handles.ymax = uicontrol(graspplot_handles.figure,'units','normalized','Position',[0.02,0.86,0.05,0.04],'ToolTip',['ymax'],...
    'FontName',graspplot.font,'FontSize',graspplot.fontsize,'Style','edit','String','','HorizontalAlignment','left','backgroundcolor',[1,1,1],'foregroundcolor',graspplot.backgroundcolor,'callback','grasp_plot3_callbacks(''ymax'')');
    graspplot_handles.ymin = uicontrol(graspplot_handles.figure,'units','normalized','Position',[0.02,0.1,0.05,0.04],'ToolTip',['ymax'],...
    'FontName',graspplot.font,'FontSize',graspplot.fontsize,'Style','edit','String','','HorizontalAlignment','left','backgroundcolor',[1,1,1],'foregroundcolor',graspplot.backgroundcolor,'callback','grasp_plot3_callbacks(''ymin'')');
    graspplot_handles.xmax = uicontrol(graspplot_handles.figure,'units','normalized','Position',[0.8,0.005,0.05,0.04],'ToolTip',['ymax'],...
    'FontName',graspplot.font,'FontSize',graspplot.fontsize,'Style','edit','String','','HorizontalAlignment','left','backgroundcolor',[1,1,1],'foregroundcolor',graspplot.backgroundcolor,'callback','grasp_plot3_callbacks(''xmax'')');
    graspplot_handles.xmin = uicontrol(graspplot_handles.figure,'units','normalized','Position',[0.1,0.005,0.05,0.04],'ToolTip',['ymax'],...
    'FontName',graspplot.font,'FontSize',graspplot.fontsize,'Style','edit','String','','HorizontalAlignment','left','backgroundcolor',[1,1,1],'foregroundcolor',graspplot.backgroundcolor,'callback','grasp_plot3_callbacks(''xmin'')');


    %Log and Lin Dropdown list
    %y_list_string = {'y','log10(y)','ln(y)', 'y^2', 'y^4', 'y^n', 'y*x'};
    y_list_string = {'y','log10(y)'};
    graspplot_handles.yscale_list = uicontrol(graspplot_handles.figure,'units','normalized','Position',[0.025 0.92 0.09 0.05],'FontName',graspplot.font,'FontSize',graspplot.fontsize,'Style','Popup','String',y_list_string,'HorizontalAlignment','left','Tag','log_button_y','Visible','on',...
        'CallBack','grasp_plot3_callbacks(''y_scale'');');
    x_list_string = {'x','log10(x)'};
    graspplot_handles.xscale_list = uicontrol(graspplot_handles.figure,'units','normalized','Position',[0.88 0.005 0.1 0.05],'FontName',graspplot.font,'FontSize',graspplot.fontsize,'Style','Popup','String',x_list_string,'HorizontalAlignment','left','Tag','log_button_x','Visible','on',...
        'CallBack','grasp_plot3_callbacks(''x_scale'');');
%     %Scaling Power Box
%     graspplot_handles.yscale_edit = uicontrol(graspplot_handles.figure,'units','normalized','Position',[0.120 0.9 0.08 0.08],'FontName',graspplot.font,'FontSize',graspplot.fontsize,'Style','edit','String','1','HorizontalAlignment','left','Tag','yscaling_power_box','Visible','off',...
%         'CallBack','grasp_plot3_callbacks(''y_power_scale'');');
%     graspplot_handles.xscale_edit = uicontrol(graspplot_handles.figure,'units','normalized','Position',[0.89 0.12 0.03 0.08],'FontName',graspplot.font,'FontSize',graspplot.fontsize,'Style','edit','String','1','HorizontalAlignment','left','Tag','xscaling_power_box','Visible','off',...
%         'CallBack','grasp_plot3_callbacks(''x_power_scale'');');
    %Make a dummy graph axes
    curve_handles = []; %Store this in the axis userdata and add to it as curves are drawn
    graspplot_handles.axis = axes('Position',[0.1 0.1 0.75 0.8],'tag','results_axes','box','on','FontName',graspplot.font,'FontSize',graspplot.fontsize,'Layer','Top','TickDir','in','userdata',curve_handles);
    
    %Store all the new handles in the figure's userdata
    set(graspplot_handles.figure,'userdata',graspplot_handles);
end

%Find number of previous curves from previous plot_data or previous plotting instances
if ishandle(graspplot_handles.axis)
    curve_handles = get(graspplot_handles.axis,'userdata');
    number_previous_curves = length(curve_handles);
end

%Check if plotting on the left or right axis
if strcmpi(graspplot.yaxis,'right')
    yyaxis(graspplot_handles.axis,'left');
    set(graspplot_handles.axis,'YColor','white');
    yyaxis(graspplot_handles.axis,'right');
    set(graspplot_handles.axis,'YColor','white');
    temp = get(graspplot_handles.axis,'YLabel');
    set(temp,'Rotation',270);
else
    %test to see if a right axis already exists
    temp = get(graspplot_handles.axis,'yaxis');
    if size(temp,1) == 2 %then right axis already exists else do nothing as default should already be left
        yyaxis('left'); %switch back to left
    end
end

%Parse the column_format string
curve_number = 1; %Curves within each plot_data
time_x = 'off';
x_counter = 1; y_counter = 1; e_counter = 1; h_counter = 1; t_counter = 1;
for col_pointer = 1:length(column_format)
    if strcmpi(column_format(col_pointer),'x') || strcmpi(column_format(col_pointer),'t') %New x-column
        if strcmp(column_format(col_pointer),'x')
            xdata = plotdata.(['x' num2str(x_counter)]);
            x_counter = x_counter+1;
        elseif strcmp(column_format(col_pointer),'t')
            xdata = plotdata.(['t' num2str(t_counter)]);
            t_counter = t_counter+1;
            time_x = 'on';
        end
        
    elseif strcmpi(column_format(col_pointer),'y')
        ydata = plotdata.(['y' num2str(y_counter)]);
        y_counter = y_counter+1;
        %Check if X error data is coming also (h)
        hdata = [];
        if col_pointer < length(column_format)
            if strcmpi(column_format(col_pointer+1),'h')
                hdata = plotdata.(['h' num2str(h_counter)]);
                h_counter = h_counter +1;
                col_pointer = col_pointer +1;
            end
        end
        %Check if Y error data is coming also (e)
        edata = [];
        if col_pointer < length(column_format)
            if strcmpi(column_format(col_pointer+1),'e')
                edata = plotdata.(['e' num2str(e_counter)]);
                e_counter = e_counter +1;
                col_pointer = col_pointer +1;
            end
        end
        
        %***** Work out the next curve colour, symbol, line style and size *****
        total_curve_number = curve_number +number_previous_curves;
        curve_colour = curve_number +number_previous_curves;
        symbol_type = curve_number +number_previous_curves;
        while curve_colour > length(graspplot.colors)
            curve_colour = curve_colour - length(graspplot.colors);
        end
        while symbol_type > length(graspplot.symbols)
            symbol_type = symbol_type - length(graspplot.symbols);
        end
        %override colour if specifically defined
        if not(isempty(graspplot.color))
            line_color = graspplot.color;
        else
            line_color = graspplot.colors(curve_colour);
        end
        %override symbol if specifically defined
        if not(isempty(graspplot.symbol))
            line_symbol = graspplot.symbol;
        else
            line_symbol = graspplot.symbols(symbol_type);
        end
        
        
        %**************************************************************
        
        %Re-hash the stored plot_data in the structure - needed for curve fitting etc
        plot_info.plot_data.xdat = xdata; plot_info.plot_data.ydat = ydata;
        plot_info.plot_data.edat = edata; plot_info.plot_data.hdat = hdata;
        plot_info.curve_number = total_curve_number;
        if curve_number<= length(graspplot.legend)
            plot_info.legend_str = graspplot.legend{curve_number};
        else
            plot_info.legend_str = graspplot.legend{end};
        end
        plot_info.plot_title = graspplot.title;
        plot_info.xlabel = graspplot.xlabel;
        plot_info.ylabel = graspplot.ylabel;
        
        
        if strcmpi(graspplot.plottype,'plot') || strcmpi(graspplot.plottype,'errorbar')
            linespec = [graspplot.linestyle line_color line_symbol]; %Plot line type specification

            %Plot the data as either plot or errorbar
            if isempty(edata) %Plot only
                set(graspplot_handles.axis,'nextplot','add') %Same as hold on
                plot_handle = plot(graspplot_handles.axis,xdata,ydata,linespec);
                
                %Store curve handle in axis userdata
                curve_handles = get(graspplot_handles.axis,'userdata');
                curve_handles{length(curve_handles)+1} = plot_handle;
                set(graspplot_handles.axis,'userdata',curve_handles);
                
                %Store the plot_info in the curve userdata
                set(plot_handle,'userdata',plot_info,'linewidth',graspplot.linewidth,'markersize',graspplot.markersize);
                
            else %Errorbar plot
                set(graspplot_handles.axis,'nextplot','add') %Same as hold on
                
                if isempty(hdata)  % No horizontal error bar data then use Matlab's errorbar plot
                    figure(graspplot_handles.figure);
                    plot_handle = errorbar(graspplot_handles.axis,xdata,ydata,edata,linespec);
                    
                else  %Use the one I found online 'ploterr' or 'xyerrorbar'
                    figure(graspplot_handles.figure);
                    %plot_handle = xyerrorbar(xdata,ydata,hdata,edata,linespec);
                    plot_handle = ploterr(xdata,ydata,hdata,edata,linespec);
                end
                
                %Store curve handle in axis userdata
                curve_handles = get(graspplot_handles.axis,'userdata');
                curve_handles{length(curve_handles)+1} = plot_handle;
                set(graspplot_handles.axis,'userdata',curve_handles);
                
                %Store the plot_info in the curve userdata
                set(plot_handle,'userdata',plot_info,'linewidth',graspplot.linewidth,'markersize',graspplot.markersize);
            end
            
        elseif strcmpi(graspplot.plottype,'bar')
            set(graspplot_handles.axis,'nextplot','add') %Same as hold on
            figure(graspplot_handles.figure);
            plot_handle = bar(graspplot_handles.figure,'xdata',xdata,'ydata',ydata,'linestyle',graspplot.linestyle,'linewidth',graspplot.linewidth);
            
            %Store curve handle in axis userdata
            curve_handles = get(graspplot_handles.axis,'userdata');
            curve_handles{length(curve_handles)+1} = plot_handle;
            set(graspplot_handles.axis,'userdata',curve_handles);
            
            %Store the plot_info in the curve userdata
            set(plot_handle,'userdata',plot_info);
        end
        
        curve_number = curve_number +1;
    end
end


%Now add the titles to the graph
xlabel(graspplot_handles.axis,graspplot.xlabel);
ylabel(graspplot_handles.axis,graspplot.ylabel);
title(graspplot_handles.axis,graspplot.title);
grid(graspplot_handles.axis,graspplot.grid);

%x y limits
axlims = axis;
set(graspplot_handles.ymax,'string',num2str(axlims(4)),'visible',graspplot.axlim);
set(graspplot_handles.ymin,'string',num2str(axlims(3)),'visible',graspplot.axlim);
set(graspplot_handles.xmax,'string',num2str(axlims(2)),'visible',graspplot.axlim);
set(graspplot_handles.xmin,'string',num2str(axlims(1)),'visible',graspplot.axlim);



%Check if x-axis is time
if strcmpi(time_x,'on'); datetick('x', 'DD-mmm-yy HH:MM:SS'); end

%Check if incoming log / lin axes
if strcmpi(graspplot.yscale,'log')
    set(graspplot_handles.yscale_list,'value',2)
    set(graspplot_handles.axis,'YScale','Log');
else
    set(graspplot_handles.yscale_list,'value',1)
    set(graspplot_handles.axis,'YScale','Linear');
end

%Check if incoming log / lin axes
if strcmpi(graspplot.xscale,'log')
    set(graspplot_handles.xscale_list,'value',2)
    set(graspplot_handles.axis,'XScale','Log');
else
    set(graspplot_handles.xscale_list,'value',1)
    set(graspplot_handles.axis,'XScale','Linear');
end

%Set manual axis limits
axis auto;
lims = axis;
if not(strcmpi(graspplot.xlims,'auto'))
    lims(1:2) = graspplot.xlims;
end
if not(strcmpi(graspplot.ylims,'auto'))
    lims(3:4) = graspplot.ylims;
end
axis(lims);

%General update of the plot
grasp_plot3_callbacks('build_curve_tools_menu',graspplot_handles);
grasp_plot3_callbacks('update_legend',graspplot_handles);
grasp_plot3_menu_callbacks; %General update of menu items

