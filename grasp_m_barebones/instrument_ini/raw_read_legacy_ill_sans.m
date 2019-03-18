function numor_data = raw_read_legacy_ill_sans(fname)

%Usage:  numor_data = raw_read_ill_sans(fname);
%'fname' is the full data path AND filename
%
%Reads file Data Numor and outputs all information as a structure including fields:
%numor_data.data1    - 2D matrix of detector data from detector1
%          .data2    -  ...from detector 2 etc.
%          .error1   - sqrt(data1)
%          .params  - Parameter array from detector1

global inst_params
global grasp_env

numor_data = [];

%Load In Data, Numor
fid=fopen(fname);

%Read Data blocks in order they appear in the file

%Loop to find the numor line
while feof(fid) ==0
    text = fgetl(fid);
    if findstr(text,'RRRRR')
        [pointers,~] = fscanf(fid,'%8g');
        numor_data.params1{1}.numor = pointers(1);
        break
    end
end

%Loop to find first IIII block - describes number of frames and detector size
while feof(fid) ==0
    text = fgetl(fid);
    if findstr(text,'IIIII')
        [pointers,~] = fscanf(fid,'%8i',1); %Get data sizer (=156)
        frame_det_size = fscanf(fid,'%g',pointers);
        frames = frame_det_size(1);
        %image_size = frame_det_size(2);
        break
    end
end

%Loop to find the parsub, time & date block (2nd AAAAA block)
while feof(fid) ==0
    text = fgetl(fid);
    %Search for Parsub Block
    if findstr(text,'AAAAA')%
        [~,~] = fscanf(fid,'%8i'); %Read the data sizer line (not used)
        parsub=fgetl(fid);
        %User
        numor_data.params1{1}.user = parsub(1:10);
        %Parsub
        l = size(parsub);
        numor_data.params1{1}.subtitle =  parsub(61:l(2));
        %Start and End Time and Date
        date_time = fgetl(fid);
        numor_data.params1{1}.start_date =  date_time(1:10);
        numor_data.params1{1}.start_time =  date_time(11:20);
        numor_data.params1{1}.end_date = date_time(21:30);
        numor_data.params1{1}.end_time = date_time(31:40);
        break
    end
end

