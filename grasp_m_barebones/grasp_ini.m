function grasp_ini

global grasp_env
global status_flags


fid=fopen(['ini' filesep 'grasp.ini']); %Open default grasp.ini file
line = 1;
warning off

if not(fid==-1)
    disp('Loading Grasp Configuration from grasp.ini');
    
    while line~=-1
        line = fgets(fid);

        %Instrument
        if findstr(line,'inst=')
            eqpos = findstr(line,'=');
            grasp_env.inst = strtok(line(eqpos+1:end));
        end
        
        %Data Path
        if findstr(line,'data_dir')
            eqpos = findstr(line,'=');
            grasp_env.path.data_dir = strtok(line(eqpos+1:end));
        end

        %Project Path
        if findstr(line,'project_dir')
            eqpos = findstr(line,'=');
            grasp_env.path.project_dir = strtok(line(eqpos+1:end));
        end
        
        %Project Title
        if findstr(line,'project_title')
            eqpos = findstr(line,'=');
            grasp_env.project_title = strtok(line(eqpos+1:end));
        end
        
        %Display
        if findstr(line,'fontsize')
            eqpos = findstr(line,'=');
            grasp_env.fontsize = str2num(line(eqpos+1:end));
            
        elseif findstr(line,'font')
            eqpos = findstr(line,'=');
            grasp_env.font = deblank(line(eqpos+1:end));
        end
        
        if findstr(line,'colormap_invert')
            eqpos = findstr(line,'=');
            status_flags.color.invert = str2num(line(eqpos+1:end));
            
        elseif findstr(line,'colormap_swap')
            eqpos = findstr(line,'=');
            status_flags.color.swap = str2num(line(eqpos+1:end));
            
        elseif findstr(line,'colormap')
            eqpos = findstr(line,'=');
            status_flags.color.map = strtok(line(eqpos+1:end));
        end

        if findstr(line,'render')
            eqpos = findstr(line,'=');
            status_flags.display.render = strtok(line(eqpos+1:end));
        end
        
        if findstr(line,'sub_figure_background_color')
            eqpos = findstr(line,'=');
            grasp_env.sub_figure_background_color = str2num(line(eqpos+1:end));
        elseif findstr(line,'background_color')
            eqpos = findstr(line,'=');
            grasp_env.background_color = str2num(line(eqpos+1:end));
        end

        %Worksheets
        if findstr(line,'worksheets=')
            eqpos = findstr(line,'=');
            grasp_env.worksheet.worksheets = str2num(line(eqpos+1:end));
        end

        if findstr(line,'worksheets_max=')
            eqpos = findstr(line,'=');
            grasp_env.worksheet.worksheet_max = str2num(line(eqpos+1:end));
        end

        if findstr(line,'depth_max=')
            eqpos = findstr(line,'=');
            grasp_env.worksheet.depth_max = str2num(line(eqpos+1:end));
        end
        
        %Data
        if findstr(line,'normalization')
            eqpos = findstr(line,'=');
            status_flags.normalization.status = strtok(line(eqpos+1:end));
        end
        if findstr(line,'standard_monitor')
            eqpos = findstr(line,'=');
            status_flags.normalization.standard_monitor = str2num(line(eqpos+1:end));
        end
        if findstr(line,'standard_time')
            eqpos = findstr(line,'=');
            status_flags.normalization.standard_time = str2num(line(eqpos+1:end));
        end
    end
    fclose(fid);
    warning on
       
else
    disp('''grasp.ini'' doesn''t exist. Using default settings.');
    
    %Default Data Dir
    grasp_env.path.data_dir = filesep; %PC path to network drive 'z' attached to SERDON/DATA/
    grasp_env.path.project_dir = filesep;
    
    %Default Instrument
    grasp_env.inst = 'ILL_d33';
    
    %Default project title
    grasp_env.project_title = 'UNTITLED';
    
    %Font Style and Sizes. These should be tuned depending on the system
    grasp_env.font = 'Arial';
    grasp_env.fontsize = 10; %Windows NT/98 (1280x1024 - Small Fonts)
    
    %Default Display Colours
    grasp_env.background_color = [0.2 0.26 0.21]; %- Dark Grey /Green
    grasp_env.sub_figure_background_color = [0.4 0.05 0]; %- Burgundy
    
    %Worksheet management
    grasp_env.worksheet.worksheets = 6; %Number of Worksheets per Worksheet Group
    grasp_env.worksheet.worksheet_max = 20; %Max number of Worksheets
    grasp_env.worksheet.depth_max = 500;
end

%Set misc environment parameters
set(0,'defaultfigurepapertype','a4');
%colordef black; %Window bacground
colordef none;
grasp_env.displayimage.active_axis_color = 'white'; %Red
grasp_env.displayimage.inactive_axis_color = [0.8 0.6 0.4]; %White

%Screen resolution and scaling
temp = get(0,'screensize');
grasp_env.screen.grasp_main_default_position = [0.025, 0.1, 0.4, 0.82]; %x0,y0,dx0,dy0
screen_scaling = 2560 * temp(4) / ( 1400 * temp(3)); 
grasp_env.screen.screen_scaling = [screen_scaling, 1, screen_scaling, 1];
grasp_env.screen.grasp_plot_default_position = [0.53, 0.48, 0.41, 0.44];
grasp_env.fontsize = grasp_env.fontsize / screen_scaling; %Rescale fonts according to screen resolution
if ispc
    grasp_env.fontsize = grasp_env.fontsize*0.8;
end

%Data types
grasp_env.data_type.data = 'single';
grasp_env.data_type.error = 'single';
grasp_env.data_type.mask = 'logical';
grasp_env.data_type.det_eff = 'single';



