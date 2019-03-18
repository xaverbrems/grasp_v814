function [data_out, data_out2] = radial_average_callbacks(to_do,options,options2)

global displayimage
global status_flags
global grasp_handles
global inst_params
global grasp_data

data_out = []; data_out2 = [];
if nargin <3; options2 = []; end
if nargin <2; options = ''; end
if nargin <1; to_do = ''; end


%Radial Average Window & Parameter Callbacks
switch to_do
    
    case 'post_av_stats_chk'
        status_flags.analysis_modules.averaging_filters.post_av_stats_chk = get(gcbo,'value');
        
    case 'post_av_stats_threshold'
        temp = str2num(get(gcbo,'string'));
        if not(isempty(temp))
            status_flags.analysis_modules.averaging_filters.post_av_stats_threshold = temp;
        else
            set(gcbo,'string',num2str(status_flags.analysis_modules.averaging_filters.post_av_stats_threshold));
        end
        
    case 'pre_av_res_chk'
        status_flags.analysis_modules.averaging_filters.pre_av_res_chk = get(gcbo,'value');
        
    case 'pre_av_res_threshold'
        temp = str2num(get(gcbo,'string'));
        if not(isempty(temp))
            status_flags.analysis_modules.averaging_filters.pre_av_res_threshold = temp;
        else
            set(gcbo,'string',num2str(status_flags.analysis_modules.averaging_filters.pre_av_res_threshold));
        end
        
    case 'close'
        grasp_handles.window_modules.radial_average.window = [];
        return
    case 'q_bin_pixels'
        status_flags.analysis_modules.radial_average.q_bin_units = 'pixels';
        
    case 'q_bin_absolute'
        status_flags.analysis_modules.radial_average.q_bin_units = 'absolute';
        status_flags.analysis_modules.radial_average.q_bin_absolute_scale = options;
        
    case 'q_bin_resolution'
        status_flags.analysis_modules.radial_average.q_bin_units = 'resolution';
        
    case 'theta_bin_pixels'
        status_flags.analysis_modules.radial_average.theta_bin_units = 'pixels';
        
    case 'theta_bin_absolute'
        status_flags.analysis_modules.radial_average.theta_bin_units = 'absolute';
        status_flags.analysis_modules.radial_average.theta_bin_absolute_scale = options;
        
    case 'theta_bin_resolution'
        status_flags.analysis_modules.radial_average.theta_bin_units = 'resolution';
        
    case 'azimuth_bin_absolute'
        status_flags.analysis_modules.radial_average.azimuth_bin_units = 'absolute';
        
    case 'azimuth_bin_smart'
        status_flags.analysis_modules.radial_average.azimuth_bin_units = 'smart';
        
    case 'q_bin'
        temp = str2num(get(grasp_handles.window_modules.radial_average.q_bin,'string'));
        if not(isempty(temp))
            if strcmp(status_flags.analysis_modules.radial_average.q_bin_units,'pixels')
                status_flags.analysis_modules.radial_average.q_bin_pixels = temp;
            elseif strcmp(status_flags.analysis_modules.radial_average.q_bin_units,'absolute')
                status_flags.analysis_modules.radial_average.q_bin_absolute = temp;
            elseif strcmp(status_flags.analysis_modules.radial_average.q_bin_units,'resolution')
                status_flags.analysis_modules.radial_average.q_bin_resolution = temp;
            end
        end
        
    case 'theta_bin'
        temp = str2num(get(grasp_handles.window_modules.radial_average.theta_bin,'string'));
        if not(isempty(temp))
            if strcmp(status_flags.analysis_modules.radial_average.theta_bin_units,'pixels')
                status_flags.analysis_modules.radial_average.theta_bin_pixels = temp;
            elseif strcmp(status_flags.analysis_modules.radial_average.theta_bin_units,'absolute')
                status_flags.analysis_modules.radial_average.theta_bin_absolute = temp;
            elseif strcmp(status_flags.analysis_modules.radial_average.theta_bin_units,'resolution')
                status_flags.analysis_modules.radial_average.theta_bin_resolution = temp;
            end
        end
        
    case 'azimuth_bin'
        temp = str2num(get(grasp_handles.window_modules.radial_average.azimuth_bin,'string'));
        if not(isempty(temp))
            if strcmp(status_flags.analysis_modules.radial_average.azimuth_bin_units,'smart')
            elseif strcmp(status_flags.analysis_modules.radial_average.azimuth_bin_units,'absolute')
                status_flags.analysis_modules.radial_average.azimuth_bin_absolute = temp;
            end
        end
        
    case 'sector_mask_chk'
        status_flags.analysis_modules.radial_average.sector_mask_chk = not(status_flags.analysis_modules.radial_average.sector_mask_chk);
        
    case 'ellipse_mask_chk'
        status_flags.analysis_modules.radial_average.ellipse_mask_chk = not(status_flags.analysis_modules.radial_average.ellipse_mask_chk);
        
    case 'strip_mask_chk'
        status_flags.analysis_modules.radial_average.strip_mask_chk = not(status_flags.analysis_modules.radial_average.strip_mask_chk);
        
    case 'single_radio'
        status_flags.analysis_modules.radial_average.single_depth_radio = 0;
        %         set(grasp_handles.window_modules.radial_average.depth_combine_text,'visible','off');
        %         set(grasp_handles.window_modules.radial_average.depth_combine_check,'visible','off');
        
    case 'depth_radio'
        status_flags.analysis_modules.radial_average.single_depth_radio = 1;
        %         set(grasp_handles.window_modules.radial_average.depth_combine_text,'visible','on');
        %         set(grasp_handles.window_modules.radial_average.depth_combine_check,'visible','on');
        
    case 'tof_radio'
        status_flags.analysis_modules.radial_average.single_depth_radio = 2;
        %         set(grasp_handles.window_modules.radial_average.depth_combine_text,'visible','on');
        %         set(grasp_handles.window_modules.radial_average.depth_combine_check,'visible','on');
        
    case 'direct_to_file_check'
        status_flags.analysis_modules.radial_average.direct_to_file = get(gcbo,'value');
        
        
        
        
        
    case 'radial_average'
        
        switch options
            case 'q'
                av_type = 'radial_q_pixels';
                bin_type = 'radial_q_rebin';
                
            case '2theta'
                av_type = 'radial_theta_pixels';
                bin_type = 'radial_theta_bin';
                
            case 'azimuthal'
                av_type = 'azimuthal_angle';
                bin_type = 'azimuthal_bin';
                
        end
        
        %Calculates the IvsQ for all detectors and depending on
        %Single Averages, Multiple Averages though Depth or Combined
        %depth averages i.e. TOF data to single IvsQ curve
        
        depth_start = status_flags.selector.fd; %remember the initial foreground depth
        
        
        %Single Average of Current Display
        if status_flags.analysis_modules.radial_average.single_depth_radio == 0
            disp(['Averaging Current Display Data']);
            message_handle = grasp_message(['Averaging current display data']);
            [iq_list, resolution_data] = radial_average_callbacks(av_type);
            if isempty(iq_list); return; end
            resolution_data.history = [resolution_data.history, {['***** Analysis *****']}];
            resolution_data.history = [resolution_data.history, {['Averaging Current Display Data']}];
            plot_data(1) = radial_average_callbacks(bin_type,iq_list,resolution_data);
            %Depth or TOF
        else
            
            %Find and check validity of depth start and end
            index = data_index(status_flags.selector.fw);
            foreground_depth = status_flags.selector.fdpth_max - grasp_data(index).sum_allow;
            
            %Check if using depth max min
            if status_flags.selector.depth_range_chk ==1
                if status_flags.selector.depth_range_min > foreground_depth
                    d_start = 1;
                else
                    d_start = status_flags.selector.depth_range_min;
                end
                if status_flags.selector.depth_range_max > foreground_depth
                    d_end = 1;
                else
                    d_end = status_flags.selector.depth_range_max;
                end
            else
                d_start = 1;
                d_end = foreground_depth;
            end
            
            
            %Turn off graphic and command display for speed if required
            status_flags.command_window.display_params=0; status_flags.display.refresh = 0;
            
            
            
            %Depth - Scroll though depth either for individual depth averages
            if  status_flags.analysis_modules.radial_average.single_depth_radio == 1
                
                disp(['Averaging Worksheets through Depth']);
                message_handle = grasp_message(['Averaging worksheets through Depth: ' num2str(d_start) ' to ' num2str(d_end)]);
                %Churn though depth making all the averages and collecting all individual plot structures
                for n = d_start:d_end
                    status_flags.selector.fd = n+grasp_data(index).sum_allow;
                    main_callbacks('depth_scroll'); %Scroll all linked depths and update
                    [iq_list, resolution_data] = radial_average_callbacks(av_type);
                    if isempty(iq_list); return; end
                    resolution_data.history = [resolution_data.history, {['***** Analysis *****']}];
                    resolution_data.history = [resolution_data.history, {['Averaging Worksheets through Depths  ' num2str(d_start) ':' num2str(d_end)]}];
                    resolution_data.history = [resolution_data.history, {['Numor:  ' num2str(displayimage.params1.numor)]}];
                    plot_data(n-d_start+1) = radial_average_callbacks(bin_type,iq_list,resolution_data);
                end
                
                %Depth TOF rebin
            elseif status_flags.analysis_modules.radial_average.single_depth_radio == 2
                
                %Pre-allocate matirx for all pixels for speed
                n_depths = d_end-d_start+1; pixels_per_depth = 0;
                for det = 1:inst_params.detectors
                    det_pixels = inst_params.(['detector' num2str(det)]).pixels;
                    pixels_per_depth = pixels_per_depth + det_pixels(1)*det_pixels(2);
                end
                total_pixels = pixels_per_depth * n_depths;
                iq_list = zeros(total_pixels,8);
                
                disp(['TOF averaging of worksheets though Depth']);
                message_handle = grasp_message(['TOF averaging worksheets through depth: ' num2str(d_start) ' to ' num2str(d_end)]);
                %Churn though depth collecting all pixels to TOF rebin
                for n = d_start:d_end
                    status_flags.selector.fd = n + grasp_data(index).sum_allow;
                    main_callbacks('depth_scroll'); %Scroll all linked depths and update
                    [iq_list_depth,resolution_data] = radial_average_callbacks(av_type);
                    pointer = (n-d_start)*pixels_per_depth + 1;
                    l = length(iq_list_depth);
                    iq_list((pointer:l+pointer-1),1:size(iq_list_depth,2)) = iq_list_depth;
                end
                resolution_data.history = [resolution_data.history, {['***** Analysis *****']}];
                resolution_data.history = [resolution_data.history, {['TOF averaging of worksheets though Depths  ' num2str(d_start) ':' num2str(d_end)]}];
                resolution_data.history = [resolution_data.history, {['Numors:  ' num2str(displayimage.params1.numor)]}];
                
                
                temp = sum(iq_list,2)~=0;
                iq_list = iq_list(temp,:);
                if isempty(iq_list); return; end
                plot_data(1) = radial_average_callbacks(bin_type,iq_list,resolution_data);
            end
            
            
            %Set depth selector back to as before
            status_flags.selector.fd = depth_start;
            main_callbacks('depth_scroll'); %Scroll all linked depths and update
            grasp_update
        end
        
        %Turn back on graphic and command display & delete message
        delete(message_handle);
        status_flags.display.refresh = 1; status_flags.command_window.display_params = 1;
        
        %****** Now Plot the single or many e.g. IvsQ curves here *******
        if status_flags.analysis_modules.radial_average.direct_to_file == 0 %plot curves
            grasp_plot2(plot_data);
        else %Direct to file
            direct_to_file(plot_data);
        end
        
        
        
        
    case 'radial_q_pixels'
        
        %Check for Sector Masks
        smask = [];
        if status_flags.analysis_modules.radial_average.sector_mask_chk ==1
            %Check sector window is still open
            if ishandle(grasp_handles.window_modules.sector.window)
                smask = sector_callbacks('build_sector_mask');
            else
                status_flags.analysis_modules.radial_average.sector_mask_chk =0;
            end
        end
        
        %Check for Strip Masks
        strip_mask = [];
        if status_flags.analysis_modules.radial_average.strip_mask_chk ==1
            %Check if strip window is still open
            if ishandle(grasp_handles.window_modules.strips.window)
                strip_mask = strips_callbacks('build_strip_mask');
            else
                status_flags.analysis_modules.radial_average.strip_mask_chk =0;
            end
        end
        
        data_out = [];
        for det = 1:inst_params.detectors
            detno=num2str(det);
            if status_flags.display.(['axis' detno '_onoff']) ==1 %i.e. Detector is Active
                
                %Check current displayimage is not empty
                if sum(sum(displayimage.(['data' detno])))==0
                    disp(['Detector ' detno ' data empty']);
                else
                    
                    %Prepare any aditional masks, e.g. sector & strip masks.
                    mask = displayimage.(['mask' detno]);  %This is the combined user & instrument mask
                    %Add the Sector Mask
                    if not(isempty(smask)); mask = mask.*smask.(['det' detno]); end
                    %Add the Strip Mask
                    if not(isempty(strip_mask)); mask = mask.*strip_mask.(['det' detno]); end
                    
                    %***** Turn 2D detector data into list(s) for re-binning *****
                    %Turn 2D data into a list for re-binning
                    temp = displayimage.(['qmatrix' detno])(:,:,5); %mod_q
                    temp2 = displayimage.(['qmatrix' detno])(:,:,13); %delta_q (FWHM) - Classic Resolution
                    temp3 = displayimage.(['qmatrix' detno])(:,:,11); %delta_q_lambda (FWHM)
                    temp4 = displayimage.(['qmatrix' detno])(:,:,12); %delta_q_theta (FWHM)
                    temp5 = displayimage.(['qmatrix' detno])(:,:,18); %delta_q_pixel (FWHM)
                    temp6 = displayimage.(['qmatrix' detno])(:,:,19); %delta_q_sample_aperture (FWHM)
                    %temp8 = displayimage.(['qmatrix' detno])(:,:,3); %qx
                    %temp9 = displayimage.(['qmatrix' detno])(:,:,4); %qy
                    
                    iq_list_det = [];
                    iq_list_det(:,1) = temp(logical(mask)); %mod q
                    iq_list_det(:,2) = displayimage.(['data' detno])(logical(mask)); %Intensity
                    iq_list_det(:,3) = displayimage.(['error' detno])(logical(mask)); %err_Intensity
                    iq_list_det(:,4) = temp2(logical(mask)); %delta_q FWHM
                    iq_list_det(:,5) = temp3(logical(mask)); %delta_q_lambda FWHM
                    iq_list_det(:,6) = temp4(logical(mask)); %delta_q_theta FWHM
                    iq_list_det(:,7) = temp5(logical(mask)); %delta_q_pixel FWHM
                    iq_list_det(:,8) = temp6(logical(mask)); %delta_q_sample_aperture FWHM
                    %iq_list_det(:,9) = temp8(logical(mask));
                    %iq_list_det(:,10) = temp9(logical(mask));
                    
                    
                    data_out = [data_out; iq_list_det]; %This is the raw list of un-binned I vs. Q's
                    data_out2.(['resolution_data' detno]) = displayimage.(['resolution_data' detno]);
                    data_out2.resolution_data0 = displayimage.resolution_data0; %General resolution description - not detector specific
                end
            end
        end
        data_out2.history = displayimage.history;
        
    case 'radial_q_rebin'
        
        iq_list = options; %[mod_q, I, err_I, .....]
        resolution_data0 = options2.resolution_data0;
        history = options2.history;
        
        if isempty(iq_list)
            disp('Nothing to rebin')
            return;
        end
        
        %Apply pre-average filters
        if status_flags.analysis_modules.averaging_filters.pre_av_res_chk == 1 %Switch within the averaging filters window
            disp('Filter:  Pre Averaging Resolution Filter')
            %Resolution filters
            l1 = length(iq_list);
            d_q_q = iq_list(:,4) ./ iq_list(:,1);
            temp = d_q_q <= status_flags.analysis_modules.averaging_filters.pre_av_res_threshold;
            iq_list = iq_list(temp,:);
            l2 = length(iq_list);
            disp(['         Rejecting ' num2str(100*(l1-l2)/l1) ' [%] of pixel data'])
            
        end
        
        
        %Generate Bin_Edges
        x_min = min(iq_list(:,1)); x_max = max(iq_list(:,1));
        detno=num2str(1);%So below takes parameters from main detector
        switch status_flags.analysis_modules.radial_average.q_bin_units
            case 'pixels'
                bin_step = status_flags.analysis_modules.radial_average.q_bin_pixels;
                if ~contains(history{end},'Averaging I vs. Q')
                    history = [history, {['Averaging I vs. Q.  Bin size:  ' num2str(status_flags.analysis_modules.radial_average.q_bin_pixels) ' [Pixel(s)]']}];
                end
                %Calculate bin edges based on pixel steps across the detector *****
                %Calculate delta_q across 1 pixel at q=0
                %The wavelength used to calculate delta_q is taken from the
                %displayimage params.  i.e. Single - current displayed image
                %wav, Individual depths - wav of each depth, TOF wav taken from
                %last displayed image in the depth range, i.e. usually the longest wav therefore smallest delta_q
                delta_q = (4*pi / displayimage.(['params' detno]).wav) * ((max(inst_params.(['detector' detno]).pixel_size) *1e-3 * bin_step)/displayimage.(['params' detno]).det)/2;
                bin_edges = x_min; bin_edge = x_min;
                while bin_edge < x_max
                    bin_edge = bin_edge + delta_q;
                    bin_edges = [bin_edges, bin_edge];
                end
                
            case 'absolute'
                bin_step = status_flags.analysis_modules.radial_average.q_bin_absolute;
                if ~contains(history{end},'Averaging I vs. Q')
                    history = [history, {['Averaging I vs. Q.  Bin size:  ' num2str(status_flags.analysis_modules.radial_average.q_bin_absolute) ' [???-1]  '  status_flags.analysis_modules.radial_average.q_bin_absolute_scale]}];
                end
                %Check if using linear or log bins
                if strcmp(status_flags.analysis_modules.radial_average.q_bin_absolute_scale,'linear')
                    %Constant bin size across data_range
                    bin_edges = (x_min-bin_step):bin_step:(x_max+bin_step);
                elseif strcmp(status_flags.analysis_modules.radial_average.q_bin_absolute_scale,'log10')
                    step = (log10(x_min+bin_step)) - log10(x_min); %Size of the first low q bin in log10 space
                    log_edges = (log10(x_min-bin_step)):step:(log10(x_max+bin_step));
                    bin_edges = 10.^log_edges;
                end
                
            case 'resolution'
                if x_min==0; x_min = eps; end %this avoids an error when the beam centre has not been set and is left on 64,64
                bin_edges = [x_min];
                while bin_edges(length(bin_edges)) < x_max
                    %Find the closest data q-point to this q
                    temp = iq_list(:,1) - bin_edges(length(bin_edges));
                    temp = abs(temp);
                    [~, itemp] = min(temp);
                    delta_q_fraction = iq_list(itemp,4) / status_flags.analysis_modules.radial_average.q_bin_resolution;
                    bin_edges = [bin_edges, bin_edges(length(bin_edges))+delta_q_fraction];
                end
                if ~contains(history{end},'Averaging I vs. Q')
                    history = [history, {['Averaging I vs. Q.  Bin size:  ' num2str(status_flags.analysis_modules.radial_average.q_bin_resolution) ' [Fractional Resolution]  '  status_flags.analysis_modules.radial_average.q_bin_absolute_scale]}];
                end
        end
        
        if length(bin_edges) <2
            disp('Error generating Bin_Edges - not enough Bins')
            disp('Please check re-binning paramters');
            
        else
            
            %***** Now re-bin the iq_list of raw pixels from all detectors *****
            disp('Rebinning .....');tic
            
            iq_data = rebin(iq_list,bin_edges);
            disp(['......done.... ' num2str(toc) '[s]'])
            
            
            %Apply post-average filters
            if status_flags.analysis_modules.averaging_filters.post_av_stats_chk == 1 %Switch within the averaging filters window
                disp('Filter:  Post Averaging Statistics Filter')
                %Apply Statistics Filter
                l1 = length(iq_data);
                d_i_i = iq_data(:,3) ./ abs(iq_data(:,2));
                temp = find(d_i_i <= status_flags.analysis_modules.averaging_filters.post_av_stats_threshold);
                iq_data = iq_data(temp,:);
                l2 = length(temp);
                disp(['         Rejecting ' num2str(100*(l1-l2)/l1) ' [%] of Binned data'])
            end
            
            
            %append the iq data from the different bins together
            %Note: Note, output from rebin is:
            %iq_data(:,1) = mod_q
            %iq_data(:,2) = Intensity
            %iq_data(:,3) = Err_Intensity
            %iq_data(:,4) = delta_q Classic q-resolution
            %iq_data(:,5) = delta_q Lambda
            %iq_data(:,6) = delta_q Theta
            %iq_data(:,7) = delta_q Detector Pixels
            %iq_data(:,8) = delta_q Sample Aperture
            %iq_data(:,9) = delta_q Binning (FWHM Square) - always next to last
            %iq_data(:,10) = # elements - always last
            
            %If enabled (ticked) add the binning resolution (FWHM) to the classic q-resolution (FWHM)
            if status_flags.resolution_control.binning_check == 1
                %convert both back to sigma before adding in quadrature
                sigma1 = iq_data(:,4)/2.3548; %Came as a Gaussian FWHM
                sigma2 = iq_data(:,9)/3.4; %Came as a Square FWHM
                sigma = sqrt( sigma1.^2 + sigma2.^2 ); %Gaussian Equivalent
                fwhm = sigma * 2.3548;
                iq_data(:,4) = fwhm;
            end
            
        end
        
        %Check all the detector data wasn't empty
        if isempty(iq_data)
            disp(['All detector data was empty:  Nothing to rebin']);
            return
        end
        
        %***** Build Resolution Kernels for every q point *****
        kernel_data.fwhmwidth = status_flags.resolution_control.fwhmwidth;
        kernel_data.finesse = status_flags.resolution_control.finesse * status_flags.resolution_control.fwhmwidth;
        if not(isodd(kernel_data.finesse)); kernel_data.finesse = kernel_data.finesse+1; end %Finesse should be ODD number
        
        kernel_data.classic_res.fwhm = iq_data(:,4); kernel_data.classic_res.shape = resolution_data0.classic_res_shape;
        kernel_data.lambda.fwhm = iq_data(:,5); kernel_data.lambda.shape = resolution_data0.lambda_shape;
        kernel_data.theta.fwhm = iq_data(:,6); kernel_data.theta.shape = resolution_data0.theta_shape;
        kernel_data.pixel.fwhm = iq_data(:,7); kernel_data.pixel.shape = resolution_data0.pixel_shape;
        kernel_data.binning.fwhm = iq_data(:,9); kernel_data.binning.shape = 'tophat';
        kernel_data.aperture.fwhm = iq_data(:,8); kernel_data.aperture.shape = resolution_data0.aperture_shape;
        kernel_data.cm = displayimage.cm.(['det' detno]); %Send real beam profile in to use for resolution smearing
        %Build the kernels
        resolution_data = build_resolution_kernels(iq_data(:,1), kernel_data);
        
        if strcmp(status_flags.subfigure.show_resolution,'on')
            column_format = 'xyhe'; %Show resolution
            %Note, need to swap colums around for the ploterr fn.  Need [x,y,err_x,err_y]
            plotdata = [iq_data(:,1:2),iq_data(:,4),iq_data(:,3)];% IvsQ, Horz Delta_q FWHM and Vert Err_I error bars
        else
            column_format = 'xye'; %Do not show resolution.
            %Note, uses Matlab errorbar fn.  Need [x,y,err_y]
            plotdata = [iq_data(:,1:3)];
        end
        
        plot_info = struct(....
            'plot_type','plot',....
            'plot_data',plotdata,....
            'column_format',column_format,....
            'resolution_kernels',resolution_data,....
            'plot_title',['Radial Re-grouping: |q|'],....
            'x_label',['|q| (' char(197) '^{-1})'],....
            'y_label',displayimage.units,....
            'legend_str',['#' num2str(displayimage.params1.numor)],....
            'params',displayimage.params1,....
            'subtitle',displayimage.params1.subtitle,....
            'export_data',iq_data(:,1:4),.... %[q, I, err_I, dq resolutuion(fwhm)]
            'export_column_format','xyeh',....
            'export_column_labels',['Mod_Q   ' char(9) 'I       ' char(9) 'Err_I   ' char(9) 'FWHM_Q']);
        plot_info.history = history;
        data_out = plot_info;
        
        
        
    case 'radial_theta_pixels'
        
        %Check for Sector Masks
        smask = [];
        if status_flags.analysis_modules.radial_average.sector_mask_chk ==1
            %Check sector window is still open
            if ishandle(grasp_handles.window_modules.sector.window)
                smask = sector_callbacks('build_sector_mask');
            else
                status_flags.analysis_modules.radial_average.sector_mask_chk =0;
            end
        end
        
        %Check for Strip Masks
        strip_mask = [];
        if status_flags.analysis_modules.radial_average.strip_mask_chk ==1
            %Check if strip window is still open
            if ishandle(grasp_handles.window_modules.strips.window)
                strip_mask = strips_callbacks('build_strip_mask');
            else
                status_flags.analysis_modules.radial_average.strip_mask_chk =0;
            end
        end
        
        data_out = [];
        for det = 1:inst_params.detectors
            detno=num2str(det);
            if status_flags.display.(['axis' detno '_onoff']) ==1 %i.e. Detector is Active
                
                %Check current displayimage is not empty
                if sum(sum(displayimage.(['data' detno])))==0
                    disp(['Detector ' detno ' data empty']);
                else
                    
                    %Prepare any aditional masks, e.g. sector & strip masks.
                    mask = displayimage.(['mask' detno]);  %This is the combined user & instrument mask
                    %Add the Sector Mask
                    if not(isempty(smask)); mask = mask.*smask.(['det' detno]); end
                    %Add the Strip Mask
                    if not(isempty(strip_mask)); mask = mask.*strip_mask.(['det' detno]); end
                    
                    
                    %***** Turn 2D detector data into list(s) for re-binning *****
                    %Turn 2D data into a list for re-binning
                    temp = displayimage.(['qmatrix' detno])(:,:,9); %mod_2theta
                    temp2 = displayimage.(['qmatrix' detno])(:,:,17)*2; %delta_2theta (FWHM)
                    
                    
                    
                    iq_list_det = [];
                    iq_list_det(:,1) = temp(logical(mask)); %mod_2theta
                    iq_list_det(:,2) = displayimage.(['data' detno])(logical(mask)); %Intensity
                    iq_list_det(:,3) = displayimage.(['error' detno])(logical(mask)); %err_Intensity
                    iq_list_det(:,4) = temp2(logical(mask)); %delta_2theta
                    
                    
                    
                    data_out = [data_out; iq_list_det]; %This is the raw list of un-binned I vs. Q's
                    
                    data_out2.(['resolution_data' detno]) = displayimage.(['resolution_data' detno]);
                    data_out2.resolution_data0 = displayimage.resolution_data0; %General resolution description - not detector specific
                end
            end
        end
        data_out2.history = displayimage.history;
        
        
        
        
        
    case 'radial_theta_bin'
        
        iq_list = options; %[mod_2theta, I, err_I, .....]
        resolution_data = options2;
        history = options2.history;
        
        
        %Generate Bin_Edges
        x_min = min(iq_list(:,1)); x_max = max(iq_list(:,1));
        detno=num2str(1);%So below takes parameters from main detector
        
        if strcmp(status_flags.analysis_modules.radial_average.theta_bin_units,'pixels')
            bin_step = status_flags.analysis_modules.radial_average.theta_bin_pixels;
            history = [history, {['Averaging I vs. 2Theta.  Bin size:  ' num2str(status_flags.analysis_modules.radial_average.theta_bin_pixels) ' [Pixel(s)]']}];
            
            %Calculate bin edges based on pixel steps across the detector *****
            %Calculate delta_2theta across 1 pixel at q=0
            delta_2theta = ((180/pi)* (max(inst_params.detector1.pixel_size)) *1e-3 * bin_step)/displayimage.params1.det;
            bin_edges = x_min; bin_edge = x_min;
            while bin_edge < x_max
                bin_edge = bin_edge + delta_2theta;
                bin_edges = [bin_edges, bin_edge];
            end
            
        elseif strcmp(status_flags.analysis_modules.radial_average.theta_bin_units,'absolute')
            bin_step = status_flags.analysis_modules.radial_average.theta_bin_absolute;
            history = [history, {['Averaging I vs. 2Theta.  Bin size:  ' num2str(status_flags.analysis_modules.radial_average.theta_bin_absolute) ' [???-1]  '  status_flags.analysis_modules.radial_average.theta_bin_absolute_scale]}];
            %Check if using linear or log bins
            if strcmp(status_flags.analysis_modules.radial_average.theta_bin_absolute_scale,'linear')
                %Constant bin size across data_range
                bin_edges = x_min:bin_step:x_max;
            elseif strcmp(status_flags.analysis_modules.radial_average.theta_bin_absolute_scale,'log10')
                step = (log10(x_min+bin_step)) - log10(x_min); %Size of the first low q bin in log10 space
                log_edges = floor(log10(x_min)):step:ceil(log10(x_max));
                bin_edges = 10.^log_edges;
            end
            
        elseif strcmp(status_flags.analysis_modules.radial_average.theta_bin_units,'resolution')
            twothetamin = min(iq_list(:,1)); twothetamax = max(iq_list(:,1));
            if twothetamin==0; twothetamax = eps; end %this avoids an error when the beam centre has not been set and is left on 64,64
            bin_edges = [twothetamin];
            while bin_edges(length(bin_edges)) < twothetamax
                %Find the closest data 2th-point to this 2th
                temp = iq_list(:,1) - bin_edges(length(bin_edges));
                temp = abs(temp);
                [~, itemp] = min(temp);
                twotheta_fraction = iq_list(itemp,4) / status_flags.analysis_modules.radial_average.theta_bin_resolution;
                bin_edges = [bin_edges, bin_edges(length(bin_edges))+twotheta_fraction];
                history = [history, {['Averaging I vs. 2Theta.  Bin size:  ' num2str(status_flags.analysis_modules.radial_average.theta_bin_resolution) ' [Fractional Resolution]  '  status_flags.analysis_modules.radial_average.theta_bin_absolute_scale]}];
            end
        end
        
        if length(bin_edges) <2
            disp('Error generating Bin_Edges - not enough Bins')
            disp('Please check re-binning paramters');
        end
        
        
        
        
        
        %***** Now re-bin the iq_list of raw pixels from all detectors *****
        disp('Rebinning .....');tic
        
        iq_data = rebin(iq_list,bin_edges);
        %                         temp = rebin([iq_list(:,1),iq_list(:,2),iq_list(:,3),iq_list(:,4)],bin_edges); %[two_theta,I,errI,delta_two_theta,pixel_count]
        disp(['......done.... ' num2str(toc) '[s]'])
        
        
        %Apply post-average filters
        if status_flags.analysis_modules.averaging_filters.post_av_stats_chk == 1 %Switch within the averaging filters window
            disp('Filter:  Post Averaging Statistics Filter')
            %Apply Statistics Filter
            l1 = length(iq_data);
            d_i_i = iq_data(:,3) ./ abs(iq_data(:,2));
            temp = find(d_i_i <= status_flags.analysis_modules.averaging_filters.post_av_stats_threshold);
            iq_data = iq_data(temp,:);
            l2 = length(temp);
            disp(['         Rejecting ' num2str(100*(l1-l2)/l1) ' [%] of Binned data'])
        end
        
        
        
        %append the iq data from the different bins together
        %Note: Note, output from rebin is:
        %iq_data(:,1) = mod_2theta
        %iq_data(:,2) = Intensity
        %iq_data(:,3) = Err_Intensity
        %iq_data(:,4) = delta_2theta
        %iq_data(:,5) = Binning resolution(FWHM Square) - always next to last
        %iq_data(:,6) = # elements - always last
        
        %If enabled (ticked) add the binning resolution (FWHM) to the classic q-resolution (FWHM)
        if status_flags.resolution_control.binning_check == 1
            %convert both back to sigma before adding in quadrature
            sigma1 = iq_data(:,4)/2.3548; %Came as a Gaussian FWHM
            sigma2 = iq_data(:,5)/3.4; %Came as a Square FWHM
            sigma = sqrt( sigma1.^2 + sigma2.^2 ); %Gaussian Equivalent
            fwhm = sigma * 2.3548;
            iq_data(:,4) = fwhm;
        end
        
        
        %Check all the detector data wasn't empty
        if isempty(iq_data)
            disp(['All detector data was empty:  Nothing to rebin']);
            return
        end
        
        %         %***** Build Resolution Kernels for every q point *****
        %         kernel_data.fwhmwidth = status_flags.resolution_control.fwhmwidth;
        %         kernel_data.finesse = status_flags.resolution_control.finesse * status_flags.resolution_control.fwhmwidth;
        %         if not(isodd(kernel_data.finesse)); kernel_data.finesse = kernel_data.finesse+1; end %Finesse should be ODD number
        %
        %         kernel_data.classic_res.fwhm = iq_data(:,4); kernel_data.classic_res.shape = resolution_data.resolution_data0.classic_res_shape;
        %         kernel_data.lambda.fwhm = iq_data(:,5); kernel_data.lambda.shape = resolution_data.resolution_data0.lambda_shape;
        %         kernel_data.theta.fwhm = iq_data(:,6); kernel_data.theta.shape = resolution_data.resolution_data0.theta_shape;
        %         kernel_data.pixel.fwhm = iq_data(:,7); kernel_data.pixel.shape = resolution_data.resolution_data0.pixel_shape;
        %         kernel_data.binning.fwhm = iq_data(:,9); kernel_data.binning.shape = 'tophat';
        %         kernel_data.aperture.fwhm = iq_data(:,8); kernel_data.aperture.shape = resolution_data.resolution_data0.aperture_shape;
        %         kernel_data.cm = displayimage.cm.(['det' detno]); %Send real beam profile in to use for resolution smearing
        %         %Build the kernels
        %         resolution_data = build_resolution_kernels(iq_data(:,1), kernel_data);
        
        if strcmp(status_flags.subfigure.show_resolution,'on')
            column_format = 'xyhe'; %Show resolution
            %Note, need to swap colums around for the ploterr fn.  Need [x,y,err_x,err_y]
            plotdata = [iq_data(:,1:2),iq_data(:,4),iq_data(:,3)];% IvsQ, Horz Delta_q FWHM and Vert Err_I error bars
        else
            column_format = 'xye'; %Do not show resolution.
            %Note, uses Matlab errorbar fn.  Need [x,y,err_y]
            plotdata = [iq_data(:,1:3)];
        end
        
        plot_info = struct(....
            'plot_type','plot',....
            'plot_data',plotdata,....
            'column_format',column_format,....
            'resolution_kernels',resolution_data,....
            'plot_title',['Radial Re-grouping: 2Theta'],....
            'x_label',['2Theta [Degrees]'],....
            'y_label',displayimage.units,....
            'legend_str',['#' num2str(displayimage.params1.numor)],....
            'params',displayimage.params1,....
            'subtitle',displayimage.params1.subtitle,....
            'export_data',iq_data(:,1:4),.... %[2theta, I, err_I, d_2theta resolutuion(fwhm)]
            'export_column_format','xyeh',....
            'export_column_labels',['Two_Theta   ' char(9) 'I       ' char(9) 'Err_I   ' char(9) 'FWHM_2Theta']);
        plot_info.history = history;
        data_out = plot_info;
        
        
        
        
    case 'azimuthal_angle'
        
        %Check for Sector Masks
        smask = [];
        if status_flags.analysis_modules.radial_average.sector_mask_chk ==1
            %Check sector window is still open
            if ishandle(grasp_handles.window_modules.sector.window)
                smask = sector_callbacks('build_sector_mask');
            else
                status_flags.analysis_modules.radial_average.sector_mask_chk =0;
            end
        end
        
        %Check for Strip Masks
        strip_mask = [];
        if status_flags.analysis_modules.radial_average.strip_mask_chk ==1
            %Check if strip window is still open
            if ishandle(grasp_handles.window_modules.strips.window)
                strip_mask = strips_callbacks('build_strip_mask');
            else
                status_flags.analysis_modules.radial_average.strip_mask_chk =0;
            end
        end
        
        data_out = [];
        for det = 1:inst_params.detectors
            detno=num2str(det);
            if status_flags.display.(['axis' detno '_onoff']) ==1 %i.e. Detector is Active
                
                %Check current displayimage is not empty
                if sum(sum(displayimage.(['data' detno])))==0
                    disp(['Detector ' detno ' data empty']);
                else
                    
                    %Prepare any aditional masks, e.g. sector & strip masks.
                    mask = displayimage.(['mask' detno]);  %This is the combined user & instrument mask
                    %Add the Sector Mask
                    if not(isempty(smask)); mask = mask.*smask.(['det' detno]); end
                    %Add the Strip Mask
                    if not(isempty(strip_mask)); mask = mask.*strip_mask.(['det' detno]); end
                    
                    %***** Turn 2D detector data into list(s) for re-binning *****
                    %Turn 2D data into a list for re-binning
                    temp = displayimage.(['qmatrix' detno])(:,:,6); %q_angle
                    iq_list_det = [];
                    iq_list_det(:,1) = temp(logical(mask)); %q-angle
                    iq_list_det(:,2) = displayimage.(['data' detno])(logical(mask)); %Intensity
                    iq_list_det(:,3) = displayimage.(['error' detno])(logical(mask)); %err_Intensity
                    
                    data_out = [data_out; iq_list_det]; %This is the raw list of un-binned I vs. Q's
                    data_out2.(['resolution_data' detno]) = displayimage.(['resolution_data' detno]);
                    data_out2.resolution_data0 = displayimage.resolution_data0; %General resolution description - not detector specific
                end
            end
        end
        data_out2.history = displayimage.history;
        
        
    case 'azimuthal_bin'
        
        iq_list = options; %[az_angle, I, err_I, .....]
        resolution_data0 = options2.resolution_data0;
        history = options2.history;
        
        if isempty(iq_list)
            disp('Nothing to rebin')
            return;
        end
        
        %Apply pre-average filters
        if status_flags.analysis_modules.averaging_filters.pre_av_res_chk == 1 %Switch within the averaging filters window
            disp('Filter:  Pre Averaging Resolution Filter')
            %Resolution filters
            l1 = length(iq_list);
            d_q_q = iq_list(:,4) ./ iq_list(:,1);
            temp = d_q_q <= status_flags.analysis_modules.averaging_filters.pre_av_res_threshold;
            iq_list = iq_list(temp,:);
            l2 = length(iq_list);
            disp(['         Rejecting ' num2str(100*(l1-l2)/l1) ' [%] of pixel data'])
            
        end
        
        
        
        %Generate Bin Edges
        if strcmp(status_flags.analysis_modules.radial_average.azimuth_bin_units,'absolute')
            bin_step = status_flags.analysis_modules.radial_average.azimuth_bin_absolute;
            bin_edges = 0:bin_step:359.999;
        end
        history = [history, {['Averaging I vs. Azimuth.  Bin size:  ' num2str(status_flags.analysis_modules.radial_average.azimuth_bin_absolute) ' [Degree(s)]']}];
        
        if length(bin_edges) <2
            disp('Error generating Bin_Edges - not enough Bins')
            disp('Please check re-binning parameters');
            
        else
            
            %***** Now re-bin the iq_list of raw pixels from all detectors *****
            disp('Rebinning .....');tic
            iq_data = rebin(iq_list,bin_edges); %[q,I,errI,delta_q,pixel_count]
            disp(['......done.... ' num2str(toc) '[s]'])
            
            %Apply post-average filters
            if status_flags.analysis_modules.averaging_filters.post_av_stats_chk == 1 %Switch within the averaging filters window
                disp('Filter:  Post Averaging Statistics Filter')
                %Apply Statistics Filter
                l1 = length(iq_data);
                d_i_i = iq_data(:,3) ./ abs(iq_data(:,2));
                temp = find(d_i_i <= status_flags.analysis_modules.averaging_filters.post_av_stats_threshold);
                iq_data = iq_data(temp,:);
                l2 = length(temp);
                disp(['         Rejecting ' num2str(100*(l1-l2)/l1) ' [%] of Binned data'])
            end
            
        end
        
        %Check all the detector data wasn't empty
        if isempty(iq_data)
            disp(['All detector data was empty:  Nothing to rebin']);
            return
        end
        
        column_format = 'xye'; %Do not show resolution
        plotdata = [iq_data(:,1:3)];
        
        plot_info = struct(....
            'plot_type','plot',....
            'plot_data',plotdata,....
            'column_format',column_format,....
            'plot_title',['Azimuthal Re-grouping: |degrees|'],....
            'x_label',['Azimuthal Angle [degrees]'],....
            'y_label',displayimage.units,....
            'legend_str',['#' num2str(displayimage.params1.numor)],....
            'params',displayimage.params1,....
            'parsub',displayimage.params1.subtitle,....
            'export_data',iq_data(:,1:4),....
            'export_column_labels',['Az_Angle   ' char(9) 'I       ' char(9) 'Err_I   ']);
        plot_info.history = history;
        data_out = plot_info;
