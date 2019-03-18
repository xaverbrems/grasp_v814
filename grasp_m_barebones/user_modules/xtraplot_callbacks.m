function xtraplot_callbacks(to_do)

global status_flags
global displayimage
global grasp_handles


if nargin<1; to_do = ''; end


switch to_do
    
    case 'yparameter'
        string = get(gcbo,'string');
        value = get(gcbo,'value');
        status_flags.analysis_modules.xtraplot.yparameter = string{value};
        
        
    case 'xparameter'
        string = get(gcbo,'string');
        value = get(gcbo,'value');
        status_flags.analysis_modules.xtraplot.xparameter = string{value};
        
    case 'plot'
        xdata = displayimage.params1.([status_flags.analysis_modules.xtraplot.xparameter]);
        ydata = displayimage.params1.([status_flags.analysis_modules.xtraplot.yparameter]);        

        if size(xdata) == size(ydata)
        disp([xdata,ydata])
        plotdata = [xdata,ydata];
        column_format = 'xy';
        
          plot_params = struct(....
            'plot_type','plot',....
            'plot_data',plotdata,....
            'column_format',column_format,....
            'hold_graph','off',....
            'plot_title',['XtraPlot'],....
            'x_label',([status_flags.analysis_modules.xtraplot.xparameter]),....
            'y_label',[status_flags.analysis_modules.xtraplot.yparameter],....
            'legend_str',[status_flags.analysis_modules.xtraplot.yparameter],....
            'params',displayimage.params1,....
            'export_data',plotdata,....
            'export_column_format',column_format,....
            'column_labels',[status_flags.analysis_modules.xtraplot.xparameter char(9) status_flags.analysis_modules.xtraplot.yparameter]);
                    
        grasp_plot2(plot_params); %Plot
        
        else
            disp('Sorry, the lengths of your X & Y data do not match for plotting')
        end
        
end




%Update Dropdown list of parameters
index=data_index(status_flags.selector.fw);
string = rot90(fieldnames(displayimage.params1));
p_names = [];
p_values = displayimage.params1;
for p = 1:length(string)
     if isnumeric(p_values.(string{p}))
         p_names{end+1} = (string{p});
     end
end
yvalue = find(strcmp(p_names,status_flags.analysis_modules.xtraplot.yparameter));
if isempty(yvalue)
    yvalue = find(strcmp('numor',p_names));
    status_flags.analysis_modules.xtraplot.yparameter = 'numor';
end
set(grasp_handles.window_modules.xtraplot.yparameter,'string',p_names,'value',yvalue);

xvalue = find(strcmp(p_names,status_flags.analysis_modules.xtraplot.xparameter));
if isempty(xvalue)
    xvalue = find(strcmp('numor',p_names));
    status_flags.analysis_modules.xtraplot.xparameter = 'numor';
end
set(grasp_handles.window_modules.xtraplot.xparameter,'string',p_names,'value',xvalue);