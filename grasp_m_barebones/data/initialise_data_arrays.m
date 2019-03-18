function initialise_data_arrays(specific_wks_type, specific_wks_nmbr)

%Initialises all the raw and screen data storage arrays

global grasp_data
global inst_params
global grasp_env

%***** Worksheet types *****
% 1 = sample scattering
% 2 = sample background
% 3 = sample cadmium
% 4 = sample transmission
% 5 = sample empty transmission
% 6 = sample empty beam transmission
% 7 = sample mask
% 8 = I0 Beam Intensity
% 99 = detector efficiency map
% % 10 = NOT USED
% 11 = FR Trans Check without sample
% 12,13,14,15 = PA Sample Scattering 00 10 11 01 (0 Flipper off, 1 Flipper on)
% 16, 17, 18, 19 = PA Background Scattering
% 20 2D fit result
% 21 2D fit result residual
% 22,23 = SANSPOL Sample I0,I1
% 30 - Last box mask
% 31 - Last sector mask

%***** Worksheet Descriptions *****
worksheet = {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24};
wks_name = {'Sample' 'Empty Cell' 'Blocked Beam' 'Trans Sample' 'Trans Empty Cell' 'Trans Empty Beam' 'I0 Beam Intensity' 'Masks' 'Detector Eff' 'FR Trans Check','PA 00 Sample','PA 10 Sample','PA 11 Sample','PA 01 Sample','PA 00 Background','PA 10 Background','PA 11 Background','PA 01 Background', 'I0 SANSPOL','I1 SANSPOL','2D Fit result', '2D Fit Residual','Box Mask','Sector Mask'};
wks_type = {1 2 3 4 5 6 8 7 99 11 12 13 14 15 16 17 18 19 22 23 20 21 30 31};
wks_visibility = {1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1};
n = grasp_env.worksheet.worksheets;
wks_nmbr = {n n n n n n n n 1 n n n n n n n n n n n n n 1 1};
wks_dpth = {1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1};
n = grasp_env.worksheet.depth_max;
wks_dpthmax = {n n n n n n n n 1 n n n n n n n n n n n 1 1 1 1};
wks_sum_allowed = {1 1 1 1 1 1 1 0 0 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0}; %determines whether SUM is allowed and whether depth can exist
wks_allowed = {[1,2,3] [1,2,3] [1,2,3] [4,5,6] [4,5,6] [6] [8] [7] [99] [11] [12,13,14,15] [12,13,14,15] [12,13,14,15] [12,13,14,15] [16,12,3] [17,13,3] [18,14,3] [19,15,3] [22,23] [23,22] [20] [21] [30] [31]};
wks_last_disp = {[2, 3] [1, 3] [0, 0] [5, 0] [6, 0] [0,0] [0, 0] [0, 0] [0, 0] [0, 0] [12,0] [13,0] [14,0] [15,0] [12,3] [13,3] [14,3] [15,3] [22, 0] [23, 0] [0,0] [0,0] [0,0] [0,0]}; %Zero means do not display selector at all


%Test whether to do complete initialisation or re-initialise single worksheets
if nargin <1 %Do a complete (re)initialisation of all worksheets
    disp(['Initialising Data Arrays']);
    grasp_data = [];
    wks_start = 1; wks_end = length(worksheet);
else %Do a partial initialisation of single worksheet number
    wks_start = data_index(specific_wks_type); wks_end = wks_start;
end

