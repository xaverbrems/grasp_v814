function pa_optimise_callbacks(to_do)

global status_flags
global grasp_handles
global grasp_env

switch to_do
    
    case 't1_edit'
        temp = get(gcbo,'string');
        value = str2num(temp);
        if not(isempty(value))
            status_flags.pa_optimise.pa_3he_t1(1) = value;
        end
        pa_optimise_callbacks('update_time');

    case 'max_time_edit'
        temp = get(gcbo,'string');
        value = str2num(temp);
        if not(isempty(value))
            status_flags.pa_optimise.pa_3he_time_max = value;
        end
        pa_optimise_callbacks('update_time');

    case 'close'
        grasp_handles.window_modules.pa_tools.optimise_window = [];
        
    case 'he_pol_edit'
        
        temp = get(gcbo,'string');
        value = str2num(temp);
        if not(isempty(value))
            status_flags.pa_optimise.pa_3he_pol(1) = value/100;
        end
        pa_optimise_callbacks('update');
        
         case 't_emptycell_edit'
        temp = get(gcbo,'string');
        value = str2num(temp)
        if not(isempty(value));
            status_flags.pa_optimise.parameters.t_emptycell(1) = value/100;
        end 
        pa_optimise_callbacks('update');
        
    case 'he_opacity_max'
        temp = get(gcbo,'string');
        value = str2num(temp);
        if not(isempty(value))
            status_flags.pa_optimise.pa_3he_opacity_max = value;
        end
        pa_optimise_callbacks('update');
        
        
    case 'he_pressure_edit'
        temp = get(gcbo,'string');
        value = str2num(temp);
        if not(isempty(value))
            status_flags.pa_optimise.pa_3he_pressure = value;
        end
        
        
    case 'he_wav_edit'
        temp = get(gcbo,'string');
        value = str2num(temp);
        if not(isempty(value))
            status_flags.pa_optimise.pa_3he_wavelength = value;
        end
        
    case 'he_pathlength_edit'
        temp = get(gcbo,'string');
        value = str2num(temp);
        if not(isempty(value))
            status_flags.pa_optimise.pa_3he_pathlength = value;
        end
        
    case 'he_optimum_opacity'
        temp = get(gcbo,'string');
        value = str2num(temp);
        if not(isempty(value))
            status_flags.pa_optimise.pa_3he_optimum = value;
        end
        %pa_optimise_callbacks('update');
        
          
      
        
        
        
        
    case 'update'
        pa_optimise_callbacks('update_opacity');
        pa_optimise_callbacks('update_time');
        
    case 'update_opacity'
      for t = 1:100
        opacity = t*status_flags.pa_optimise.pa_3he_opacity_max/100;
        opacitylist(t) = opacity;
        pa_cell = pa_cell_optimise_polarisation([opacity 0],status_flags.pa_optimise.pa_3he_pol,status_flags.pa_optimise.parameters.t_emptycell);
        fomlist(t)= pa_cell.fom;
        ttotallist(t) = pa_cell.t_total;
        pollist(t) = pa_cell.pol;
%         frlist(t) = (1+pa_cell.pol)/(1-pa_cell.pol);
      end
        
        %Determine Optimum
        [fom_max, opacity_index]  = max(fomlist);
        status_flags.pa_optimise.pa_3he_optimum = opacitylist(opacity_index);

        
        %delete previous plots (if they exist)
        if isfield(grasp_handles.window_modules.pa_optimise,'fom_curve');
            if ishandle(grasp_handles.window_modules.pa_optimise.fom_curve);
                delete(grasp_handles.window_modules.pa_optimise.fom_curve);
                grasp_handles.window_modules.pa_optimise.fom_curve = [];
                delete(grasp_handles.window_modules.pa_optimise.transmission_curve);
                grasp_handles.window_modules.pa_optimise.transmission_curve = [];
                delete(grasp_handles.window_modules.pa_optimise.pol_curve);
                grasp_handles.window_modules.pa_optimise.pol_curve = [];
%                 delete(grasp_handles.window_modules.pa_optimise.fr_curve);
%                 grasp_handles.window_modules.pa_optimise.fr_curve = [];
                delete(grasp_handles.window_modules.pa_optimise.fom_line);
                grasp_handles.window_modules.pa_optimise.fom_line = [];
            end
        end
   
        
        %Plot P2T
        axes(grasp_handles.window_modules.pa_optimise.pa_optimise_plot);
        hold on
        grasp_handles.window_modules.pa_optimise.fom_curve = plot(opacitylist,fomlist,'.','color',[0.4, 0.4, 1]);
        %Plot Transmission
        axes(grasp_handles.window_modules.pa_optimise.pa_optimise_plot);
        hold on
        grasp_handles.window_modules.pa_optimise.transmission_curve = plot(opacitylist,ttotallist,'.','color',[0.7, 0.6, 0.5]);
        %Plot Polarisation
        axes(grasp_handles.window_modules.pa_optimise.pa_optimise_plot);
        hold on
        grasp_handles.window_modules.pa_optimise.pol_curve = plot(opacitylist,pollist,'.','color',[1, 0.2, 0.2]);
