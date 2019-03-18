function data_read

global grasp_handles
global inst_params
global grasp_env
global status_flags
global grasp_data

text_handle = [];


%last_elapsed_time = zeros(inst_params.detectors,1);



%Retrieve the <Numors> string
numors_str_in = get(grasp_handles.figure.data_load,'string');

disp('  '); %Blank text to space out text display
disp(['***** Loading data:  ' numors_str_in ' *****']);
disp('  ');

%Special cases: eg. clear etc.
if strcmp(numors_str_in,'<Numors>'); return %i.e do nothing
elseif strcmp(numors_str_in,'0')
    clear_wks_nmbr(status_flags.selector.fw,status_flags.selector.fn);
    disp('  ');
    return %clear worksheet and depth
elseif isempty(numors_str_in); return %i.e do nothing
end

%Keep the current beam centre and transmission if if loading into foreground worksheet
index = data_index(1); %Beam centres and thicknesses are stored with the sample scattering worksheet
for det=1:inst_params.detectors
    beam_centres.(['cm' num2str(det)]) = grasp_data(index).(['cm' num2str(det)]);
end
thickness = grasp_data(index).thickness{status_flags.selector.fn}; %KEEP THE CURRENT THICKNESSES if loading into foreground worksheet

%Clear worksheet and depth
clear_wks_nmbr(status_flags.selector.fw,status_flags.selector.fn);
status_flags.selector.fd = 1;

%Put old beam centre back into cleared worksheet
if status_flags.selector.fw == 1 %foreground worksheet
    for det = 1:inst_params.detectors
        grasp_data(index).(['cm' num2str(det)]) = beam_centres.(['cm' num2str(det)]);
    end
    grasp_data(index).thickness{status_flags.selector.fn} = thickness;
end


%***** Parse the Numors String for all the avaialible data load options *****
[numor_list, depth_list] = numor_parse(numors_str_in);

%***** Go though the numor list and load the data *****

%Replace the Numors Get It Button with a STOP button
set(grasp_handles.figure.getit,'value',0);
set(grasp_handles.figure.getit,'string','STOP!','foregroundcolor',[0.8 0 0],'callback','set(gcbo,''userdata'',1);');
drawnow

index = data_index(status_flags.selector.fw);
text_handle = grasp_message(['Loading Data:   ' numors_str_in ],1,'main');

for n = 1:length(numor_list)
    numor = numor_list(n);
    depth = depth_list(n);
    
    %Prepare the full file name string
    numors_str = [inst_params.filename.lead_string num2str(numor,['%.' num2str(inst_params.filename.numeric_length) 'i']) inst_params.filename.tail_string inst_params.filename.extension_string];
      
    %Full path to file
    file_name_path = fullfile(grasp_env.path.data_dir,numors_str);
    
    
    %
    %file_name_path = fullfile(grasp_env.path.data_dir, 'p13931_59242_Stan_C8_S2_D0.DAT')
    
    disp(' ');
    disp(['Loading file:  ' file_name_path]);
    
    %Check for file decompression (using gzip)
    file_name_path = numor_decompress(file_name_path);
    
    %Check for empty file_name_path
    if isempty(file_name_path)
        break
    end
    
    
    %***** Read the file & return the 'numor_data' structure ******
    
    if ~isdeployed
        %m-code version running in matlab:  just runs the raw_read .. file loader m-code as usual
        disp(['DataLoader: Using m-code ' inst_params.filename.data_loader]);
        fn_string = [inst_params.filename.data_loader '(file_name_path)'];
        numor_data = eval(fn_string);
    else
        if strcmp(status_flags.preferences.override_inbuild_dataloader,'off') %i.e. use pre-compiled data loader if it exists
            %try running pre-compiled m-code contained within the package
            try
                fn_string = [inst_params.filename.data_loader '(file_name_path)'];
                numor_data = eval(fn_string);
                disp(['DataLoader: Using pre-compiled m-code ' inst_params.filename.data_loader]);
            catch
                disp(['DataLoader: pre-compiled m-code ' inst_params.filename.data_loader ' not found'])
                disp(['Looking for external instrument_ini' filesep 'dataloaders' filesep inst_params.filename.data_loader '.m code in  to try to evaluate']);
                disp('Ask Chuck if you would like this code compiled into Grasp')
                try
                    %check for .m on the end of the data loader file name
                    if isempty(strfind(inst_params.filename.data_loader,'.m'))
                        fname_string = [inst_params.filename.data_loader '.m'];
                    else
                        fname_string = inst_params.filename.data_loader;
                    end
                    numor_data = chuck_eval(['instrument_ini' filesep 'dataloaders' filesep fname_string], file_name_path);
                    disp('chuck_eval of external .m code !Success!')
                catch
                    disp('Oh dear.  Grasp either can''t find your .m code data loader file or it doesn''t run properly')
                end
            end
        else %Override pre-compiled data loader with external .m code if exists
            disp('Overriding internal (compiled-in) DataLoader')
            disp(['Looking for external instrument_ini' filesep 'dataloaders' filesep inst_params.filename.data_loader '.m code in  to try to evaluate']);
            disp('Ask Chuck if you would like this code compiled into Grasp')
            try
                %check for .m on the end of the data loader file name
                if isempty(strfind(inst_params.filename.data_loader,'.m'))
                    fname_string = [inst_params.filename.data_loader '.m'];
                else
                    fname_string = inst_params.filename.data_loader;
                end
                numor_data = chuck_eval(['instrument_ini' filesep 'dataloaders' filesep fname_string], file_name_path);
                disp('chuck_eval of external .m code !Success!')
            catch
                disp('Oh dear.  Grasp either can''t find your .m code data loader file or it doesn''t run properly')
            end
        end
        
    end
    
    %add the load string for reference into the data parameters
    numor_data.load_string = numors_str_in;
    %check n_frames exists
    if not(isfield(numor_data,'n_frames')); numor_data.n_frames = 1; end
    
    
    %New way to calculate elapsed time, taking into about staggered
    %measurements - use serial time converted to seconds
    if n == 1 %First numor reference time
        first_numor_time = datenum([numor_data.params1{1}.start_date numor_data.params1{1}.start_time]);
    end
    start_time = datenum([numor_data.params1{1}.start_date numor_data.params1{1}.start_time]);
    %end_time = datenum([numor_data.params1{1}.end_date numor_data.params1{1}.end_time]);
    %serial_time = ( mean([start_time, end_time]) - first_numor_time) * 24*60*60;
    serial_time = (start_time- first_numor_time) * 24*60*60;
