function ancos2_callbacks(to_do)

if nargin<1; to_do = ''; end

global status_flags
global displayimage
global grasp_handles
global inst_params
global grasp_env

switch to_do
    
    case 'plot_together'
         status_flags.analysis_modules.ancos2.plot_off_amp_together = ~ status_flags.analysis_modules.ancos2.plot_off_amp_together;
         
    case 'plot_offset'
        status_flags.analysis_modules.ancos2.plot_offset = ~status_flags.analysis_modules.ancos2.plot_offset;
        
    case 'plot_amplitude'
        status_flags.analysis_modules.ancos2.plot_amplitude = ~status_flags.analysis_modules.ancos2.plot_amplitude;
        
    case'plot_phase'
        status_flags.analysis_modules.ancos2.plot_phase = ~status_flags.analysis_modules.ancos2.plot_phase;
        
    case 'graphic_display'
        status_flags.analysis_modules.ancos2.graphic_display = ~status_flags.analysis_modules.ancos2.graphic_display;
        
    case 'ancos2_window_close'
        %Delete old sectors
        if isfield(grasp_handles.window_modules.ancos2,'sketch_handles')
            temp = find(ishandle(grasp_handles.window_modules.ancos2.sketch_handles));
            delete(grasp_handles.window_modules.ancos2.sketch_handles(temp));
        end
        grasp_handles.window_modules.ancos2.sketch_handles = [];
        grasp_handles.window_modules.ancos2.window = [];
        return
        
    case 'phase_lock'
        status_flags.analysis_modules.ancos2.phase_lock = not(status_flags.analysis_modules.ancos2.phase_lock);
        
    case 'phase_angle'
        value = str2num(get(gcbo,'string'));
        if not(isempty(value))
            status_flags.analysis_modules.ancos2.phase_angle = value;
        end
        
    case 'start'
        value = str2num(get(gcbo,'string'));
        if not(isempty(value))
            status_flags.analysis_modules.ancos2.start_radius = value;
        end
        
    case 'end'
        value = str2num(get(gcbo,'string'));
        if not(isempty(value))
            status_flags.analysis_modules.ancos2.end_radius = value;
        end
        
    case 'width'
        value = str2num(get(gcbo,'string'));
        if not(isempty(value))
            status_flags.analysis_modules.ancos2.radius_width = value;
        end
        
    case 'step'
        value = str2num(get(gcbo,'string'));
        if not(isempty(value))
            status_flags.analysis_modules.ancos2.radius_step = value;
        end
        
    case 'color'
        color_list = get(gcbo,'string');
        value = get(gcbo,'value');
        status_flags.analysis_modules.ancos2.color = color_list{value};
        
        
    case 'ancos2_it'
        
        %Get the Ancos2 parameters
        start_radius = status_flags.analysis_modules.ancos2.start_radius;
        end_radius = status_flags.analysis_modules.ancos2.end_radius;
        radius_width = status_flags.analysis_modules.ancos2.radius_width;
        radius_step = status_flags.analysis_modules.ancos2.radius_step;
        phase_lock_angle = status_flags.analysis_modules.ancos2.phase_angle;
        phase_lock = status_flags.analysis_modules.ancos2.phase_lock;
        color = [1 0 0]; %status_flags.analysis_modules.ancos2.color;
        
        %Take a copy of the history to modify though this process
        local_history = displayimage.history;
        local_history = [local_history, {'***** Analysis *****'}];
        local_history = [local_history, {'Ancos2: I(theta,q)'}];
        
        %***** Add Ancos2 History *****
        local_history = [local_history, {['Ancos2: R_start= ' num2str(start_radius) ', R_end = ' num2str(end_radius)]}];
        local_history = [local_history, {['Ancos2: R_width= ' num2str(radius_width) ', R_step = ' num2str(radius_step)]}];
        
        
        
        %***** Loop though the rings, extract and fit *****
        message_handle = grasp_message(['Working: Ancos2:  Radius = ' num2str(start_radius) ' : ' num2str(end_radius)]);
        
        fit_list = []; fit_list_error = [];q_list = [];counter = 1;
        for radius = start_radius:radius_step:end_radius
            disp(['Ancos2: Radius = ' num2str(radius)]);
            
            %Make Compund Mask and Ring Mask (FOR ALL DETECTORS - done in one go)
            smask = sector_callbacks('build_sector_mask',[radius,radius+radius_width,0,360,1]);
            
            %figure
            % pcolor(smask.det1)
            
            %Loop though the detectors for each ANCOS2 ring
            ancos2_sketch_handle = [];
            ring_data = []; %This is a variable that is appended to for each detector before doing the cos2 fit
            for det = 1:inst_params.detectors
                detno=num2str(det);
                %Retrieve parameters for this detector pannel
                params = displayimage.(['params' detno]);
                
                %***** Make Raw Intensity vs. Angle @ mod_q list for given detector pannel *****
                IAngleQ_list = []; %Clear the variable as matrix size changes for each detector
                IAngleQ_list(:,1) = reshape(displayimage.(['qmatrix' detno])(:,:,6),inst_params.(['detector' detno]).pixels(2)*inst_params.(['detector' detno]).pixels(1),1); %q_Angle
                IAngleQ_list(:,2) = reshape(displayimage.(['data' detno])(:,:),inst_params.(['detector' detno]).pixels(2)*inst_params.(['detector' detno]).pixels(1),1); %Intensity
                IAngleQ_list(:,3) = reshape(displayimage.(['error' detno])(:,:),inst_params.(['detector' detno]).pixels(2)*inst_params.(['detector' detno]).pixels(1),1); %Error in intensity
                IAngleQ_list(:,4) = reshape(displayimage.(['qmatrix' detno])(:,:,5),inst_params.(['detector' detno]).pixels(2)*inst_params.(['detector' detno]).pixels(1),1); %mod q
                
                IAngleQ_list(:,5) = reshape(displayimage.(['qmatrix' detno])(:,:,13),inst_params.(['detector' detno]).pixels(2)*inst_params.(['detector' detno]).pixels(1),1); %delta_q (FWHM) - Classic Resolution
                %IAngleQ_list(:,6) = reshape(displayimage.(['qmatrix' detno])(:,:,11),inst_params.(['detector' detno]).pixels(2)*inst_params.(['detector' detno]).pixels(1),1); %delta_q_lambda (FWHM)
                %IAngleQ_list(:,7) = reshape(displayimage.(['qmatrix' detno])(:,:,12),inst_params.(['detector' detno]).pixels(2)*inst_params.(['detector' detno]).pixels(1),1); %delta_q_theta (FWHM)
                %IAngleQ_list(:,8) = reshape(displayimage.(['qmatrix' detno])(:,:,18),inst_params.(['detector' detno]).pixels(2)*inst_params.(['detector' detno]).pixels(1),1); %delta_q_pixel (FWHM)
                %IAngleQ_list(:,9) = reshape(displayimage.(['qmatrix' detno])(:,:,19),inst_params.(['detector' detno]).pixels(2)*inst_params.(['detector' detno]).pixels(1),1); %delta_q_sample_aperture (FWHM)

                
                %***** Conical Ring Radius Scaling *****
                %Find current detector distance for particular detector pannel
                det_current = params.det; %Default unless otherwise
                if strcmp(status_flags.q.det,'detcalc')
                    if isfield(params,'detcalc')
                        if not(isempty(params.detcalc))
                            det_current = params.detcalc;
                        end
                    end
                end
                if isfield(params,'det_pannel')
                    det_current = params.det_pannel;
                end
                %Keep a memory of the main detector(1) Det
                if det ==1; det1det = det_current; end
                %For conical radius scaling of multiple detectors
                eff_radius = radius * det_current / det1det;
                eff_radius_width = radius_width * det_current / det1det;
                %***** End Conical Ring Radius Scaling *****
                
                
                %***** Draw ANCOS2 Ring Sketches *****
                if status_flags.analysis_modules.ancos2.graphic_display ==1
                    cm = displayimage.cm.(['det' detno]);
                    %Pixel distances from Beam Centre
                    if isfield(params,'ox')
                        cx_eff = cm.cm_pixels(1) - ((params.ox - cm.cm_translation(1))/inst_params.detector1.pixel_size(1));
                    else
                        cx_eff = cm.cm_pixels(1);
                    end
                    if isfield(params,'oy')
                        cy_eff = cm.cm_pixels(2) - ((params.oy - cm.cm_translation(2))/inst_params.detector1.pixel_size(1));
                    else
                        cy_eff = cm.cm_pixels(2);
                    end
                    
                    if strcmp(grasp_env.inst,'ILL_d33')
                        switch det
                            case 1 %Rear
                                
                                cx_eff = cm.cm_pixels(1);
                                cy_eff = cm.cm_pixels(2);
                            case 2 % Right
                                cx_eff = cm.cm_pixels(1) - ((params.oxr - cm.cm_translation(1)))/inst_params.(['detector' detno]).pixel_size(2); %horizontal distance from beam centre to pixel (m)
                                cy_eff = cm.cm_pixels(2);
                            case 3 % Left
                                cx_eff = cm.cm_pixels(1) + ((params.oxl - cm.cm_translation(1)))/inst_params.(['detector' detno]).pixel_size(2); %horizontal distance from beam centre to pixel (m)
                                cy_eff = cm.cm_pixels(2);
                            case 4 %Bottom
                                cx_eff = cm.cm_pixels(1);
                                cy_eff = cm.cm_pixels(2)  + ((params.oyb - cm.cm_translation(2)))/inst_params.(['detector' detno]).pixel_size(2); %vertical distance from beam centre to pixel (m)
                            case 5 %Top
                                cx_eff = cm.cm_pixels(1);
                                cy_eff = cm.cm_pixels(2) - ((params.oyt - cm.cm_translation(2)))/inst_params.(['detector' detno]).pixel_size(2); %vertical distance from beam centre to pixel (m)
                        end
                    end
                    
                    %Draw Sketches
                    handle = circle(det,eff_radius+eff_radius_width,eff_radius,cx_eff,cy_eff,0,360,color);
                    ancos2_sketch_handle = [ancos2_sketch_handle, handle];
                    drawnow; %Wait for screen update
                    %**************************************
                    
                end
                %Final ring mask
                ring_mask = displayimage.(['mask' detno]).* smask.(['det' detno]);
                
                %Reshape Compound Ring Mask to a list like the data
                ring_mask_list = reshape(ring_mask(:,:),inst_params.(['detector' detno]).pixels(1)*inst_params.(['detector' detno]).pixels(2),1);
                
                %Illiminate Pixels in the ring-mask
                temp = find(ring_mask_list==1);
                IAngleQ_ring_list = IAngleQ_list(temp,:);
                
                %Final check for any Zero Counts, Zero Error - this should
                %never be produced BUT, for D33 test data where detectors
                %shadow this was being produced.
                temp = find(IAngleQ_ring_list(:,2)~=0 & IAngleQ_ring_list(:,3)~=0);
                IAngleQ_ring_list = IAngleQ_ring_list(temp,:);
                
                ring_data = [ring_data; IAngleQ_ring_list];
            end
                        
            %Only do the Cos^2 fit if there is enough data to fit
            %if length(ring_data) > 10;
                
                %Retrieve the 1D Cosine^2 fit function
                fn_name = 'Cosine^2';
                ancos2_fn = grasp_plot_fit_callbacks('retrieve_fn',fn_name);
                ancos2_fn.number1d =1;
                
                %***** Fit to each curve *****
                xdat = ring_data(:,1);
                ydat = ring_data(:,2);
                edat = ring_data(:,3);
                
                %Check for zero's in the edat - this crashes the fitter
                temp = find(edat==0); edat(temp) = 1;
                
                %             %Fix - Data when in units of solid angle can be very large numbers, i.e. 10^7.
                %             %This causes mflsqr not to function properly, probably due to rounding errors.
                %             %To Fix, find the 'order of magnitude' of the dacta divide, fit, then re-multiply.
                %             data_order_mag = round(mean(floor(real(log10(ydat)))));
                %             if isinf(data_order_mag); data_order_mag = 0; end
                %             ydat = ydat / 10^data_order_mag;
                %             edat = edat / 10^data_order_mag;
                
                %Guess Start Parameters
                code = ancos2_fn.auto_guess_code;
                x = xdat; y = ydat;
                for line = 1:length(code)
                    eval([code{line} ';'])
                end
                ancos2_fn.values = guess_values;
                ancos2_fn.err_values = zeros(size(guess_values));
                
                start_params = ancos2_fn.values;
                vary_mask = double(not(ancos2_fn.fix));
                vary_params = 0.1*vary_mask;
                
                %Check if phase is locked - if so, replace the guessed phase with the fixed phase
                if phase_lock ==1
                    start_params(3) = phase_lock_angle; %Set the angle
                    vary_params(3) = 0; %Fix the parameter
                end
                
                %Run the fit once
                pseudo_fn = 'ancos2_pseudo_fn';
                [fit_params, fit_params_err] = mf_lsqr_grasp(xdat,ydat,edat,start_params,vary_params,pseudo_fn,ancos2_fn);
                
                %***** Covarience checking *****
                disp(' ');
                disp('Covarience Checking');
                fit_params_err_cov = zeros(size(fit_params_err)); %only store the error
                params_to_vary = find(vary_params~=0);
                for n = 1:length(params_to_vary)
                    temp_vary_params = zeros(size(vary_params));
                    temp_vary_params(params_to_vary(n)) = vary_params(params_to_vary(n));
                    %Recal the fitting function with the temporary vary_params
                    [temp_fit_params, temp_fit_params_err] = mf_lsqr_grasp(xdat,ydat,edat,fit_params,temp_vary_params,pseudo_fn,ancos2_fn);
                    fit_params_err_cov(params_to_vary(n)) = temp_fit_params_err(params_to_vary(n));
                end
                
                fit_list(counter,:) = rot90(fit_params);
                fit_list_error(counter,:) = rot90(fit_params_err);
                q_list(counter) = (sum(ring_data(:,4))/length(ring_data));
                %Resolution (FWHM classic)
                res_list(counter) = mean(ring_data(:,5));
                counter = counter+1;
                
            %else
            %    disp('Warning:  Ancos2 - Ring does not have enough data to fit at this radius')
            %end
            
            
            if status_flags.analysis_modules.ancos2.graphic_display ==1
                %Delete ancos2 sketch
                if not(isempty(ancos2_sketch_handle))
                    if ishandle(ancos2_sketch_handle)
                        delete(ancos2_sketch_handle);
                        ancos2_sketch_handle = [];
                    end
                end
            end
            
            
        end
        %Delete message
        delete(message_handle);
        %***** Abs Phase - That is what is fitted after all *****
        fit_list(:,2) = abs(fit_list(:,2));
        
        %***** Renormalize phase angle to between 0 and 180 *****
        while find(fit_list(:,3)>=135); temp = find(fit_list(:,3)>=135); fit_list(temp,3) = fit_list(temp,3)-180; end
        while find(fit_list(:,3)<-45); temp = find(fit_list(:,3)<-45); fit_list(temp,3) = fit_list(temp,3)+180; end
        
        
        %***** Plot Ancos2 outputs *****
        
        %********** Cosine Offset - Nuclear Scattering:  Plot and Export Results ************
        if status_flags.analysis_modules.ancos2.plot_offset == 1
           
            if strcmp(status_flags.subfigure.show_resolution,'on')
                column_format = 'xyhe'; %Show resolution
                %Note, need to swap colums around for the ploterr fn.  Need [x,y,err_x,err_y]
                plotdata = [q_list(:),fit_list(:,1),res_list(:),fit_list_error(:,1)];% q, Cosine^2 Offset, Horz Delta_q FWHM, Err_Cosine^2
            else
                column_format = 'xye'; %Do not show resolution.
                %Note, uses Matlab errorbar fn.  Need [x,y,err_y]
                plotdata = [q_list(:),fit_list(:,1),fit_list_error(:,1)];% q, Cosine^2 Offset, Err_Cosine^2
            end
            export_data = [q_list(:),fit_list(:,1),fit_list_error(:,1), res_list(:)];% q, Cosine^2 Offset, Err_Cosine^2,  Horz Delta_q FWHM
            
            if status_flags.analysis_modules.ancos2.plot_off_amp_together ==1 %Plot Offset and Amplitude together
                plot_title = ['Ancos2 Analysis : Cosine Offset (Nuclear) & Cosine Amplitude (Magnetic)'];
                plot_hold = 'on';
            else
                plot_title = ['Ancos2 Analysis : Cosine Offset (Nuclear Scattering)'];
                plot_hold = 'off';
            end
            
            plot_params = struct(....
                'plot_type','plot',....
                'plot_data',plotdata,....
                'column_format',column_format,....
                'hold_graph',plot_hold,....
                'plot_title',plot_title,....
                'x_label',['|q| (' char(197) '^{-1})'],....
                'y_label',['Nuclear Scattering : ' displayimage.units],....
                'legend_str',['Cos^2 Offset'],....
                'params',displayimage.params1,....
                'subtitle',displayimage.params1.subtitle,....
                'export_data',export_data,....
                'export_column_format','xyeh',....
                'column_labels',['Mod_Q   ' char(9) 'I       ' char(9) 'Err_I   '  char(9) 'FWHM_Q']);
            plot_params.history = local_history;
            grasp_plot2(plot_params);
        end
        
        
        
        %********** Cosine Amplitude - Magnetic Scattering:  Plot and Export Results ************
        if status_flags.analysis_modules.ancos2.plot_amplitude == 1
            
            if strcmp(status_flags.subfigure.show_resolution,'on')
                column_format = 'xyhe'; %Show resolution
                %Note, need to swap colums around for the ploterr fn.  Need [x,y,err_x,err_y]
                plotdata = [q_list(:),fit_list(:,2),res_list(:),fit_list_error(:,2)];% q, Cosine^2 Amplitude, Horz Delta_q FWHM, Err_Cosine^2
            else
                column_format = 'xye'; %Do not show resolution.
                %Note, uses Matlab errorbar fn.  Need [x,y,err_y]
                plotdata = [q_list(:),fit_list(:,2),fit_list_error(:,2)];% q, Cosine^2 Amplitude, Err_Cosine^2
            end
            export_data = [q_list(:),fit_list(:,2),fit_list_error(:,2),res_list(:)];% q, Cosine^2 Amplitude, Err_Cosine^2, Horz Delta_q FWHM
            
            if status_flags.analysis_modules.ancos2.plot_off_amp_together ==1 %Plot Offset and Amplitude together
                plot_title = ['Ancos2 Analysis : Cosine Offset (Nuclear) & Cosine Amplitude (Magnetic)'];
                plot_hold = 'on';
            else
                plot_title = ['Ancos2 Analysis : Cosine Amplitude (Magnetic Scattering)'];
                plot_hold = 'off';
            end

            plot_params = struct(....
                'plot_type','plot',....
                'plot_data',plotdata,....
                'column_format',column_format,....
                'hold_graph',plot_hold,....
                'plot_title',plot_title,....
                'x_label',['|q| (' char(197) '^{-1})'],....
                'y_label',['Magnetic Scattering : ' displayimage.units],....
                'legend_str',['Cos^2 Offset'],....
                'params',displayimage.params1,....
                'subtitle',displayimage.params1.subtitle,....
                'export_data',export_data,....
                'export_column_format','xyhe',....
                'column_labels',['Mod_Q   ' char(9) 'I       ' char(9) 'Err_I   ']);
            plot_params.history = local_history;
            grasp_plot2(plot_params);
        end
        
        
        %********** Cosine Phase:  Plot and Export Results ************
        if status_flags.analysis_modules.ancos2.plot_phase == 1
            if phase_lock ~=1
                plotdata(:,1) = q_list(:);
                plotdata(:,2) = fit_list(:,3); %Cosine^2 Phase
                plotdata(:,3) = fit_list_error(:,3); %Cosine^2 Phase Error
                plot_params = struct(....
                    'plot_type','plot',....
                    'plot_data',plotdata,....
                    'column_format','xye',...
                    'hold_graph','off',....
                    'plot_title',['Ancos2 Analysis : Cosine Phase'],....
                    'x_label',['|q| (' char(197) '^{-1})'],....
                    'y_label',['Cosine Phase [degs]'],....
                    'legend_str',['Cos^2 Phase'],....
                    'params',displayimage.params1,....
                    'subtitle',displayimage.params1.subtitle,....
                    'export_data',plotdata,....
                    'export_column_format','xye',....
                    'column_labels',['Mod_Q   ' char(9) 'Phase       ' char(9) 'Err_Phase   ']);
                plot_params.history = local_history;
                grasp_plot2(plot_params);
            end
        end
        
        %Update the schematic annuli
        ancos2_callbacks;
        
        
