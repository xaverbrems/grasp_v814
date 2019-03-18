function foreimage=build_q_matrix(foreimage,cm_multibeam)

%'options' is an optional flat to instruct specific multi-beam
%functionality - in particular to take different beam centers

if nargin <2; cm_multibeam = []; end


warning off
%foreimage contains all data arrays for all detectors and parameters.  cm
%contains all beam centres for all detectors.
%Output matrix has n x m x depth where the qmatrix depths are:
%(1) pixel_x
%(2) pixel_y
%(3) qx
%(4) qy
%(5) mod q
%(6) q angle
%(7) 2theta_x
%(8) 2theta_y
%(9) mod_2theta
%(10) solid_angle
%(11) delta_q_lambda
%(12) delta_q_theta
%(13) delta_q
%(14) radius_x
%(15) radius_y
%(16) mod_radius  (m)
%(17) delta_theta
%(18) delta_q_pixel
%(19) detla_q_sample_aperture
%(20) qx/pixelx
%(21) qy/pixely


global inst_params
global status_flags
global grasp_env

%Loop though the number of detectors
for det = 1:inst_params.detectors
    detno=num2str(det);
    %Parameters for this detector
    det_params = inst_params.(['detector' detno]);
    params = foreimage.(['params' detno]);
    
    %Get Beam Center - check if function is being called with a given beam center - i.e. MULTIBEAM
    if isempty(cm_multibeam)
        cm = foreimage.cm.(['det' detno]).cm_pixels;  %Beam centre coordinates in pixels
    else
        cm = cm_multibeam;
    end
    cm_offset = foreimage.cm.(['det' detno]).cm_translation; %Detector pannel opening translation when beam centre was measured
    
    %Make empty q-matrix
    qmatrix =  zeros(det_params.pixels(2),det_params.pixels(1),21);
    
    %Make the pixel x & y matricies
    [pixel_x,pixel_y] = meshgrid(1:det_params.pixels(1),1:det_params.pixels(2));
    qmatrix(:,:,1) = pixel_x;
    qmatrix(:,:,2) = pixel_y;
    %Check that an empty parameter block hasn't been sent in
    
    if params.wav ~= 0
        
        %DAN:  Check if detector angle parameter exists
        dan_angle = 0; %unless otherwise parameter exists
        dan_offset = 0; %unless otherwise parameter exists
        if isfield(params,'dan')
            if not(isempty(params.dan))
                dan_angle = params.dan;
                if isfield(params,'dan_rotation_offset')
                    dan_offset = params.dan_rotation_offset;
                end
            end
        end
        
        %DET:  Check if to use Det,  DetCalc (m) or Det_Pannel
        if strcmp(grasp_env.inst,'ILL_d33')
            switch det
                case 1 %Rear
                    sdet = params.detcalc2;
                case 2 % Right
                    sdet = params.detcalc1 + params.det1_panel_offset;
                case 3 % Left
                    sdet = params.detcalc1 + params.det1_panel_offset;
                case 4 %Bottom
                    sdet = params.detcalc1;
                case 5
                    sdet = params.detcalc1;
                    
            end
            
        else  %All other cases
            sdet = params.det; %Default, unless otherwise
            if strcmp(status_flags.q.det,'detcalc')
                if isfield(params,'detcalc')
                    if not(isempty(params.detcalc))
                        sdet = params.detcalc;
                    end
                end
            end
            
            %         if isfield(params,'det_pannel')
            %             sdet = params.det_pannel;
            %         end
            
        end
        
        %Detector pixel size (x,y)
        pixelsize_x = det_params.pixel_size(1) * 1e-3; %x-pixel size in m
        pixelsize_y = det_params.pixel_size(2) * 1e-3; %y-pixel size in m
        
        %Wave vector (Angs-1)
        lambda = params.wav;
        k = (2*pi)/lambda;
        
        %Pixel distances from Beam Centre
        if strcmp(grasp_env.inst,'ILL_d33')
            %det = 1 ;  Rear
            %det = 2 ;  Right
            %det = 3 ;  Left
            %det = 4 ;  Bottom
            %det = 5 ;  Top
            switch det
                case 1 %Rear
                    
                    %disp('build_q_matrix rear')
                    r_x = ((qmatrix(:,:,1) - cm(1))*pixelsize_x);
                    r_y = ((qmatrix(:,:,2) - cm(2))*pixelsize_y);
                case  2 % Right
                    r_x = ((qmatrix(:,:,1) - cm(1))*pixelsize_x) + (params.oxr - cm_offset(1))/1000; %horizontal distance from beam centre to pixel (m)
                    r_y = ((qmatrix(:,:,2) - cm(2))*pixelsize_y);
                case  3 % Left
                    r_x = ((qmatrix(:,:,1) - cm(1))*pixelsize_x) - (params.oxl - cm_offset(1))/1000; %horizontal distance from beam centre to pixel (m)
                    r_y = ((qmatrix(:,:,2) - cm(2))*pixelsize_y);
                case  4 %Bottom
                    r_x = ((qmatrix(:,:,1) - cm(1))*pixelsize_x);
                    r_y = ((qmatrix(:,:,2) - cm(2))*pixelsize_y) - (params.oyb - cm_offset(2))/1000; %vertical distance from beam centre to pixel (m)
                case  5 %Top
                    r_x = ((qmatrix(:,:,1) - cm(1))*pixelsize_x);
                    r_y = ((qmatrix(:,:,2) - cm(2))*pixelsize_y) + (params.oyt - cm_offset(2))/1000; %vertical distance from beam centre to pixel (m)
            end
            
        else %All other instruments
            r_x = ((qmatrix(:,:,1) - cm(1))*pixelsize_x);
            r_y = ((qmatrix(:,:,2) - cm(2))*pixelsize_y);
        end
        qmatrix(:,:,14) = r_x; %radii (m) used for building sector masks
        qmatrix(:,:,15) = r_y;
        qmatrix(:,:,16) = sqrt(r_x.*r_x + r_y.*r_y);
        
        
        %DAN Correction (22/9/2008)
        %Find true Sample - Pixel distance based on DET and DAN Rotation
        S = r_x * cos(dan_angle *pi/180);  %This is r_x corrected for the dan angle
        n = (pixel_x - (det_params.pixels(1) + 0.5)) * pixelsize_x * tan(dan_angle *pi/180);
        m = dan_offset - dan_offset*cos(dan_angle*pi/180);
        R = sdet - (m+n); %R is the effective projected detector distance corrected for DAN
        %Effective (project) radius on detector, mod_r
        mod_r = sqrt(S.*S + r_y.*r_y); %S is used instead of r_x for DAN correction.
        %mod_r is then the projected radius on the detector and not the physical radius on the detector
        
        
        %Mod 2Theta
        two_theta = atan(mod_r ./ R); %radians.  R is used instead of DET for DAN correction
        qmatrix(:,:,9) = two_theta * (180/pi); %degrees in qmatrix;
        
        %2Theta_x & 2Theta_y (there is also a 2Theta_z component not calculated here)
        two_theta_x = atan(r_x / sdet); %radians
        qmatrix(:,:,7) = two_theta_x * (180/pi); %degrees in qmatrix;
        
        two_theta_y = atan(r_y / sdet); %radians
        qmatrix(:,:,8) = two_theta_y * (180/pi); %degrees in qmatrix;
        
        %Mod q
        mod_q = 2*k*sin(two_theta/2);
        qmatrix(:,:,5) = mod_q;
        
        %q_angle around the detector (measured clockwise from vertical)
        %This is not quite correct for DAN angles
        ang_array = ((atan2(r_x,r_y)) *180 / pi);
        temp = find(ang_array<0);
        ang_array(temp) = ang_array(temp) +360;
        qmatrix(:,:,6) = ang_array;
        
        %q_x and q_y components (resolved from Mod_q taking into acount the q_z component)
        q_x = mod_q.*cos(two_theta/2).*sin(ang_array*pi/180);
        qmatrix(:,:,3) = q_x;
        q_y = mod_q.*cos(two_theta/2).*cos(ang_array*pi/180);
        qmatrix(:,:,4) = q_y;
        
        %***** Solid Angle *****
        pixel_area = ones(det_params.pixels(2),det_params.pixels(1)).*(pixelsize_x * pixelsize_y); %m^2
        pixel_distance = zeros(det_params.pixels(2),det_params.pixels(1),5); %x,y, r, theta on detector, then R, distance to sample
        
        %geometry!
        % pixelx_line = ((1:det_params.pixels(1)) - cm(1))*pixelsize_x; %x distance from centre in m
        % pixely_line = ((1:det_params.pixels(2)) - cm(2))*pixelsize_y; %y distance from centre in m
        
        %Geometry - Pixel distances from Beam Centre
        if strcmp(grasp_env.inst,'ILL_d33')
            %if strcmp(grasp_env.inst_option,'D33'); %Real D33 instrument with Panel Detector
            switch det
                case 1 %Rear
                    
                    pixelx_line = ((1:det_params.pixels(1)) - cm(1))*pixelsize_x; %x distance from centre in m
                    pixely_line = ((1:det_params.pixels(2)) - cm(2))*pixelsize_y; %y distance from centre in m
                case 2 % Right
                    pixelx_line = (((1:det_params.pixels(1)) - cm(1))*pixelsize_x) + (params.oxr - cm_offset(1))/1000; %x distance from centre in m
                    pixely_line = ((1:det_params.pixels(2)) - cm(2))*pixelsize_y; %y distance from centre in m
                case 3 % Left
                    pixelx_line = (((1:det_params.pixels(1)) - cm(1))*pixelsize_x)  - (params.oxl - cm_offset(1))/1000; %x distance from centre in m
                    pixely_line = ((1:det_params.pixels(2)) - cm(2))*pixelsize_y; %y distance from centre in m
                case 4 %Bottom
                    pixelx_line = ((1:det_params.pixels(1)) - cm(1))*pixelsize_x; %x distance from centre in m
                    pixely_line = ((1:det_params.pixels(2)) - cm(2))*pixelsize_y  - (params.oyb - cm_offset(2))/1000; %y distance from centre in m
                case 5 %Top
                    pixelx_line = ((1:det_params.pixels(1)) - cm(1))*pixelsize_x; %x distance from centre in m
                    pixely_line = (((1:det_params.pixels(2)) - cm(2))*pixelsize_y)  + (params.oyt - cm_offset(2))/1000; %y distance from centre in m
            end
            
            
        else %All other instruments
            pixelx_line = ((1:det_params.pixels(1)) - cm(1))*pixelsize_x; %x distance from centre in m
            pixely_line = ((1:det_params.pixels(2)) - cm(2))*pixelsize_y; %y distance from centre in m
            
        end
        [pixel_distance(:,:,1), pixel_distance(:,:,2)] = meshgrid(pixelx_line,pixely_line);
        
        
        %Correct pixel area for curvature effect
        effective_pixel_area = pixel_area .* cos((dan_angle*pi/180) - two_theta_x) .* cos(two_theta_y);
        
        %Calculate distance from sample in x-plane taking into account DAN
        pixel_distance_x = sqrt(R.*R + S.*S);
        pixel_distance(:,:,3) = sqrt(pixel_distance_x.*pixel_distance_x + pixel_distance(:,:,2).*pixel_distance(:,:,2));
        %Finally calculate solid angle subtended by each pixel
        qmatrix(:,:,10) = effective_pixel_area./(pixel_distance(:,:,3).*pixel_distance(:,:,3)); %matrix - to account for distortions of flat detector against scattering sphere at short distances.
        
        
        
        
        
        
        
        %***** Calcualte resolution components, dq, dtheta or dlambda *****
        %Resolution kernel shapes can be:
        %circular
        %tophat
        %triangular
        %gaussian
        
        resolution_history{1} = '***** Resolution Components: *****'; %A text log to display about resolution components
        
        %***** Source Aperture & Divergence *****
        %a zero in the y position means circular of diameter x
        ap_x = params.source_ap_x;
        ap_y = params.source_ap_y;
        
        col = params.col;
        div_x = ap_x / col; %Radians FWHM TOPHAT Distribution
        div_y = ap_y / col; %Radians FWHM TOPHAT Distribution
        
        if ap_y ==0 % Circular Source Aperture
            d_theta_r = ones(det_params.pixels(2),det_params.pixels(1))* div_x;
            resolution_history{length(resolution_history)+1} = ['Effective source is Circular of dimensions: ' num2str(ap_x*1000) ' (mm) Diameter at a distance of: ' num2str(col) ' (m)'];
            foreimage.(['resolution_data' detno]).theta_shape = 'circular';
            foreimage.resolution_data0.theta_shape = 'circular'; %General resolution description - not detector specific

        else %Rectangular Source Aperture
            d_theta_r = zeros(det_params.pixels(2),det_params.pixels(1));
            rectangle_angle = atan(ap_x/ap_y); %Radians
            rmax = sqrt(div_x^2 + div_y^2);
            angle = qmatrix(:,:,6);
            temp = find(angle <= rectangle_angle*180/pi);
            d_theta_r(temp) = sqrt( div_y.^2 + (rmax.*sin(angle(temp)*pi/180)).^2);
            temp = find(angle > rectangle_angle*180/pi & angle <= 180-rectangle_angle*180/pi);
            d_theta_r(temp) = sqrt( (rmax.*cos(angle(temp)*pi/180)).^2 + div_x.^2);
            temp = find(angle >180-rectangle_angle*180/pi & angle <= 180+rectangle_angle*180/pi);
            d_theta_r(temp) = sqrt( div_y.^2 + (rmax.*sin(angle(temp)*pi/180)).^2);
            temp = find(angle >180+rectangle_angle*180/pi & angle <= 360-rectangle_angle*180/pi);
            d_theta_r(temp) = sqrt( (rmax.*cos(angle(temp)*pi/180)).^2 + div_x.^2);
            temp = find(angle > 360-rectangle_angle*180/pi);
            d_theta_r(temp) = sqrt( div_y.^2 + (rmax.*sin(angle(temp)*pi/180)).^2);
            foreimage.(['resolution_data' detno]).theta_shape = 'tophat';
            foreimage.resolution_data0.theta_shape = 'tophat'; %General resolution description - not detector specific
            if ap_x == ap_y
                resolution_history{length(resolution_history)+1} = ['Effective source is Square of dimensions:  ' num2str(ap_x*1000) ' (mm)  x  ' num2str(ap_y*1000) ' (mm) at a distance of: ' num2str(col) ' (m)'];
            else
                resolution_history{length(resolution_history)+1} = ['Effective source is Rectangular of dimensions:  ' num2str(ap_x*1000) ' (mm)  x  ' num2str(ap_y*1000) ' (mm) at a distance of: ' num2str(col) ' (m)'];
            end
        end
        
        d_theta_r = d_theta_r /2;  %(Radians) Above actually calculates Delta_2Theta FWHM TOPHAT Distribution
        qmatrix(:,:,17) = d_theta_r*180/pi; %(Degrees) Delta Theta Radial  FWHM TOPHAT Distribution in qmatrix
        
        
        %***** Wavelength Spread - Monochromatic SANS: determined by velocity selector (triangular distribution)*****
        lambda = params.wav; %absolute wavelength
        d_lambda_lambda = params.deltawav; %Fraction (e.g. 0.1 FWHM TRIANGULAR distribution for velocity selector)
        
        if strcmp(foreimage.data_type,'tof')
            foreimage.(['resolution_data' detno]).lambda_shape = 'tophat'; %This is NOT used in build_resolution kernels as it is overridden by the resolution control setting
            foreimage.resolution_data0.lambda_shape = 'tophat'; %General resolution description - not detector specific
        else %Default case - monochromatic selector
            foreimage.(['resolution_data' detno]).lambda_shape = 'triangular'; %This is NOT used in build_resolution kernels as it is overridden by the resolution control setting
            foreimage.resolution_data0.lambda_shape = 'triangular'; %General resolution description - not detector specific
        end
        resolution_history{length(resolution_history)+1} = ['Wavelength resolution d_lambda / lambda:  ' num2str(d_lambda_lambda*100) ' [%] FWHM of ' foreimage.(['resolution_data' detno]).lambda_shape ' shape'];
        
        %Wavelength delta_q resolution component
        warning off
        q = qmatrix(:,:,5); %Mod_q
        d_q_lambda_squared = (q.*q) .* (d_lambda_lambda.*d_lambda_lambda);
        qmatrix(:,:,11) = real(sqrt(d_q_lambda_squared)); %FWHM Triangular (selector) or Top-Hat (D33 TOF)
        
        %Divergence delta_q resolution component (Geometric)
        d_q_theta_squared = (d_theta_r.*d_theta_r) .*( 16*pi*pi / (lambda.*lambda)  - q.*q );
        qmatrix(:,:,12) = real(sqrt(d_q_theta_squared)); %FWHM TOPHAT   OR SHOULD THIS BE A CIRCUAR KERNEL????  FOR CIRCULAR SOURCE APERTURE?
        
        %Detector Pixelation smearing
        [d_q_pixel_line_x] = (gradient(qmatrix(det_params.pixels(2)/2,:,3)));%FWHM TOPHAT profile
        [d_q_pixel_line_y] = (gradient(qmatrix(:,det_params.pixels(1)/2,4)));%FWHM TOPHAT profile
        [temp1,temp2] = meshgrid(d_q_pixel_line_x, d_q_pixel_line_y);
        %Which Mean to take?
        %d_q_pixel = sqrt((temp1.^2 + temp2.^2)/2); %RMS FWHM TOPHAT profile
        %d_q_pixel = (temp1 + temp2)/2; %Mean FWHM TOPHAT profile
        %d_q_pixel = sqrt(temp1.*temp2); %Geometric Mean (square of equivalent area) FWHM TOPHAT profile
        d_q_pixel = 2*sqrt((temp1.*temp2)/pi); %Cricle of the same area FWHM TOPHAT profile
        qmatrix(:,:,18) = d_q_pixel; %FWHM TOPHAT Profile
        resolution_history{length(resolution_history)+1} = ['Detector pixelation:  x: ' num2str(inst_params.(['detector' detno]).pixel_size(1)) '  y: ' num2str(inst_params.(['detector' detno]).pixel_size(2)) ' [mm]'];
        foreimage.(['resolution_data' detno]).pixel_shape = 'tophat';
        foreimage.resolution_data0.pixel_shape = 'tophat'; %General resolution description - not detector specific

        
        %Aperture (sample) smearing
        sample_ap_size = status_flags.resolution_control.aperture_size; %m (diameter)
        r = sample_ap_size*(col + sdet)/col;
        two_theta_ap = atan(r/sdet);
        theta_ap = two_theta_ap / 2;
        delta_q_ap_hwhm = (4*pi/lambda)*sin(theta_ap/2);
        delta_q_ap_fwhm = delta_q_ap_hwhm*2;
        qmatrix(:,:,19) = delta_q_ap_fwhm; %FWHM Top_Hat Distribution
        resolution_history{length(resolution_history)+1} = ['Sample aperture: assuming circular  ' num2str(sample_ap_size*1000) ' [mm] diameter'];
        foreimage.(['resolution_data' detno]).aperture_shape = 'circular';
        foreimage.resolution_data0.aperture_shape = 'circular'; %General resolution description - not detector specific

        
        % ***** Classic Resolution ****
        % Total q-resolution (add components in quadrature)
        
        %convert to sigmas to add in quadrature
        if status_flags.resolution_control.wavelength_type ==1
            d_q_lambda_squared = d_q_lambda_squared ./ (2.45*2.45); %fwhm = 2.45sigma (triangular)
        elseif status_flags.resolution_control.wavelength_type ==2
            d_q_lambda_squared = d_q_lambda_squared ./ (3.4*3.4); %fwhm = 3.4sigma (to-hat)
        end
        d_q_theta_squared = d_q_theta_squared ./ (3.4*3.4);
        d_q_ap_squared = (delta_q_ap_fwhm^2) ./ (3.4*3.4); %fwhm to sigma for square
        d_q_pixel_squared = mean(mean(d_q_pixel))^2 / (3.4*3.4); %fwhm to sigma for square
        
        %Check if to use all components
        if status_flags.resolution_control.wavelength_check == 0; d_q_lambda_squared = 0; end
        if status_flags.resolution_control.divergence_check == 0; d_q_theta_squared = 0; end
        if status_flags.resolution_control.aperture_check == 0; d_q_ap_squared = 0; end
        if status_flags.resolution_control.pixelation_check == 0; d_q_pixel_squared = 0; end
        
        %Add all resolution components 'sigma's' in quadrature (Gaussian Aproximation)
        delta_q_squared = d_q_lambda_squared  +   d_q_theta_squared   + d_q_ap_squared  +  d_q_pixel_squared;
        delta_q = real(sqrt(delta_q_squared));
        qmatrix(:,:,13) = delta_q*2.3548; %back to fwhm Gaussian - to be used in gaussian approximation after
        foreimage.(['resolution_data' detno]).classic_res_shape = 'gaussian';
        foreimage.resolution_data0.classic_res_shape = 'circular'; %General resolution description - not detector specific

        
        
        %Lastly - calculate gradients in x and y for q/pixel - used, e.g. in 2D
        %fitting resolution correction to calculate virtual pixel coordinates for
        %the smearing matrix
        [qmatrix(:,:,20),~] = gradient(qmatrix(:,:,3));
        [~,qmatrix(:,:,21)] = gradient(qmatrix(:,:,4));
        
        
        if status_flags.command_window.display_params ==1 && det ==1
            for n = 1:length(resolution_history)
                disp(resolution_history{n});
            end
        end
        
    end
    foreimage.(['qmatrix' detno]) = qmatrix;
    
    
end
warning on


