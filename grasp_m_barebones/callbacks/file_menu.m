function button = file_menu(to_do,options)

global grasp_env
global grasp_handles
global displayimage
global inst_params
global status_flags
global last_saved
global grasp_data

if nargin<2; options = []; end


%attachment_name = []; %This is the sup_figure attachment file name loaded with the main project
button = [];



switch to_do
    
    case 'active_axis_color'
        grasp_env.displayimage.active_axis_color = get(gcbo,'label');
        set(grasp_handles.menu.file.preferences.active_axis_color,'checked','off');
        set(gcbo,'checked','on');
        main_callbacks('active_axis',status_flags.display.active_axis);
        
    case 'inactive_axis_color'
        grasp_env.displayimage.inactive_axis_color = get(gcbo,'label');
        set(grasp_handles.menu.file.preferences.inactive_axis_color,'checked','off');
        set(gcbo,'checked','on');
        main_callbacks('active_axis',status_flags.display.active_axis);
        
        
        
        
        
        
        %***** File>Open Menu *****
    case 'open'
        
        [fname, directory] = uigetfile([grasp_env.path.project_dir '*.mat'],'Open File');
        
        if fname ~=0
            %button = file_menu('close');  %Flag returns whether the close previous project was canceled.
            if not(strcmp(button,'Cancel')) %i.e. it wasn't cancelled during the previous close project
                
                grasp_version = grasp_env.grasp_version;
                grasp_version_date = grasp_env.grasp_version_date;
                grasp_name = grasp_env.grasp_name;
                grasp_screen = grasp_env.screen;
                
                %Open saved Grasp project
                load([directory fname]);
                
                %Replace some of the project parameters with those relevant to the current system
                grasp_env.project_title = fname;
                grasp_env.path.project_dir = directory;
                grasp_env.grasp_version = grasp_version;
                grasp_env.grasp_version_date = grasp_version_date;
                grasp_env.grasp_name = grasp_name;
                grasp_env.screen = grasp_screen;
                
                %                 %Check for any new missing parameters due to Grasp update
                %                 if not(isfield(status_flags.calibration,'det_eff_nmbr')); status_flags.calibration.det_eff_nmbr = 1; end
                %                 if not(isfield(status_flags,'resolution_control')); %Added in V6.30
                %                     %Resolution Control
                %                     status_flags.resolution_control.wavelength_check = 1;
                %                     status_flags.resolution_control.divergence_check = 1;
                %                     status_flags.resolution_control.divergence_type = 1; %1 = Geometric, 2 = Measured Beam Shape
                %                     status_flags.resolution_control.aperture_check = 1;
                %                     status_flags.resolution_control.aperture_size = [10e-3]; %m (10mm) Single figure denotes circular
                %                     status_flags.resolution_control.pixelation_check = 1;
                %                     status_flags.resolution_control.binning_check = 1;
                %                     status_flags.resolution_control.show_kernels_check = 0;
                %                     status_flags.resolution_control.convolution_type = 1;
                %                     status_flags.resolution_control.fwhmwidth = 1; %extent to which convolution kernel goes out.
                %                     status_flags.resolution_control.finesse = 31;  %finesse (number of points) over the concolution kernel - should be ODD number
                %                 end
                %                 if not(isfield(status_flags.resolution_control,'wavelength_type')); status_flags.resolution_control.wavelength_type = 1; end
                %                 if not(isfield(status_flags.analysis_modules.radial_average,'direct_to_file')); status_flags.analysis_modules.radial_average.direct_to_file = 0; end
                %                 if not(isfield(status_flags.fitter,'delete_curves_check')); status_flags.fitter.delete_curves_check = 0; end
                %                 if not(isfield(status_flags,'pa_correction')); status_flags.pa_correction.calibrate_check = 0; end
                %                 %Rebin (complex) parameters
                %                 if not(isfield(status_flags.analysis_modules,'rebin'));
                %                     status_flags.analysis_modules.rebin.bin_spacing = 'linear';
                %                     status_flags.analysis_modules.rebin.n_bins = 500;
                %                     status_flags.analysis_modules.rebin.regroup_bands = [0,1];
                %                     status_flags.analysis_modules.rebin.dii_power = 2;
                %                     status_flags.analysis_modules.rebin.dqq_power = 2;
                %                 end
                %
                %                 %D33 tof combine
                %                 if not(isfield(status_flags.analysis_modules.radial_average,'d33_tof_combine'))
                %                     status_flags.analysis_modules.radial_average.d33_tof_combine = 0;
                %                 end
                %
                %                 %Depth frame start & end
                %                 if not(isfield(status_flags.analysis_modules.radial_average,'depth_frame_start'))
                %                     status_flags.analysis_modules.radial_average.depth_frame_start = 1;
                %                     status_flags.analysis_modules.radial_average.depth_frame_start = 1;
                %                 end
                %
                %                 temp = findstr(grasp_env.project_title,'.mat'); %Check to stop '.mat's' propogating though project_title
                %                 if not(isempty(temp)); grasp_env.project_title = grasp_env.project_title(1:temp-1); end
                %
                %                 %Active axis on/off
                %                 if not(isfield(status_flags.display,'axis1_onoff'));
                %                     status_flags.display.axis1_onoff = 1;
                %                     status_flags.display.axis2_onoff = 1;
                %                     status_flags.display.axis3_onoff = 1;
                %                     status_flags.display.axis4_onoff = 1;
                %                     status_flags.display.axis5_onoff = 1;
                %                     status_flags.display.axis6_onoff = 1;
                %                     status_flags.display.axis7_onoff = 1;
                %                     status_flags.display.axis8_onoff = 1;
                %                     status_flags.display.axis9_onoff = 1;
                %                     status_flags.display.axis10_onoff = 1;
                %                 end
                %
                %                 %PA Corrections
                %                 if not(isfield(status_flags,'figure.pa_chk'))
                %                     status_flags.calibration.pa_chk = 0;
                %                 end
                %
                %                 %Detector position soft-calibration
                %                 if not(isfield(status_flags,'soft_det_cal'))
                %                     status_flags.calibration.soft_det_cal = 0;
                %                 end
                %
                %                 %Raw tube data load
                %                 if not(isfield(status_flags.fname_extension,'raw_tube_data_load'))
                %                     status_flags.fname_extension.raw_tube_data_load = 0;
                %                 end
                %
                %                 %Tof distance
                %                 if not(isfield(status_flags.normalization,'d33_total_tof_dist'));
                %                     status_flags.normalization.d33_total_tof_dist = 0;
                %                 end
                %
                %                 %Tof delay
                %                 if not(isfield(status_flags.normalization,'d33_tof_delay'));
                %                     status_flags.normalization.d33_tof_delay = 0;
                %                 end
                %
                %                 %Exposure time
                %                 if not(isfield(status_flags.normalization,'standard_exposure_time'));
                %                     status_flags.normalization.standard_exposure_time  =1;
                %                 end
                %
                %                 %Aq time
                %                 if not(isfield(inst_params.vectors,'aq_time'));
                %                     inst_params.vectors.aq_time = inst_params.vectors.time;
                %                 end
                %
                %                 %Depth frame
                %                 %if not(isfield(status_flags.analysis_modules.radial_average,'depth_frame_start'));
                %                 %    status_flags.analysis_modules.radial_average.depth_frame_start = 1;
                %                 %end
                %                 %if not(isfield(status_flags.analysis_modules.radial_average,'depth_frame_end'));
                %                 %    status_flags.analysis_modules.radial_average.depth_frame_end = 1;
                %                 %end
                %
                %                 %Relative Detector efficiency
                %                 for det = 1:inst_params.detectors
                %                     if not(isfield(inst_params.(['detector' num2str(det)]),'relative_efficiency'));
                %                         inst_params.(['detector' num2str(det)]).relative_efficiency = 1;
                %                     end
                %                 end
                %
                %                 %Sector box & box track with wavelength
                %                 if not(isfield(status_flags.analysis_modules.sector_boxes,'q_lock_chk'))
                %                     status_flags.analysis_modules.sector_boxes.q_lock_chk = 0;
                %                     status_flags.analysis_modules.sector_boxes.q_lock_wav_ref = 0;
                %                     status_flags.analysis_modules.sector_boxes.q_lock_box_size_chk = 0;
                %                     status_flags.analysis_modules.boxes.q_lock_chk = 0;
                %                     status_flags.analysis_modules.boxes.q_lock_wav_ref = 0;
                %                     status_flags.analysis_modules.boxes.q_lock_box_size_chk = 0;
                %                     status_flags.analysis_modules.sector_boxes.t2t_lock_chk = 0;
                %                     status_flags.analysis_modules.sector_boxes.t2t_lock_box_size_chk = 0;
                %                     status_flags.analysis_modules.boxes.t2t_lock_chk = 0;
                %                     status_flags.analysis_modules.boxes.t2t_lock_box_size_chk = 0;
                %                     status_flags.analysis_modules.sector_boxes.t2t_lock_angle_ref1 = 0;
                %                     status_flags.analysis_modules.boxes.t2t_lock_angle_ref1 = 0;
                %                     status_flags.analysis_modules.boxes.t2t_lock_angle_ref2 = 0;
                %                     status_flags.analysis_modules.boxes.t2t_lock_angle_ref3 = 0;
                %                     status_flags.analysis_modules.boxes.t2t_lock_angle_ref4 = 0;
                %                     status_flags.analysis_modules.boxes.t2t_lock_angle_ref5 = 0;
                %                     status_flags.analysis_modules.boxes.t2t_lock_angle_ref6 = 0;
                %                     status_flags.analysis_modules.sector_boxes.t2t_lock_angle_ref2 = 0;
                %                     status_flags.analysis_modules.sector_boxes.t2t_lock_angle_ref3 = 0;
                %                     status_flags.analysis_modules.sector_boxes.t2t_lock_angle_ref4 = 0;
                %                     status_flags.analysis_modules.sector_boxes.t2t_lock_angle_ref5 = 0;
                %                     status_flags.analysis_modules.sector_boxes.t2t_lock_angle_ref6 = 0;
                %                     status_flags.analysis_modules.boxes.display_refresh = 'off';
                %                     status_flags.analysis_modules.sector_boxes.display_refresh = 'off';
                %                     status_flags.analysis_modules.radial_average.display_update = 'off';
                %                 end
                %
                %                 %Depth range check
                %                 if not(isfield(status_flags.selector,'depth_range_chk'))
                %                     status_flags.selector.depth_range_chk = 0;
                %                     status_flags.selector.depth_range_min = 1;
                %                     status_flags.selector.depth_range_max = 100;
                %                 end
                %
                %                 %Spelling error in D33_Instrument_Comissioning >> D33_Instrument_Commissioning
                %                 %Also Correct Data reader
                %                 if strcmp(grasp_env.inst_option,'D33_Instrument_Comissioning');
                %                     grasp_env.inst_option = 'D33_Instrument_Commissioning';
                %                     inst_params.filename.data_loader = 'raw_read_ill_nexus_d33_commissioning';
                %                 end
                %
                %                 %Data Type
                %                 if not(isfield(grasp_data,'data_type'))
                %                     disp('no data type field')
                %                     for index = 1:length(grasp_data)
                %                         for n = 1:grasp_data(index).nmbr
                %                             grasp_data(index).data_type{n} = 'single frame';
                %                         end
                %                     end
                %                 end
                %
                %
                %                 %Multibeam
                %                 if not(isfield(status_flags.analysis_modules,'multi_beam'));
                %                     %Multi Beam Parameters
                %                     status_flags.analysis_modules.multi_beam.number_beams_index = 2;
                %                     status_flags.analysis_modules.multi_beam.number_beams = 9; %Corresponding to index above
                %                     for n = 1:150 %Max possible number of beams
                %                         %Box Coords
                %                         status_flags.analysis_modules.multi_beam.box_beam_coordinates.(['beam' num2str(n)]).x1 = 0;
                %                         status_flags.analysis_modules.multi_beam.box_beam_coordinates.(['beam' num2str(n)]).x2 = 0;
                %                         status_flags.analysis_modules.multi_beam.box_beam_coordinates.(['beam' num2str(n)]).y1 = 0;
                %                         status_flags.analysis_modules.multi_beam.box_beam_coordinates.(['beam' num2str(n)]).y2 = 0;
                %
                %                         %Beam Centers
                %                         status_flags.analysis_modules.multi_beam.box_beam_coordinates.(['beam' num2str(n)]).cx = 0;
                %                         status_flags.analysis_modules.multi_beam.box_beam_coordinates.(['beam' num2str(n)]).cy = 0;
                %                     end
                %                     status_flags.analysis_modules.multi_beam.fit2d_checkbox = 0;
                %                     status_flags.analysis_modules.multi_beam.auto_mask_check = 1;
                %                     status_flags.analysis_modules.multi_beam.auto_mask_radius = 5;
                %                     status_flags.analysis_modules.multi_beam.beam_scale_check =1;
                %
                %                 end
                %
                %                 %Include 2D resolution
                %                 if not(isfield(status_flags.fitter,'include_res_check_2d'))
                %                     status_flags.fitter.include_res_check_2d = 0;
                %                     status_flags.resolution_control.xgrid_2d = 5;  %2D finesse X (number of grid points)
                %                     status_flags.resolution_control.ygrid_2d = 5;  %2D finesse Y (number of grid points)
                %                     status_flags.resolution_control.sigma_extent_2d = 2;  %2D sigma extent over which to build the gaussian
                %                 end
                %
                %                 %Show/Hide Minor Detectors e.g. D33 side panels
                %                 if not(isfield(status_flags.display,'show_minor_detectors'));
                %                     status_flags.display.show_minor_detectors = 'on'; %e.g. show/hide D33 side panels
                %                 end
                %
                %
                %
                %
                %Rebuild background & cadmium selector
                selector_build
                selector_build_values; %all
                initialise_2d_plots
                update_last_saved_project
                grasp_update
                
                
                %rescale to the saved axes limits
                %file_xlims = status_flags.axes.xlim;
                %file_ylims = status_flags.axes.ylim;
                %set(grasp_handles.displayimage.axis,'xlim',file_xlims);
                %set(grasp_handles.displayimage.axis,'ylim',file_ylims);
                
                %Now load any attachment figures that should be there also
                if not(isempty(attachment_figures))
                    for n = 1:length(attachment_figures)
                        %[project_dir attachment_name{n} '.fig']
                        test_exist = dir([directory attachment_figures{n} '.fig']);
                        if not(isempty(test_exist))
                            disp('Opening Project Attachment Figures');
                            warning off
                            uiopen([directory attachment_figures{n} '.fig'],1);
                            %Correct the handles stored in the saved figure
                            grasp_plot_handles = get(gcf,'userdata');
                            grasp_plot_handles.figure = gcf;
                            set(gcf,'userdata',grasp_plot_handles);
                            warning on
                            %                             %If 2D fit window, then update fitted conturs
                            %                             temp = findstr(attachment_2df{n},'_2Df');
                            %                             if not(isempty(temp)); fit2d_callbacks('update_fit_contours'); end
                        else
                            disp('Project Attachment Figures appear to be missing');
                        end
                    end
                end
            end
        end
        
        
    case 'sectors_color'
        
        status_flags.analysis_modules.sectors.sector_color = get(gcbo,'label');
        set(grasp_handles.menu.file.preferences.sectors_color,'checked','off');
        set(gcbo,'checked','on');
        %Update, if sectors are open
        if ishandle(grasp_handles.window_modules.sector.window)
            sector_callbacks;
        end
        
    case 'sector_box_color'
        status_flags.analysis_modules.sector_boxes.box_color = get(gcbo,'label');
        set(grasp_handles.menu.file.preferences.sector_box_color,'checked','off');
        set(gcbo,'checked','on');
        %Update, if sectors are open
        if ishandle(grasp_handles.window_modules.sector_box.window)
            sector_box_callbacks;
        end
        
    case 'box_color'
        status_flags.analysis_modules.boxes.box_color = get(gcbo,'label');
        set(grasp_handles.menu.file.preferences.box_color,'checked','off');
        set(gcbo,'checked','on');
        %Update, if sectors are open
        if ishandle(grasp_handles.window_modules.box.window)
            box_callbacks;
        end
        
        
    case 'close'
        %****** Check if to save data ********************
        %Compare each element in 'last_saved' to see if anything has changed
        current_project = struct(....
            'grasp_env',grasp_env,....
            'inst_params',inst_params,....
            'status_flags',status_flags,....
            'grasp_data',grasp_data);
        %Check if to save current project
        if ~isequal(current_project,last_saved)
            button = questdlg('Save Changes?','Close Project:','Cancel');
            if strcmp(button,'Yes')
                file_menu('save'); %Save project
            elseif strcmp(button,'Cancel')
                return
            end
        end
        
        %Close Window Modules
        file_menu('close_window_modules');
        
        %Close Grasp Changer Window
        try
            if ishandle(grasp_handles.grasp_changer.window)
                close(grasp_handles.grasp_changer.window);
                grasp_handles.grasp_changer.window = [];
            end
        catch
        end
        
        % reset calibration option
        status_flags.calibration.calibrate_check = 0;
        %Close any output figures
        %i = findobj('tag','grasp_plot');
        %if ishandle(i)
        %    close(i);
        %end
        if strcmp(options,'exit') %Make a quick exit here
            return
        else
            
            
            %Reinitialise all program workspaces & variables
            %initialise_environment_params
            grasp_env.project_title = 'UNTITLED';
            initialise_status_flags;
            %initialise_environment_params
            %grasp_ini
            %Re-initialise instrument
            [a,~] = split(grasp_env.inst,'_');
            facility = a{1}; instrument = a{2};
            inst_menu_callbacks('change',facility,instrument);
            %initialise_instrument_params;
            %initialise_grasp_handles
            initialise_data_arrays;
            selector_build;
            selector_build_values('all');
            grasp_update;
            update_last_saved_project;
            tool_callbacks('rescale');
        end
        
    case 'save'
        if strcmp(grasp_env.project_title,'UNTITLED')
            file_menu('save_as');
        else
            raw_save(grasp_env.path.project_dir, grasp_env.project_title);
        end
        
        
    case 'save_as'
        if strcmp(grasp_env.project_title,'UNTITLED')
            fname = [num2str(displayimage.params1.numor)]; %Suggest a file name based on numor range
        else
            fname = grasp_env.project_title;
        end
        start_string = [grasp_env.path.project_dir fname '.mat'];
        [fname, directory] = uiputfile(start_string,'Save Project');
        if fname == 0
        else
            grasp_env.project_title = fname; grasp_env.path.project_dir = directory;
            raw_save(grasp_env.path.project_dir, grasp_env.project_title);
            temp = findstr(grasp_env.project_title,'.mat'); %Check to stop '.mat's' propogating though project_title
            if not(isempty(temp)); grasp_env.project_title = grasp_env.project_title(1:temp-1); end
            grasp_update;
        end
        
        
    case 'set_project_dir'
        pathname = uigetdir(grasp_env.path.project_dir,'Please select your Project directory');
        if pathname ~= 0
            grasp_env.path.project_dir = [pathname filesep];
        end
        
        
    case 'set_data_dir'
        pathname = uigetdir(grasp_env.path.data_dir,'Please select your SANS data directory');
        if pathname ~= 0
            grasp_env.path.data_dir = [pathname filesep];
        end
        
        
    case 'set_filedata_dir'
        status_flags.fname_extension.extension=strcat(inst_params.filename.extension_string);
        temp = fullfile(grasp_env.path.data_dir,'*.*');
        [fname, pathname] = uigetfile(temp,'Please select SANS data in the choosen directory: For multiple selections hold cmd', 'MultiSelect','on');
        
        if ~iscell(fname)
            if fname == 0
                return
            end
        end
        
        % else
        if ischar(pathname)
            grasp_env.path.data_dir = pathname;
        else
            grasp_env.path.data_dir = pathname(1);
        end
        %See if there is an extension, e.g. .nxs, .dat etc
        [fname,extension] = strtok(fname,'.');
        
        if ischar(extension)
            set(grasp_handles.figure.data_ext,'string',extension);
            inst_params.filename.extension_string = extension;
        else
            set(grasp_handles.figure.data_ext,'string',extension{1});
            inst_params.filename.extension_string = extension{1};
        end
        
        %Strip the Leadstring name part from the total filename, e.g. for HMI, SINQ, NIST, Strip the e.g. xxx1234.dat
       
        if strcmp(grasp_env.inst,'FRM2_kws2') %Special case for kws2 complex file name
            temp = strfind(fname,'_');
            inst_params.filename.lead_string = fname(1:temp(1));
            inst_params.filename.extension_string = [fname(temp(2):end) inst_params.filename.extension_string];  %this should maybe go into the tail_string instead
            fname = fname(temp(1)+1:temp(2)-1); %this becomes the numor
            
            
        else
            
            if ischar(fname) %all other instruments
                inst_params.filename.lead_string = regexprep(fname,'\d',''); %find the NON numeric ASCII codes (and numbers between non numeric codes)
            else
                inst_params.filename.lead_string = regexprep(fname{1},'\d','');
            end
            fname = regexprep(fname,'\D',''); %find the numeric ASCII codes (and numbers between non numeric codes)
        end
        
        
        %                status_flags.fname_extension.shortname = [];
        
        
        set(grasp_handles.figure.data_lead,'string',inst_params.filename.lead_string);
        
        %             %For FRM2_Mira Strip the ShortName part from the total filename
        %                 set(grasp_handles.figure.data_lead,'string',status_flags.fname_extension.shortname);
        %                 fname = fname(max(i)+1:length(fname));
        %             end
        
        %Check numeric length agrees with that given by the instrument config .ini file
        if ischar(fname)
            if length(fname) == inst_params.filename.numeric_length
                %all is ok
            else
                inst_params.filename.numeric_length = length(fname);
            end
        else
            if max(cellfun('length',fname)) == inst_params.filename.numeric_length
                %all is ok
            else
                inst_params.filename.numeric_length = max(cellfun('length',fname));
            end
            
        end
        
        
        
        
        if ischar(fname)
        else
            fname=strjoin(fname,{', '});
        end
        
        set(grasp_handles.figure.data_load,'string',fname);
        % end
        
   
    case 'export_displayimage'
        
        [numor_str, directory, filterindex] = uiputfile('*.nxs', 'Export Display Image (Numeric file name)', [grasp_env.path.project_dir '000000']);
        
        numor = sscanf(numor_str, ['%d' '.dat'])';
        if numor_str ~=0 & not(isempty(numor))
            grasp_env.path.project_dir = directory;
            grasp_2d_nexus_write(directory,numor,displayimage);             %Export 2d nexus
        else
            disp('Bad filename - should be numeric without extension')
        end
        
    case 'export_displayimage_NISTformat'
        
        
        [numor_str, directory, filterindex] = uiputfile('*.dat', 'Export Display Image (Numeric file name)', [grasp_env.path.project_dir '000000']);
        
        
        numor = sscanf(numor_str, ['%d' '.dat'])';
        not(isempty(numor))
        if numor_str ~=0 & not(isempty(numor))
            grasp_env.path.project_dir = directory;
            grasp_2d_NIST_write(directory,numor);             %Export 2d data in NIST format
        else
            disp('Bad filename - should be numeric without extension')
        end
        
        
    case 'export_binary'
        
        [fname, directory] = uiputfile([grasp_env.path.project_dir '000000'],'Export Display Image');
        
        if fname ~=0
            grasp_env.path.project_dir = directory;
            fname = [directory fname];
            fid = fopen([fname '.dat'],'wb');
            fwrite(fid,displayimage.data1,'real*4');
            fclose(fid);
            fid = fopen([fname '.err'],'wb');
            fwrite(fid,displayimage.error1,'real*4');
            fclose(fid);
        end
        
        
    case 'export_efficiency_map'
        index = data_index(99); %Index to the det efficiency worksheet
        number = status_flags.selector.fn; %Index to det efficiency number
        det = status_flags.display.active_axis;
        eff_data = grasp_data(index).(['data' num2str(det)]){number};
        eff_err_data = grasp_data(index).(['error' num2str(det)]){number};
        disp(['Exporting Detector Efficiency Map for Detector #' num2str(det)]);
        uisave({'eff_data', 'eff_err_data'} ,[grasp_env.path.project_dir, 'detector_efficiency_det' num2str(det) '_' grasp_env.inst]);
    
     case 'export_mask'
        index = data_index(7); %Index to the det mask worksheet
        number = status_flags.display.mask.number; %Index to mask number
        det = status_flags.display.active_axis;
        mask_data = grasp_data(index).(['data' num2str(det)]){number};        
        disp(['Exporting Detector Mask for Detector #' num2str(det)]);
        uisave({'mask_data'} ,[grasp_env.path.project_dir, 'mask_det' num2str(det) '_' grasp_env.inst]);
            
        
    case 'export_depth_frames'
        
        first_file_str = '000001';
        first_file_numor = [];
        while isempty(first_file_numor)
            disp('Please enter a numeric Start File Numor and Directoy');
            [first_file_str, directory] = uiputfile([grasp_env.path.project_dir first_file_str],'Export Depth Frames (Raw Data)');
            first_file_numor = str2num(first_file_str);
        end
        
        index = data_index(status_flags.selector.fw);
        number = status_flags.selector.fn;
        depth = grasp_data(index).dpth{number};
        
        depth_data = grasp_data(index).data1{number};
        depth_params = grasp_data(index).params1{number};
        depth_parsub = grasp_data(index).subtitle{number};
        
        for n = 1:depth
            numor = first_file_numor + n -1;
            disp(['Exporting Depth Frame ' num2str(n) ' as Raw Data to file: ' num2str(numor)]);
            ill_sans_data_write(depth_data(:,:,n),depth_params(:,n),depth_parsub{n},numor,directory);
        end
        
        
    case 'import_efficiency_map'
        det = status_flags.display.active_axis;
        disp(['Importing Detector Efficiency Map for Detector #' num2str(det)])
        eff_fname = ['detector_efficiency_det' num2str(det) '_' grasp_env.inst '.mat'];
        [fname, pathname] = uigetfile(eff_fname,'Import Detector Efficiency File');
        if fname ~=0
            
            eff_data = load([pathname fname]);
            
            index = data_index(99); %Index to the det efficiency worksheet
            number = status_flags.selector.fn; %Index to det efficiency number
            
            %Check Imported Data is of the correct size for this detector
            size_eff_data = size(eff_data.eff_data);
            size_wks_det = size(grasp_data(index).(['data' num2str(det)]){number});
            if size_eff_data == size_wks_det
                grasp_data(index).(['data' num2str(det)]){number} = eff_data.eff_data;
                grasp_data(index).(['error' num2str(det)]){number} = eff_data.eff_err_data;
                disp('Success!')
                
                %Switch worksheet display to detector efficincy
                status_flags.selector.fw = 99;
                grasp_update;
            else
                disp('Error:  The size of the imported detector efficiency data does not match that of the chosen detector')
            end
        end
        
        case 'import_mask'
        det = status_flags.display.active_axis;
        disp(['Importing Mask for Detector #' num2str(det)])
        mask_fname = ['mask_det' num2str(det) '_' grasp_env.inst '.mat'];
        [fname, pathname] = uigetfile(mask_fname,'Import Mask File');
        if fname ~=0
            
            mask_data = load([pathname fname]);
            
            index = data_index(7); %Index to the mask worksheet
            number = status_flags.display.mask.number; %Index to det efficiency number
            
            %Check Imported Data is of the correct size for this detector
            size_mask_data = size(mask_data.mask_data);
            size_wks_det = size(grasp_data(index).(['data' num2str(det)]){number});
            if size_mask_data == size_wks_det
                grasp_data(index).(['data' num2str(det)]){number} = mask_data.mask_data;
                disp('Success!')
                
                %Switch worksheet display to detector efficincy
                status_flags.selector.fw = 7;
                grasp_update;
            else
                disp('Error:  The size of the imported Mask does not match that of the chosen detector')
            end
        end    
        

        
        
    case 'exit'
        button = file_menu('close','exit');
        if not(strcmp(button,'Cancel'))
            %Close Main Window
            set(grasp_handles.figure.grasp_main,'CloseRequestFcn','closereq');
            close(grasp_handles.figure.grasp_main);
            %Close All Sub Figures
            i = findobj('tag','plot_result');
            close(i);
        end
        
        
    case 'close_window_modules'
        
        %Close Window Modules
        window_module_names = fieldnames(grasp_handles.window_modules);
        n= length(window_module_names);
        for n = 1:n
            window_module_sub_names = getfield(grasp_handles.window_modules,window_module_names{n});
            if isfield(window_module_sub_names,'window')
                if ishandle(window_module_sub_names.window)
                    close(window_module_sub_names.window);
                end
            end
        end
        
    case 'show_resolution'
        if strcmp(status_flags.subfigure.show_resolution,'on')
            status_flags.subfigure.show_resolution = 'off';
        else
            status_flags.subfigure.show_resolution = 'on';
        end
        set(gcbo,'checked',status_flags.subfigure.show_resolution);
        
    case 'uisetfont'
        fontstruct = uisetfont('Set GRASP Font & Size');
        if isstruct(fontstruct)
            i = findobj('fontsize',grasp_env.fontsize);
            grasp_env.fontsize = fontstruct.FontSize;
            set(i,'fontsize',grasp_env.fontsize);
            %Set New Font
            i = findobj('fontname',grasp_env.font);
            grasp_env.font = fontstruct.FontName;
            set(i,'fontname',grasp_env.font);
        end
        
    case 'line_style'
        switch options
            case 'none'
                status_flags.display.linestyle = '';
            case 'solid'
                status_flags.display.linestyle = '-';
            case 'dotted'
                status_flags.display.linestyle = ':';
            case 'dashdot'
                status_flags.display.linestyle = '-.';
            case 'dahed'
                status_flags.display.linestyle = '--';
        end
        update_menus
        
        
    case 'linewidth'
        status_flags.display.linewidth = get(gcbo,'userdata');
        update_menus
        
    case 'markersize'
        status_flags.display.markersize = get(gcbo,'userdata');
        update_menus
        
    case 'invert_hardcopy'
        status_flags.display.invert_hardcopy = not(status_flags.display.invert_hardcopy);
        update_menus
        
    case 'save_sub_figures'
        status_flags.file.save_sub_figures = not(status_flags.file.save_sub_figures);
        update_menus
        
    case 'override_dataloader'
        if strcmp(status_flags.preferences.override_inbuild_dataloader,'on')
            status_flags.preferences.override_inbuild_dataloader = 'off';
        else
            status_flags.preferences.override_inbuild_dataloader = 'on';
        end
        update_menus
end
