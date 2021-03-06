function grasp_plot3(varargin)

if nargin <1
    disp('grasp_plot3 needs some input arguments')
    return
end

global graspplot

%Initialise some defaults
if isempty(graspplot)
    graspplot.plottype = 'plot';
    graspplot.columnformat = 'xy';
    graspplot.position = [0.53, 0.48, 0.41, 0.44];
    graspplot.units = 'normalized';
    graspplot.backgroundcolor = [0.05,0.1,0.3];
    graspplot.font = 'Arial';
    graspplot.fontsize = 10;
    graspplot.linestyle = '-';
    graspplot.linewidth = 1;
    graspplot.markersize = 5;
    graspplot.plottype = 'plot';
    graspplot.title = 'No Title';
    graspplot.xlabel = 'x-axis';
    graspplot.ylabel = 'y-axis';
    graspplot.hold = 'on';
    graspplot.legend = 'No Legend';
    graspplot.colors = ['w' 'r' 'c' 'm' 'y' 'g' 'b' 'w' 'y' 'm' 'c' 'r' 'g' 'b'];
    graspplot.symbols = ['o' 'x' '+' '*' '.' 's' 'd' 'v' '^' '<' '>' 'p' 'h' '.' 'o' 'x' '+' '*' 's' 'd' 'v' '^' '<' '>' 'p' 'h'];
    
end

%Check for user modified parameters
params = fieldnames(graspplot);
for n = 1:length(params)
    %Check for and overwrite if found graspplot parameter
    idx=find(cellfun(@(varargin) any(strcmp(varargin,params{n})),varargin));
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
            x_counter = e_counter + 1;
            plotdata.([column num2str(e_counter)]) = varargin{n};
        end
        if strcmpi(column,'h')
            x_counter = h_counter + 1;
            plotdata.([column num2str(h_counter)]) = varargin{n};
        end
        
    else
        break
    end
end
number_plots = 1;
double_y_flag= 0;


%***** Plot Variables *****
%number_previous_curves = 0; %for incremental colours and symbols in overplotting mode


%***** Check to see if we are over-plotting in an existing window or opening a new plot window *****
new_plot_flag = 1; %i.e. the default is to open a new plot
%double_y_flag = 0; %Default(0) is single y-axis, (1) add a double-y axis


% %Check if XtraPlot is trying to overplot any other grasp_plot
% i = findobj('name',plot_data(1).plot_title); %See if there is an existing plot with the same title
% 
% if strcmp(plot_data(1).plot_title,'XtraPlot') %Check if this is an XtraPlot coming in
%     %See if there is an XtraPlot already with hold status
%     if not(isempty(i)) %An XtraPlot already exists...use this if hold is on
%         grasp_plot_handles = get(i(1),'userdata');
%         if strcmpi(grasp_plot_handles.hold_status,'on')
%             new_plot_flag = 0; %i.e. there is a plot of the same type on hold so add to it
%             figure(i(1)); %Make over plotting figure the current one
%             
%         else
%             %Then find ANY grasp_plot with a hold status on and take the latest
%             j = findobj('tag','grasp_plot');  %See if ANY plot exists to over plot with XrtraPlot
%             if not(isempty(j)) %i.e. at least one exists
%                 grasp_plot_handles = get(j(1),'userdata');
%                 if strcmpi(grasp_plot_handles.hold_status,'on')
%                     new_plot_flag = 0; %i.e. there is a plot to overplot with a double-y axis
%                     double_y_flag = 1; %i.e. generate a second y-axis when plotting below
%                     figure(j(1)); %Make over plotting figure the current one
%                 else
%                     new_plot_flag = 1; %i.e. not a plot of the same type on hold so open a new plot
%                 end
%             end
%         end
%     else
%         %Then find ANY grasp_plot with a hold status on and take the latest
%         j = findobj('tag','grasp_plot');  %See if ANY plot exists to over plot with XrtraPlot
%         if not(isempty(j)) %i.e. at least one exists
%             grasp_plot_handles = get(j(1),'userdata');
%             if strcmpi(grasp_plot_handles.hold_status,'on')
%                 new_plot_flag = 0; %i.e. there is a plot to overplot with a double-y axis
%                 double_y_flag = 1; %i.e. generate a second y-axis when plotting below
%                 figure(j(1)); %Make over plotting figure the current one
%             else
%                 new_plot_flag = 1; %i.e. not a plot of the same type on hold so open a new plot
%             end
%         end
%     end
% elseif not(isempty(i)) %i.e. at least one exists
%     grasp_plot_handles = get(i(1),'userdata');
%     if strcmpi(grasp_plot_handles.hold_status,'on')
%         new_plot_flag = 0; %i.e. there is a plot of the same type on hold so add to it
%         figure(i(1)); %Make over plotting figure the current one
%     else
%         new_plot_flag = 1; %i.e. not a plot of the same type on hold so open a new plot
%     end
% end
% 





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
        
    %grasp_plot_handles = [];
    grasp_plot_handles.figure = figure(....
        'units',graspplot.units,....
        'Position',graspplot.position,....
        'Name',graspplot.title,....
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
        'windowbuttondownfcn','grasp_plot_callbacks(''button_down'');');
    
    %Modify Grasp_Plot Menu Items
    grasp_plot_handles = modify_grasp_plot_menu(grasp_plot_handles);
    %Modify Grasp_Plot Tool Items
    grasp_plot_handles = modify_grasp_plot_toolbar(grasp_plot_handles);
    drawnow; %Let the figure window finnish displaying
    
    