end



%Update Ancos2
start_radius = status_flags.analysis_modules.ancos2.start_radius;
end_radius = status_flags.analysis_modules.ancos2.end_radius;
radius_width = status_flags.analysis_modules.ancos2.radius_width;
radius_step = status_flags.analysis_modules.ancos2.radius_step;
phase_lock_angle = status_flags.analysis_modules.ancos2.phase_angle;
phase_lock = status_flags.analysis_modules.ancos2.phase_lock;
color = status_flags.analysis_modules.ancos2.color;

%Update the window parameters
set(grasp_handles.window_modules.ancos2.start_radius,'string',num2str(start_radius));
set(grasp_handles.window_modules.ancos2.end_radius,'string',num2str(end_radius));
set(grasp_handles.window_modules.ancos2.radius_width,'string',num2str(radius_width));
set(grasp_handles.window_modules.ancos2.radius_step,'string',num2str(radius_step));
set(grasp_handles.window_modules.ancos2.phase_lock_angle,'string',num2str(phase_lock_angle));
set(grasp_handles.window_modules.ancos2.phase_lock_check,'value',phase_lock);
if phase_lock == 1; set(grasp_handles.window_modules.ancos2.phase_lock_angle,'visible','on');
else set(grasp_handles.window_modules.ancos2.phase_lock_angle,'visible','off'); end


