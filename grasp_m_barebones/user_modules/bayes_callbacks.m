function rheo_anisotropy_callbacks(to_do)

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
        
end


%Update rheo_anisotropy
input_name = status_flags.user_modules.bayes.input_name;






%Update the window parameters
%set(grasp_handles.user_modules.rheo_anisotropy.start_radius,'string',num2str(start_radius));
%set(grasp_handles.user_modules.rheo_anisotropy.end_radius,'string',num2str(end_radius));
set(grasp_handles.user_modules.bayes.input_name,'string',num2str(input_name));

grasp_update
 
    
 
 
    
end



