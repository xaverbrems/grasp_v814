function pa_polarisation_callbacks(to_do)

global status_flags
global grasp_handles
global grasp_data
global displayimage

switch to_do
    
    case 'grab_fit_params'
        
        if isfield(status_flags.fitter,'function_info_1d')
            pnames = [{'p'}, {'opacity'}, {'phe0'},{'t1'}, {'t0'}];
            for m = 1:length(pnames);
                for n = 1:length(status_flags.fitter.function_info_1d.variable_names);
                    if strcmp(status_flags.fitter.function_info_1d.variable_names{n},pnames{m})
                        status_flags.pa_optimise.parameters.([pnames{m}]) = [status_flags.fitter.function_info_1d.values(n), status_flags.fitter.function_info_1d.err_values(n)];
                    end
                end
            end
        end
        
        
    case 'phi_time_max_edit'
        temp = str2num(get(gcbo,'string'));
        if not(isempty(temp));
            status_flags.pa_optimise.phi_time_max = temp;
        end
        
    case 'p_edit'
        temp = str2num(get(gcbo,'string'));
        if not(isempty(temp));
            status_flags.pa_optimise.parameters.p = [temp, 0];
        end
        
    case 'pf_edit'
        temp = str2num(get(gcbo,'string'));
        if not(isempty(temp));
            status_flags.pa_optimise.parameters.pf = [temp, 0];
        end
        
          case 'trans_empty_cell_edit'
        temp = str2num(get(gcbo,'string'));
        if not(isempty(temp));
            status_flags.pa_optimise.parameters.t_emptycell = [temp, 0];
        end
   
        
    case 'opacity_edit'
        temp = str2num(get(gcbo,'string'));
        if not(isempty(temp));
            status_flags.pa_optimise.parameters.opacity = [temp, 0];
        end
        
    case 'phe0_edit'
        temp = str2num(get(gcbo,'string'));
        if not(isempty(temp));
            status_flags.pa_optimise.parameters.phe0 = [temp, 0];
        end
        
    case 't1_edit'
        temp = str2num(get(gcbo,'string'));
        if not(isempty(temp));
            status_flags.pa_optimise.parameters.t1 = [temp, 0];
        end
        
    case 't0_edit'
        temp = str2num(get(gcbo,'string'));
        if not(isempty(temp));
            status_flags.pa_optimise.parameters.t0 = [temp, 0];
        end
        
  
        
        %status_flags.pa_optimise.parameters.t_emptycell = [temp, 0];
        
    case 'use_pf'
        status_flags.pa_optimise.parameters.pf = status_flags.pa_optimise.pf_av;
       
        
        
    case 'close'
        grasp_handles.window_modules.pa_tools.polarisation_window = [];
        
    case 'fit_combined_polarisation'
        %Re-plot the displayed combined polarisation in a Grasp plot figure
        %ready for fitting
        
        %***** Plot Phi vs. Time ****
        plot_data = [rot90(status_flags.pa_optimise.polarisation.normalised_time_hrs),rot90(status_flags.pa_optimise.polarisation.phi),rot90(status_flags.pa_optimise.polarisation.err_phi)]; 
        column_format = 'xye';
        column_labels = ['Time [hrs]  ' char(9) 'Phi       ' char(9) 'Err_Phi  '];
        export_data = plot_data;
        
        plot_info = struct(....
            'plot_type','plot',....
            'hold_graph',0,....
            'plot_title',['Combined Supermirror--Analyser Polarisation'],....
            'x_label',['Time [hrs]'],....
            'y_label','Phi',....
            'legend_str','',....
            'export_data',export_data,....
            'column_labels',column_labels);
        grasp_plot(plot_data,column_format,plot_info);

        %Open Curve fitter
        grasp_plot_fit_window
        %Set grasp plot fitter to the correct function
        for n = 1:length(status_flags.fitter.fn_list1d)
            if strcmp(status_flags.fitter.fn_list1d{n},'Combined Supermirror--Analyser Polarisation')
                status_flags.fitter.fn1d = n;
                set(grasp_handles.window_modules.curve_fit1d.fn_selector,'value',n);
                grasp_plot_fit_callbacks('retrieve_fn');
                grasp_plot_fit_callbacks('update_curve_fit_window');
            end
        end
        return
        
        
        
    case 'calculate_polarisation'
        
        %Run though all the depths and collect the stats (normalised counts & errors)
        
        
        %Turn off updating
        remember_display_params_status = status_flags.command_window.display_params; %Turn off command window parameter update for the boxing
        status_flags.command_window.display_params= 0;
        status_flags.display.refresh = 0; %Turn off the 2D display for speed
        
        %Find the worksheet we are dealing with
       % userdata = get(grasp_handles.window_modules.pa_tools.pa_polarisation_worksheet_popup,'userdata')
       % wks = userdata(status_flags.pa_optimise.pa_polarisation_wks)
        wks = status_flags.selector.fw;
        
        index = data_index(wks);
        total_depth = grasp_data(index).dpth{status_flags.selector.fn}
        %total_depth = grasp_data(index).dpth{1};
        depth_start = status_flags.selector.fd; %remember the initial foreground depth
        
        disp(' ')
        disp(['Collecting Total intensities & time though depth']);
        box_intensities = [];
        disp(['Depth #:  Mid-point Time  Total Counts (after Normalisation):   Error Counts:']);
        
        for n = 1:total_depth
            message_handle = grasp_message(['Extracting Total intensities Depth: ' num2str(n) ' of ' num2str(total_depth)]);
            status_flags.selector.fd = n+grasp_data(index).sum_allow;
            
            main_callbacks('depth_scroll'); %Scroll all linked depths and update
            
            det = 1;
           detno= num2str(det);
             %***** Get current axis coordinates *****
        axis_limits  = current_axis_limits;
        axis_lims = axis_limits.(['det' detno]).pixels; %x,y
        axis_lims = round(axis_lims); %for indexing the data array
         box_sum = sum(sum(displayimage.(['data' detno])(axis_lims(3):axis_lims(4),axis_lims(1):axis_lims(2))));
             box_sum_error= sqrt(sum(sum(displayimage.(['error' detno])(axis_lims(3):axis_lims(4),axis_lims(1):axis_lims(2)).^2)));
            
            
            %Calculate mid-point-time
            temp1 = datenum([displayimage.params1.start_date displayimage.params1.start_time])
            temp2 = datenum([displayimage.params1.end_date displayimage.params1.end_time]);
            mid_point_time = temp1+(temp2-temp1)/2;
            box_intensities(n,:) = [mid_point_time, box_sum, box_sum_error];
            
            %Display results in the comment window
            disp([num2str(n) char(9) datestr(mid_point_time) char(9) num2str(box_sum) char(9) num2str(box_sum_error)])
        end
        
        %Set selector back to where it was in the beginning
        status_flags.selector.fd = depth_start;
        main_callbacks('depth_scroll'); %Scroll all linked depths and update
        delete(message_handle);
        
        %Turn on command window parameter update for the boxing
        status_flags.command_window.display_params = remember_display_params_status;
        %Turn on the 2D display
        status_flags.display.refresh = 1;
        disp(' ');
        
        %Calculate Polarisation
        status_flags.pa_optimise.polarisation = [];
        for n = 1:length(box_intensities)/4;
            temp = pa_polarisation([box_intensities(1+(n-1)*4,2), box_intensities(1+(n-1)*4,3)],[box_intensities(2+(n-1)*4,2),box_intensities(2+(n-1)*4,3)],[box_intensities(3+(n-1)*4,2), box_intensities(3+(n-1)*4,3)],[box_intensities(4+(n-1)*4,2),box_intensities(4+(n-1)*4,3)]);
            
            %re-order data into status_flags
            status_flags.pa_optimise.polarisation.absolute_time(n) = mean([box_intensities(1+(n-1)*4,1),box_intensities(2+(n-1)*4,1),box_intensities(3+(n-1)*4,1),box_intensities(4+(n-1)*4,1)]);
            status_flags.pa_optimise.polarisation.intensity(n) = mean([box_intensities(1+(n-1)*4,2),box_intensities(2+(n-1)*4,2),box_intensities(3+(n-1)*4,2),box_intensities(4+(n-1)*4,2)]);
            status_flags.pa_optimise.polarisation.int_error(n) = mean([box_intensities(1+(n-1)*4,3),box_intensities(2+(n-1)*4,3),box_intensities(3+(n-1)*4,3),box_intensities(4+(n-1)*4,3)]);
            status_flags.pa_optimise.polarisation.fr_phi(n) = temp.fr_phi;
            status_flags.pa_optimise.polarisation.err_fr_phi(n) = temp.err_fr_phi;
            status_flags.pa_optimise.polarisation.phi(n) = temp.phi;
            status_flags.pa_optimise.polarisation.err_phi(n) = temp.err_phi;
            status_flags.pa_optimise.polarisation.fr_f(n) = temp.fr_f;
            status_flags.pa_optimise.polarisation.err_fr_f(n) = temp.err_fr_f;
            status_flags.pa_optimise.polarisation.pf(n) = temp.pf;
            status_flags.pa_optimise.polarisation.err_pf(n) = temp.err_pf;
           
            
        end
        status_flags.pa_optimise.polarisation.normalised_time_hrs = (status_flags.pa_optimise.polarisation.absolute_time - status_flags.pa_optimise.polarisation.absolute_time(1))*24;
        pa_cellcalc =  pa_cell_optimise_polarisation(status_flags.pa_optimise.parameters.opacity,status_flags.pa_optimise.parameters.phe0,[status_flags.pa_optimise.parameters.t_emptycell(1) 0],status_flags.pa_optimise.polarisation.normalised_time_hrs,0,status_flags.pa_optimise.parameters.t1,status_flags.pa_optimise.parameters.t0,status_flags.pa_optimise.parameters.p);
        phi_calc = pa_cellcalc.phi; 
        
        
        %calculate expected effective supermirror polarisation for which SF
        %states are equal
        disp('theoretical supermirror polarisation PSM (assumption: SF equal)');
        for n = 1:length(status_flags.pa_optimise.polarisation.pf)
        temp = pa_supermirror_check([box_intensities(1+(n-1)*4,2), box_intensities(1+(n-1)*4,3)],[box_intensities(2+(n-1)*4,2),box_intensities(2+(n-1)*4,3)],[box_intensities(3+(n-1)*4,2), box_intensities(3+(n-1)*4,3)],[box_intensities(4+(n-1)*4,2),box_intensities(4+(n-1)*4,3)],[pa_cellcalc.t_para(n), pa_cellcalc.dt_para(n)],[pa_cellcalc.t_anti(n), pa_cellcalc.dt_anti(n)], status_flags.pa_optimise.parameters.pf);
        disp([datestr(status_flags.pa_optimise.polarisation.absolute_time(n)) ' '  num2str(temp.p,'%5g') ' '  num2str(temp.err_p,'%5g') ' '  num2str(pa_cellcalc.t_para(n),'%5g')])
        end
        
        %Display Polarisation Data vs Time in the Text window
        disp('    Time      P_f             Phi+- Err   calc. Phi    Exp/Calc     ');
        
        
        %Calculate average polarisation
        pf_list = []; 
        for n = 1:length(status_flags.pa_optimise.polarisation.pf)
           disp([datestr(status_flags.pa_optimise.polarisation.absolute_time(n)) ' '  num2str(status_flags.pa_optimise.polarisation.pf(n),'%5g') '  ' num2str(status_flags.pa_optimise.polarisation.phi(n),'%5g')  '  ' num2str(status_flags.pa_optimise.polarisation.err_phi(n),'%5g')  '  ' num2str(phi_calc(n),'%5g') ' ' num2str(status_flags.pa_optimise.polarisation.phi(n)/phi_calc(n),'%5g') ])
           pf_list(n,:) = [status_flags.pa_optimise.polarisation.pf(n), status_flags.pa_optimise.polarisation.err_pf(n)];
        end
        pf_list
        status_flags.pa_optimise.pf_av = average_error(pf_list);
      
        
        
        
        pa_polarisation_callbacks('update_plots');
        
        
    case 'update_plots'
        
        %Update Plots if previous polarisation data exists in status_flags
        if isfield(status_flags.pa_optimise,'polarisation')
            if isfield(status_flags.pa_optimise.polarisation,'pf')
                
                %Polarisation plot
                %delete previous plots (if they exist)
                if isfield(grasp_handles.window_modules.pa_polarisation,'pf_curve');
                    if ishandle(grasp_handles.window_modules.pa_polarisation.pf_curve);
                        delete(grasp_handles.window_modules.pa_polarisation.pf_curve);
                        grasp_handles.window_modules.pa_polarisation.pf_curve = [];
                    end
                end
                
                        
                
                %Plot Pf 
                axes(grasp_handles.window_modules.pa_polarisation.pf_plot);
                hold on
                grasp_handles.window_modules.pa_polarisation.pf_curve = errorbar(status_flags.pa_optimise.polarisation.normalised_time_hrs,status_flags.pa_optimise.polarisation.pf,status_flags.pa_optimise.polarisation.err_pf,'.','color','y');
                legend('Pf');
                axis auto;
               
                
                 %3He Cell Transmission plot
                %delete previous plots (if they exist)
                if isfield(grasp_handles.window_modules.pa_polarisation,'hetrans_curve');
                    if ishandle(grasp_handles.window_modules.pa_polarisation.hetrans_curve);
                        delete(grasp_handles.window_modules.pa_polarisation.hetrans_curve);
                        grasp_handles.window_modules.pa_polarisation.hetrans_curve = [];
                    end
                end
                
                 %Plot 3He Cell Transmission 
                axes(grasp_handles.window_modules.pa_polarisation.hetrans_plot);
                hold on
                grasp_handles.window_modules.pa_polarisation.hetrans_curve = errorbar(status_flags.pa_optimise.polarisation.normalised_time_hrs,status_flags.pa_optimise.polarisation.intensity,status_flags.pa_optimise.polarisation.int_error,'.','color','y');
                legend('3He Trans');
                axis auto;
                
                