%         %Plot Flipping Ratio
%         axes(grasp_handles.window_modules.pa_optimise.pa_optimise_plot);
%         hold on
%         grasp_handles.window_modules.pa_optimise.fr_curve = plot(opacitylist,frlist,'.','color',[0.2, 0.8, 0.2]);
%         
        axis auto;
        %Plot line at optimum
        hold on
        ax_lims = axis;
        grasp_handles.window_modules.pa_optimise.fom_line = line([status_flags.pa_optimise.pa_3he_optimum,status_flags.pa_optimise.pa_3he_optimum],[ax_lims(3),ax_lims(4)],'color',[0.4, 0.4, 1]);
        %Add legend
        h = legend(grasp_handles.window_modules.pa_optimise.pa_optimise_plot,'P^2T', 'Total Transmission', 'Polarisation');
        set(h,'fontsize',grasp_env.fontsize)

        
       
        
        
    case 'update_time'
        for t = 1:100
        time = t*status_flags.pa_optimise.pa_3he_time_max/100;
        timelist(t) = time;
        pa_cell = pa_cell_optimise_polarisation([status_flags.pa_optimise.pa_3he_optimum 0],status_flags.pa_optimise.pa_3he_pol,status_flags.pa_optimise.parameters.t_emptycell,time,0,status_flags.pa_optimise.pa_3he_t1); 
        ttotallist(t) = pa_cell.t_total;
        pollist(t) = pa_cell.pol;
        frlist(t) = (1+pa_cell.pol)/(1-pa_cell.pol);
        end
              
        
            
        %delete previous plots (if they exist)
        if isfield(grasp_handles.window_modules.pa_optimise,'trans_curve');
            if ishandle(grasp_handles.window_modules.pa_optimise.trans_curve);
                delete(grasp_handles.window_modules.pa_optimise.trans_curve);
                grasp_handles.window_modules.pa_optimise.trans_curve = [];
            end
        end
        
        %delete previous plots (if they exist)
        if isfield(grasp_handles.window_modules.pa_optimise,'pol_beam_curve');
            if ishandle(grasp_handles.window_modules.pa_optimise.pol_beam_curve);
                delete(grasp_handles.window_modules.pa_optimise.pol_beam_curve);
                grasp_handles.window_modules.pa_optimise.pol_beam_curve = [];
            end
        end
        
         %delete previous plots (if they exist)
        if isfield(grasp_handles.window_modules.pa_optimise,'fr_time_curve');
            if ishandle(grasp_handles.window_modules.pa_optimise.fr_time_curve);
                delete(grasp_handles.window_modules.pa_optimise.fr_time_curve);
                grasp_handles.window_modules.pa_optimise.fr_time_curve = [];
            end
        end 
        
        
      
        
        %Plot Transmission  vs. Time
        axes(grasp_handles.window_modules.pa_optimise.pa_transmission_time_plot);
        hold on
        grasp_handles.window_modules.pa_optimise.trans_curve = plot(timelist,ttotallist,'.y');
        axis auto;
        h = legend('Transmission of Unpolarised beam');
        set(h,'fontsize',grasp_env.fontsize);

        
        
        %Plot Polarisation of Unpolarised Beam  vs. Time
        axes(grasp_handles.window_modules.pa_optimise.pa_polbeam_time_plot);
        hold on
        grasp_handles.window_modules.pa_optimise.pol_beam_curve = plot(timelist,pollist,'.b');
        axis auto;
        h = legend('Polarisation of Unpolarised beam');
        set(h,'fontsize',grasp_env.fontsize);

      %Plot Flipping Ratio Analyser vs. Time
        axes(grasp_handles.window_modules.pa_optimise.pa_fr_time_plot);
        hold on
        grasp_handles.window_modules.pa_optimise.fr_time_curve = plot(timelist,frlist,'.r');
        axis auto;
        h = legend('Flipping ratio of Analyser');
        set(h,'fontsize',grasp_env.fontsize);   
        
        
        
        
        
        
        
end

%Re-calculate derived parameters e.g. pressure from given path length and wavelength
status_flags.pa_optimise.pa_3he_pressure = status_flags.pa_optimise.pa_3he_optimum ./ ( status_flags.pa_optimise.pa_3he_pathlength.* status_flags.pa_optimise.pa_3he_wavelength);

%General Update

set(grasp_handles.window_modules.pa_optimise.pol_3he_edit,'string', num2str(status_flags.pa_optimise.pa_3he_pol(1)*100));
set(grasp_handles.window_modules.pa_optimise.pol_t_emptycell_edit,'string', num2str(status_flags.pa_optimise.parameters.t_emptycell(1)*100));
set(grasp_handles.window_modules.pa_optimise.pol_optimum_edit,'string', num2str(status_flags.pa_optimise.pa_3he_optimum));
set(grasp_handles.window_modules.pa_optimise.pol_pressure_edit,'string', num2str(status_flags.pa_optimise.pa_3he_pressure));
set(grasp_handles.window_modules.pa_optimise.pol_pathlength_edit,'string', num2str(status_flags.pa_optimise.pa_3he_pathlength));
set(grasp_handles.window_modules.pa_optimise.pol_wavelength_edit,'string', num2str(status_flags.pa_optimise.pa_3he_wavelength));
set(grasp_handles.window_modules.pa_optimise.pol_opacity_edit,'string', num2str(status_flags.pa_optimise.pa_3he_opacity_max));
set(grasp_handles.window_modules.pa_optimise.pol_3he_t1_edit,'string', num2str(status_flags.pa_optimise.pa_3he_t1(1)));
set(grasp_handles.window_modules.pa_optimise.pol_3he_time_max_edit,'string', num2str(status_flags.pa_optimise.pa_3he_time_max));

