function gs(to_do,varargin)

%***** Grasp Automation Language Help *****
%
%Use a text editor to write a script file using the 'gs' commands below
%AND any usual Matlab commands, e.g. to make loops etc.
%
%Run the grasp script file either from the Matlab command line or from the
%Grasp Script menu in Grasp
%
%Any Grasp operation can in-principle be automated and the 'gs' script
%language is growing according to requested functionality
%Please contact me, dewhurst@ill.fr to include additonal functionality
%
%
%An example file might contain:
%
%gs('load',1,1,'88144{21}')     %sample worksheet 1
%gs('load',2,1,'88526{21}')     %background worksheet 1
%gs('display',1,1,0)            %Switch display back to sample worksheet 1 sum
%gs('bg','on')                  %Subtract background from foreground
%gs('boxit','san',[43,48,60,65,1],[78,84,60,65,1]) %Box Two Bragg peaks
%
%
%
%
%***** Commands *****
%
%***** Instrument and Data Configuration *****
%
%gs('load',wks,nmbr,'loadstring')
%       Loads data into the wks, nmbr
%       worksheet as described by the 'loadstring'
%       e.g. gs('load',1,1,'12345{21}')
%
%gs('set_data_dir',datapath)
%       Sets the data directory
%       e.g. gs('set_data_dir','/Users/chuck/Desktop/sans_data/')
%
%gs('set_project_dir',datapath)
%       Sets the project/output directory
%       e.g. gs('set_project_dir','/Users/chuck/Desktop/')
%
%gs('set_instrument',facility,inst)
%       Sets the current working instrument
%       e.g. gs('set_instrument','ILL','d22_legecy')
%
%
%
%***** Analysis Tools ******
%
%gs('cm',option)
%       Calculates the Beam Centre from the centre of mass of the current
%       displayed image
%       option = [x1,x2,y1,y2] axis limits within which to take the centre
%       of mass
%       e.g. gs('cm')
%       e.g. gs('cm',[40,80,20,100])
%
%gs('boxit','pname',box1,box2....)
%       Makes a box sum though the current depth against parameter 'pname'.
%       boxes are described by [xmin,xmax,ymin,ymax,det], where det is the
%       detector number. Up to 6 boxes possible
%       e.g. gs('boxit','san',[43,48,60,65,1],[78,84,60,65,1])
%
%gs('sectors',[R1,R2,Th,dTh,Mirrors])
%       Opens the sectors tool with inner radius R1, outer radius R2, angle
%       Th and opening dTh.  Mirrors (optional) is the number of mirror
%       sectors
%       e.g. gs('sector',[10,100,0,45,2])
%
%gs('sector_boxit','pname',sectbox1,sectbox2....)
%       Makes a sector box sum though the current depth against parameter 'pname'.
%       boxes are described by [R1,R2,Theta,DTheta].
%       Up to 6 boxes possible
%       e.g. gs('sector_boxit','san',[15,25,90,20])
%
%gs('fit1d',fn_name,curve#,guess)
%       Fits a 1D curve in the grasp_plot window with function given by the
%       fn_name (as it appears in the functions list), curve# is the curve
%       number to fit, guess is a flag, 1(yes) or 0(no) as to autoguess
%       before fitting
%       e.g. gs('fit1d','Gaussian',1,1)
%
%gs('fit2d',fn_name,#functions,guess)
%       Fits a 2D curve in the main grasp window with function given by the
%       fn_name (as it appears in the functions list), #functions is the
%       number of simultaneous functions to fit (note autoguess does not
%       work for multiple functions), guess is a flag, 1(yes) or 0(no) as
%       to autoguess before fitting
%       e.g. gs('fit2d','Gaussian - Polar Pixels',1,1)
%
%gs('fit_memory',option)
%       option = 'clear' - clears all fit memory from grasp script
%       option = 'on' - starts recording of fit parameters.  No option
%       argument defaults to turn on the recording of fit parameters
%       option = 'off' - stops recording of fit parameters
%       e.g. gs('fit_memory','clear')
%
%gs('save_fit_params',fnamepath);
%       Saves the fit parameters to the file and path described by
%       fnamepath. If fnamepath does not exist then opens a save dialog box
%       e.g. gs('save_fit_params','~/Desktop/fit_params.dat')
%
%gs('export_grasp_plot_data')
%       Saves the current data plotted in grasp_plot
%       to the directory specified as the project directory.
%       See gs('set_project_dir',datapath)
%
%gs('iq', option1, argument, option2, argument etc.)  - IvsQ average
%       Performes radial average I vs. Q
%       option = 'sectormask', argument = 0 (off), 1 (on) - Use sector mask
%       option = 'stripmask', argument = 0 (off), 1 (on) - Use strip mask
%       option = 'directtofile', argument = 0 (off), 1 (on) - Save direct to file
%       option = 'qbinunits', argument = 'pixels', 'absolute', 'resolution'
%       option = 'qbinpixels', argument = 1, 2 etc.
%       option = 'qbinabsolute', argument = 0.001 etc.
%       option = 'qbinresolution', argument = 5 etc.
%       option = 'qbinabsolutescale', argument = 'linear', 'log10'
%       option = 'singledepthtof', argument = 0 (single), 1 (depth), 2 (tof)
%       e.g. gs('iq')
%       e.g. gs('iq','sectormask',1)
%       e.g. gs('iq','qbinunits','pixels','qbinpixels',2,'directtofile',1')
%
%gs('i2t', option1, argument, option2, argument etc.) - Ivs2Theta average
%       Performes radial average I vs. 2theta
%       option = 'sectormask', argument = 0 (off), 1 (on) - Use sector mask
%       option = 'stripmask', argument = 0 (off), 1 (on) - Use strip mask
%       option = 'directtofile', argument = 0 (off), 1 (on) - Save direct to file
%       option = 'thetabinunits', argument = 'pixels', 'absolute', 'resolution'
%       option = 'thetabinpixels', argument = 1, 2 etc.
%       option = 'thetabinabsolute', argument = 0.001 etc.
%       option = 'thetabinresolution', argument = 5 etc.
%       option = 'thetabinabsolutescale', argument = 'linear', 'log10'
%       option = 'singledepthtof', argument = 0 (single), 1 (depth), 2 (tof)
%       e.g. gs('i2t')
%       e.g. qs('i2t','stripmask',1)
%       e.g. gs('i2t','thetabinunits','absolute','thetabinabsolute',0.05)
%
%gs('ixi', option1, argument, option2, argument etc.) - IvsAzimuthal angle
%       Performes azimuthal average I vs. Xi (angle around detector)
%       option = 'sectormask', argument = 0 (off), 1 (on) - Use sector mask
%       option = 'stripmask', argument = 0 (off), 1 (on) - Use strip mask
%       option = 'directtofile', argument = 0 (off), 1 (on) - Save direct to file
%       option = 'azimuth_bin_units', argument = 'absolute'
%       option = 'azimuth_bin_absolute', argument = 1, 2 etc. (degrees)
%       option = 'singledepthtof', argument = 0 (single), 1 (depth), 2 (tof)
%       e.g. gs('ixi')
%       e.g. gs('ixi','sectormask',1)
%       e.g. gs('ixi','singledepthtof',1)
%
%
%***** Display Tools ******
%
%gs('display',fw,fn,fd)
%       Toggles the grasp main display to show worksheet: fn, number: fw,
%       depth: fd.  A depth of 0 displays the sum
%
%gs('bg','on')
%       Enable/Disable background subtraction 'on', 'off'
%
%gs('bb','on')
%       Enable/Disable blocked beam subtraction 'on', 'off'
%
%gs('close',option,option2)
%       Closes the last open grasp_plot window if option =
%       option = 'all' closes all grasp_plot windows
%       option = '', option2 = <window name>
%       e.g. option2 = 'Curve Fit Control', closes the curve fit window
%       e.g. gs('close','all')
%
%gs('axis_limits',[x1,x2,y1,y2])
%       Rescales the current display to the given axis limits
%       e.g. gs('axis_limits',[40,80,20,100])
%
%gs('axis_rescale')
%       Rescales the current display to the full limits
%       e.g. gs('axis_rescale');
%




global status_flags
global grasp_handles
global grasp_env
global grasp_data
global gs_fit_fnname
global gs_fit_params
global gs_fit_pnames
global gs_fit_store_status
global gs_box_data
global gs_box_store_status
global gs_grasp_box_data



if ~exist('gs_fit_fnname'); gs_fit_fnname = []; end
if ~exist('gs_fit_params'); gs_fit_params = []; end
if ~exist('gs_fit_pnames'); gs_fit_pnames = []; end
if ~exist('gs_fit_store_status'); gs_fit_store_status = 'off'; end
if ~exist('gs_box_data'); gs_box_data = []; end
if ~exist('gs_box_store_status'); gs_box_store_status = 'off'; end

switch to_do
    
    case 'help'
        if ismac
            [status,~] = system('open grasp_script/gs_help.pdf');
        elseif isunix
            [status,~] = system('gio open grasp_script/gs_help.pdf');
        elseif ispc
            [status,~] = system('start grasp_script/gs_help.pdf');
        end
        if status ~=0
            helpdlg('Cannot find helper application to open PDF on this system:  Please open and read the ''grasp_script/gs_help.pdf''')
        end
        
        
    case 'sector'
        sector_coords = varargin{1};
        status_flags.analysis_modules.sectors.inner_radius = sector_coords(1);
        status_flags.analysis_modules.sectors.outer_radius = sector_coords(2);
        status_flags.analysis_modules.sectors.theta = sector_coords(3);
        status_flags.analysis_modules.sectors.delta_theta = sector_coords(4);
        if length(sector_coords) ==5
            status_flags.analysis_modules.sectors.mirror_sectors = sector_coords(5);
        else
            status_flags.analysis_modules.sectors.mirror_sectors = 1;
        end
        sector_window
        
        
    case 'cm'
        if nargin>1
            gs('axis_limits',varargin{1});
        end
        status_flags.beamcentre.cm_number = status_flags.selector.fn;
        main_callbacks('cm_calc');
        
        
    case 'axis_limits'
        ax_lims = varargin{1}; %[x1,x2,y1,y2]
        %Find which detector plot to rescale
        temp = get(gca,'userdata');
        if isfield(temp,'detector')
            det = temp.detector;
        else
            return
        end
        axis(grasp_handles.displayimage.(['axis' num2str(det)]),ax_lims);
        
    case 'axis_rescale'
        tool_callbacks('rescale');
        
        
    case 'iq'
        
        %Check for sector mask
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'sectormask')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.sector_mask_chk = varargin{idx+1}; end
        %Check for strip mask
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'stripmask')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.strip_mask_chk = varargin{idx+1}; end
        %Check for direct to file
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'directtofile')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.direct_to_file = varargin{idx+1}; end
        %single_depth_tof
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'singledepthtof')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.single_depth_radio = varargin{idx+1}; end
        %q_bin units
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'qbinunits')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.q_bin_units = varargin{idx+1}; end
        %q_bin pixels
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'qbinpixels')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.q_bin_pixels = varargin{idx+1}; end
        %q_bin absolute
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'qbinabsolute')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.q_bin_absolute = varargin{idx+1}; end
        %q_bin absolute_scale
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'qbinabsolutescale')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.q_bin_absolute_scale = varargin{idx+1}; end
        %q_bin resolution
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'qbinresolution')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.q_bin_resolution = varargin{idx+1}; end
        
        
        
        radial_average_window;
        radial_average_callbacks('radial_average','q');
        
    case 'i2t'
        
        %Check for sector mask
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'sectormask')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.sector_mask_chk = varargin{idx+1}; end
        %Check for strip mask
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'stripmask')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.strip_mask_chk = varargin{idx+1}; end
        %Check for direct to file
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'directtofile')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.direct_to_file = varargin{idx+1}; end
        %single_depth_tof
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'singledepthtof')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.single_depth_radio = varargin{idx+1}; end
        %theta_bin units
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'thetabinunits')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.theta_bin_units = varargin{idx+1}; end
        %theta_bin pixels
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'thetabinpixels')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.theta_bin_pixels = varargin{idx+1}; end
        %theta_bin absolute
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'thetabinabsolute')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.theta_bin_absolute = varargin{idx+1}; end
        %q_bin absolute_scale
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'thetabinabsolutescale')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.theta_bin_absolute_scale = varargin{idx+1}; end
        %q_bin resolution
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'thetabinresolution')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.theta_bin_resolution = varargin{idx+1}; end
        
        radial_average_window;
        radial_average_callbacks('radial_average','2theta');
        
        
    case 'ixi'
        
        %Check for sector mask
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'sectormask')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.sector_mask_chk = varargin{idx+1}; end
        %Check for strip mask
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'stripmask')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.strip_mask_chk = varargin{idx+1}; end
        %Check for direct to file
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'directtofile')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.direct_to_file = varargin{idx+1}; end
        %single_depth_tof
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'singledepthtof')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.single_depth_radio = varargin{idx+1}; end
        %azimuth_bin units
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'azimuthbinunits')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.azimuth_bin_units = varargin{idx+1}; end
        %theta_bin absolute
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'azimuthbinabsolute')),varargin));
        if not(isempty(idx));status_flags.analysis_modules.radial_average.azimuth_bin_absolute = varargin{idx+1}; end
        
        
        radial_average_window;
        radial_average_callbacks('radial_average','azimuthal');
        
    case 'run'
        [fname,pathname] = uigetfile('*.m');
        if fname ~= 0
            disp(['Running Grasp Script: ' pathname fname])
            button = questdlg('Are you sure you want to run the Grasp Script?', 'Run Grasp Script?','Yes', 'Cancel', 'Yes');
            if strcmp(button,'Yes')
                chuck_eval([pathname fname]);
            end
        end
        
        
    case 'set_instrument'
        inst_menu_callbacks('change', varargin{1}, varargin{2});
        
    case 'display'
        status_flags.selector.fw = varargin{1};
        status_flags.selector.fn = varargin{2};
        status_flags.beamcentre.cm_number = varargin{2}
        grasp_update
        index = data_index(status_flags.selector.fw);
        status_flags.selector.fd = varargin{3}+ grasp_data(index).sum_allow;
        grasp_update
        
        
    case 'load'
        %Change to worksheet to load into
        status_flags.selector.fw = varargin{1};
        status_flags.selector.fn = varargin{2};
        status_flags.beamcentre.cm_number = varargin{2};
        grasp_update
        %Poke the load string into the load text box
        set(grasp_handles.figure.data_load,'string',varargin{3});
        main_callbacks('data_read'); %load the data
        
    case 'sector_boxit'
        
        sector_box_window;
        status_flags.analysis_modules.sector_boxes.parameter = varargin{1}; %Sector Box parameter
        %Set sector box coordinates
        for n = 1:length(varargin)-1
            temp = varargin{n+1};
            if isnumeric(temp)
                status_flags.analysis_modules.sector_boxes.(['coords' num2str(n)])(1:length(temp)) = varargin{n+1};
            else
                break
            end
        end
        
        %Check for plot_off command
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'plot_off')),varargin));
        if not(isempty(idx))
            plot_off = 'plot_off';
        else
            plot_off = [];
        end
        %Sector Box it!
        sector_box_callbacks('box_it',plot_off);
        
        %Check if to store box data
        if strcmpi(gs_box_store_status,'on')
            gs_box_data = [gs_box_data; gs_grasp_box_data];
        end
        
    case 'boxit'
        box_window;%Open boxwindow
        status_flags.analysis_modules.boxes.parameter = varargin{1}; %Box parameter
        %Set box coordinates
        for n = 1:length(varargin)-1
            temp = varargin{n+1};
            if isnumeric(temp)
                if length(temp) ==4; temp(5) = 1; end
                status_flags.analysis_modules.boxes.(['coords' num2str(n)]) = temp;
            else
                break
            end
        end
        
        %Check for plot_off command
        idx=find(cellfun(@(varargin) any(strcmp(varargin,'plot_off')),varargin));
        if not(isempty(idx))
            plot_off = 'plot_off';
        else
            plot_off = [];
        end
        
        %Box it!
        box_callbacks('box_it',plot_off);
        
        %Check if to store box data
        if strcmpi(gs_box_store_status,'on')
            gs_box_data = [gs_box_data; gs_grasp_box_data];
        end
        
        
    case 'fit1d'
        %fit it - gaussian
        gs_fit_fnname = varargin{1};
        fit1d(varargin{1},varargin{2},varargin{3});
        
        %Check if to store fit parameters
        if strcmpi(gs_fit_store_status,'on')
            gs_fit_pnames = status_flags.fitter.function_info_1d.variable_names;
            values = status_flags.fitter.function_info_1d.values;
            err_values = status_flags.fitter.function_info_1d.err_values;
            
            for n = 1:length(values)
                temp_params(1+(n-1)*2:2+(n-1)*2) = [values(n),err_values(n)];
            end
            gs_fit_params = [gs_fit_params;temp_params];
        end
        
        
    case 'fit2d'
        % function fit2d(fn,number_fns,guess_flag)
        gs_fit_fnname = varargin{1};
        fit2d(varargin{1},varargin{2},varargin{3});
        
        %Check if to store fit parameters
        if strcmpi(gs_fit_store_status,'on')
            gs_fit_pnames = status_flags.fitter.function_info_2d.variable_names;
            values = status_flags.fitter.function_info_2d.values;
            err_values = status_flags.fitter.function_info_2d.err_values;
            
            for n = 1:length(values)
                temp_params(1+(n-1)*2:2+(n-1)*2) = [values(n),err_values(n)];
            end
            gs_fit_params = [gs_fit_params;temp_params];
        end
        
        
        
        
    case 'close'
        if nargin==1
            i = findobj('tag','grasp_plot');
            close(i(1));
        else
            if length(varargin) ==2
                i = findobj('name',varargin{2});
                if ~isempty(i); close(i); end
                return
            end
            
            if length(varargin) ==1
                i = findobj('tag','grasp_plot');
                if ~isempty(varargin)
                    if strcmpi(varargin{1},'all')
                        close(i);
                    else
                        close(i(1));
                    end
                else
                    close(i(1));
                end
            end
        end
        
        
    case 'fit_memory'
        if isempty(varargin)
            gs_fit_store_status = 'on';
        else
            if strcmpi(varargin{1},'clear')
                gs_fit_params = [];
                gs_fit_pnames = [];
                gs_fit_fnname = [];
            elseif strcmpi(varargin{1},'on')
                gs_fit_store_status = 'on';
            elseif strcmpi(varargin{1},'off')
                gs_fit_store_status = 'off';
            end
        end
        
    case 'box_memory'
        if isempty(varargin)
            gs_box_store_status = 'on';
        else
            if strcmpi(varargin{1},'clear')
                gs_box_data = [];
            elseif strcmpi(varargin{1},'on')
                gs_box_store_status = 'on';
            elseif strcmpi(varargin{1},'off')
                gs_box_store_status = 'off';
            end
        end
        
    case 'export_grasp_plot_data'
        grasp_plot_menu_callbacks('export_ascii')
        
    case 'export_box_data'
        fname = varargin{1};
        dlmwrite(fname,gs_box_data,'delimiter','\t')
        
        
    case 'save_fit_params'
        if ~isempty(gs_fit_params)
            if isempty(varargin)
                [fname, directory] = uiputfile(['fit_data.dat'],'Export Fit Parameters');
                full_path = fullfile(directory,fname);
            else
                full_path = varargin{1};
            end
            
            disp(['Exporting Grasp_Script Curve Fit Parameters: '  full_path]);
            fid=fopen(full_path,'wt');
            %Write Fit fn name
            fprintf(fid,'%s \n',['Grasp_Script Fit Function: ' gs_fit_fnname]);
            %Write Parameter names
            header_string =[];
            for n = 1:length(gs_fit_pnames)
                header_string = [header_string  gs_fit_pnames{n} char(9) 'err_' gs_fit_pnames{n} char(9)];
            end
            fprintf(fid,'%s \n',header_string);
            fprintf(fid,'%s \n','');
            fprintf(fid,'%s \n','');
            if ispc; newline_type = 'pc'; else newline_type = 'unix'; end
            dlmwrite(full_path,gs_fit_params,'delimiter','\t','newline',newline_type,'-append','precision',5);
            fclose(fid);
        end
        
        
    case 'set_data_dir'
        grasp_env.path.data_dir = varargin{1};
        
    case 'set_project_dir'
        grasp_env.path.project_dir = varargin{1};
        
    case 'bg'
        if strcmpi(varargin{1},'on')
            status_flags.selector.b_check = 1;
        else
            status_flags.selector.b_check = 0;
        end
        grasp_update
        
        
    case 'bb'
        if strcmpi(varargin{1},'on')
            status_flags.selector.c_check = 1;
        else
            status_flags.selector.c_check = 0;
        end
        grasp_update
        
        
        
end
