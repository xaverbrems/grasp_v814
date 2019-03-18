function numor_data = raw_read_ornl_sans(fname)

%This is the data loader for ORNL CG2 SANS.

global inst_params

param = [];

%Load In Data, Numor
fid=fopen(fname);

warning on
%Read ORNL CG2 XML format data
%linestr = ''; line_counter = 0;

param.start_date = ['**-**-**']; %Start Date
param.start_time = ['**-**-**']; %Start Time
param.end_date = ['**-**-**']; %End Date
param.end_time = ['**-**-**']; %End Time
param.info.user = ['NoName']; %User name



while feof(fid) ==0
    linestr = fgetl(fid);
%     
%     if strfind(linestr,'<x_mm_per_pixel type=')
%         temp1 = findstr(linestr,'>'); temp2 = findstr(linestr,'<');
%         str = linestr(temp1+1:temp2(2)-1);
%         numor_data.params1(inst_params.vectors.pixel_x) = str2num(str);
%         if numor_data.params1(inst_params.vectors.pixel_x) ~= inst_params.detector1.pixel_size(1); %Default Pixel X-setting
%             disp(['Modifying Pixel X size from ' num2str(inst_params.detector1.pixel_size(1)) ' to ' num2str(numor_data.params1(inst_params.vectors.pixel_x))]);
%             inst_params.detector1.pixel_size(1) = numor_data.params1(inst_params.vectors.pixel_x);
%         end
%     end
%     
%     if strfind(linestr,'<y_mm_per_pixel type=')
%         temp1 = findstr(linestr,'>'); temp2 = findstr(linestr,'<');
%         str = linestr(temp1+1:temp2(2)-1);
%         param(inst_params.vectors.pixel_y) = str2num(str);
%         if param(inst_params.vectors.pixel_y) ~= inst_params.detector1.pixel_size(2); %Default Pixel Y-setting
%             disp(['Modifying Pixel Y size from ' num2str(inst_params.detector1.pixel_size(2)) ' to ' num2str(param(inst_params.vectors.pixel_y))]);
%             inst_params.detector1.pixel_size(2) = param(inst_params.vectors.pixel_y);
%         end
%     end
    
    
    
    if strfind(linestr,'<Reactor_Power type=')
        temp1 = findstr(linestr,'>'); temp2 = findstr(linestr,'<');
        str = linestr(temp1+1:temp2(2)-1);
        param.reactor_power = str2num(str); % in m
    end
    
    if strfind(linestr,'<Users>')
        user_str = strrep(linestr,'</Users>','');
        [token,rem] = strtok(user_str,'<Users>');
        param.user = strcat(token,rem);
    end
    
    if strfind(linestr,'<Scan_Title>')
        Title_str=strrep(linestr,'</Scan_Title>','');
        [token,rem]=strtok(Title_str,'<Scan_Title>');
        param.subtitle = strcat(token,rem);
    end
    
    if strfind(linestr,'sample_det_dist pos=')
        temp1 = findstr(linestr,'>'); temp2 = findstr(linestr,'<');
        det_str = linestr(temp1+1:temp2(2)-1);
        param.det = str2num(det_str); % in m
    end
    
    if strfind(linestr,'wavelength type=')
        temp1 = findstr(linestr,'>'); temp2 = findstr(linestr,'<');
        wav_str = linestr(temp1+1:temp2(2)-1);
        param.wav = str2num(wav_str); % in Angs    
        
        %Check for zero value
        if param.wav ==0
            temp =inputdlg(({'Enter Wavelength'}),'Wavelength Zero in File: Enter Wavelength',[1],{'6'});
            param.wav = str2num(temp{:});
        end
    end
    
    if strfind(linestr,'wavelength_spread type=')
        temp1 = findstr(linestr,'>'); temp2 = findstr(linestr,'<');
        delta_wav_str = linestr(temp1+1:temp2(2)-1);
        param.deltawav = str2num(delta_wav_str); % in Angs
        
        %Check for zero value
        if param.deltawav ==0
            temp =inputdlg(({'Enter Wavelength Spread'}),'Wavelength Spread Zero in File: Enter DLambda (%)',[1],{'6'});
            param.deltawav = str2num(temp{:})/100;
        end
    end
  
    if strfind(linestr,'<source_distance type=')
        temp1 = findstr(linestr,'>'); temp2 = findstr(linestr,'<');
        col_str = linestr(temp1+1:temp2(2)-1);
        param.col=str2num(col_str)/1000;
    end
    
    if strfind(linestr,'<source_aperture_size type=')
        temp1 = findstr(linestr,'>'); temp2 = findstr(linestr,'<');
        source_str = linestr(temp1+1:temp2(2)-1);
        param.source_ap=str2num(source_str)/1000;
        
        try
            param.source_ap_x = param.source_ap(1);
            param.source_ap_y = param.source_ap(2);
            
        catch
            disp('Warning:  Source size is not defined in the data file')
            try
                disp('Trying guide_size specified in instrument config as default source size (inst_params.guide_size = [x,y];')
                param.source_ap_x = inst_params.guide_size(1);
                param.source_ap_y = inst_params.guide_size(2);
                
            catch
                disp('Failed:  Using default source size of 40 x 40 mm')
                param.source_ap_x = 40e-3;
                param.source_ap_y = 40e-3;
            end
            
        end
       
    end

    if strfind(linestr,'<selector_speed pos=') %Selector speed RPM EB 07/08/11
        temp1 = findstr(linestr,'"'); temp2 = findstr(linestr,'"');
        temp_str = linestr(temp1+1:temp2(2)-1);
        param.sel_rpm = str2num(temp_str);
    end

    if strfind(linestr,'<beam_trap_x pos=') %Beam stop x EB 07/08/11
        temp1 = findstr(linestr,'"'); temp2 = findstr(linestr,'"');
        temp_str = linestr(temp1+1:temp2(2)-1);
        param.bx = str2num(temp_str);
    end
    
    if strfind(linestr,'<trap_y_76mm pos=') %Beam stop y EB 07/08/11
        temp1 = findstr(linestr,'"'); temp2 = findstr(linestr,'"');
        temp_str = linestr(temp1+1:temp2(2)-1);
        param.by = str2num(temp_str);
    end
    
    if strfind(linestr,'<time units=')
        temp1 = findstr(linestr,'>'); temp2 = findstr(linestr,'<');
        time_str = linestr(temp1+1:temp2(2)-1);
        params.time = str2num(time_str);
    end

    if strfind(linestr,'tsample pos=') %Regulation temperature EB 07/08/11
        temp1 = findstr(linestr,'"'); temp2 = findstr(linestr,'"');
        temp_str = linestr(temp1+1:temp2(2)-1);
        param.treg = str2num(temp_str);
    end
    
    if strfind(linestr,'tsample2 pos=') %Sample temperature
        temp1 = findstr(linestr,'"'); temp2 = findstr(linestr,'"');
        temp_str = linestr(temp1+1:temp2(2)-1);
        param.temp = str2num(temp_str);
    end
    
    if strfind(linestr,'<monitor units=')
        temp1 = findstr(linestr,'>'); temp2 = findstr(linestr,'<');
        monitor_str = linestr(temp1+1:temp2(2)-1);
        param.monitor = str2num(monitor_str);
    end

    if strfind(linestr,'sample_zarc pos=')     %zarc is d22 phi
        temp1 = findstr(linestr,'>'); temp2 = findstr(linestr,'<');
        zarc_str = linestr(temp1+1:temp2(2)-1);
        param.zarc=str2num(zarc_str);
    end

    if strfind(linestr,'sample_rotation pos=')
        temp1 = findstr(linestr,'>'); temp2 = findstr(linestr,'<');
        rot_str = linestr(temp1+1:temp2(2)-1);
        param.san=str2num(rot_str);
    end
    
    if strfind(linestr,'attenuator_pos pos=')
        temp1 = findstr(linestr,'"'); temp2 = findstr(linestr,'"');
        att_str = linestr(temp1+1:temp2(2)-1);
        if strcmp(att_str,'open'); att = 0; att_status = 0;
        elseif strcmp(att_str,'x2k'); att = 1; att_status = 1;
        else  att = 0; att_status = 0;
        end
        
        
        param.att_type = att;
        param.att_status = att_status;
        %Patch nominal attenuation values if the actual value doesn't exist in the file
        param.attenuation = inst_params.attenuators(param.att_type+1);

        
    end


    

    %if strfind(linestr,'<mag_field>') %Magnetic field
    %   field_str = strtok(linestr,'<mag_field>');
    %    param(inst_params.vectors.mag_field) = str2num(field_str);
    %end

    %
    %     if strfind(linestr,'<beam_center_x_pixel type="FLOAT32">')
    %         bx=strtok(linestr,'<beam_center_x_pixel type="FLOAT32">');
    %         param(inst_params.vectors.bx)=str2num(bx);
    %     end
    %
    %     if strfind(linestr,'<beam_center_y_pixel type="FLOAT32">')
    %         by=strtok(linestr,'<beam_center_y_pixel type="FLOAT32">');
    %         param(inst_params.vectors.by)=str2num(by);
    %     end

    %if strfind(linestr,'<Detector type="INT32[192,192]">')
    if strfind(linestr,'<Detector type="INT32') % EB 06/08/2011
        data=fscanf(fid,'%g',[inst_params.detector1.pixels(2) inst_params.detector1.pixels(1)]);
    end
end
 
%Close the data file
fclose(fid);

%Add extra parameter total counts actually counted from the data in the file
param.array_counts = sum(sum(data)); %The total Det counts as summed from the data array
param.numor = 00000; %Additional parameter added by chuck
disp('Using SQRT(I) errors')
error_data = sqrt(data);

numor_data.data1 = data;
numor_data.error1 = error_data;
numor_data.params1{1} = param;