%                 %FR plot
%                 %delete previous plots (if they exist)
%                 if isfield(grasp_handles.window_modules.pa_polarisation,'fr_f_curve');
%                     if ishandle(grasp_handles.window_modules.pa_polarisation.fr_f_curve);
%                        delete(grasp_handles.window_modules.pa_polarisation.fr_f_curve);
%                        grasp_handles.window_modules.pa_polarisation.fr_f_curve = [];
%                        delete(grasp_handles.window_modules.pa_polarisation.fr_phi_curve);
%                        grasp_handles.window_modules.pa_polarisation.fr_phi_curve = [];
%                    end
%                end
%                 
%                 %Plot FR_f and FR_phi
%                axes(grasp_handles.window_modules.pa_polarisation.fr_plot);
%                hold on
%                grasp_handles.window_modules.pa_polarisation.fr_f_curve = errorbar(status_flags.pa_optimise.polarisation.normalised_time_hrs,status_flags.pa_optimise.polarisation.fr_f,status_flags.pa_optimise.polarisation.err_fr_f,'.','color','y');
%                hold on
%                grasp_handles.window_modules.pa_polarisation.fr_phi_curve = errorbar(status_flags.pa_optimise.polarisation.normalised_time_hrs,status_flags.pa_optimise.polarisation.fr_phi,status_flags.pa_optimise.polarisation.err_fr_phi,'.','color','r');
%                legend('Fr-f (FR Flipper + polarizer + analyser)','Fr-phi (FR polarizer + analyser)');
%                axis auto;
%                 
                
                %Combined Polariser & Analyser polarisation, Phi
                %delete previous plots (if they exist)
                if isfield(grasp_handles.window_modules.pa_polarisation,'phi_curve');
                    if ishandle(grasp_handles.window_modules.pa_polarisation.phi_curve);
                        delete(grasp_handles.window_modules.pa_polarisation.phi_curve);
                        grasp_handles.window_modules.pa_polarisation.phi_curve = [];
                    end
                end
                
                %Plot combined polarisation
                axes(grasp_handles.window_modules.pa_polarisation.phi_plot);
                hold on
                grasp_handles.window_modules.pa_polarisation.phi_curve = errorbar(status_flags.pa_optimise.polarisation.normalised_time_hrs,status_flags.pa_optimise.polarisation.phi,status_flags.pa_optimise.polarisation.err_phi,'o','color',[1, 1, 1]);
                axis auto;
            end
        end