end


%General update stuff if the Radial average window exists
if isfield(grasp_handles.window_modules.radial_average,'window')
    if ishandle(grasp_handles.window_modules.radial_average.window)
        %Update displayed Radial Average objects
        switch status_flags.analysis_modules.radial_average.q_bin_units
            case 'pixels'
                
                bin_string = 'Radial q-bins [pixels]:';
                bin_size = status_flags.analysis_modules.radial_average.q_bin_pixels;
                delta_q = (4*pi / displayimage.params1.wav) * ((max(inst_params.detector1.pixel_size) *1e-3 * bin_size)/displayimage.params1.det)/2;
                bin_tip = ['Delta_q bins defined at q=0 by largest pixel ' newline 'dimension on Detector1 of ' num2str(max(inst_params.detector1.pixel_size)) ' [mm]' newline 'Delta_q = ' num2str(delta_q) ' [Angs-1]'];
            case 'absolute'
                
                if strcmp(status_flags.analysis_modules.radial_average.q_bin_absolute_scale,'log10')
                    bin_string = ['Radial Log10 q-bins [' char(197) ']:'];
                    bin_size = status_flags.analysis_modules.radial_average.q_bin_absolute;
                    bin_tip = ['Log10 increasing q-bins beginning with Delta_q = ' num2str(bin_size) ' [Angs-1]'];
                elseif strcmp(status_flags.analysis_modules.radial_average.q_bin_absolute_scale,'linear')
                    bin_string = ['Radial q-bins [' char(197) ']:'];
                    bin_size = status_flags.analysis_modules.radial_average.q_bin_absolute;
                    bin_tip = ['Linear bins of Delta_q = ' num2str(bin_size) ' [Angs-1]'];
                end
            case 'resolution'
                bin_string = 'Radial fract. res. bins [dq/q]:';
                bin_size = status_flags.analysis_modules.radial_average.q_bin_resolution;
                bin_tip = ['Delta_q bin defineds as a fraction (1 / ' num2str(bin_size) ') of the ' newline 'q resolution of the highest resolution data at this q'];
        end
        if ishandle(grasp_handles.window_modules.radial_average.q_bin_text)
            set(grasp_handles.window_modules.radial_average.q_bin_text,'string',bin_string);
        end
        if ishandle(grasp_handles.window_modules.radial_average.q_bin)
            set(grasp_handles.window_modules.radial_average.q_bin,'string',num2str(bin_size));
            set(grasp_handles.window_modules.radial_average.q_bin,'tooltip',bin_tip);
        end
        
        switch status_flags.analysis_modules.radial_average.theta_bin_units
            case 'pixels'
                
                bin_string = 'Radial bins [pixels]:';
                bin_size = status_flags.analysis_modules.radial_average.theta_bin_pixels;
                delta_2theta = ((180/pi)* (max(inst_params.detector1.pixel_size)) *1e-3 * bin_size)/displayimage.params1.det;
                bin_tip = ['Delta_2' char(415) ' bin defined at theta=0 by largest pixel ' newline 'dimension on Detector1 of ' num2str(max(inst_params.detector1.pixel_size)) ' [mm]' newline 'Delta_2' char(415) ' = ' num2str(delta_2theta) ' [Degrees]'];
                
            case 'absolute'
                if strcmp(status_flags.analysis_modules.radial_average.theta_bin_absolute_scale,'log10')
                    bin_string = ['Radial Log10 2' char(415) '-bins [Degs]:'];
                    bin_size = status_flags.analysis_modules.radial_average.theta_bin_absolute;
                    bin_tip = ['Log10 increasing 2' char(415) '-bins beginning with Delta_2theta = ' num2str(bin_size) ' [Degrees]'];
                elseif strcmp(status_flags.analysis_modules.radial_average.theta_bin_absolute_scale,'linear')
                    bin_string = ['Radial 2' char(415) '-bins [Degs]:'];
                    bin_size = status_flags.analysis_modules.radial_average.theta_bin_absolute;
                    bin_tip = ['Linear bins of Delta_2' char(415) ' = ' num2str(bin_size) ' [Degrees]'];
                end
                
                
            case 'resolution'
                bin_string = ['Radial fract. res. bins [d2' char(415) '/2' char(415) ']:'];
                bin_size = status_flags.analysis_modules.radial_average.theta_bin_resolution;
                bin_tip = ['Delta_2' char(415) ' bins defined as a fraction of (1 / ' num2str(bin_size) ') of the 2' char(415) ' resoltution'];
                
        end
        if ishandle(grasp_handles.window_modules.radial_average.theta_bin_text)
            set(grasp_handles.window_modules.radial_average.theta_bin_text,'string',bin_string);
        end
        if ishandle(grasp_handles.window_modules.radial_average.theta_bin)
            set(grasp_handles.window_modules.radial_average.theta_bin,'string',num2str(bin_size));
            set(grasp_handles.window_modules.radial_average.theta_bin,'tooltip',bin_tip);
            
        end
        
        
        if strcmp(status_flags.analysis_modules.radial_average.azimuth_bin_units,'smart')
            bin_string = 'Angle Bin [smart]:';
            bin_size = 0;
        elseif strcmp(status_flags.analysis_modules.radial_average.azimuth_bin_units,'absolute')
            bin_string = 'Angle Bin [degs]:';
            bin_size = status_flags.analysis_modules.radial_average.azimuth_bin_absolute;
        end
        if ishandle(grasp_handles.window_modules.radial_average.azimuth_bin_text)
            set(grasp_handles.window_modules.radial_average.azimuth_bin_text,'string',bin_string);
        end
        if ishandle(grasp_handles.window_modules.radial_average.azimuth_bin)
            set(grasp_handles.window_modules.radial_average.azimuth_bin,'string',num2str(bin_size));
        end
        
        if ishandle(grasp_handles.window_modules.radial_average.sector_mask_chk)
            set(grasp_handles.window_modules.radial_average.sector_mask_chk,'value',status_flags.analysis_modules.radial_average.sector_mask_chk);
        end
        if ishandle(grasp_handles.window_modules.radial_average.strip_mask_chk)
            set(grasp_handles.window_modules.radial_average.strip_mask_chk,'value',status_flags.analysis_modules.radial_average.strip_mask_chk);
        end
        
        %Single, Depth, TOF radio button
        if status_flags.analysis_modules.radial_average.single_depth_radio == 0 %Single
            single_radio_value = 1; depth_radio_value = 0; tof_radio_value = 0;
        elseif status_flags.analysis_modules.radial_average.single_depth_radio == 1 %Depth
            single_radio_value = 0; depth_radio_value = 1; tof_radio_value = 0;
        elseif status_flags.analysis_modules.radial_average.single_depth_radio == 2 %TOF
            single_radio_value = 0; depth_radio_value = 0; tof_radio_value = 1;
        end
        
        set(grasp_handles.window_modules.radial_average.radio_single,'value',single_radio_value);
        set(grasp_handles.window_modules.radial_average.radio_depth,'value',depth_radio_value);
        set(grasp_handles.window_modules.radial_average.radio_tof,'value',tof_radio_value);
        
        filter_tip = ['Reject bins with statistics worse than d_I / I > ' num2str(status_flags.analysis_modules.averaging_filters.post_av_stats_threshold) ' after averaging'];
        set(grasp_handles.window_modules.radial_average.post_av_stats,'tooltip',filter_tip);
        filter_tip = ['Reject pixels with sigma_q / q > ' num2str(status_flags.analysis_modules.averaging_filters.pre_av_res_threshold) ' before averaging'];
        set(grasp_handles.window_modules.radial_average.pre_av_res,'tooltip',filter_tip);
        
    end