%     %Hold Graph Checkbox - when ticked and another graph is requested it plots into the last figure.
%     if strcmpi(plot_data(1).hold_graph,'on'); hold_status = 1; else hold_status = 0; end
%     grasp_plot_handles.hold_status = plot_data(1).hold_graph;
%     grasp_plot_handles.hold_check = uicontrol(grasp_plot_handles.figure,'units','normalized','Position',[0.9,0.93,0.1,0.06],'ToolTip',['Hold Graph: Yes(checked) / No(un-checked)' char(13) 'Next Results Output will plot in this Figure.'],...
%         'FontName',graspplot.font,'FontSize',graspplot.fontsize,'Style','checkbox','String','Hold!','HorizontalAlignment','left','value',hold_status,'backgroundcolor',background_color,'foregroundcolor',[1 1 1],'callback','grasp_plot_callbacks(''hold_toggle'')');
    %Log and Lin Dropdown list
    %y_list_string = {'y','log10(y)','ln(y)', 'y^2', 'y^4', 'y^n', 'y*x'};
    y_list_string = {'y','log10(y)'};
    grasp_plot_handles.yscale_list = uicontrol(grasp_plot_handles.figure,'units','normalized','Position',[0.025 0.92 0.09 0.05],'FontName',graspplot.font,'FontSize',graspplot.fontsize,'Style','Popup','String',y_list_string,'HorizontalAlignment','left','Tag','log_button_y','Visible','on',...
        'CallBack','grasp_plot_callbacks(''y_scale'');');
    x_list_string = {'x','log10(x)'};
    grasp_plot_handles.xscale_list = uicontrol(grasp_plot_handles.figure,'units','normalized','Position',[0.88 0.005 0.1 0.05],'FontName',graspplot.font,'FontSize',graspplot.fontsize,'Style','Popup','String',x_list_string,'HorizontalAlignment','left','Tag','log_button_x','Visible','on',...
        'CallBack','grasp_plot_callbacks(''x_scale'');');
    %Scaling Power Box
    grasp_plot_handles.yscale_edit = uicontrol(grasp_plot_handles.figure,'units','normalized','Position',[0.120 0.9 0.08 0.08],'FontName',graspplot.font,'FontSize',graspplot.fontsize,'Style','edit','String','1','HorizontalAlignment','left','Tag','yscaling_power_box','Visible','off',...
        'CallBack','grasp_plot_callbacks(''y_power_scale'');');
    grasp_plot_handles.xscale_edit = uicontrol(grasp_plot_handles.figure,'units','normalized','Position',[0.89 0.12 0.03 0.08],'FontName',graspplot.font,'FontSize',graspplot.fontsize,'Style','edit','String','1','HorizontalAlignment','left','Tag','xscaling_power_box','Visible','off',...
        'CallBack','grasp_plot_callbacks(''x_power_scale'');');
    
    %Make a dummy graph axes
    curve_handles = []; %Store this in the axis userdata and add to it as curves are drawn
    grasp_plot_handles.axis = axes('Position',[0.1 0.1 0.75 0.8],'tag','results_axes','box','on','FontName',graspplot.font,'FontSize',graspplot.fontsize,'Layer','Top','TickDir','in','userdata',curve_handles);
    %set(grasp_plot_handles.axis,'YColor','black','Xcolor','black')
    
    
    %Store all the new handles in the figure's userdata
    set(grasp_plot_handles.figure,'userdata',grasp_plot_handles);
    