end


%Update some displayed Values

%Display average Pf
set(grasp_handles.window_modules.pa_tools.pa_polarisation_pf_average,'string',['Pf :  ' num2str(status_flags.pa_optimise.pf_av(1))  '  +-  ' num2str(status_flags.pa_optimise.pf_av(2))]);


%Polariser
set(grasp_handles.window_modules.pa_tools.parameter_p_edit,'String',num2str(status_flags.pa_optimise.parameters.p(1)));
%RF Flipper
set(grasp_handles.window_modules.pa_tools.parameter_pf_edit,'String',num2str(status_flags.pa_optimise.parameters.pf(1)));
%Transmission Empty Analyser Cell
set(grasp_handles.window_modules.pa_tools.parameter_ec_edit,'String',num2str(status_flags.pa_optimise.parameters.t_emptycell(1)));


%3He Opacity
set(grasp_handles.window_modules.pa_tools.parameter_opacity_edit,'String',num2str(status_flags.pa_optimise.parameters.opacity(1)));
%3He Initial Polarisation
set(grasp_handles.window_modules.pa_tools.parameter_phe0_edit,'String',num2str(status_flags.pa_optimise.parameters.phe0(1)));
%3He Decay T1
set(grasp_handles.window_modules.pa_tools.parameter_t1_edit,'String',num2str(status_flags.pa_optimise.parameters.t1(1)));
%3He Time Offset T0
set(grasp_handles.window_modules.pa_tools.parameter_t0_edit,'String',num2str(status_flags.pa_optimise.parameters.t0(1)));


