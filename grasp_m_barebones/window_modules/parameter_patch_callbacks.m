function parameter_patch_callbacks(to_do)

if nargin <1; to_do = '';end

global status_flags
global grasp_data
global grasp_handles

switch to_do
    
    case 'parameter_edit'
        number = get(gcbo,'userdata');
        string = get(gcbo,'string');
        value = get(gcbo,'value');
        status_flags.data.(['patch_parameter_value' num2str(number)]) = get(gcbo,'value');
        status_flags.data.(['patch_parameter' num2str(number)]) = string{value};
        
    case 'patch_edit'
        number = get(gcbo,'userdata');
        temp = str2num(get(gcbo,'string'));
        if not(isempty(temp))
            status_flags.data.(['patch' num2str(number)]) = temp;
        end
        
    case 'replace_modify'
        number = get(gcbo,'userdata');
        status_flags.data.(['rep_mod' num2str(number)]) = get(gcbo,'value');
        
    case 'close'
        
    case 'parameter_check'
        status_flags.data.patch_check = get(gcbo,'value');
        
end

%Build Patch dropdown menus
string = rot90(fieldnames(grasp_data(status_flags.selector.fw).params1{status_flags.selector.fn}{status_flags.selector.fd}));
string = [{'none'},string];
for n = 1:status_flags.data.number_patches    
    value = status_flags.data.(['patch_parameter_value' num2str(n)]);
    set(grasp_handles.window_modules.(['parameter_parameter_popup' num2str(n)]),'string',string,'value',value);
end

grasp_update
      
