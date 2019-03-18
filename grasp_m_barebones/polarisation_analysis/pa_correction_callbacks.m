function pa_correction_callbacks(to_do)

if nargin<1; to_do = '';end

global status_flags
global data
global grasp_handles
global grasp_data

switch to_do
    
        case 'f_pol_edit'
        
        temp = get(gcbo,'string');
        value = str2num(temp);
        if not(isempty(value))
            status_flags.pa_optimise.parameters.pf = [value, 0];
            disp(['Supermirror Polarisation = ' num2str(status_flags.pa_optimise.parameters.p(1)) ', RF Flipper Polarisation = ' num2str(status_flags.pa_optimise.parameters.pf(1))]);
        end
        
        
        
       case 'p_pol_edit'
        
        temp = get(gcbo,'string');
        value = str2num(temp);
        if not(isempty(value))
            status_flags.pa_optimise.parameters.p = [value, 0];
            disp(['Supermirror Polarisation = ' num2str(status_flags.pa_optimise.parameters.p(1)) ', RF Flipper Polarisation = ' num2str(status_flags.pa_optimise.parameters.pf(1))]);
        end
        
        case 'bck'
        status_flags.pa_correction.bck_check = not(status_flags.pa_correction.bck_check);
        set(grasp_handles.window_modules.pa_correction.bck_check,'value',status_flags.pa_correction.bck_check);
        %grasp_update
        
      

        case 'cad'
        status_flags.pa_correction.cad_check = not(status_flags.pa_correction.cad_check);
        set(grasp_handles.window_modules.pa_correction.cad_check,'value',status_flags.pa_correction.cad_check);
        %grasp_update
        
        case 'pa_correction'
        status_flags.pa_correction.pa_check = not(status_flags.pa_correction.pa_check);
        if status_flags.pa_correction.pa_check == 1;
        disp('Polarisation Spin Leackage Correction')
          disp(' ');
        disp(['Spin-Leakage Corrections:   ']);
        disp(['Supermirror Polarisation = ' num2str(status_flags.pa_optimise.parameters.p(1)) ', RF Flipper Polarisation = ' num2str(status_flags.pa_optimise.parameters.pf(1))]);
        set(grasp_handles.window_modules.pa_correction.pa_check,'value',status_flags.pa_correction.pa_check);
        %grasp_update
        end;
        
        case 'sigmaadd'
        status_flags.pa_correction.add_check = not(status_flags.pa_correction.add_check);
        set(grasp_handles.window_modules.pa_correction.add_check,'value',status_flags.pa_correction.add_check);
        %grasp_update
        
        
     
        
        case 'close'
        grasp_handles.window_modules.pa_correction.window = [];
        return
       
end

grasp_update