%Modeled combined polarisation
time = 0:status_flags.pa_optimise.phi_time_max/100:status_flags.pa_optimise.phi_time_max;
%duration=zeros(length(time));
status_flags.pa_optimise.parameters.t_emptycell(1)
pa_cell = pa_cell_optimise_polarisation(status_flags.pa_optimise.parameters.opacity,status_flags.pa_optimise.parameters.phe0,[status_flags.pa_optimise.parameters.t_emptycell(1) 0],time,0,status_flags.pa_optimise.parameters.t1,status_flags.pa_optimise.parameters.t0,status_flags.pa_optimise.parameters.p);
phi = pa_cell.phi;
trans_calc=pa_cell.t_total;
%delete previous plots (if they exist)
if isfield(grasp_handles.window_modules.pa_polarisation,'phi_model_curve');
    if ishandle(grasp_handles.window_modules.pa_polarisation.phi_model_curve);
        delete(grasp_handles.window_modules.pa_polarisation.phi_model_curve);
        grasp_handles.window_modules.pa_polarisation.phi_model_curve = [];
    end
end

if isfield(grasp_handles.window_modules.pa_polarisation,'trans_model_curve');
    if ishandle(grasp_handles.window_modules.pa_polarisation.trans_model_curve);
        delete(grasp_handles.window_modules.pa_polarisation.trans_model_curve);
        grasp_handles.window_modules.pa_polarisation.trans_model_curve = [];
    end
end

%Plot Combined polarisation of Supermirror and 3HeCell
axes(grasp_handles.window_modules.pa_polarisation.phi_plot);
hold on
grasp_handles.window_modules.pa_polarisation.phi_model_curve = plot(time,phi,'-y');
axis auto;

%Plot 3HeCell transmission
axes(grasp_handles.window_modules.pa_polarisation.hetrans_plot);
hold on
grasp_handles.window_modules.pa_polarisation.trans_model_curve = plot(time,trans_calc,'-y');

axis auto;