%Loop to find the parameter names and parameters
%Note: the parameter names are not always there so can't rely on finding them
while feof(fid) ==0
    text = fgetl(fid);
    
    %Search for header text and parameters block
    if findstr(text,'FFFFF')
        text = fgetl(fid); %Read the data sizer line
        temp = str2num(text);
        no_parameters = temp(1);
        if length(temp) ==2
            lines_pnames = temp(2);
            for n = 1:lines_pnames
                text = fgetl(fid);
            end
        end
        
        %Read Parameters
        params=fscanf(fid,'%g',no_parameters);
        
        %Allocated the essential parameters
        
        %Instrument Config
        numor_data.params1{1}.det = params(19);
        numor_data.params1{1}.detcalc = params(26);
        numor_data.params1{1}.col = params(58);
        numor_data.params1{1}.bx = params(17);
        numor_data.params1{1}.by = params(16);
        numor_data.params1{1}.att_status = params(60);
        numor_data.params1{1}.att_type = params(59);
        %Patch nominal attenuation values if the actual value doesn't exist in the file
        numor_data.params1{1}.attenuation = inst_params.attenuators(numor_data.params1{1}.att_type+1);
        numor_data.params1{1}.reactor_power = params(84);
        numor_data.params1{1}.wav = params(53);
        numor_data.params1{1}.deltawav = params(54);
        numor_data.params1{1}.tof_delay = 86; %microS
        numor_data.params1{1}.tof_width = 87; %microS
        
        numor_data.params1{1}.source_ap_x = params(61);
        numor_data.params1{1}.source_ap_y = params(62);
        
        numor_data.params1{1}.pixel_x = params(55);
        numor_data.params1{1}.pixel_y = params(56);
        
        
        %Acquisition
        numor_data.params1{1}.aq_time = params(1)/10; %10th seconds to seconds
        numor_data.params1{1}.ex_time = params(1)/10;
        numor_data.params1{1}.monitor = params(5);
        numor_data.params1{1}.array_counts = 0; %Will be updated below
        
        %Sample movements
        numor_data.params1{1}.sdi = params(64);
        numor_data.params1{1}.san = params(65);
        numor_data.params1{1}.chpos = params(66);
        numor_data.params1{1}.sht = params(67);
        numor_data.params1{1}.omega = params(69);
        numor_data.params1{1}.gsan = params(70);
        numor_data.params1{1}.gtrs = params(71);
        numor_data.params1{1}.trs = params(101);
        numor_data.params1{1}.phi = params(102);
        numor_data.params1{1}.gtrs = params(71);
        
        %Sample Environment
        numor_data.params1{1}.tset = params(29);
        numor_data.params1{1}.treg = params(30);
        numor_data.params1{1}.temp = params(31);
        
        
        %         if isfield(inst_params.vectors,'col_app');
        %              params(inst_params.vectors.col_app) = params(inst_params.vectors.col_app) + 1; %D22 gives 0 or 1, I want 1 or 2 to index a matrix
        %         end
        %
        %         %Temporary Collimation =0 Instrument bug
        %         if params(inst_params.vectors.col) == 0;
        %             %temp =inputdlg(({'Enter Collimation Length'}),'Data Patch:',[1],{num2str(d22_bugs.col)});
        %             %params(inst_params.vectors.col) = str2num(temp{:});
        %             params(inst_params.vectors.col) = d22_bugs.col;
        %         elseif not(single(inst_params.col) == single(params(inst_params.vectors.col)))
        %             %temp =inputdlg(({'Enter Collimation Length'}),'Data Patch:',[1],{num2str(d22_bugs.col)});
        %             %params(inst_params.vectors.col) = str2num(temp{:});
        %             params(inst_params.vectors.col) = d22_bugs.col;
        %         else
        %             d22_bugs.col = params(inst_params.vectors.col);
        %         end
        
        
        %         %Temporary Attenuator Bugs (for fake d22 data from laptop)
        %         params(inst_params.vectors.att_type) = round(params(inst_params.vectors.att_type));
        %         if params(inst_params.vectors.att_type) ==0; params(inst_params.vectors.att_status) = 0; end
        %         if params(inst_params.vectors.det) == 0; params(inst_params.vectors.det) = 1; end
        
        
        
        %Check if the pixel size reported in the params is different to the default instrument setting.
        %Added after change of D22 detector, March 2004.
        if strcmp(grasp_env.inst,'ILL_d22') %D22 only at the moment DO NOT DO THIS FOR RAW DATA AS IT HAS THE WRONG PIXEL SIZE
            
            if numor_data.params1{1}.pixel_x ~= inst_params.detector1.pixel_size(1) %Default Pixel X-setting
                
                disp(['Modifying Pixel X size from ' num2str(inst_params.detector1.pixel_size(1)) ' to ' num2str(numor_data.params1{1}.pixel_x)]);
                inst_params.detector1.pixel_size(1) = numor_data.params1{1}.pixel_x;
            end
            if numor_data.params1{1}.pixel_y ~= inst_params.detector1.pixel_size(2) %Default Pixel Y-setting
                disp(['Modifying Pixel Y size from ' num2str(inst_params.detector1.pixel_size(2)) ' to ' num2str(numor_data.params1{1}.pixel_y)]);
                inst_params.detector1.pixel_size(2) = numor_data.params1{1}.pixel_y;
            end
            
%             %Patch effective collimation length if using entrance apertures at the attenuator position
%             if params(inst_params.vectors.att_type) > 3 && params(inst_params.vectors.att_type) < 8
%                 if params(inst_params.vectors.att_status) == 1
%                     disp(['Entrance Aperture in use:  Patching effective collimation length to ' num2str(inst_params.col(length(inst_params.col)))]);
%                     params(inst_params.vectors.col) = inst_params.col(length(inst_params.col));
%                     params(inst_params.vectors.col_app) = params(inst_params.vectors.att_type);
%                 end
%             end
        end

        
        
        
        
        break
    end
end


%Loop to find the 2nd IIIII block - contains nothing useful at this time
while feof(fid) ==0
    text = fgetl(fid);
    if findstr(text,'IIIII')
        break
    end
end

