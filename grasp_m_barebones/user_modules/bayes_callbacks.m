function bayes_callbacks(to_do)

if nargin<1; to_do = ''; end

global status_flags
global displayimage
global grasp_handles
global inst_params
global grasp_data
global last_result
global box_Af



switch to_do
    
        
    case 'input_name'
        value = (get(gcbo,'string'));
        if not(isempty(value))
            status_flags.user_modules.bayes.input_name = value;
        end
        
    case 'input_index'
        value = str2num(get(gcbo,'string'));
        if not(isempty(value))
            status_flags.user_modules.bayes.input_index = value;
        end 
        
    case 'output_index'
        value = str2num(get(gcbo,'string'));
        if not(isempty(value))
            status_flags.user_modules.bayes.output_index = value;
        end
        
    case 'spot_x'
        value = str2num(get(gcbo,'string'));
        if not(isempty(value))
            status_flags.user_modules.bayes.spot_x = value;
        end
        
    case 'spot_y'
        value = str2num(get(gcbo,'string'));
        if not(isempty(value))
            status_flags.user_modules.bayes.spot_y = value;
        end 
    case 'sanoffset'
        value = str2num(get(gcbo,'string'));
        if not(isempty(value))
            status_flags.user_modules.bayes.sanoffset = value;
        end
        
    case 'phioffset'
        value = str2num(get(gcbo,'string'));
        if not(isempty(value))
            status_flags.user_modules.bayes.phioffset = value;
        end
        
    case 'eta0'
        value = str2num(get(gcbo,'string'));
        if not(isempty(value))
            status_flags.user_modules.bayes.eta0 = value;
        end
        
    case 'rock_type'
        rock_type_list = get(gcbo,'String');
        value = get(gcbo,'Value');
        status_flags.user_modules.bayes.rock_type = rock_type_list{value};
        
    case 'boxing_type'
        boxing_type_list = get(gcbo,'String');
        value = get(gcbo,'Value');
        if value == 1;
            status_flags.user_modules.bayes.boxing_type = 0;
        else
            status_flags.user_modules.bayes.boxing_type = boxing_type_list{value}; 
        end
        
    case 'shape'
        shape_list = get(gcbo,'String');
        value = get(gcbo,'Value');
        if strcmp(shape_list{value}, 'lorentzian')
            status_flags.user_modules.bayes.shape = 'l'
        elseif strcmp(shape_list{value}, 'gaussian')
            status_flags.user_modules.bayes.shape = 'g'
        end
        
    case 'nonsensefactor'
        nonsensefactor = get(gcbo,'Value')
        status_flags.user_modules.bayes.nonsensefactor = 1 - nonsensefactor ; % adapt so the slider is from left (=low) to right(=high)
        
    case 'run_bayes'
        run_Bayes;
        
    case 'display_fit_results'
        display('test print lorem ipsum');
        bayes_result_window;
        
end


%Update rheo_anisotropy
input_name = status_flags.user_modules.bayes.input_name;








grasp_update
 
    
 
 
    
end



