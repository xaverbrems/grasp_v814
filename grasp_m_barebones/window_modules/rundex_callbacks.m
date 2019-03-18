function rundex_callbacks(to_do)

global grasp_handles
global grasp_env
global inst_params
global status_flags
global displayimage

if nargin ==0; to_do = ''; end

switch to_do
    case 'params'
        param_values = get(gcbo,'value');
        string = get(gcbo,'string');
        status_flags.rundex.params = string(param_values);
        
    case 'close'
        grasp_handles.window_modules.rundex.window = [];
        
    case 'rundex'
        
        print_headers = 'on'; %Use this to enable / disable printing of suplimentary information
        
        %Retrieve Parameters Back From Rundex Window
        numor1 = str2num(get(grasp_handles.window_modules.rundex.numor1,'string'));
        numor2 = str2num(get(grasp_handles.window_modules.rundex.numor2,'string'));
        skip = str2num(get(grasp_handles.window_modules.rundex.skip,'string'));
        extra = status_flags.rundex.params;
        if numor2 ==0; numor2 = numor1; end
        
        %***** Open text file for output *****
        fname = '*.dex';
        start_string = [grasp_env.path.project_dir fname];
        [fname, directory] = uiputfile(start_string,'Save Rundex As:');
        
        if fname == 0
            write_file_flag = 0; print_headers = 'off';
        else
            if isempty(findstr(fname,'.dex')); fname = [fname '.dex']; end
            grasp_env.path.project_dir = directory;
            fid=fopen([directory fname],'w');
            write_file_flag = 1;
        end
        
        %***** Two lines of header *****
        if strcmp(print_headers,'on')
            time = fix(clock);
            textstring = ['Rundex Directory File Listing:'];
            if write_file_flag == 1; fprintf(fid,'%s',[textstring char(13) newline]); end
            textstring = ['Created by ' grasp_env.grasp_name  ';  Date ' num2str(time(3)) '/' num2str(time(2)) '/' num2str(time(1)) '; Time ' num2str(time(4)) ':' num2str(time(5)) ':' num2str(time(6))];
            if write_file_flag == 1; fprintf(fid,'%s',[textstring char(13) newline]); fprintf(fid,'%s',[char(13) newline]); end
        end
        
        %***** Header text *******
        %if strcmp(print_headers,'on');
            %disp_string = ['Run     User       Title                   Det     Col     Wav     Time    Monitor Mon/s  DetSum    Det/s     '];
            disp_string = ['Run     Title                   Det     Col     Wav     Det1Rate     MonRate     '];
            %Now add aditional user params names
            if not(isempty(extra))
                len = length(extra);
                for m = 1:len
                    disp_string = [disp_string extra{m} blanks(8-length(extra{m}))];
                end
            end
            disp(' ');
            disp(disp_string); %Write to Screen
            if write_file_flag ==1; fprintf(fid,'%s',[disp_string char(13) newline]); end %Write to file
        %end
        
        %***** Search through Numors *****
        last_col = []; last_det = []; last_att = []; last_wav = []; last_dtr = []; col_app_str = ' ';
        last_user = '        ';
        for numor = numor1:skip:numor2
            
            %Prepare the full file name string
            numors_str = [inst_params.filename.lead_string num2str(numor,['%.' num2str(inst_params.filename.numeric_length) 'i']) inst_params.filename.tail_string inst_params.filename.extension_string];
            %Full path to file
            file_name_path = fullfile(grasp_env.path.data_dir,numors_str);
            %disp(' ')
            %disp(['Loading file:  ' file_name_path]);
            
            %Check for file decompression (using gzip)
            file_name_path = numor_decompress(file_name_path);
            
            %Read the file
            if not(isempty(file_name_path))
                fn_string = [inst_params.filename.data_loader '(file_name_path)'];
                try
                    numor_data = eval(fn_string);
                    param = numor_data.params1{1};
                catch
                     param = [];
                end
                
                %Add a few 'manufactured' parameters
                param.monitor_rate = param.monitor / param.aq_time;
                param.det1_rate = param.array_counts / param.aq_time;
                
                %Collimation change notification
                new_col = param.col;
                if not(isempty(last_col))
                    if last_col ~= new_col
                        
                        col_app_str = ' ';
                        if isfield(param,'col_app')
                            if param(param.col_app) == 0; col_app_str = 'R';
                            else col_app_str = 'C';
                            end
                        end
                        if strcmp(print_headers,'on')
                            disp_string = ['Collimation Change from ' num2str(last_col) ' (m)   >  ' num2str(new_col) ' (m) ' col_app_str];
                            fprintf(fid,'%s',[char(13) char(10)]);
                            fprintf(fid,'%s',[disp_string char(13) char(10)]);
                            fprintf(fid,'%s',[char(13) char(10)]);
                        end
                    end
                end
                last_col = new_col;
                
                %Attentuator change notification
                new_att = param.att_type;
                if not(isempty(last_att))
                    if last_att ~= new_att
                        if strcmp(print_headers,'on')
                            disp_string = ['Attenuator Change from Att# ' num2str(last_att) '  >  Att# ' num2str(new_att)];
                            fprintf(fid,'%s',[char(13) char(10)]);
                            fprintf(fid,'%s',[disp_string char(13) char(10)]);
                            fprintf(fid,'%s',[char(13) char(10)]);
                        end
                    end
                end
                last_att = new_att;
                
                %Detector Distance change notification
                new_det = param.det;
                if not(isempty(last_det))
                    if last_det ~= new_det
                        if strcmp(print_headers,'on')
                            disp_string = ['Detector Distance Change from ' num2str(last_det) ' (m)  >  ' num2str(new_det) ' (m)'];
                            fprintf(fid,'%s',[char(13) char(10)]);
                            fprintf(fid,'%s',[disp_string char(13) char(10)]);
                            fprintf(fid,'%s',[char(13) char(10)]);
                        end
                    end
                end
                last_det = new_det;
                
                %DTR change notification
                if isfield(param,'dtr')
                    new_dtr = param.dtr;
                    if not(isempty(last_dtr))
                        if last_dtr ~= new_dtr
                            if strcmp(print_headers,'on')
                                disp_string = ['Detector Translation (DTR) Change from ' num2str(last_dtr) ' (m)  >  ' num2str(new_dtr) ' (m)'];
                                fprintf(fid,'%s',[char(13) newline]);
                                fprintf(fid,'%s',[disp_string char(13) newline]);
                                fprintf(fid,'%s',[char(13) newline]);
                            end
                        end
                    end
                    last_dtr = new_dtr;
                end
                
                
                %Wavelength change notification
                %Needs to be a bit more sensitive as wavelength wanders a bit
                new_wav = param.wav;
                if not(isempty(last_wav))
                    if last_wav < new_wav*0.9 || last_wav > new_wav*1.1
                        if strcmp(print_headers,'on')
                            disp_string = ['Wavelength Change from ' num2str(last_wav) ' (???)  >  ' num2str(new_wav) ' (???)'];
                            fprintf(fid,'%s',[char(13) newline]);
                            fprintf(fid,'%s',[disp_string char(13) newline]);
                            fprintf(fid,'%s',[char(13) newline]);
                        end
                    end
                end
                last_wav = new_wav;
                if abs(param.by) > 99; trans_flag = 'T';
                else trans_flag = ' ';
                end
                
                
                
                if isfield(param,'user'); user = param.user; else user = '        '; end
                if not(strcmp(user,last_user))
                    last_user = user;
                    if strcmp(print_headers,'on')
                        disp_string = ['User Change from ' num2str(last_user) '  >  ' num2str(user)];
                        fprintf(fid,'%s',[char(13) newline]);
                        fprintf(fid,'%s',[disp_string char(13) newline]);
                        fprintf(fid,'%s',[char(13) newline]);
                    end
                end
                %user = [user '                    ']; user = user(1:7); %pad then truncate
                
                title = param.subtitle; title= [title '                                 ']; title = title(1:32);
                
                
                %Numor, title, monitor, monitor/s
                disp_string = [num2str(numor) blanks(8-length(num2str(numor)))]; %Numor
                disp_string = [disp_string user '   ']; %User
                disp_string = [disp_string title '   ']; %Title
                disp_string = [disp_string ' ' trans_flag '  '];
                
                disp_string = [disp_string num2str(param.det,'%6.1f') blanks(8-length(num2str(param.det,'%6.1f')))]; %Det
                
                %Find which col_app
                if isfield(param,'col_app')
                    if param(param.col_app) == 0; col_app_str = 'R';
                    elseif param.col_app ==1; col_app_str = 'C';
                    else col_app_str = ' ';
                    end
                end
                disp_string = [disp_string num2str(param.col,'%6.1f')  col_app_str blanks(7-length(num2str(param.col,'%6.1f')))]; %Col
                disp_string = [disp_string num2str(param.wav,'%6.1f') blanks(8-length(num2str(param.wav,'%6.1f')))]; %Wav
                disp_string = [disp_string num2str(param.det1_rate,'%6.1f') blanks(8-length(num2str(param.det1_rate,'%6.1f')))]; %Det & Mon rate
                disp_string = [disp_string num2str(param.monitor_rate,'%6.1f') blanks(8-length(num2str(param.monitor_rate,'%6.1f')))]; %Det & Mon rate

                %Now add aditional user params
                if not(isempty(extra))
                    len = length(extra);
                    for m = 1:len
                        disp_string = [disp_string num2str(param.([extra{m}]),'%6.1f') blanks(8-length(num2str(param.([extra{m}]),'%6.1f')))];
                    end
                end
                
            else %in case of failure to load file
                disp_string = [num2str(numor) '  :  Error Finding or Loading File'];
            end
            
            disp(disp_string); %Write to Screen
            if write_file_flag == 1; fprintf(fid,'%s',[disp_string char(13) newline]); end%Write to file
            
        end
        %Close File
        if write_file_flag == 1; fclose(fid); end
end

%Update Rundex parameters list

string = rot90(fieldnames(displayimage.params1));
set(grasp_handles.window_modules.rundex.params,'string',string,'max',length(string),'min',1)