%Loop to find the SSSSS block - cross-check to see if there are now more frames declared i.e. kinetic files.
while feof(fid) ==0
    text = fgetl(fid);
    if findstr(text,'SSSSS')
        [pointers,~] = fscanf(fid,'%8g');
        kin_frames = pointers(3);
        break
    end
end


if frames == 1 && kin_frames == 1
    file_type = 'single frame';
elseif frames ~=1
    file_type = 'tof';
elseif frames ==1 && kin_frames ~=1
    file_type = 'kinetic';
    frames = kin_frames;
end
disp(['File type is: ' file_type]);
disp(['Number of frames:  ' num2str(frames)]);
numor_data.n_frames = frames;


%If TOF File the there is an extra IIIII - This should contain the monitors
%Loop to find the 3rd IIIII block
monitor_block = [];
if strcmp(file_type,'tof')
    while feof(fid) ==0
        text = fgetl(fid);
        if findstr(text,'IIIII')
            %Frame Monitors
            n_i_params= fscanf(fid,'%g',1);
            numor_data.monitors = fscanf(fid,'%g',n_i_params);
            break
        end
    end
end



%Loop to find the final IIIII blocks, containing detector images (single file and tof)
%Loop to find the each monitor/time FFFFF block and IIIII image block / slice (kinetic)
data = [];
for n = 1:frames
    while feof(fid) ==0
        text = fgetl(fid);
        %If Kinetic file each monitor and time / slice is stored above each frame
        if strcmp(file_type,'kinetic')
            if findstr(text,'FFFFF')
                disp(['Reading Time/Monitor frame ' num2str(n)]);
                text = fgetl(fid); %skip
                text = fgetl(fid); %skip
                [pointers,~] = fscanf(fid,'%16g');
                monitor_block(n) = pointers(2);
                time_block(n) = pointers(1); %AT THE MOMENT NOMAD IS WRITING Kinetic file time in Seconds, not 10ths seconds
            end
        end
        %If tof then calculate frame_time (Calculate to CENTRE of time frame)
        if strcmp(file_type,'tof')
            numor_data.params1{1}.frame_time = (numor_data.params1{1}.tof_delay + numor_data.params1{1}.tof_width * (n-1) + numor_data.params1{1}.tof_width/2)/1e6; %convert microS to Seconds
        end
        
        if findstr(text,'IIIII')
            disp(['Reading Frame ' num2str(n)]);
            fgetl(fid); %Skip data sizer
            data(:,:,n)=fscanf(fid,'%g',[inst_params.detector1.pixels(2) inst_params.detector1.pixels(1)]); %Read Data

            data(:,:,n) = rot90(data(:,:,n)); %Turn data right way round for D22 legacy
            
            numor_data.data1(:,:,n) = flipud(data(:,:,n));
            disp('Using SQRT(I) errors')
            numor_data.error1(:,:,n) = sqrt(numor_data.data1(:,:,n));
            
            %Make a copy of the parameters for each frame
            %Add extra parameter total counts actually counted from the data in the file
            %inst_params.fparams(127) = {'Multi Det Sum'};
            numor_data.params1{1}.array_counts = sum(sum(sum(numor_data.data1(:,:,n))));
            
            %             %Add additional 'Is Tof' flag parameter - used to automatically switch the resolution selector (triangle) or D33 TOF (top-hat) resolution function
            %             if isfield(inst_params.vectors,'is_tof')
            %                 params(inst_params.vectors.is_tof) = 0; %Default Monochromatic Selector
            %                 if strcmp(file_type,'tof');
            %                     params(inst_params.vectors.is_tof) = 1;
            %                 end
            %             end
            
            
            %             %Patch the correct monitor and time for kinetic files
            %             if strcmp(file_type,'kinetic')
            %                 params(inst_params.vectors.monitor) = monitor_block(n);
            %                 params(inst_params.vectors.time) = time_block(n);
            %             end
            
            %             %Patch the correct monitor for TOF files
            %             if strcmp(file_type,'tof')
            %                 params(inst_params.vectors.monitor) = numor_data.monitors(n);
            %             end
            
            %numor_data.params1(:,n) = params;
            
            break
        end
    end
end

numor_data.file_type = file_type;


%Close file
fclose(fid);


% if isfield(inst_params.vectors,'att2');
%     numor_data.params1(inst_params.vectors.att2) = 1;
% end