end

end


function direct_to_file(plot_data)

global grasp_env
global status_flags
global inst_params

disp('Exporting Radial Average Direct to File')

for curve = 1:length(plot_data)
    
    %Use different line terminators for PC or unix
    if ispc; newline = 'pc'; terminator_str = [char(13) newline]; %CR/LF
    else; newline = 'unix'; terminator_str = newline; end %LF
    
    %ONLY use Auto file numbering for 'direct to file'
    %***** Build Output file name *****
    numor_str = pad(num2str(plot_data(curve).params.numor),inst_params.filename.numeric_length,'left','0');
    fname = [numor_str '_' num2str(curve,'%6.3i') '.dat'];
    
    %Open file for writing
    disp(['Exporting data: '  grasp_env.path.project_dir fname]);
    fid=fopen([grasp_env.path.project_dir fname],'wt');
    
    %Check if to include history header
    if strcmp(status_flags.subfigure.export.data_history,'on')
        history = plot_data(curve).history;
        for m = 1:length(history)
            fprintf(fid,'%s \n',history{m});
        end
        fprintf(fid,'%s \n',''); fprintf(fid,'%s \n','');
    end
    
    %Check if to include column labels
    if strcmp(status_flags.subfigure.export.column_labels,'on')
        if isfield(plot_data(curve),'export_column_labels')
            %Convert column labels to hwhm or fwhm if necessary
            if strcmp(status_flags.subfigure.export.resolution_format,'hwhm') %Convert to hwhm
                plot_data(curve).export_column_labels = strrep(plot_data(curve).export_column_labels,'FWHM_Q','HWHM_Q');
            elseif strcmp(status_flags.subfigure.export.resolution_format,'sigma') %Convert to sigma
                plot_data(curve).export_column_labels = strrep(plot_data(curve).export_column_labels,'FWHM_Q','Sigma_Q');
            end
            fprintf(fid,'%s \n',[plot_data(curve).export_column_labels terminator_str]);
            fprintf(fid,'%s \n','');
        end
    end
    
    %Check if to include q-reslution (4th column)
    if strcmp(status_flags.subfigure.export.include_resolution,'on')
        %Check what format of q-resolution, sigma, hwhm, fwhm
        %Default coming though from Grasp is sigma
        if strcmp(status_flags.subfigure.export.resolution_format,'hwhm') %Convert to hwhm
            plot_data(curve).export_data(:,4) = plot_data(curve).export_data(:,4)/2; %hwhm
        elseif strcmp(status_flags.subfigure.export.resolution_format,'sigma') %Convert to sigma
            plot_data(curve).export_data(:,4) = plot_data(curve).export_data(:,4)/ (2 * sqrt(2 * log(2)));%fwhm
        end
    else
        disp('help here:  radial_average_callbacks 1015')
    end
    dlmwrite([grasp_env.path.project_dir fname],plot_data(curve).export_data,'delimiter','\t','newline',newline,'-append','precision',6);
    fclose(fid);
end


end


