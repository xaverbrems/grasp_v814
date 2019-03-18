function display_params

global displayimage
global grasp_env
global inst_params
global status_flags

%Display Relavent Params
disp(' ');
disp(' ');

if displayimage.params1.wav ==0 && displayimage.params1.det == 0
    disp('***** Params are empty *****');
else
    disp('***** Numor Parameter Summary *****');
    if     displayimage.sum_flag ==1 %sum is displayed
        disp(['Loaded Numor(s) = ' displayimage.load_string '  : Current = Depth Sum' ]); %Numors
    else
        disp(['Loaded Numor(s) = ' displayimage.load_string '  : Current = ' num2str(displayimage.params1.numor)]); %Numors
    end
    if isfield(displayimage.params1,'user'); disp(['User:  "' displayimage.params1.user '"']); end
    disp(['Subtitle:  "' displayimage.params1.subtitle '"']);
    disp(['Start: ' displayimage.params1.start_time ' ' displayimage.params1.start_date '  End: ' displayimage.params1.end_time ' ' displayimage.params1.end_date]);
    
    
    %Instrument Configuration
    disp(' ')
    disp('Instrument Config:')
    selector_str = [];
    if isfield(displayimage.params1,'sel_rpm'); selector_str = ['Selector RPM = ' num2str(displayimage.params1.sel_rpm)]; end
    res_str = [];
    if isfield(displayimage.params1,'deltawav'); res_str = ['DeltaWav ' num2str((displayimage.params1.deltawav)*100) ' (%)']; end
    disp(['      Wavelength ' num2str(displayimage.params1.wav) '(' char(197) '),  ' res_str '    ' selector_str]);
    disp(['      Collimation '  num2str(displayimage.params1.col) ' (m)']);
    
    %Detectors
    for det = 1:inst_params.detectors
        detno=num2str(det);
        params = displayimage.(['params' detno]);
        
        
        
        if strcmp(grasp_env.inst,'ILL_d33') %D33 specific
            
            if det==1 %Only do it once and do all at one time.
                if isfield(params,'det1'); det1_str = [num2str(params.det1) ' [m]']; det1_dist = params.det1; else det1_str = []; end
                if isfield(params,'detcalc1'); det1_calc_str = ['  DET_CALC1: ' num2str(params.detcalc1) ' [m]']; det1_dist = params.detcalc1; else det1_calc_str = []; end
                disp(['Detector1 : ' det1_str det1_calc_str]);
                %Panel properties
                panel_str = [];
                if isfield(params,'oxl'); panel_str = [panel_str 'OXL: ' num2str(params.oxl) ' [mm]  ']; end
                if isfield(params,'oxr'); panel_str = [panel_str 'OXR: ' num2str(params.oxr) ' [mm]  ']; end
                if isfield(params,'oyt'); panel_str = [panel_str 'OYT: ' num2str(params.oyt) ' [mm]  ']; end
                if isfield(params,'oyb'); panel_str = [panel_str 'OYB: ' num2str(params.oyb) ' [mm]  ']; end
                disp(['Panel Openings: ' panel_str]);
                if isfield(params,'det1_panel_offset'); panel_offset = params.det1_panel_offset; else panel_offset = 0; end
                disp(['Panel Offset : ' num2str(panel_offset)]);
                disp(['Panel Distance: OYT : ' num2str(det1_dist) ' [m]  OYB : ' num2str(det1_dist) ' [m]  OXL : ' num2str(det1_dist+panel_offset) ' [m]  OXR : ' num2str(det1_dist+panel_offset) ' [m]  ']);
                
                if isfield(params,'det2'); det2_str = [num2str(params.det2) ' [m]']; else det_str = []; end
                if isfield(params,'detcalc2'); det2_calc_str = ['  DET_CALC2: ' num2str(params.detcalc2)]; else det2_calc_str = []; end
                disp(['Detector2 : ' det2_str det2_calc_str]);
            end
            
        else %All other instruments
            %DET:  Check if to use Det or DetCalc (m)
            det_dist = params.det; %Default, unless otherwise
            if strcmp(status_flags.q.det,'detcalc')
                if isfield(params,'detcalc')
                    if not(isempty(params.detcalc))
                        det_dist = params.detcalc;
                    end
                end
            end
            det_str = ['      Det' num2str(detno) ': ' num2str(params.det) ' [m]'];
            if isfield(params,'detcalc'); det_calc_str = ['  Det_calc: ' num2str(params.detcalc)]; else det_calc_str = []; end
            disp([det_str det_calc_str]);
        end
        
                
    end
    
    %beamstop
    if isfield(displayimage.params1,'bx')
        disp(['      Beam Stop:  BX  ' num2str(displayimage.params1.bx) ',  BY  ' num2str(displayimage.params1.by)]);
    end
    
    %attenuator
    if isfield(displayimage.params1,'att_type')
        att_type =  num2str(displayimage.params1.att_type);
    else
        att_type = 'Unknown';
    end
    
    if isfield(displayimage.params1,'attenuation')
        attenuation = displayimage.params1.attenuation;
    else
        attenuation = 1;
    end
    
    disp(['      Attenuator1: ' att_type '  , Attenuation value: ' num2str(attenuation)]);
    
    if isfield(displayimage.params1,'att2')
        disp(['      Attenuator2:  ' num2str(displayimage.params1.att2)]);
    end
    disp(['      Auto Attenuator correction is ' status_flags.normalization.auto_atten])

    
    
    %     %Collimation Motors
    %     if isfield(vectors,'col1') && isfield(vectors,'dia1'); col_str = ['Dia1 ' num2str(params(vectors.dia1)) ' Col1 ' num2str(params(vectors.col1)) char (10)]; else col_str = [];end
    %     if isfield(vectors,'col2') && isfield(vectors,'dia2'); col_str = [col_str 'Dia2 ' num2str(params(vectors.dia2)) ' Col2 ' num2str(params(vectors.col2)) char(10)]; end
    %     if isfield(vectors,'col3') && isfield(vectors,'dia3'); col_str = [col_str 'Dia3 ' num2str(params(vectors.dia3)) ' Col3 ' num2str(params(vectors.col3)) char(10)]; end
    %     if isfield(vectors,'col4') && isfield(vectors,'dia4'); col_str = [col_str 'Dia4 ' num2str(params(vectors.dia4)) ' Col4 ' num2str(params(vectors.col4)) char(10)]; end
    %     if isfield(vectors,'dia5'); col_str = [col_str 'Dia5 ' num2str(params(vectors.dia5))]; else col_str = [];end
    %     disp(col_str); disp(' ');
    %
        %Choppers
        if isfield(displayimage.params1,'chopper1_speed') && isfield(displayimage.params1,'chopper1_phase'); chop_str = ['Chopper #1 : ' num2str(displayimage.params1.chopper1_speed) ' [RPM]  '  num2str(displayimage.params1.chopper1_phase) ' [degs]' char(10)]; else chop_str =[]; end
        if isfield(displayimage.params1,'chopper2_speed') && isfield(displayimage.params1,'chopper2_phase'); chop_str = [chop_str 'Chopper #2 : ' num2str(displayimage.params1.chopper2_speed) ' [RPM]  '  num2str(displayimage.params1.chopper2_phase) ' [degs]' char(10)]; end
        if isfield(displayimage.params1,'chopper3_speed') && isfield(displayimage.params1,'chopper3_phase'); chop_str = [chop_str 'Chopper #3 : ' num2str(displayimage.params1.chopper3_speed) ' [RPM]  '  num2str(displayimage.params1.chopper3_phase) ' [degs]' char(10)]; end
        if isfield(displayimage.params1,'chopper4_speed') && isfield(displayimage.params1,'chopper4_phase'); chop_str = [chop_str 'Chopper #4 : ' num2str(displayimage.params1.chopper4_speed) ' [RPM]  '  num2str(displayimage.params1.chopper4_phase) ' [degs]' char(10)]; end
        disp(chop_str); disp(' ');
    
    
    
    
    %Sample Motors
    disp(' ')
    disp('Sample Movements:')
    motors_str = [];
    if isfield(displayimage.params1,'san'); motors_str = [motors_str 'SAN: ' num2str(displayimage.params1.san) '   '];end
    if isfield(displayimage.params1,'phi'); motors_str = [motors_str 'PHI: ' num2str(displayimage.params1.phi) '   '];end
    if isfield(displayimage.params1,'chi'); motors_str = [motors_str 'CHI: ' num2str(displayimage.params1.chi) '   '];end
    if isfield(displayimage.params1,'trs'); motors_str = [motors_str 'TRS: ' num2str(displayimage.params1.trs) '   ']; end
    if isfield(displayimage.params1,'sdi'); motors_str = [motors_str 'SDI: ' num2str(displayimage.params1.sdi) '   ']; end
    if isfield(displayimage.params1,'sdi1'); motors_str = [motors_str 'SDI1: ' num2str(displayimage.params1.sdi1) '   ']; end
    if isfield(displayimage.params1,'sdi2'); motors_str = [motors_str 'SDI2: ' num2str(displayimage.params1.sdi2) '   ']; end
    if isfield(displayimage.params1,'sht'); motors_str = [motors_str 'SHT: ' num2str(displayimage.params1.sht) '    ']; end
    if isfield(displayimage.params1,'omega'); motors_str = [motors_str 'Omega: ' num2str(displayimage.params1.omega) '    ']; end
    disp(['      '  motors_str]);
    
    changer_str = [];
    if isfield(displayimage.params1,'chpos'); changer_str = [changer_str 'Changer Pos: ' num2str(displayimage.params1.chpos) '   ']; end
    if isfield(displayimage.params1,'str'); changer_str = [changer_str 'STR: ' num2str(displayimage.params1.str) '   ']; end
    disp(changer_str);
    
    
    %Sample Environment
    disp(' ')
    disp('Sample Environment:')
    
    if isfield(displayimage.params1,'tset'); t_set_str = num2str(displayimage.params1.tset); else t_set_str = 'N/A'; end
    if isfield(displayimage.params1,'treg'); t_reg_str = num2str(displayimage.params1.treg); else t_reg_str = 'N/A'; end
    if isfield(displayimage.params1,'temp'); t_temp_str = num2str(displayimage.params1.temp); else t_temp_str = 'N/A'; end
    disp(['      T_set = ' t_set_str '; T_reg = ' t_reg_str '; T_sample = ' t_temp_str]);
    
    if isfield(displayimage.params1,'field'); disp(['Magnetic Field = ' num2str(displayimage.params1.field)]); end
    
    %Power Supplies
    if isfield(displayimage.params1,'ps1_i'); ps1_i_str = num2str(displayimage.params1.ps1_i); else ps1_i_str = 'N/A'; end
    if isfield(displayimage.params1,'ps1_v'); ps1_v_str = num2str(displayimage.params1.ps1_v); else ps1_v_str = 'N/A'; end
    if isfield(displayimage.params1,'ps2_i'); ps2_i_str = num2str(displayimage.params1.ps2_i); else ps2_i_str = 'N/A'; end
    if isfield(displayimage.params1,'ps2_v'); ps2_v_str = num2str(displayimage.params1.ps2_v); else ps2_v_str = 'N/A'; end
    if isfield(displayimage.params1,'ps3_i'); ps3_i_str = num2str(displayimage.params1.ps3_i); else ps3_i_str = 'N/A'; end
    if isfield(displayimage.params1,'ps3_v'); ps3_v_str = num2str(displayimage.params1.ps3_v); else ps3_v_str = 'N/A'; end
    disp(['      Power Supplies :  PS1 ' num2str(ps1_i_str) ' [A]  ' num2str(ps1_v_str) ' [V] :  PS2 ' num2str(ps2_i_str) ' [A]  ' num2str(ps2_v_str) ' [V] :  PS3 ' num2str(ps3_i_str) ' [A]  ' num2str(ps3_v_str) ' [V]  ']);
    
    
    %Lockin Amplifier
    if isfield(displayimage.params1,'lockin_x')
        x_str = num2str(displayimage.params1.lockin_x);
        y_str = num2str(displayimage.params1.lockin_y);
        mag_str = num2str(displayimage.params1.lockin_mag);
        phase_str = num2str(displayimage.params1.lockin_phase);
        disp(['Lockin Amplifier :  X ' x_str ' [V]   Y ' y_str ' [V]   Magnitude ' mag_str ' [V]   Phase ' phase_str ' [degs]']);
    end
    
    
    
    
    %Acquisition
    disp(' ');
    disp('Acquisition::')
    disp(['      Acquisition Time = ' num2str(displayimage.params1.aq_time) ' [s]     Exposure Time = ' num2str(num2str(displayimage.params1.ex_time)) ' [s]']);
    
    text_string = [];
    if isfield(displayimage.params1,'slice_time')
        text_string = [text_string '      Slice Time = ' num2str(displayimage.params1.slice_time) ' [s]'];
    end
    if isfield(displayimage.params1,'pickups')
        text_string = [text_string '      #Pickups = ' num2str(displayimage.params1.pickups)];
    end
    %     if isfield(displayimage.params1,'time')
    %         text_string = [text_string '   Exposure time = ' num2str(num2str(displayimage.params1.ex_time)) ' (s)'];
    %     end
    disp(text_string);
    
    for det = 1:inst_params.detectors
        detno=num2str(det);
        disp(['      Total Det Counts [Det:' detno '] ' num2str(displayimage.(['params' detno]).array_counts) ' Over ' num2str(displayimage.params1.ex_time) 'secs (~' num2str(round(displayimage.(['params' detno]).array_counts/(displayimage.params1.ex_time))) ' cps)']);
    end
    
    
    %disp(['Total Det Counts (array) / Monitor (x1000) ' num2str((displayimage.params(vectors.array_counts))*1000/displayimage.params(vectors.monitor))]);
    disp(['      Total Monitor1 Counts  ' num2str(displayimage.params1.monitor) ' Over ' num2str(displayimage.params1.ex_time) 'secs (~' num2str(round(displayimage.params1.monitor/(displayimage.params1.ex_time))) ' cps)']);
    if isfield(displayimage.params1,'monitor2') && displayimage.params1.monitor2 ~= 0
        disp(['      Total Monitor2 Counts  ' num2str(displayimage.params1.monitor2) ' Over ' num2str(displayimage.params1.ex_time) 'secs (~' num2str(round(displayimage.params1.monitor2/(displayimage.params1.ex_time))) ' cps)']);
    end
    if isfield(displayimage.params1,'reactor_power')
        disp(['      Reactor Power = ' num2str(displayimage.params1.reactor_power) ' MW']);
    end
    
    
end
disp(' ');
disp(' ');
disp(' ');

warning on
