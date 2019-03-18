function inst_menu_callbacks(to_do,option1,option2)


if nargin<3; option2 = []; end
if nargin<2; option1 = []; end

global grasp_env
global inst_params %Needed for the instrument runcode
global grasp_handles
global status_flags

switch to_do

    case 'change' %Change instrument
        button = file_menu('close','exit');
        if not(strcmp(button,'cancel'))
            
            %Cleanly find handle to wanted instrument - instead of using
            %GCBO as call may not always come from the menu, e.g. can be
            %called by close project
            grasp_env.inst = [option1 '_' option2];
            inst_menu_handle = grasp_handles.menu.instrument.inst.([grasp_env.inst]);
            set(inst_menu_handle,'checked','on');
            %grasp_env.inst_option = option2;
            %initialise_instrument_params;
            inst_config = get(inst_menu_handle,'userdata');
            %Then execute the runcode to initilaise the instrument config
            eval(inst_config.runcode);

            %initialise_status_flags;
            initialise_status_flags;
            initialise_data_arrays;
            status_flags.selector.fd=1;
            selector_build;
            selector_build_values('all');
            initialise_2d_plots
            grasp_update
            tool_callbacks('rescale');
            update_last_saved_project
        end
        
    case 'sans_instrument_model'
        
        sans_instrument_model(grasp_env.inst);
        
        
        
end