%***** Build Worksheets *****
for wks = wks_start:wks_end %Worksheets loop, fore, back, cad, etc.
    grasp_data(wks).number = wks;
    grasp_data(wks).name = wks_name{wks};
    grasp_data(wks).nmbr = wks_nmbr{wks};
    grasp_data(wks).type = wks_type{wks};
    grasp_data(wks).allowed_types = wks_allowed{wks};
    grasp_data(wks).sum_allow = wks_sum_allowed{wks};
    grasp_data(wks).last_displayed = wks_last_disp{wks};
    grasp_data(wks).visible = wks_visibility{wks};
    
    dpth = wks_dpth{wks};  %Number of Depths reserved by default (usually 1).  These can be expanded during operation
    dpth_max = wks_dpthmax{wks};
    
    if nargin<1 %Do a complete (re)initalisation of all worksheets
        wks_nmbr_start = 1; wks_nmbr_end = wks_nmbr{wks};
    else %Do a partial initialisation fo a single worksheet number
        wks_nmbr_start = specific_wks_nmbr; wks_nmbr_end = specific_wks_nmbr;
        %Check if adding worksheet
        if specific_wks_nmbr > wks_nmbr{wks}
            grasp_data(wks).nmbr = specific_wks_nmbr;
        end
    end
    
    %Loop though number of Worksheet_Numbers
    for n = wks_nmbr_start:wks_nmbr_end
        
        grasp_data(wks).dpth{n} = dpth;
        grasp_data(wks).dpth_max{n} = dpth_max;
        grasp_data(wks).thickness{n} = ones(dpth,1)*0.1; %cm
        grasp_data(wks).trans{n} = [ones(dpth,1), zeros(dpth,1)]; %Trans, Err_trans
        grasp_data(wks).trans_smooth{n} = [ones(dpth,1), zeros(dpth,1)]; %Trans, Err_trans
        grasp_data(wks).data_type{n} = 'mono';
        for det = 1:inst_params.detectors
            detno=num2str(det);
            grasp_data(wks).(['params' detno]){n} = [];
        end
        
        %Loop though number of detectors
        for det = 1:inst_params.detectors
            detno=num2str(det);
            
            if wks_type{wks} == 99 %Detector efficiency
                %Load Default Detector Efficiency if exists, variable is called eff_data
                %Check if efficiency file exists
                fname = ['instrument_ini' filesep 'det_efficiency' filesep inst_params.(['detector' detno]).efficiency_file];
                
                fid = fopen(fname);
                disp(['Looking for Detector Efficiency Map: ' fname]);
                if fid ~= -1 %File exists
                    fclose(fid);
                    disp(['Loading Default Detector Efficiency Map for Detector: ' detno ' : ' fname])
                    eff_data = load([fname]);
                    data = eff_data.eff_data;
                    try error = eff_data.eff_err_data; catch error = zeros(inst_params.(['detector' detno]).pixels(2), inst_params.(['detector' detno]).pixels(1),grasp_env.data_type.det_eff); end;
                else
                    disp(['WARNING:  No Default Detector Efficiency Map Found for Detector: ' detno]);
                    data = ones(inst_params.(['detector' detno]).pixels(2), inst_params.(['detector' detno]).pixels(1),grasp_env.data_type.det_eff);
                    error = zeros(inst_params.(['detector' detno]).pixels(2), inst_params.(['detector' detno]).pixels(1),grasp_env.data_type.det_eff);
                end
                grasp_data(wks).(['mean_intensity' detno]){n} = 1;
                grasp_data(wks).(['mean_intensity_units' detno]){n} = 'N/A';
                grasp_data(wks).calibration_xsection{n} = 1;
                
            elseif wks_type{wks} == 7 %Masks
                %initialise user mask
                data = ones(inst_params.(['detector' detno]).pixels(2), inst_params.(['detector' detno]).pixels(1),dpth,grasp_env.data_type.mask);
                error = zeros(inst_params.(['detector' detno]).pixels(2), inst_params.(['detector' detno]).pixels(1),dpth,grasp_env.data_type.mask);
                
                         
            else %Normal Scattering or Transmission Data
                data = zeros(inst_params.(['detector' detno]).pixels(2), inst_params.(['detector' detno]).pixels(1),dpth,grasp_env.data_type.data);
                error = zeros(inst_params.(['detector' detno]).pixels(2), inst_params.(['detector' detno]).pixels(1),dpth,grasp_env.data_type.error);
                
            end
            %Allocate a beam centre and detector translation to every type of worksheet
            cm.cm_pixels(1:dpth,1) = inst_params.(['detector' detno]).nominal_beam_centre(1);
            cm.cm_pixels(1:dpth,2) = inst_params.(['detector' detno]).nominal_beam_centre(2);
            cm.cm_translation(1:dpth,1) = inst_params.(['detector' detno]).nominal_det_translation(1); %This is the translation in mm to tell where the pannel is relative to the direct beam measurement
            cm.cm_translation(1:dpth,2) = inst_params.(['detector' detno]).nominal_det_translation(2);
            
            %Allocate data and error values to the grasp_data structure
            %grasp_data(wks).(['params' detno]){n} = zeros(128,dpth);
            grasp_data(wks).(['cm' detno]){n} = cm;
            grasp_data(wks).(['data' detno]){n} = data;
            grasp_data(wks).(['error' detno]){n} = error;
            
            %Allocate default standard, fundamental and necessary parameters
            params.aq_time = 0;
            params.ex_time = 0;
            params.monitor = 0;
            params.monitor2 = 0;
            params.det = 0;
            params.det1 = 0; params.det2 = 0; params.detcalc = 0; params.detcalc1 = 0; params.detcalc2 = 0;
            params.det1_panel_offset = 0;
            params.oxr = 0; params.oxl = 0; params.oyb = 0; params.oyt = 0;
            params.wav = 0;
            params.deltawav = 0;
            params.col = 0;
            params.array_counts = 0;
            params.attenuation = 1;
            params.numor = 0;
            params.subtitle = ['no data'];
            params.user = ['no user'];
            params.start_date = '01-Jan-2017';
            params.start_time = '00:00:00';
            params.end_date = '01-Jan-2017';
            params.end_time = '00:00:00';
            params.san = 0; params.phi = 0; params.temp = 0;
            grasp_data(wks).(['params' detno]){n}{1} = orderfields(params);
            grasp_data(wks).load_string{n} = ['<Numors>'];
        end
        
        
        if wks_type{wks} == 99 %Detector efficiency
            grasp_data(wks).(['params' detno]){n}{1}.subtitle = ['Detector Efficiency Map'];
            grasp_data(wks).(['params' detno]){n}{1}.load_string = ['Detector Efficiency Map'];
        elseif wks_type{wks} == 7 %Masks
            grasp_data(wks).(['params' detno]){n}{1}.subtitle = ['Mask'];
            grasp_data(wks).(['params' detno]){n}{1}.load_string = ['Mask'];
        end
        
    end
end