end


%***** Loop though the plot_data structure - i.e. number of individual plot_data's , remember, might be multiple curves within each plot_data *****
for plot_data_number = 1:number_plots
    
    %Find number of previous curves from previous plot_data or previous plotting instances
    if ishandle(grasp_plot_handles.axis)
        curve_handles = get(grasp_plot_handles.axis,'userdata');
        number_previous_curves = length(curve_handles);
    end
    
    %Add a second y-axis if XtraPlot is being overplotted on other data
    if double_y_flag ==1 %Plot in a double y-axis
        yyaxis(grasp_plot_handles.axis,'left');
        set(grasp_plot_handles.axis,'YColor','white')
        yyaxis(grasp_plot_handles.axis,'right')
        set(grasp_plot_handles.axis,'YColor','white')
    end
    
    curve_number = 1; %Curves within each plot_data
%    plotdata = plot_data(plot_data_number).plot_data;
%    column_format = plot_data(plot_data_number).column_format;
%    plot_info = plot_data(plot_data_number);
    
%    plot_info = rmfield(plot_info,'plot_data'); %Remove plot_data so next curve plotted gets new data stored in plot_data
    %Parse the column_format string
    xdata = []; ydata = []; hdata = []; edata = [];
    x_counter = 1; y_counter = 1; e_counter = 1; h_counter = 1; t_counter = 1;
    for col_pointer = 1:length(column_format)
        if strcmp(column_format(col_pointer),'x')  %New x-column
            xdata = plotdata.(['x' num2str(x_counter)]);
            x_counter = x_counter+1;
        elseif strcmp(column_format(col_pointer),'y')
            ydata = plotdata.(['y' num2str(y_counter)]);
            y_counter = y_counter+1;
            %Check if X error data is coming also (h) 
            if col_pointer < length(column_format)
                if strcmp(column_format(col_pointer+1),'h')
                    hdata = plotdata.(['h' num2str(h_counter)]);
                    h_counter = h_counter +1;
                    col_pointer = col_pointer +1;
                else
                    hdata = [];
                end
            end
            %Check if Y error data is coming also (e)
            if col_pointer < length(column_format)
                if strcmp(column_format(col_pointer+1),'e')
                    edata = plotdata.(['e' num2str(e_counter)]);
                    e_counter = e_counter +1;
                    col_pointer = col_pointer +1;
                else
                    edata = [];
                end
            end
            plot_data_number
            curve_number
            number_previous_curves
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
            
            %**************************************************************
            
            %Re-hash the stored plot_data in the structure - needed for curve fitting etc
            plot_info.plot_data.xdat = xdata;
            plot_info.plot_data.ydat = ydata;
            plot_info.plot_data.edat = edata;
            plot_info.plot_data.hdat = hdata;
            plot_info.curve_number = total_curve_number;
            plot_info.legend_str = graspplot.legend;

            if strcmp(graspplot.plottype,'plot') || strcmp(graspplot.plottype,'errorbar')
                
                %Plot the data as either plot or errorbar
                if isempty(edata) %Plot only
                    
                    set(grasp_plot_handles.axis,'nextplot','add') %Same as hold on
                    plot_handle = plot(grasp_plot_handles.axis,xdata,ydata);
                    set(plot_handle,'linestyle',graspplot.linestyle,'linewidth',graspplot.linewidth,'color',graspplot.colors(curve_colour),'marker',graspplot.symbols(symbol_type),'markersize',graspplot.markersize);
                    
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
xlabel(grasp_plot_handles.axis,graspplot.xlabel);
ylabel(grasp_plot_handles.axis,graspplot.ylabel);
title(grasp_plot_handles.axis,graspplot.title);
warning on
%end
%****************************************************************

%General update of the plot
grasp_plot_callbacks('build_curve_tools_menu',grasp_plot_handles);
grasp_plot_callbacks('update_legend',grasp_plot_handles);
grasp_plot_menu_callbacks; %General update of menu items