%    numor_data.params1{1}.serial_time =  serial_time;
    
    
    %***** Elapsed time corrections for multiple data load *****
    
    %Add the last elapsed time to the current elapsed time(s).
    %'last_elapsed_time = 0' at the beginning of this routine and gets
    %added too by subsequent data loads and kinetic files
    
    if isfield(numor_data.params1{1},'elapsed_time')
        for d = 1:inst_params.detectors
            detno = num2str(d);
            for e = 1:numor_data.n_frames
                %numor_data.(['params' detno]){e}.elapsed_time = numor_data.(['params' detno]){e}.elapsed_time + last_elapsed_time(d);
                numor_data.(['params' detno]){e}.elapsed_time = numor_data.(['params' detno]){e}.elapsed_time + serial_time;
            end
        end
    end
    
    %Check for kinetic & TOF:  Then modify the subsequent depth lists to take account of multi-depth single files (kin & tof)
    if n< length(numor_list)
        if numor_data.n_frames >1
            temp = find(depth_list>depth_list(n));  %Only modify those not being summed into the current depth(s)
            if ~isempty(temp)
                depth_list(temp) = depth_list(temp)+numor_data.n_frames -1;
                disp(' ')
                disp('Incoming multi-frame data:  Kinetic or TOF.  Modifying Load Depth List')
                disp('Data Load Scheme:')
                disp('Depth:  Numor:')
                disp([depth_list,numor_list])
                disp(' ')
            end
            %                 %Remember the last elapsed time (kinetic & tof multi-frame numor) & compensate for the slice width as elapsed times are centered in the slice
            %                 for d = 1:inst_params.detectors
            %                     detno = num2str(d);
            %                     last_elapsed_time(d) = numor_data.(['params' detno]){end}.elapsed_time + numor_data.(['params' detno]){end}.slice_time_width/2;
            %                 end
        else
            %                 %Remember the last elapsed time (single frame numor) & compensate for the exposure time width as elapsed times are centered in the slice
            %                 for d = 1:inst_params.detectors
            %                     detno = num2str(d);
            %                     last_elapsed_time(d) = numor_data.(['params' detno]){end}.elapsed_time + numor_data.(['params' detno]){end}.ex_time/2;
            %                 end
        end
        
    end
    
    %Data Type - Temporary catch for the file readers that do not spit out a 'file_type' field
    if not(isfield(numor_data,'file_type'))
        numor_data.file_type = 'single frame';
    end
    
    %Place data
    place_data(numor_data, status_flags.selector.fw, status_flags.selector.fn, depth);
    
    if ishandle(text_handle); delete(text_handle); end
end

disp('******** END DATA LOADING ********'); %Blank text to space out text display
disp('  ');


%Replace the Numors Get It Button back to normal
if ishandle(text_handle); delete(text_handle); end
old_getit_callback = ['main_callbacks(''data_read'')'];
set(grasp_handles.figure.getit,'String','Get It!','CallBack',old_getit_callback,'busyaction','cancel','userdata',0,'foregroundcolor',[0 0 0]);
%***** Delete the Loading Message *****