%Delete any previous sketches
i = findobj('tag','ac2_circle_sketch');
if not(isempty(i));delete(i);end




%Delete old sectors
if isfield(grasp_handles.window_modules.ancos2,'sketch_handles')
    temp = find(ishandle(grasp_handles.window_modules.ancos2.sketch_handles));
    delete(grasp_handles.window_modules.ancos2.sketch_handles(temp));
end
grasp_handles.window_modules.ancos2.sketch_handles = [];

%Draw new sectors
for det = 1:inst_params.detectors
    detno=num2str(det);
    cm = displayimage.cm.(['det' detno]);
    params = displayimage.(['params' detno]);
    
    
    %Find current detector distance for particular detector pannel
    det_current = params.det; %Default unless otherwise
    if strcmp(status_flags.q.det,'detcalc')
        if isfield(params,'detcalc')
            if not(isempty(params.detcalc))
                det_current = params.detcalc;
            end
        end
    end
    if isfield(params,'det_pannel')
        det_current = params.det_pannel;
    end
    
    %Keep a memory of the main detector(1) Det
    if det ==1; det1det = det_current; end
    
    
    %Pixel distances from Beam Centre
    cx_eff = cm.cm_pixels(1);
    cy_eff = cm.cm_pixels(2);
    
    if strcmp(grasp_env.inst,'ILL_d33')
        if det ==1 %Rear
            cx_eff = cm.cm_pixels(1);
            cy_eff = cm.cm_pixels(2);
        elseif det == 2 % Right
            cx_eff = cm.cm_pixels(1) - ((params.oxr - cm.cm_translation(1)))/inst_params.(['detector' detno]).pixel_size(2); %horizontal distance from beam centre to pixel (m)
            cy_eff = cm.cm_pixels(2);
        elseif det == 3 % Left
            cx_eff = cm.cm_pixels(1) + ((params.oxl - cm.cm_translation(1)))/inst_params.(['detector' detno]).pixel_size(2); %horizontal distance from beam centre to pixel (m)
            cy_eff = cm.cm_pixels(2);
        elseif det == 4 %Bottom
            cx_eff = cm.cm_pixels(1);
            cy_eff = cm.cm_pixels(2)  + ((params.oyb - cm.cm_translation(2)))/inst_params.(['detector' detno]).pixel_size(2); %vertical distance from beam centre to pixel (m)
        elseif det == 5 %Top
            cx_eff = cm.cm_pixels(1);
            cy_eff = cm.cm_pixels(2) - ((params.oyt - cm.cm_translation(2)))/inst_params.(['detector' detno]).pixel_size(2); %vertical distance from beam centre to pixel (m)
        end
    end
    
    
    %For conical radius scaling of multiple detectors
    eff_start_radius = start_radius * det_current / det1det;
    eff_radius_width = radius_width * det_current / det1det;
    eff_end_radius = end_radius * det_current / det1det;
    
    
    %Draw Sketches
    sector_handles = circle(det,eff_start_radius, eff_start_radius + eff_radius_width, cx_eff,cy_eff, 0, 360, color);
    grasp_handles.window_modules.ancos2.sketch_handles = [grasp_handles.window_modules.ancos2.sketch_handles; sector_handles];
    
    
    sector_handles = circle(det,eff_end_radius, eff_end_radius + eff_radius_width, cx_eff,cy_eff, 0, 360, color);
    grasp_handles.window_modules.ancos2.sketch_handles = [grasp_handles.window_modules.ancos2.sketch_handles; sector_handles];
    
end

