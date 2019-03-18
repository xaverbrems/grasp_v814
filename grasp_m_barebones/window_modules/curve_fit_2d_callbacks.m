function output = curve_fit_2d_callbacks(to_do,option, multibeam)

global displayimage
global status_flags
global inst_params
global fit_parameters
global grasp_handles
global grasp_env
global fit_refresh_flag; fit_refresh_flag = 1;  %Allows parameters within the fits to be recalled without recalculating
%global fitdata
global fit_return_data; fit_return_data = []; % Aditional data that may be returned by the fit but can't be passed though mf_lsqr
global grasp_data

if nargin < 3; multibeam = []; end
if nargin < 2; option = []; end

output = [];

grasp_main_figure = grasp_handles.figure.grasp_main;
active_axis = status_flags.display.active_axis;
detno=num2str(active_axis);


%some editable parameters
guess_color = 'red';
fit_color = 'white';


switch(to_do)
    
    case 'resolution_check'
        status_flags.fitter.include_res_check_2d  = get(gcbo,'value');
        curve_fit_2d_callbacks('draw_fn',guess_color); %update the function
        
    case 'multi_beam_check'
        status_flags.analysis_modules.multi_beam.fit2d_checkbox = get(gcbo,'value');
        if status_flags.analysis_modules.multi_beam.fit2d_checkbox == 1;
            multi_beam_define_window; %Open multibeam window
        end
        %curve_fit_2d_callbacks('draw_fn',guess_color); %update the function
        
        
    case 'auto_guess'
        
        if strcmp(option,'point_click')
            code = status_flags.fitter.function_info_2d.point_click_code;
        else %auto guess
            code = status_flags.fitter.function_info_2d.auto_guess_code;
            if status_flags.fitter.number2d >1;
                disp(' ');
                disp('Sorry: Cannot Auto-Guess for multiple curves');
                disp('Please enter start parameters manually or use ''Point & Click''');
                disp(' ');
                return
            end
        end
        
        if not(isempty(code))
            
           try
                
                figure(grasp_main_figure); %Make sure the current grasp_plot is the active figure so mouse input works on that figure
                fitdata = curve_fit_2d_callbacks('get_fit_data');
                xy = [fitdata.xdat, fitdata.ydat]; z = fitdata.zdat;
                
                final_guess = [];
                for n_fn = 1:status_flags.fitter.number2d
                    for line = 1:length(code)
                        code{line}
                        eval([code{line} ';'])
                    end
                    if exist('guess_values')
                        final_guess = [final_guess,guess_values];
                    end
                end
                status_flags.fitter.function_info_2d.values = final_guess;
                status_flags.fitter.function_info_2d.err_values = zeros(size(final_guess));
                
                curve_fit_2d_callbacks('update_curve_fit_window');
                curve_fit_2d_callbacks('draw_fn',guess_color);
                
            catch
                disp(' ')
                disp(['There was an error in evaluating the AutoGuessCode in your Fit Function']);
                disp('Reform your Matlab code and Try again.');
                disp('Make sure that the variable ''guess_values = [    ]'' is defined as a final result of the auto guess procedure');
                disp(' ')
                return
            end
            
        else
            disp(' ');
            disp('Sorry:  No Auto-Guess or Point & Click code is availaible for this function');
            disp('Please enter start parameters manually');
            disp(' ');
        end
        
    case 'copy_to_clipboard'
        
        str = [];
        for n = 1:length(status_flags.fitter.function_info_2d.values)
            str = [str status_flags.fitter.function_info_2d.long_names{n} char(9) num2str(status_flags.fitter.function_info_2d.values(n),'%0.5g') char(9) num2str(status_flags.fitter.function_info_2d.err_values(n),'%0.5g') char(13) char(10)];
            str
            
            
        end
        clipboard('copy',str);
        
        
    case 'build_curve_number'
        
        n_str = [];
        for n =1:length(curve_handles);
            if not(isempty(curve_handles{n}));
                plot_info = get(curve_handles{n}(1),'userdata');
                curve_number = plot_info.curve_number;
                n_str = [n_str, {num2str(curve_number)}];
            end
        end
        
        if isfield(grasp_handles.window_modules.curve_fit2d,'curve_number')
            if ishandle(grasp_handles.window_modules.curve_fit2d.curve_number);
                set(grasp_handles.window_modules.curve_fit2d.curve_number,'string',n_str);
                value = get(grasp_handles.window_modules.curve_fit2d.curve_number,'value');
                if value > length(n_str);
                    set(grasp_handles.window_modules.curve_fit2d.curve_number,'value',length(n_str));
                end
                
            end
        end
        
        
    case 'delete_curves'
        %Delete the old contours
        if isfield(grasp_handles.fitter,'fit2d_contours')
            if ishandle(grasp_handles.fitter.fit2d_contours);
                delete(grasp_handles.fitter.fit2d_contours);
                grasp_handles.fitter.fit2d_contours = [];
            end
        end
        
        %Delete old fit plot plot if exists
        if isfield(grasp_handles.fitter,'fit2d_fit');
            if ishandle(grasp_handles.fitter.fit2d_fit);
                delete(grasp_handles.fitter.fit2d_fit);
                grasp_handles.fitter.fit2d_fit = [];
            end
        end
        
        %Delete old fit error plot if exists
        if isfield(grasp_handles.fitter,'fit2d_fit_error')
            if ishandle(grasp_handles.fitter.fit2d_fit_error)
                delete(grasp_handles.fitter.fit2d_fit_error);
                grasp_handles.fitter.fit2d_fit_error = [];
            end
        end
        
        
        
    case 'build_fn_list'
        
        fn_name_list = [];
        fid=fopen(['fit_functions' filesep 'functions2d.fn']);
        if not(fid==-1)
            disp('Loading 2D Fitting List');
            while feof(fid) ==0
                line = fgetl(fid);
                if strcmpi(line,'<FnName>')
                    fn_name = fgetl(fid);
                    fn_name_list = [fn_name_list, {fn_name}];
                end
                if strcmpi(line,'<Divider>')
                    fn_name = fgetl(fid);
                    fn_name_list = [fn_name_list, {fn_name}];
                end
            end
            fclose(fid);
        else
            disp('No 2D Fitting Functions File Found');
        end
        status_flags.fitter.fn_list2d = fn_name_list; %Keep a store of the fitting functions in the status_flags
        set(grasp_handles.window_modules.curve_fit2d.fn_selector,'string',fn_name_list,'value',status_flags.fitter.fn2d)
        
        
        
    case 'retrieve_fn'
        
        fn.name = status_flags.fitter.fn_list2d{status_flags.fitter.fn2d};
        fn.variable_names = [];
        fn.long_names = [];
        fn.math_code = [];
        fn.auto_guess_code = [];
        fn.point_click_code = [];
        values = [];
        
        %Open the function file and find the fit parameters and function
        loop_exit = 0;
        fid=fopen(['fit_functions' filesep 'functions2d.fn']);
        if not(fid==-1)
            disp(['Loading 2D Fit Function: ' fn.name]);
            if not(isempty(strfind(fn.name,'----'))); %Check for Divider line
                status_flags.fitter.function_info_2d = fn; %Put the blank functions parameters in to status flags
                curve_fit_2d_callbacks('update_curve_fit_window'); %update the window to be blank
                return;
            end
            while feof(fid) ==0 || loop_exit ==0;
                line = fgetl(fid);
                %Search for FnName declarations
                if strcmpi(line,'<Function>')
                    while not(strcmpi(line,'</Function>')) || loop_exit ==0;
                        line = fgetl(fid);
                        if strcmpi(line,'<FnName>')
                            line = fgetl(fid);
                            
                            %Search for Specific Fn
                            if strcmpi(line,fn.name)
                                
                                %Search for Parameters
                                while not(strcmpi(line,'</Function>'))
                                    line = fgetl(fid);
                                    
                                    %Read Param variable names
                                    if strcmpi(line,'<Params>')
                                        while not(strcmpi(line,'</Params>'))
                                            line = fgetl(fid);
                                            if not(strcmpi(line,'</Params>')) && not(strcmpi(line(1),'%'))
                                                if strcmpi(line(1),'#');  %Code to execute
                                                    ex_line = line(2:length(line));
                                                    eval(ex_line);
                                                else %Simple variable name
                                                    fn.variable_names = [fn.variable_names, {line}];
                                                end
                                            end
                                        end
                                    end
                                    
                                    %Read Param Start Values
                                    if strcmpi(line,'<StartValues>')
                                        while not(strcmpi(line,'</StartValues>'))
                                            line = fgetl(fid);
                                            if not(strcmpi(line,'</StartValues>')) && not(strcmpi(line(1),'%'))
                                                if strcmpi(line(1),'#');  %Code to execute
                                                    ex_line = line(2:length(line));
                                                    eval(ex_line);
                                                else
                                                    values = [values, {line}];
                                                end
                                            end
                                            %Convert cell of values to numbers
                                            for n =1:length(values)
                                                fn.values(1,n) = str2num(values{n});
                                            end
                                        end
                                        
                                        
                                    end
                                    
                                    %Read Long Names
                                    %By default pnames = variable names unless replaced below
                                    %fn.long_names = fn.variable_names;
                                    if strcmpi(line,'<ParamNames>')
                                        while not(strcmpi(line,'</ParamNames>'))
                                            line = fgetl(fid);
                                            if not(strcmpi(line,'</ParamNames>')) && not(strcmpi(line(1),'%'))
                                                fn.long_names = [fn.long_names, {line}];
                                            end
                                        end
                                    end
                                    
                                    %Read the math function string
                                    if strcmpi(line,'<FnCode>')
                                        while not(strcmpi(line,'</FnCode>'))
                                            line = fgetl(fid);
                                            if not(strcmpi(line,'</FnCode>')) && not(strcmpi(line(1),'%'))
                                                fn.math_code = [fn.math_code, {line}];
                                            end
                                        end
                                    end
                                    
                                    %Read the AutoGuess Code
                                    if strcmpi(line,'<AutoGuessCode>')
                                        while not(strcmpi(line,'</AutoGuessCode>'))
                                            line = fgetl(fid);
                                            if not(strcmpi(line,'</AutoGuessCode>')) && not(strcmpi(line(1),'%'))
                                                fn.auto_guess_code = [fn.auto_guess_code, {line}];
                                            end
                                        end
                                    end
                                    
                                    %Read the Point Click parameter guide
                                    if strcmpi(line,'<PointClickCode>')
                                        while not(strcmpi(line,'</PointClickCode>'))
                                            line = fgetl(fid);
                                            if not(strcmpi(line,'</PointClickCode>')) && not(strcmpi(line(1),'%'))
                                                fn.point_click_code = [fn.point_click_code, {line}];
                                            end
                                        end
                                    end
                                end
                                loop_exit =1;
                            end
                        end
                    end
                end
            end
            fclose(fid);
        else
            disp('No 2D Fitting Functions File Found');
        end
        fn.fix = zeros(1,length(fn.variable_names)); %Fix parameter
        fn.group = zeros(1,length(fn.variable_names)); %Group parameter
        fn.err_values = zeros(1,length(fn.values)); %Err_Values
        fn.no_parameters = length(fn.values); %Intrinsic number of parameters BEFORE multiplexing
        %Put the fn into the status flags
        status_flags.fitter.function_info_2d = fn; %some of these get added to in the multiplex process below
        
        %***** Function Multiplex *****
        %Multiply up the function i.e. n of the same functions, with
        %different or grouped parameters added together
        for n = 2:status_flags.fitter.number2d
            status_flags.fitter.function_info_2d.fix = [status_flags.fitter.function_info_2d.fix, fn.fix];
            status_flags.fitter.function_info_2d.group = [status_flags.fitter.function_info_2d.group, fn.group];
            status_flags.fitter.function_info_2d.values = [status_flags.fitter.function_info_2d.values, fn.values];
            status_flags.fitter.function_info_2d.err_values = [status_flags.fitter.function_info_2d.err_values, fn.err_values];
            status_flags.fitter.function_info_2d.variable_names = [status_flags.fitter.function_info_2d.variable_names, fn.variable_names];
            status_flags.fitter.function_info_2d.long_names = [status_flags.fitter.function_info_2d.long_names, fn.long_names];
            %status_flags.fitter.function_info_2d.point_click_code = [status_flags.fitter.function_info_2d.point_click_code, fn.point_click_code];
        end
        
        
    case 'update_curve_fit_window'
        
        %Delete old displayed parameters
        if isfield(grasp_handles,'fitter')
            if isfield(grasp_handles.fitter,'fit2d_handles')
                for n = 1:length(grasp_handles.fitter.fit2d_handles)
                    if ishandle(grasp_handles.fitter.fit2d_handles(n)); delete(grasp_handles.fitter.fit2d_handles(n)); end
                end
            end
        end
        %Draw parameter entry boxes and check-boxes - dependent on the number and parameter names returned by the function
        grasp_handles.fitter.fit2d_handles = [];
        handles_store = [];
        for n = 1:length(status_flags.fitter.function_info_2d.long_names)
            %Parameter Names
            handle = uicontrol(grasp_handles.window_modules.curve_fit2d.window, 'units','normalized','Position',[0.02,(0.88-(n*0.025)),0.3, 0.02],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'HorizontalAlignment','right','Style','text','String',[status_flags.fitter.function_info_2d.long_names{n} ': ' status_flags.fitter.function_info_2d.variable_names{n} ' : ' ],'BackgroundColor', grasp_env.background_color, 'ForegroundColor', [1 1 1]);
            handles_store = [handles_store, handle];
            %Fix Check
            handle = uicontrol(grasp_handles.window_modules.curve_fit2d.window, 'units','normalized','Position',[0.37,(0.88-(n*0.025)),0.028,0.02],'ToolTip',['Fix ' status_flags.fitter.function_info_2d.long_names{n}],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','HorizontalAlignment','left','backgroundcolor',grasp_env.background_color,'value',status_flags.fitter.function_info_2d.fix(n),'userdata',n,'callback','curve_fit_2d_callbacks(''fn_value_fix_check'');');
            handles_store = [handles_store, handle];
            
            if status_flags.fitter.function_info_2d.group(n) == 1 && n > status_flags.fitter.function_info_2d.no_parameters;
                visible = 'off';
            else
                visible = 'on';
            end
            %Parameter Value
            handle = uicontrol(grasp_handles.window_modules.curve_fit2d.window, 'visible',visible, 'units','normalized','Position',[0.45,(0.88-(n*0.025)),0.15,0.02],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','edit','HorizontalAlignment','left','string',num2str(status_flags.fitter.function_info_2d.values(n)),'userdata',n,'callback','curve_fit_2d_callbacks(''fn_value_enter'');');
            handles_store = [handles_store, handle];
            %Parameter Value Error
            handle = uicontrol(grasp_handles.window_modules.curve_fit2d.window, 'visible',visible, 'units','normalized','Position',[0.62,(0.88-(n*0.025)),0.15,0.02],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','text','HorizontalAlignment','left','string',num2str(status_flags.fitter.function_info_2d.err_values(n)));
            handles_store = [handles_store, handle];
            if n <= status_flags.fitter.function_info_2d.no_parameters;
                %Group Check
                handle = uicontrol(grasp_handles.window_modules.curve_fit2d.window, 'units','normalized','Position',[0.81,(0.88-(n*0.025)),0.028,0.02],'ToolTip',['Group ' status_flags.fitter.function_info_2d.long_names{n} '`s'],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','checkbox','HorizontalAlignment','left','backgroundcolor',grasp_env.background_color,'value',status_flags.fitter.function_info_2d.group(n),'userdata',n,'callback','curve_fit_2d_callbacks(''fn_group_check'');');
                handles_store = [handles_store, handle];
            end
        end
        handle = uicontrol(grasp_handles.window_modules.curve_fit2d.window, 'units','normalized','Position',[0.02,0.06,0.96,0.11],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize*0.9,'Style','text','HorizontalAlignment','left','backgroundcolor',grasp_env.background_color,'foregroundcolor','white','string',status_flags.fitter.function_info_2d.math_code);
        handles_store = [handles_store, handle];
        
        grasp_handles.fitter.fit2d_handles = handles_store;
        
        
        
    case 'draw_fn'
        
        %Get the xdata over the zoomed range
        fitdata = curve_fit_2d_callbacks('get_fit_data','unmasked'); %fitdata.curve_number contains the curve number
        xy = [fitdata.xdat, fitdata.ydat]; %Doesn't work when pixels were masked
                
        %Generate the function
        fit_refresh_flag = 1; %Recalculate any parameters required for the fit on first pass though the function
        z = pseudo_fn2d(xy,status_flags.fitter.function_info_2d.values,fitdata);
        %Reshape to 2D
        z = reshape(z,fitdata.zoom_size);
                
        %Now plot the fn contours
        figure(grasp_main_figure);
        
        %Find current contour levels of main display
        c_levels = status_flags.contour.current_levels_list;
        if isempty(c_levels); c_levels = 8; end %sometimes current_levels_list is empty
        
        
        %Generate the full detector worth of data to display
        fit_result = zeros(inst_params.(['detector' detno]).pixels(2),inst_params.(['detector' detno]).pixels(1)); %Empty full det image
        fit_result(fitdata.lims(3):fitdata.lims(4),fitdata.lims(1):fitdata.lims(2)) = z;
        
        
        %Poke the 2D fit result data into 2D Fit result & residual worksheet
        data_params = displayimage.(['params' detno]);
        index = data_index(20); %2D Fit result

        grasp_data(index).data1{status_flags.selector.fn}(:,:) = fit_result; 
        grasp_data(index).params1{status_flags.selector.fn}{1} = data_params; 
        
        residual_data = (displayimage.(['data' detno])-fit_result)./displayimage.(['error' detno]);
        residual_size= size(residual_data);
        residual_data = residual_data(fitdata.lims(3):fitdata.lims(4),fitdata.lims(1):fitdata.lims(2));
        
        temp = isnan(residual_data);
        residual_data(temp) = 0;
       
        
        residual_data = residual_data.*fitdata.mask_mat;
        index = data_index(21); %2D Fit result
  
        
        grasp_data(index).data1{status_flags.selector.fn}(:,:) = zeros(residual_size); 
        grasp_data(index).data1{status_flags.selector.fn}(fitdata.lims(3):fitdata.lims(4),fitdata.lims(1):fitdata.lims(2)) = residual_data; 
               
        grasp_data(index).params1{status_flags.selector.fn}{1} = data_params; 
        
        %Get Xdata and Ydata for the plot - important when using q-axes
        xdata = get(grasp_handles.displayimage.(['image' detno]),'xdata'); ydata = get(grasp_handles.displayimage.(['image' detno]),'ydata');
        
        %Delete the old contours
        if isfield(grasp_handles.fitter,'fit2d_contours')
            if ishandle(grasp_handles.fitter.fit2d_contours)
                delete(grasp_handles.fitter.fit2d_contours);
                grasp_handles.fitter.fit2d_contours = [];
            end
        end
        
        
        %Plot the contours
        figure(grasp_main_figure);
        current_axis_handle = grasp_handles.displayimage.(['axis' detno]);
        axes(current_axis_handle);
        hold on
        if status_flags.display.log == 1 && length(c_levels)>1; c_levels = 10.^c_levels; end %if logged, put the contours back to useful units.        
        
        [c,grasp_handles.fitter.fit2d_contours]=contour3(xdata,ydata,fit_result,c_levels,'-ow');
        set(grasp_handles.fitter.fit2d_contours,'linewidth',status_flags.display.linewidth,'color',option);
        
        
        
        
        %***** Add Fit Peak Window - only after real fit *****
        figure(grasp_handles.window_modules.curve_fit2d.window)
        fit_map_data = (fit_result(fitdata.lims(3):fitdata.lims(4),fitdata.lims(1):fitdata.lims(2)));
        
        %Delete old plot if exists
        if isfield(grasp_handles.fitter,'fit2d_fit')
            if ishandle(grasp_handles.fitter.fit2d_fit)
                delete(grasp_handles.fitter.fit2d_fit);
                grasp_handles.fitter.fit2d_fit = [];
            end
        end
        
        %use current mask
        mask = displayimage.(['mask' detno]);
        mask = mask(fitdata.lims(3):fitdata.lims(4),fitdata.lims(1):fitdata.lims(2));%Crop to current zoom
        
        grasp_handles.fitter.fit2d_fit = axes; %Create new axes
        h = pcolor(real(log10(fit_map_data.*mask))); shading flat
        set(get(h,'parent'),'position',[0.05 0.18 0.33 0.14],'yticklabel','','xticklabel','');axis square;
        %Placement of the axes + colour bar seem to be different between the
        %two versions
        colorbar('position',[0.38,0.18,0.025,0.14],'fontsize',grasp_env.fontsize*0.9,'fontname',grasp_env.font);
        
        
        %***** Add error plot window *****
        
        %Delete old plot if exists
        if isfield(grasp_handles.fitter,'fit2d_fit_error')
            if ishandle(grasp_handles.fitter.fit2d_fit_error)
                delete(grasp_handles.fitter.fit2d_fit_error);
                grasp_handles.fitter.fit2d_fit_error = [];
            end
        end
        
        warning off
        error_map_data = (displayimage.(['data' detno])(fitdata.lims(3):fitdata.lims(4),fitdata.lims(1):fitdata.lims(2))-fit_result(fitdata.lims(3):fitdata.lims(4),fitdata.lims(1):fitdata.lims(2)))./displayimage.(['error' detno])(fitdata.lims(3):fitdata.lims(4),fitdata.lims(1):fitdata.lims(2));
        warning on
        grasp_handles.fitter.fit2d_fit_error = axes; %Create new axes
        h = pcolor(error_map_data.*mask); shading flat
        set(get(h,'parent'),'position',[0.52 0.18 0.33 0.14],'yticklabel','','xticklabel','');axis square;
        colorbar('position',[0.85,0.18,0.025,0.14],'fontsize',grasp_env.fontsize*0.9,'fontname',grasp_env.font);
        
        grasp_update
        
    case 'toggle_fn'
        status_flags.fitter.fn2d = get(gcbo,'value');
        curve_fit_2d_callbacks('delete_curves');
        curve_fit_2d_callbacks('retrieve_fn');
        curve_fit_2d_callbacks('update_curve_fit_window');
        
    case 'fn_value_enter'
        param_number = get(gcbo,'userdata');
        value_str = get(gcbo,'string');
        value = str2num(value_str);
        if not(isempty(value))
            status_flags.fitter.function_info_2d.values(1,param_number) = value;
        end
        curve_fit_2d_callbacks('draw_fn',guess_color); %update the function
        
    case 'fn_value_fix_check'
        param_number = get(gcbo,'userdata');
        status_flags.fitter.function_info_2d.fix(param_number) = get(gcbo,'value');
        
    case 'fn_group_check'
        param_number = get(gcbo,'userdata');
        status_flags.fitter.function_info_2d.group(param_number) = get(gcbo,'value');
        while param_number <= length(status_flags.fitter.function_info_2d.group);
            status_flags.fitter.function_info_2d.group(param_number) = get(gcbo,'value');
            %also set the fix check for the grouped copies
            if param_number > status_flags.fitter.function_info_2d.no_parameters;
                status_flags.fitter.function_info_2d.fix(param_number) = 1;
            end
            param_number = param_number + status_flags.fitter.function_info_2d.no_parameters;
        end
        curve_fit_2d_callbacks('update_curve_fit_window');
        
    case 'number_of_fn'
        status_flags.fitter.number2d = get(gcbo,'value');
        curve_fit_2d_callbacks('retrieve_fn');
        curve_fit_2d_callbacks('update_curve_fit_window');
        
    case 'get_fit_data'
        
        %Incoming option to specify whether to crop to mask or not
        %e.g.   fitting uses mask-cropped data
        %       drawing the function after does not
        
        %Chopped data to fit over the zoomed area of the 2d display
        axis_lims = current_axis_limits;
        cm = current_beam_centre;
        output.cm = cm.(['det' detno]);
        lims = axis_lims.(['det' detno]).pixels;
        output.lims = lims;
        
        output.xmat = displayimage.(['qmatrix' detno])(lims(3):lims(4),lims(1):lims(2),1);
        output.ymat = displayimage.(['qmatrix' detno])(lims(3):lims(4),lims(1):lims(2),2);
        output.zmat = displayimage.(['data' detno])(lims(3):lims(4),lims(1):lims(2));
        output.emat = displayimage.(['error' detno])(lims(3):lims(4),lims(1):lims(2));
        
        %Check for any 0 errors & set to 1 * scale_factor - where scale_factor is all the normalizations that have happend to the data
        temp = find(output.emat == 0);
        if not(isempty(temp))
            %output.emat(temp2) = mean(output.emat(temp)); %The mean of all non-zero errors in the data
            output.emat(temp) = displayimage.scale_factor;
        end
        
        output.mask_mat = displayimage.(['mask' detno])(lims(3):lims(4),lims(1):lims(2));
        output.qxmat = displayimage.(['qmatrix' detno])(lims(3):lims(4),lims(1):lims(2),3);
        output.qymat = displayimage.(['qmatrix' detno])(lims(3):lims(4),lims(1):lims(2),4);
        output.modqmat = displayimage.(['qmatrix' detno])(lims(3):lims(4),lims(1):lims(2),5);
        output.delta_q_mat = displayimage.(['qmatrix' detno])(lims(3):lims(4),lims(1):lims(2),13);
        output.qanglemat = displayimage.(['qmatrix' detno])(lims(3):lims(4),lims(1):lims(2),6);
        output.qx_per_pixelx_mat = displayimage.(['qmatrix' detno])(lims(3):lims(4),lims(1):lims(2),20);
        output.qy_per_pixely_mat = displayimage.(['qmatrix' detno])(lims(3):lims(4),lims(1):lims(2),21);
        
        output.zoom_size = size(output.xmat);
        
        if strcmp(option,'masked')
            %Find any pixels that are masked
            temp = find(output.mask_mat==1);
            %Complie xyz data only using the un-masked points
            output.xdat = reshape(output.xmat(temp),[numel(output.xmat(temp)),1]);
            output.ydat = reshape(output.ymat(temp),[numel(output.ymat(temp)),1]);
            output.zdat = reshape(output.zmat(temp),[numel(output.zmat(temp)),1]);
            output.edat = reshape(output.emat(temp),[numel(output.emat(temp)),1]);
            output.qxdat = reshape(output.qxmat(temp),[numel(output.qxmat(temp)),1]);
            output.qydat = reshape(output.qymat(temp),[numel(output.qymat(temp)),1]);
            output.modqdat = reshape(output.modqmat(temp),[numel(output.modqmat(temp)),1]);
            output.delta_q_dat = reshape(output.delta_q_mat(temp),[numel(output.delta_q_mat(temp)),1]);
            output.qangledat = reshape(output.qanglemat(temp),[numel(output.qanglemat(temp)),1]);
            output.qx_per_pixelx_dat = reshape(output.qx_per_pixelx_mat(temp),[numel(output.qx_per_pixelx_mat(temp)),1]);
            output.qy_per_pixely_dat = reshape(output.qy_per_pixely_mat(temp),[numel(output.qy_per_pixely_mat(temp)),1]);
            
        else %i.e. unmasked
            %Complie xyz data only using the un-masked points
            output.xdat = reshape(output.xmat,[numel(output.xmat),1]);
            output.ydat = reshape(output.ymat,[numel(output.ymat),1]);
            output.zdat = reshape(output.zmat,[numel(output.zmat),1]);
            output.edat = reshape(output.emat,[numel(output.emat),1]);
            output.qxdat = reshape(output.qxmat,[numel(output.qxmat),1]);
            output.qydat = reshape(output.qymat,[numel(output.qymat),1]);
            output.modqdat = reshape(output.modqmat,[numel(output.modqmat),1]);
            output.delta_q_dat = reshape(output.delta_q_mat,[numel(output.delta_q_mat),1]);
            output.qangledat = reshape(output.qanglemat,[numel(output.qanglemat),1]);
            output.qx_per_pixelx_dat = reshape(output.qx_per_pixelx_mat,[numel(output.qx_per_pixelx_mat),1]);
            output.qy_per_pixely_dat = reshape(output.qy_per_pixely_mat,[numel(output.qy_per_pixely_mat),1]);
        end
        
        %Store mod_q max and min - some functions find this useful
        output.modq_minmax = [min(output.modqdat), max(output.modqdat)];
        output.original_data_size = length(output.xdat);
        
        
        %***** Prepare Data for 2D resolution smearing *****
        %This bit builds q-weight kernels in the form of extra modq-weight points associated with every real data point
        %The fit functions then just thinks there is more data to calculate a 'z' for than there is.  This then gets weight averaged to make
        %the final z corresponding to the real xy point at the end of pseudo_fn2d
        output.finesse = 1; %Default in case of no smearing
        new_modqdat = [];
        new_qxdat = []; new_qydat = []; new_xdat = []; new_ydat = [];
        if status_flags.fitter.include_res_check_2d == 1  %Convolute instrument resolution
            new_kernel_weight = [];
            %Multiply up the raw-points to become a sum (average) of points over a smearing kernel
            output.finesse = status_flags.resolution_control.xgrid_2d * status_flags.resolution_control.ygrid_2d;
            for n = 1:length(output.modqdat)
                sigma_q = output.delta_q_dat(n)/(2*sqrt(2*log(2)));
                [kernel] = gauss_qkernel(output.qxdat(n),output.qydat(n),sigma_q,sigma_q,status_flags.resolution_control.sigma_extent_2d,status_flags.resolution_control.xgrid_2d,status_flags.resolution_control.ygrid_2d,output.xdat(n),output.ydat(n),output.qx_per_pixelx_dat(n),output.qy_per_pixely_dat(n));
                new_xdat = [new_xdat; kernel.x_pixel(:)];
                new_ydat = [new_ydat; kernel.y_pixel(:)];
                new_qxdat = [new_qxdat; kernel.qx(:)];
                new_qydat = [new_qydat; kernel.qy(:)];
                new_modqdat = [new_modqdat; kernel.modq(:)];
                new_kernel_weight = [new_kernel_weight; kernel.weight(:)];
            end
            output.qxdat = new_qxdat;
            output.qydat = new_qydat;
            output.modqdat = new_modqdat;
            output.new_kernel_weight = new_kernel_weight;
            output.xdat_smear_padded = new_xdat;
            output.ydat_smear_padded = new_ydat;
        else
            output.xdat_smear_padded = output.xdat; %Defaults - maybe overwritten above
            output.ydat_smear_padded = output.ydat;
        end
        
        
        
%         %***** MULTIBEAM Modifications *****
%         %Generate all the q-matricies for all the beams
%         if status_flags.analysis_modules.multi_beam.fit2d_checkbox ==1; %multibeam ON
%             disp('***** MultiBeam Analysis is ON *****');
%             disp(['***** Generating Multi (' num2str(status_flags.analysis_modules.multi_beam.number_beams) ') Q-Matricies *****']);
%             %Generate a load more q-matricies for each beam
%             active_axis = 1; %Multibeam only for main detector
%             detno=num2str(active_axis);
%             overall_qminmax = [inf,0];
%             
%             for beam = 1:status_flags.analysis_modules.multi_beam.number_beams
%                 beamno=num2str(beam);
%                 cm = [status_flags.analysis_modules.multi_beam.box_beam_coordinates.(['beam' beamno]).cx, status_flags.analysis_modules.multi_beam.box_beam_coordinates.(['beam' beamno]).cy];
%                 temp_qmatrix = build_q_matrix(displayimage,cm);
%                 
%                 output.(['beam' beamno]).cm = cm;
%                 output.(['beam' beamno]).qxmat = temp_qmatrix.(['qmatrix' detno])(lims(3):lims(4),lims(1):lims(2),3);
%                 output.(['beam' beamno]).qymat = temp_qmatrix.(['qmatrix' detno])(lims(3):lims(4),lims(1):lims(2),4);
%                 output.(['beam' beamno]).modqmat = temp_qmatrix.(['qmatrix' detno])(lims(3):lims(4),lims(1):lims(2),5);
%                 output.(['beam' beamno]).delta_q_mat = temp_qmatrix.(['qmatrix' detno])(lims(3):lims(4),lims(1):lims(2),13);
%                 output.(['beam' beamno]).qanglemat = temp_qmatrix.(['qmatrix' detno])(lims(3):lims(4),lims(1):lims(2),6);
%                 output.(['beam' beamno]).qx_per_pixelx_mat = temp_qmatrix.(['qmatrix' detno])(lims(3):lims(4),lims(1):lims(2),20);
%                 output.(['beam' beamno]).qy_per_pixely_mat = temp_qmatrix.(['qmatrix' detno])(lims(3):lims(4),lims(1):lims(2),21);
% 
%                 
%                 if strcmp(option,'masked');
%                     %Find any pixels that are masked
%                     temp = find(output.mask_mat==1);
%                     output.(['beam' beamno]).qxdat = reshape(output.(['beam' beamno]).qxmat(temp),[numel(output.qxmat(temp)),1]);
%                     output.(['beam' beamno]).qydat = reshape(output.(['beam' beamno]).qymat(temp),[numel(output.qymat(temp)),1]);
%                     output.(['beam' beamno]).modqdat = reshape(output.(['beam' beamno]).modqmat(temp),[numel(output.modqmat(temp)),1]);
%                     output.(['beam' beamno]).delta_q_dat = reshape(output.(['beam' beamno]).delta_q_mat(temp),[numel(output.delta_q_mat(temp)),1]);
%                     output.(['beam' beamno]).qangledat = reshape(output.(['beam' beamno]).qanglemat(temp),[numel(output.qanglemat(temp)),1]);
%                     output.(['beam' beamno]).qx_per_pixelx_dat = reshape(output.(['beam' beamno]).qx_per_pixelx_mat(temp),[numel(output.qx_per_pixelx_mat(temp)),1]);
%                     output.(['beam' beamno]).qy_per_pixely_dat = reshape(output.(['beam' beamno]).qy_per_pixely_mat(temp),[numel(output.qy_per_pixely_mat(temp)),1]);
%                     
%                 else %i.e. unmasked
%                     %Complie xyz data only using the un-masked points
%                     output.(['beam' beamno]).qxdat = reshape(output.(['beam' beamno]).qxmat,[numel(output.qxmat),1]);
%                     output.(['beam' beamno]).qydat = reshape(output.(['beam' beamno]).qymat,[numel(output.qymat),1]);
%                     output.(['beam' beamno]).modqdat = reshape(output.(['beam' beamno]).modqmat,[numel(output.modqmat),1]);
%                     output.(['beam' beamno]).delta_q_dat = reshape(output.(['beam' beamno]).delta_q_mat,[numel(output.delta_q_mat),1]);
%                     output.(['beam' beamno]).qangledat = reshape(output.(['beam' beamno]).qanglemat,[numel(output.qanglemat),1]);
%                     output.(['beam' beamno]).qx_per_pixelx_dat = reshape(output.(['beam' beamno]).qx_per_pixelx_mat,[numel(output.qx_per_pixelx_mat),1]);
%                     output.(['beam' beamno]).qy_per_pixely_dat = reshape(output.(['beam' beamno]).qy_per_pixely_mat,[numel(output.qy_per_pixely_mat),1]);
% 
%                 end
%                 
%                
%                 %***** Prepare Data for 2D resolution smearing *****
%                 %This bit builds q-weight kernels in the form of extra modq-weight points associated with every real data point
%                 %The fit functions then just thinks there is more data to calculate a 'z' for than there is.  This then gets weight averaged to make
%                 %the final z corresponding to the real xy point at the end of pseudo_fn2d
%                 output.finesse = 1; %Default in case of no smearing
%                 new_modqdat = [];
%                 new_qxdat = []; new_qydat = []; new_xdat = []; new_ydat = [];
%                 if status_flags.fitter.include_res_check_2d == 1;  %Convolute instrument resolution
%                     new_kernel_weight = [];
%                     %Multiply up the raw-points to become a sum (average) of points over a smearing kernel
%                     output.finesse = status_flags.resolution_control.xgrid_2d * status_flags.resolution_control.ygrid_2d;
%                     for n = 1:length(output.(['beam' beamno]).modqdat);
%                         sigma_q = output.(['beam' beamno]).delta_q_dat(n)/(2*sqrt(2*log(2)));
%                         [kernel] = gauss_qkernel(output.(['beam' beamno]).qxdat(n),output.(['beam' beamno]).qydat(n),sigma_q,sigma_q,status_flags.resolution_control.sigma_extent_2d,status_flags.resolution_control.xgrid_2d,status_flags.resolution_control.ygrid_2d,output.xdat(n),output.ydat(n),output.(['beam' beamno]).qx_per_pixelx_dat(n),output.(['beam' beamno]).qy_per_pixely_dat(n));
%                         new_xdat = [new_xdat; kernel.x_pixel(:)];
%                         new_ydat = [new_ydat; kernel.y_pixel(:)];
%                         new_qxdat = [new_qxdat; kernel.qx(:)];
%                         new_qydat = [new_qydat; kernel.qy(:)];
%                         new_modqdat = [new_modqdat; kernel.modq(:)];
%                         new_kernel_weight = [new_kernel_weight; kernel.weight(:)];
%                         
%                     end
%                     output.(['beam' beamno]).qxdat = new_qxdat;
%                     output.(['beam' beamno]).qydat = new_qydat;
%                     output.(['beam' beamno]).modqdat = new_modqdat;
%                     output.(['beam' beamno]).new_kernel_weight = new_kernel_weight;
%                     output.(['beam' beamno]).xdat_smear_padded = new_xdat;
%                     output.(['beam' beamno]).ydat_smear_padded = new_ydat;
%                 else
%                     output.(['beam' beamno]).xdat_smear_padded = output.xdat; %Defaults - maybe overwritten above
%                     output.(['beam' beamno]).ydat_smear_padded = output.ydat;
%                 end
%                 
%                 
%                 %Store mod_q max and min - some functions find this useful
%                 qmin = min(output.(['beam' beamno]).modqdat); qmax = max(output.(['beam' beamno]).modqdat);
%                 output.(['beam' beamno]).modq_minmax = [qmin,qmax];
%                 if qmin < overall_qminmax(1); overall_qminmax(1) = qmin; end
%                 if qmax > overall_qminmax(2); overall_qminmax(2) = qmax; end
%                 
%                 
%             end
%             output.modq_minmax = overall_qminmax;
%         end
%         %***** END MULTIBEAM Modifications *****
        
        
        
    case 'fit_it'
        message_handle = grasp_message(['Working: 2d Curve Fitting']);
        
        fitdata = curve_fit_2d_callbacks('get_fit_data','masked'); %get fit data and curve number
        xy = [fitdata.xdat, fitdata.ydat];
        
        %Fit it!. - Using M_Fit
        fun_name = 'pseudo_fn2d';
        
        start_params = status_flags.fitter.function_info_2d.values;
        %vary_params = start_params;
        %vary_params(find(vary_params==0)) = 1; %i.e. Otherwise if the actual starting param= 0, then vary param would = 0 and parameter would not move in the fit.
        %Only vary parameters that are not fixed
        vary_mask = double(not(status_flags.fitter.function_info_2d.fix));
        %vary_params = vary_params.*vary_mask;
        
        %NOTE:  Not quite sure what is going on with the mf_lsqr routine
        %in terms of what value of the vary parameters should be.  mf_lsqr
        %does not converge and gives Nan's for the errors if this parameter
        %is not correct.  The thing that seems to work best is if it is set
        %to 0.1.  This is then multiplied again inside mf_lsqr.  Until I
        %really understand the mf_lsqr program I can't really work out what
        %is going on.  Maybe look for another least squares minimising
        %routine
        
        
        vary_params = 0.1*vary_mask;
        %vary_params = start_params.*vary_mask;
        
        %Check all parameters are not fixed
        if sum(vary_params)~=0
            
            %Run the fit once
            fit_refresh_flag = 1; %Recalculate any parameters required for the fit on first pass though the function
            fitdata.zdat = double(fitdata.zdat);
            fitdata.edat = double(fitdata.edat);
            [fit_params, fit_params_err,chi2] = mf_lsqr_grasp(xy,fitdata.zdat,fitdata.edat,start_params,vary_params,fun_name,fitdata);
                        
            %Store fit parameters and error in the status_flags
            status_flags.fitter.function_info_2d.values = fit_params';
            %status_flags.fitter.function_info_2d.err_values = fit_params_err_cov';
            status_flags.fitter.function_info_2d.err_values = fit_params_err';
            
            %make final copy of any grouped parameters into theircopy positions
            param_number = 1;
            for fn_multiplex = 1:status_flags.fitter.number2d
                for variable_loop = 1:status_flags.fitter.function_info_2d.no_parameters
                    if status_flags.fitter.function_info_2d.group(param_number) == 1
                        status_flags.fitter.function_info_2d.values(param_number) = status_flags.fitter.function_info_2d.values(variable_loop);
                        status_flags.fitter.function_info_2d.err_values(param_number) = status_flags.fitter.function_info_2d.err_values(variable_loop);
                    end
                    param_number = param_number+1;
                end
            end
            
            %Display Covariance corrected fit Parameters and Names
            disp(' ')
            disp('Covariance Corrected Fit Params');
            l = length(status_flags.fitter.function_info_2d.long_names);
            for n = 1:l(1)
                disp([status_flags.fitter.function_info_2d.long_names{n} ' : ' num2str(status_flags.fitter.function_info_2d.values(n)) '  err: ' num2str(status_flags.fitter.function_info_2d.err_values(n))]);
            end
            disp(['Chi^2 = ' num2str(chi2,'%8.3f')]);
            disp(' ')
            
            %Dump the fit paramters, errors and parameter names into a structure that can be picked up elsewhere
            %fit_parameters = struct('name',fun_name,'pnames',pnames,'params',fit_params,'error',fit_params_err_cov,'error_non_cov_check',fit_params_err);
            fit_parameters = status_flags.fitter.function_info_2d;
            fit_parameters.number_functions = status_flags.fitter.number2d;
            fit_parameters.fit_return_data = fit_return_data;
            
            
            %Add Fit History to the displayimage structure
            fit_history = {['Curve Fit:' status_flags.fitter.function_info_2d.name]};
            l = length(status_flags.fitter.function_info_2d.variable_names);
            for n = 1:l(1)
                fit_history(length(fit_history)+1,:) = {[status_flags.fitter.function_info_2d.variable_names{n} ' : ' num2str(fit_parameters.values(n)) ' err: ' num2str(fit_parameters.err_values(n))]};
            end
            fit_history(length(fit_history)+1,:) = {['Chi^2 = ' num2str(chi2,'%8.3f')]};
            
            displayimage.fit2d_history = fit_history;
            
        end
        
        %Delete message
        delete(message_handle);
        
        %Draw the fitted function
        curve_fit_2d_callbacks('draw_fn',fit_color); %update the function
        
        %Update the curve fit window with the new parameters
        curve_fit_2d_callbacks('update_curve_fit_window');
        
        %Poke the fit data into the 2D Fit & Residual worksheets
        
        
        
        
end



