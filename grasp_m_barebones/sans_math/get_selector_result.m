function foreimage = get_selector_result

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
% 10 = unpolarised transmission of 3He Cell
% 11 = FR Trans Check
% 12,13,14,15 = PA Sample  00 10 11 01 (0 Flipper off, 1 Flipper on)
% 16,17,18,19 = PA Background  00 10 11 01
% 22,23 = SANSPOL Sample I0,I1


global status_flags
global inst_params
global grasp_env
%global displayimage

%Begin the data treatment history
history = {[grasp_env.grasp_name ' V.' grasp_env.grasp_version '    Instrument:  ' grasp_env.inst]};
history = [history, {[' ']}];






if (status_flags.selector.fw >= 12 && status_flags.selector.fw <= 19)
    %***** Do something different for PA analysis:  Worksheets Sample++, -+, --, +- *****


    %Worksheet number & Depth
    nmbr = status_flags.selector.fn;
    dpth = status_flags.selector.fd;
    %     %Worksheet number & Depth
    %     nmbr_bck = status_flags.selector.bn;
    %     dpth_bck = status_flags.selector.bd;


    %***** Get ++Sample *****
    index = data_index(12);
    [pa00] = retrieve_data([index,nmbr,dpth]);
    history = [history, {['***** PA Worksheets ++, -+, --, +- *****']}];
    history = [history, {['Subtitle:  ' pa00.params1.subtitle]}];
    history = [history, {['Start: ' pa00.params1.start_date '  ' pa00.params1.start_time '   End: ' pa00.params1.end_date '  ' pa00.params1.end_time]}];
    history = [history, {[' ']}];
    %Add ++ info to History
    if pa00.sum_flag ==1
        history = [history, {['Sample ++: Sum ' pa00.load_string ' , Loaded: ' pa00.load_string]}];
    else
        history = [history, {['Sample ++:  ' num2str(pa00.params1.numor) ' , Loaded: ' pa00.load_string]}];
    end
    %Data Normalisation, Attenuator & Deadtime
    pa00 = normalize_data(pa00);

    %***** Get ++Background *****
    index = data_index(16);
    [bck00] = retrieve_data([index,nmbr,dpth]);
    %Data Normalisation, Attenuator & Deadtime
    bck00 = normalize_data(bck00);
    %Add -+ background info to History
    if bck00.sum_flag ==1
        history = [history, {['Background ++: Sum ' bck00.load_string ' , Loaded: ' bck00.load_string]}];
    else
        history = [history, {['Background ++:  ' num2str(bck00.params1.numor) ' , Loaded: ' bck00.load_string]}];
    end





    %***** Get -+Sample *****
    index = data_index(13);
    [pa10] = retrieve_data([index,nmbr,dpth]);
    %Data Normalisation, Attenuator & Deadtime
    pa10 = normalize_data(pa10);
    %Add -+ info to History
    if pa10.sum_flag ==1
        history = [history, {['Sample -+: Sum ' pa10.load_string ' , Loaded: ' pa10.load_string]}];
    else
        history = [history, {['Sample -+:  ' num2str(pa10.params1.numor) ' , Loaded: ' pa10.load_string]}];
    end

    %***** Get -+Background *****
    index = data_index(17);

    [bck10] = retrieve_data([index,nmbr,dpth]);
    %Data Normalisation, Attenuator & Deadtime
    bck10 = normalize_data(bck10);
    %Add -+ background info to History
    if bck10.sum_flag ==1
        history = [history, {['Background -+: Sum ' bck10.load_string ' , Loaded: ' bck10.load_string]}];
    else
        history = [history, {['Background -+:  ' num2str(bck10.params1.numor) ' , Loaded: ' bck10.load_string]}];
    end





    %***** Get --Sample *****
    index = data_index(14);
    [pa11] = retrieve_data([index,nmbr,dpth]);
    %Data Normalisation, Attenuator & Deadtime
    pa11 = normalize_data(pa11);
    %Add +- info to History
    if pa11.sum_flag ==1
        history = [history, {['Sample --: Sum ' pa11.load_string ' , Loaded: ' pa11.load_string]}];
    else
        history = [history, {['Sample --:  ' num2str(pa11.params1.numor) ' , Loaded: ' pa11.load_string]}];
    end

    %***** Get --Background *****
    index = data_index(18);
    [bck11] = retrieve_data([index,nmbr,dpth]);
    %Data Normalisation, Attenuator & Deadtime
    bck11 = normalize_data(bck11);
    %Add -- background info to History
    if bck11.sum_flag ==1
        history = [history, {['Background --: Sum ' bck11.load_string ' , Loaded: ' bck11.load_string]}];
    else
        history = [history, {['Background --:  ' num2str(bck11.params1.numor) ' , Loaded: ' bck11.load_string]}];
    end



    %***** Get +-Sample *****
    index = data_index(15);
    [pa01] = retrieve_data([index,nmbr,dpth]);
    %Data Normalisation, Attenuator & Deadtime
    pa01 = normalize_data(pa01);
    %Add +- info to History
    if pa01.sum_flag ==1
        history = [history, {['Sample +-: Sum ' pa01.load_string ' , Loaded: ' pa01.load_string]}];
    else
        history = [history, {['Sample +-:  ' num2str(pa01.params1.numor) ' , Loaded: ' pa01.load_string]}];
    end

    %***** Get +-Background *****
    index = data_index(19);
    [bck01] = retrieve_data([index,nmbr,dpth]);
    %Data Normalisation, Attenuator & Deadtime
    bck01 = normalize_data(bck01);
    %Add +- background info to History
    if bck01.sum_flag ==1
        history = [history, {['Background +-: Sum ' bck01.load_string ' , Loaded: ' bck01.load_string]}];
    else
        history = [history, {['Background +-:  ' num2str(bck01.params1.numor) ' , Loaded: ' bck01.load_string]}];
    end




    %Add the normalisation history only once
    history = [history, {[' ']}];
    history = [history, pa00.history]; %add the normalization history (taken from P00)


    %           %Set up output array 'foreimage';
    %     if status_flags.selector.fw == 11 %Sample ++ is displayed
    %          foreimage = pa00;
    %     elseif status_flags.selector.fw == 12 %Sample -+ is displayed
    %          foreimage = pa10;
    %      elseif status_flags.selector.fw == 13 %Sample -- is displayed
    %          foreimage = pa11;
    %      elseif status_flags.selector.fw == 14 %Sample +- is displayed
    %          foreimage = pa01;
    %     elseif status_flags.selector.fw == 15 %Background ++ is displayed
    %          foreimage = bck00;
    %      elseif status_flags.selector.fw == 16 %Background -+ is displayed
    %          foreimage = bck10;
    %      elseif status_flags.selector.fw == 17 %Background -- is displayed
    %          foreimage = bck11;
    %      elseif status_flags.selector.fw == 18 %Background +- is displayed
    %          foreimage = bck01;
    %      end  %}





    %Get Cadmium data
    if status_flags.pa_correction.cad_check == 1 ; %i.e. cadmium correction
        [cadmiumimage] = retrieve_data('cad'); %cadmium data
        %Add Cadmium info to History
        if cadmiumimage.sum_flag ==1
            history = [history, {['Cadmium: Sum ' cadmiumimage.load_string ' , Loaded: ' cadmiumimage.load_string]}];
        else
            history = [history, {['Cadmium:  ' num2str(cadmiumimage.params1.numor) ' , Loaded: ' cadmiumimage.load_string]}];
        end
        %Normalise cadmium data (only if real data, not masks etc)
        cadmiumimage = normalize_data(cadmiumimage); %Data Normalisation, Attenuator correction and deadtime
        history = [history, {[' ']}];
        if pa00.params1.array_counts~=0
            pa00 = pa_cadmium_data_correction(pa00,cadmiumimage);
            history = [history, {['Applying background noise SANS data correction:  I00 = I00 - I_cd']}];
        end
        if pa10.params1.array_counts~=0
            pa10 = pa_cadmium_data_correction(pa10,cadmiumimage);
            history = [history, {['Applying background noise SANS data correction:  I10 = I10 - I_cd']}];
        end
        if pa11.params1.array_counts~=0
            pa11 = pa_cadmium_data_correction(pa11,cadmiumimage);
            history = [history, {['Applying background noise SANS data correction:  I11 = I11 - I_cd']}];
        end
        if pa01.params1.array_counts~=0
            pa01 = pa_cadmium_data_correction(pa01,cadmiumimage);
            history = [history, {['Applying background noise SANS data correction:  I01 = I01 - I_cd']}];
        end
        if bck00.params1.array_counts~=0
            bck00 = pa_cadmium_data_correction(bck00,cadmiumimage);
            history = [history, {['Applying background noise SANS data correction:  Bck00 = Bck00 - I_cd']}];
        end
        if bck10.params1.array_counts~=0
            bck10 = pa_cadmium_data_correction(bck10,cadmiumimage);
            history = [history, {['Applying background noise SANS data correction:  Bck10 = Bck10 - I_cd']}];
        end
        if bck11.params1.array_counts~=0
            bck11 = pa_cadmium_data_correction(bck11,cadmiumimage);
            history = [history, {['Applying background noise SANS data correction:  Bck11 = Bck11 - I_cd']}];
        end
        if bck01.params1.array_counts~=0
            bck01 = pa_cadmium_data_correction(bck01,cadmiumimage);
            history = [history, {['Applying background noise SANS data correction:  Bck01 = Bck01 - I_cd']}];
        end
    else
        history = [history, {['Cadmium: No Cadmium Subtraction']}];
    end



    %Set up output array 'foreimage';
    if status_flags.selector.fw == 12 %Sample ++ is displayed
        foreimage = pa00;
    elseif status_flags.selector.fw == 13 %Sample -+ is displayed
        foreimage = pa10;
    elseif status_flags.selector.fw == 14 %Sample -- is displayed
        foreimage = pa11;
    elseif status_flags.selector.fw == 15 %Sample +- is displayed
        foreimage = pa01;
    elseif status_flags.selector.fw == 16 %Background ++ is displayed
        foreimage = bck00;
    elseif status_flags.selector.fw == 17 %Background -+ is displayed
        foreimage = bck10;
    elseif status_flags.selector.fw == 18 %Background -- is displayed
        foreimage = bck11;
    elseif status_flags.selector.fw == 19 %Background +- is displayed
        foreimage = bck01;
    end  %}





    %         p = status_flags.pa_optimise.parameters.p; %supermirror polarisation & error
    %         pf = status_flags.pa_optimise.parameters.pf; %rf polarisation flipping & error
    %         opacity = status_flags.pa_optimise.parameters.opacity; %3He Opacity & error
    %         phe0 = status_flags.pa_optimise.parameters.phe0; %3He initial polarisation @ t0 &  error
    %         t_emptycell = status_flags.pa_optimise.parameters.t_emptycell; %transmission of empty 3He cell &  error
    %         t1 = status_flags.pa_optimise.parameters.t1; %3He time constant & error
    %         t0 = status_flags.pa_optimise.parameters.t0; %Time offset & error
    %




    if status_flags.pa_correction.pa_check ==1&&pa00.params1.array_counts~=0&&pa10.params1.array_counts~=0&&pa11.params1.array_counts~=0&&pa01.params1.array_counts~=0;
        full_pol=1
        %       Do the Spin-Leakage Correction
        %         ***** All the 4 spin components need correcting together THEN
        %     designate one as the 'foreimage' to be displayed, depending on what is
        %     chosen in the selector *****
        disp(['3He Parameters:']);
        disp(['Opacity = ' num2str(status_flags.pa_optimise.parameters.opacity(1)) ', PHe0 = ' num2str(status_flags.pa_optimise.parameters.phe0(1))]);
        disp(['Trans Empty Cell = ' num2str(status_flags.pa_optimise.parameters.t_emptycell(1)) ', T1 = ' num2str(status_flags.pa_optimise.parameters.t1(1)) ' (hrs), T0 = ' num2str(status_flags.pa_optimise.parameters.t0(1)) ' (hrs)']);
        disp(' ');

        %Determine 3He correction parameters @ time of measurement

        dpth = status_flags.selector.fd;
        real_dpth = dpth - 1;
        disp(['Depth '   ]);
        disp(['Depth '   ]);
        disp(['Depth '   ]);
        disp(['Depth '  num2str(dpth,'%5g')  ]);
        disp(['Depth '  num2str(real_dpth,'%5g')  ]);

        %if real_dpth > grasp_data(status_flags.selector.fw).dpth{nmbr}; real_dpth = 1; end
        %in this way, if no depth then status_flags.selector.fd reflects the real
        %worksheet depth.  If there is a depth, then need to subtract 1 from
        %status_flags.selector.fd.  If the result is 0 then the sum is being
        %displayed.

        % if foreimage.sum_flag ==1
        if real_dpth == 0;  %i.e. Sum is being displayed
            pa00_polarisation=pa_analyser(12);
            scat00_para=pa00_polarisation.pa_analyser.tpara_av;
            scat00_anti=pa00_polarisation.pa_analyser.tanti_av;

            pa10_polarisation=pa_analyser(13);
            scat10_para=pa10_polarisation.pa_analyser.tpara_av;
            scat10_anti=pa10_polarisation.pa_analyser.tanti_av;

            pa11_polarisation=pa_analyser(14);
            scat11_para=pa11_polarisation.pa_analyser.tpara_av;
            scat11_anti=pa11_polarisation.pa_analyser.tanti_av;

            pa01_polarisation=pa_analyser(15);
            scat01_para=pa01_polarisation.pa_analyser.tpara_av;
            scat01_anti=pa01_polarisation.pa_analyser.tanti_av;

        elseif status_flags.selector.fw == 12

            pa10_polarisation=pa_analyser(13);
            scat10_para=pa10_polarisation.pa_analyser.tpara_av;
            scat10_anti=pa10_polarisation.pa_analyser.tanti_av;

            pa11_polarisation=pa_analyser(14);
            scat11_para=pa11_polarisation.pa_analyser.tpara_av;
            scat11_anti=pa11_polarisation.pa_analyser.tanti_av;

            pa01_polarisation=pa_analyser(15);
            scat01_para=pa01_polarisation.pa_analyser.tpara_av;
            scat01_anti=pa01_polarisation.pa_analyser.tanti_av;


            pa00_polarisation=pa_analyser(12);
            scat00_para=[pa00_polarisation.pa_analyser.t_para(real_dpth), pa00_polarisation.pa_analyser.err_t_para(real_dpth)];
            scat00_anti=[pa00_polarisation.pa_analyser.t_anti(real_dpth), pa00_polarisation.pa_analyser.err_t_anti(real_dpth)];
            disp(['Depth '  num2str(real_dpth,'%5g') ' of wks'  num2str(status_flags.selector.fw,'%5g') ' no ' num2str(nmbr,'%5g') ]);
            disp(['T_para: ' num2str(pa00_polarisation.pa_analyser.t_para(real_dpth),'%5g') ' +- ' num2str(pa00_polarisation.pa_analyser.err_t_para(real_dpth),'%5g')]);
            disp(['T_anti: ' num2str(pa00_polarisation.pa_analyser.t_anti(real_dpth),'%5g') ' +- ' num2str(pa00_polarisation.pa_analyser.err_t_anti(real_dpth),'%5g')]);

        elseif status_flags.selector.fw == 13

            pa00_polarisation=pa_analyser(12);
            scat00_para=pa00_polarisation.pa_analyser.tpara_av;
            scat00_anti=pa00_polarisation.pa_analyser.tanti_av;

            pa11_polarisation=pa_analyser(14);
            scat11_para=pa11_polarisation.pa_analyser.tpara_av;
            scat11_anti=pa11_polarisation.pa_analyser.tanti_av;

            pa01_polarisation=pa_analyser(15);
            scat01_para=pa01_polarisation.pa_analyser.tpara_av;
            scat01_anti=pa01_polarisation.pa_analyser.tanti_av;


            pa10_polarisation=pa_analyser(13);
            scat10_para=[pa10_polarisation.pa_analyser.t_para(real_dpth), pa10_polarisation.pa_analyser.err_t_para(real_dpth)];
            scat10_anti=[pa10_polarisation.pa_analyser.t_anti(real_dpth), pa10_polarisation.pa_analyser.err_t_anti(real_dpth)];
            disp(['Depth '  num2str(real_dpth,'%5g') ' of '  num2str(status_flags.selector.fw,'%5g') ' no ' num2str(nmbr,'%5g') ]);
            disp(['T_para: ' num2str(pa10_polarisation.pa_analyser.t_para(real_dpth),'%5g') ' +- ' num2str(pa10_polarisation.pa_analyser.err_t_para(real_dpth),'%5g')]);
            disp(['T_anti: ' num2str(pa10_polarisation.pa_analyser.t_anti(real_dpth),'%5g') ' +- ' num2str(pa10_polarisation.pa_analyser.err_t_anti(real_dpth),'%5g')]);

        elseif status_flags.selector.fw == 14

            pa00_polarisation=pa_analyser(12);
            scat00_para=pa00_polarisation.pa_analyser.tpara_av;
            scat00_anti=pa00_polarisation.pa_analyser.tanti_av;

            pa10_polarisation=pa_analyser(13);
            scat10_para=pa10_polarisation.pa_analyser.tpara_av;
            scat10_anti=pa10_polarisation.pa_analyser.tanti_av;

            pa01_polarisation=pa_analyser(15);
            scat01_para=pa01_polarisation.pa_analyser.tpara_av;
            scat01_anti=pa01_polarisation.pa_analyser.tanti_av;


            pa11_polarisation=pa_analyser(14);
            scat11_para=[pa11_polarisation.pa_analyser.t_para(real_dpth), pa11_polarisation.pa_analyser.err_t_para(real_dpth)];
            scat11_anti=[pa11_polarisation.pa_analyser.t_anti(real_dpth), pa11_polarisation.pa_analyser.err_t_anti(real_dpth)];
            disp(['Depth '  num2str(real_dpth,'%5g') ' of '  num2str(status_flags.selector.fw,'%5g') ' no ' num2str(nmbr,'%5g') ]);
            disp(['T_para: ' num2str(pa11_polarisation.pa_analyser.t_para(real_dpth),'%5g') ' +- ' num2str(pa11_polarisation.pa_analyser.err_t_para(real_dpth),'%5g')]);
            disp(['T_anti: ' num2str(pa11_polarisation.pa_analyser.t_anti(real_dpth),'%5g') ' +- ' num2str(pa11_polarisation.pa_analyser.err_t_anti(real_dpth),'%5g')]);

        elseif status_flags.selector.fw == 15

            pa00_polarisation=pa_analyser(12);
            scat00_para=pa00_polarisation.pa_analyser.tpara_av;
            scat00_anti=pa00_polarisation.pa_analyser.tanti_av;

            pa10_polarisation=pa_analyser(13);
            scat10_para=pa10_polarisation.pa_analyser.tpara_av;
            scat10_anti=pa10_polarisation.pa_analyser.tanti_av;

            pa11_polarisation=pa_analyser(14);
            scat11_para=pa11_polarisation.pa_analyser.tpara_av;
            scat11_anti=pa11_polarisation.pa_analyser.tanti_av;


            pa01_polarisation=pa_analyser(15);
            scat01_para=[pa01_polarisation.pa_analyser.t_para(real_dpth), pa01_polarisation.pa_analyser.err_t_para(real_dpth)];
            scat01_anti=[pa01_polarisation.pa_analyser.t_anti(real_dpth), pa01_polarisation.pa_analyser.err_t_anti(real_dpth)];
            disp(['Depth '  num2str(real_dpth,'%5g') ' of '  num2str(status_flags.selector.fw,'%5g') ' no ' num2str(nmbr,'%5g') ]);
            disp(['T_para: ' num2str(pa01_polarisation.pa_analyser.t_para(real_dpth),'%5g') ' +- ' num2str(pa01_polarisation.pa_analyser.err_t_para(real_dpth),'%5g')]);
            disp(['T_anti: ' num2str(pa01_polarisation.pa_analyser.t_anti(real_dpth),'%5g') ' +- ' num2str(pa01_polarisation.pa_analyser.err_t_anti(real_dpth),'%5g')]);
        end

        sigmafore = pa_polarisation_correct(pa00, pa10, pa11, pa01, status_flags.pa_optimise.parameters.p, status_flags.pa_optimise.parameters.pf,scat00_para,scat00_anti,scat10_para,scat10_anti,scat11_para,scat11_anti,scat01_para,scat01_anti);
        for det = 1:inst_params.detectors
            detno=num2str(det);
            % if status_flags.selector.fw == 12 %Sample ++ is displayed
            pa00.(['data' detno]) = sigmafore.i00.(['data' detno]);
            pa00.(['error' detno]) = sigmafore.i00.(['error' detno]);
            %elseif status_flags.selector.fw == 13 %Sample -+ is displayed
            pa10.(['data' detno]) = sigmafore.i10.(['data' detno]);
            pa10.(['error' detno]) = sigmafore.i10.(['error' detno]);
            % elseif status_flags.selector.fw == 14 %Sample -- is displayed
            pa11.(['data' detno]) = sigmafore.i11.(['data' detno]);
            pa11.(['error' detno]) = sigmafore.i11.(['error' detno]);
            % elseif status_flags.selector.fw == 15 %Sample +- is displayed
            pa01.(['data' detno]) = sigmafore.i01.(['data' detno]);
            pa01.(['error' detno]) = sigmafore.i01.(['error' detno]);
            % end
        end

        if status_flags.pa_correction.bck_check == 1 % Do spin leackage correction for background
            if bck00.params1.array_counts~=0 && bck10.params1.array_counts~=0&& bck11.params1.array_counts~=0&& bck01.params1.array_counts~=0
                bck00_polarisation=pa_analyser(16);
                bck00_para=bck00_polarisation.pa_analyser.tpara_av;
                bck00_anti=bck00_polarisation.pa_analyser.tanti_av;

                bck10_polarisation=pa_analyser(17);
                bck10_para=bck10_polarisation.pa_analyser.tpara_av;
                bck10_anti=bck10_polarisation.pa_analyser.tanti_av;

                bck11_polarisation=pa_analyser(18);
                bck11_para=bck11_polarisation.pa_analyser.tpara_av;
                bck11_anti=bck11_polarisation.pa_analyser.tanti_av;

                bck01_polarisation=pa_analyser(19);
                bck01_para=bck01_polarisation.pa_analyser.tpara_av;
                bck01_anti=bck01_polarisation.pa_analyser.tanti_av;

                sigmaback = pa_polarisation_correct(bck00, bck10, bck11, bck01,status_flags.pa_optimise.parameters.p, status_flags.pa_optimise.parameters.pf,bck00_para,bck00_anti,bck10_para,bck10_anti,bck11_para,bck11_anti,bck01_para,bck01_anti);
                for det = 1:inst_params.detectors
                    detno=num2str(det);
                    % if status_flags.selector.fw == 16 %Background ++ is displayed
                    bck00.(['data' detno]) = sigmaback.i00.(['data' detno]);
                    bck00.(['error' detno]) = sigmaback.i00.(['error' detno]);
                    % elseif status_flags.selector.fw == 17 %Background -+ is displayed
                    bck10.(['data' detno]) = sigmaback.i10.(['data' detno]);
                    bck10.(['error' detno]) = sigmaback.i10.(['error' detno]);
                    % elseif status_flags.selector.fw == 18 %Background -- is displayed
                    bck11.(['data' detno]) = sigmaback.i11.(['data' detno]);
                    bck11.(['error' detno]) = sigmaback.i11.(['error' detno]);
                    %  elseif status_flags.selector.fw == 19 %Background +- is displayed
                    bck01.(['data' detno]) = sigmaback.i01.(['data' detno]);
                    bck01.(['error' detno]) = sigmaback.i01.(['error' detno]);
                    % end
                end
            end
        else
            disp([' ']);
            disp(['NO Spin-Leakage Corrections of background']);
        end


    elseif status_flags.pa_correction.pa_check ==1&&pa00.params1.array_counts~=0&&pa10.params1.array_counts~=0&&pa11.params1.array_counts==0&&pa01.params1.array_counts==0
        full_pol=0
        %       Do the Spin-Leakage Correction
        %    for only two scattering spin states measured
        % ATTENTION: for the reduction, it will be assumed that the two NSF and two SF states
        % are equal. Please make sure that this is reasonable for the system under
        % study.

        %     designate one as the 'foreimage' to be displayed, depending on what is
        %     chosen in the selector *****
        disp(['3He Parameters:']);
        disp(['Opacity = ' num2str(status_flags.pa_optimise.parameters.opacity(1)) ', PHe0 = ' num2str(status_flags.pa_optimise.parameters.phe0(1))]);
        disp(['Trans Empty Cell = ' num2str(status_flags.pa_optimise.parameters.t_emptycell(1)) ', T1 = ' num2str(status_flags.pa_optimise.parameters.t1(1)) ' (hrs), T0 = ' num2str(status_flags.pa_optimise.parameters.t0(1)) ' (hrs)']);
        disp(' ');

        %Determine 3He correction parameters @ time of measurement

        dpth = status_flags.selector.fd;
        real_dpth = dpth - 1;
        disp(['Depth '   ]);
        disp(['Depth '   ]);
        disp(['Depth '   ]);
        disp(['Depth '  num2str(dpth,'%5g')  ]);
        disp(['Depth '  num2str(real_dpth,'%5g')  ]);

        %if real_dpth > grasp_data(status_flags.selector.fw).dpth{nmbr}; real_dpth = 1; end
        %in this way, if no depth then status_flags.selector.fd reflects the real
        %worksheet depth.  If there is a depth, then need to subtract 1 from
        %status_flags.selector.fd.  If the result is 0 then the sum is being
        %displayed.

        % if foreimage.sum_flag ==1
        if real_dpth == 0;  %i.e. Sum is being displayed
            pa00_polarisation=pa_analyser(12);
            scat00_para=pa00_polarisation.pa_analyser.tpara_av;
            scat00_anti=pa00_polarisation.pa_analyser.tanti_av;

            pa10_polarisation=pa_analyser(13);
            scat10_para=pa10_polarisation.pa_analyser.tpara_av;
            scat10_anti=pa10_polarisation.pa_analyser.tanti_av;


        elseif status_flags.selector.fw == 12

            pa10_polarisation=pa_analyser(13);
            scat10_para=pa10_polarisation.pa_analyser.tpara_av;
            scat10_anti=pa10_polarisation.pa_analyser.tanti_av;



            pa00_polarisation=pa_analyser(12);
            scat00_para=[pa00_polarisation.pa_analyser.t_para(real_dpth), pa00_polarisation.pa_analyser.err_t_para(real_dpth)];
            scat00_anti=[pa00_polarisation.pa_analyser.t_anti(real_dpth), pa00_polarisation.pa_analyser.err_t_anti(real_dpth)];
            disp(['Depth '  num2str(real_dpth,'%5g') ' of wks'  num2str(status_flags.selector.fw,'%5g') ' no ' num2str(nmbr,'%5g') ]);
            disp(['T_para: ' num2str(pa00_polarisation.pa_analyser.t_para(real_dpth),'%5g') ' +- ' num2str(pa00_polarisation.pa_analyser.err_t_para(real_dpth),'%5g')]);
            disp(['T_anti: ' num2str(pa00_polarisation.pa_analyser.t_anti(real_dpth),'%5g') ' +- ' num2str(pa00_polarisation.pa_analyser.err_t_anti(real_dpth),'%5g')]);

        elseif status_flags.selector.fw == 13

            pa00_polarisation=pa_analyser(12);
            scat00_para=pa00_polarisation.pa_analyser.tpara_av;
            scat00_anti=pa00_polarisation.pa_analyser.tanti_av;




            pa10_polarisation=pa_analyser(13);
            scat10_para=[pa10_polarisation.pa_analyser.t_para(real_dpth), pa10_polarisation.pa_analyser.err_t_para(real_dpth)];
            scat10_anti=[pa10_polarisation.pa_analyser.t_anti(real_dpth), pa10_polarisation.pa_analyser.err_t_anti(real_dpth)];
            disp(['Depth '  num2str(real_dpth,'%5g') ' of '  num2str(status_flags.selector.fw,'%5g') ' no ' num2str(nmbr,'%5g') ]);
            disp(['T_para: ' num2str(pa10_polarisation.pa_analyser.t_para(real_dpth),'%5g') ' +- ' num2str(pa10_polarisation.pa_analyser.err_t_para(real_dpth),'%5g')]);
            disp(['T_anti: ' num2str(pa10_polarisation.pa_analyser.t_anti(real_dpth),'%5g') ' +- ' num2str(pa10_polarisation.pa_analyser.err_t_anti(real_dpth),'%5g')]);
        end

        sigmafore = pa_polarisation_correct_reduced(pa00, pa10, status_flags.pa_optimise.parameters.p, status_flags.pa_optimise.parameters.pf,scat00_para,scat00_anti,scat10_para,scat10_anti);
        for det = 1:inst_params.detectors
            detno=num2str(det);
            if status_flags.selector.fw == 12 %Sample ++ is displayed
                pa00.(['data' detno]) = sigmafore.i00.(['data' detno]);
                pa00.(['error' detno]) = sigmafore.i00.(['error' detno]);
            elseif status_flags.selector.fw == 13 %Sample -+ is displayed
                pa10.(['data' detno]) = sigmafore.i10.(['data' detno]);
                pa10.(['error' detno]) = sigmafore.i10.(['error' detno]);

            end
        end

        if status_flags.pa_correction.bck_check == 1 % Do spin leackage correction for background
            if bck00.params1.array_counts~=0 && bck10.params1.array_counts~=0
                bck00_polarisation=pa_analyser(16);
                bck00_para=bck00_polarisation.pa_analyser.tpara_av;
                bck00_anti=bck00_polarisation.pa_analyser.tanti_av;

                bck10_polarisation=pa_analyser(17);
                bck10_para=bck10_polarisation.pa_analyser.tpara_av;
                bck10_anti=bck10_polarisation.pa_analyser.tanti_av;



                sigmaback = pa_polarisation_correct_reduced(bck00, bck10, status_flags.pa_optimise.parameters.p, status_flags.pa_optimise.parameters.pf,bck00_para,bck00_anti,bck10_para,bck10_anti);
                for det = 1:inst_params.detectors
                    detno=num2str(det);
                    % if status_flags.selector.fw == 16 %Background ++ is displayed
                    bck00.(['data' detno]) = sigmaback.i00.(['data' detno]);
                    bck00.(['error' detno]) = sigmaback.i00.(['error' detno]);
                    % elseif status_flags.selector.fw == 17 %Background -+ is displayed
                    bck10.(['data' detno]) = sigmaback.i10.(['data' detno]);
                    bck10.(['error' detno]) = sigmaback.i10.(['error' detno]);
                    % end
                end
            end
        else
            disp([' ']);
            disp(['NO Spin-Leakage Corrections of background']);
        end
        disp(['Spin-Leakage Correction for only two scattering spin states measured']);
        disp(['ATTENTION: for the reduction, it will be assumed that the two NSF and two SF states are equal.']);
        disp(['Please make sure that this is reasonable for the system under study.']);
    else
        full_pol=1
        disp([' ']);
        disp(['NO Spin-Leakage Corrections of scattering']);
    end








    %%%%%Background Correction %%%%
    if status_flags.pa_correction.bck_check == 1
        %Get current transmission values, Ts, err_Ts, Te, err_Te
        [trans] = current_transmission; %These are scalar values for simple transmissions or matricies when doing transmission thickness correction.  Also gives back the current sample thickness based upon the trasmission locked indicators.
        history = [history, {[' ']}];
        history = [history, {['Transmissions:  Ts = ' num2str(trans.ts) ' +/- ' num2str(trans.err_ts) '  Te = ' num2str(trans.te) ' +/- ' num2str(trans.err_te)]}];



        %Do the SANS subtraction
        history = [history, {[' ']}];
        pa00 = pa_background_data_correction(pa00, bck00,trans);
        history = [history, {['Applying  SANS data reduction:  I00 = 1/[Ts Te] I00   - 1/[Te] Bck00 ']}];
        pa10 = pa_background_data_correction(pa10, bck10,trans);
        history = [history, {['Applying  SANS data reduction:  I10 = 1/[Ts Te] I10   - 1/[Te] Bck10 ']}];
        pa11 = pa_background_data_correction(pa11, bck11,trans);
        history = [history, {['Applying  SANS data reduction:  I11 = 1/[Ts Te] I11  - 1/[Te] Bck11 ']}];
        pa01 = pa_background_data_correction(pa01, bck01,trans);
        history = [history, {['Applying  SANS data reduction:  I01 = 1/[Ts Te] I01  - 1/[Te] Bck01 ']}];
    end

    %Set up output array 'foreimage';
    if status_flags.selector.fw == 12 %Sample ++ is displayed
        foreimage = pa00;
    elseif status_flags.selector.fw == 13 %Sample -+ is displayed
        if full_pol==1&&status_flags.pa_correction.add_check == 1
            foreimage = pa_data_add(pa10,pa01);
        else
            foreimage = pa10;
        end
    elseif status_flags.selector.fw == 14 %Sample -- is displayed
        foreimage = pa11;
    elseif status_flags.selector.fw == 15 %Sample +- is displayed
        if full_pol==1&&status_flags.pa_correction.add_check == 1
            foreimage = pa_data_add(pa10,pa01);
        else
            foreimage = pa01;
        end
    elseif status_flags.selector.fw == 16 %Background ++ is displayed
        foreimage = bck00;
    elseif status_flags.selector.fw == 17 %Background -+ is displayed
        if status_flags.pa_correction.add_check == 1
            foreimage = pa_data_add(bck10,bck01);
        else
            foreimage = bck10;
        end
    elseif status_flags.selector.fw == 18 %Background -- is displayed
        foreimage = bck11;
    elseif status_flags.selector.fw == 19 %Background +- is displayed
        if status_flags.pa_correction.add_check == 1
            foreimage = pa_data_add(bck10,bck01);
        else
            foreimage = bck01;
        end
    end  %}




    %Get Reference data
    if status_flags.selector.b_check == 1 %i.e. work with reference
        if status_flags.selector.bw == 12 %Sample ++ is displayed
            backimage = pa00;
        elseif status_flags.selector.bw == 13 %Sample -+ is displayed
            if status_flags.pa_correction.add_check == 1
                backimage = pa_data_add(pa10,pa01);
            else
                backimage = pa10;
            end
        elseif status_flags.selector.bw == 14 %Sample -- is displayed
            backimage = pa11;
        elseif status_flags.selector.bw == 15 %Sample +- is displayed
            if status_flags.pa_correction.add_check == 1
                backimage = pa_data_add(pa10,pa01);
            else
                backimage = pa01;
            end
        else
            for det = 1:inst_params.detectors
                detno=num2str(det);
                backimage.(['data' detno]) = zeros(inst_params.(['detector' detno]).pixels(2),inst_params.(['detector' detno]).pixels(1)); %y,x
                backimage.(['error' detno]) = zeros(inst_params.(['detector' detno]).pixels(2),inst_params.(['detector' detno]).pixels(1)); %y,x
            end
        end


        %***** Various data correction algorithms *****
        %Check if doing Scattering Cross Section substraction
        if strcmp(status_flags.algorithm,'standard')
            %Do the standard SANS subtraction
            foreimage = pa_data_substraction(foreimage, backimage);
            history = [history, {['Applying Substraction:  I = I - I_reference']}];
        elseif strcmp(status_flags.algorithm,'add')
            %Calculate [(I1+I0)/2]
            foreimage = pa_data_add(foreimage,backimage) ;
            history = [history, {['Applying (I_fore+I_back)/2']}];
        elseif strcmp(status_flags.algorithm,'ratio')
            %Calculate Polarisation of Scattered Neutrons:
            %P1 = [(sigma11-sigma01) / (sigma11+sigma01)]
            %P0 = [(sigma00-sigma01) / (sigma00+sigma01)]
            [foreimage] = pa_polarisation_data(foreimage, backimage);
            history = [history, {['Applying Polarisation of the scattered neutrons:  P = [(I_fore-I_back) / (I_fore+I_back)]' ]}];
        elseif strcmp(status_flags.algorithm,'divide')
            %Divide Foreground & Background worksheets
            [foreimage] = divide_data_correction(foreimage, backimage);
            history = [history, {['Applying Dividing Foreground & Background worksheets:  I_corr = [I_s / I_bck]']}];
        else
            beep
            disp('help, don''t know what to do in get_selector_result ');
        end
    else
        %DO NOT Divide Foreground & Background worksheets.  Simply provide FOREGROUND ONLY image
        history = [history, {['Foreground Image Only :  I_corr = I_s']}];
    end








    %***** Q Calculations *****
    %Beam centre (for the current foreground data)
    foreimage.cm = current_beam_centre; %Need to get the real beam centre here rather than relying on beamcentre in worksheet as it can be different due to beam centre lock
    %Add beam centre history
    history = [history, {[' ']}];
    for det = 1:inst_params.detectors
        detno=num2str(det);
        history = [history, {['Beam Centre' detno ' :  Cx = ' num2str(foreimage.cm.(['det' detno]).cm_pixels(1)) '  Cy = ' num2str(foreimage.cm.(['det' detno]).cm_pixels(2)) '       Cm Translation :  Tx = ' num2str(foreimage.cm.(['det' detno]).cm_translation(1)) '  Ty = ' num2str(foreimage.cm.(['det' detno]).cm_translation(2)) ' [mm]']}];
    end
    %Q-matrix for the foreground data
    foreimage = build_q_matrix(foreimage); %i.e. qx, qy, mod_q, q_angle, 2thetax, 2thetay, mod_2theta, solid angle





    %%%%%SANSPOL corrections%%%%%%



elseif (status_flags.selector.fw == 22 || status_flags.selector.fw == 23)

    nmbr = status_flags.selector.fn;
    dpth = status_flags.selector.fd;

    %***** Get I0-data (Flipper off) *****
    index = data_index(22);
    [i0] = retrieve_data([index,nmbr,dpth]);
    history = [history, {['***** Sanpol Worksheets I+, I- *****']}];
    history = [history, {['Subtitle:  ' i0.params1.subtitle]}];
    history = [history, {['Start: ' i0.params1.start_date '  ' i0.params1.start_time '   End: ' i0.params1.end_date '  ' i0.params1.end_time]}];
    history = [history, {[' ']}];
    %Add ++ info to History
    if i0.sum_flag ==1
        history = [history, {['Sample - (Flip off): Sum ' i0.load_string ' , Loaded: ' i0.load_string]}];
    else
        history = [history, {['Sample - (Flip off):  ' num2str(i0.params1.numor) ' , Loaded: ' i0.load_string]}];
    end
    %Data Normalisation, Attenuator & Deadtime
    i0 = normalize_data(i0);


    %***** Get I1-data (Flipper on) *****
    index = data_index(23);
    [i1] = retrieve_data([index,nmbr,dpth]);
    history = [history, {['***** Sanpol Worksheets I+, I- *****']}];
    history = [history, {['Subtitle:  ' i1.params1.subtitle]}];
    history = [history, {['Start: ' i1.params1.start_date '  ' i1.params1.start_time '   End: ' i1.params1.end_date '  ' i1.params1.end_time]}];
    history = [history, {[' ']}];
    %Add ++ info to History
    if i1.sum_flag ==1
        history = [history, {['Sample + (Flip on): Sum ' i1.load_string ' , Loaded: ' i1.load_string]}];
    else
        history = [history, {['Sample + (Flip on):  ' num2str(i1.params1.numor) ' , Loaded: ' i1.load_string]}];
    end
    %Data Normalisation, Attenuator & Deadtime
    i1 = normalize_data(i1);

    %Add the normalisation history only once
    history = [history, i0.history]; %add the normalization history (taken from i0)






    %Get Background data
    if status_flags.pa_correction.bck_check == 1 %i.e. subtract background
        index = data_index(2);
        [backimage] = retrieve_data([index,nmbr,dpth]); %background data
        %Add Background info to History
        if backimage.sum_flag ==1
            history = [history, {['Background: Sum ' backimage.load_string ' , Loaded: ' backimage.load_string]}];
        else
            history = [history, {['Background:  ' num2str(backimage.params1.numor) ' , Loaded: ' backimage.load_string]}];
        end
        %Normalise background data (only if real data, not masks etc)
        backimage = normalize_data(backimage);  %Data Normalisation, Attenuator correction and deadtime
    else
        %Create empty effective backgrounds to subtract nothing in the data correction
        for det = 1:inst_params.detectors
            detno=num2str(det);
            backimage.(['data' detno]) = zeros(inst_params.(['detector' detno]).pixels(2),inst_params.(['detector' detno]).pixels(1)); %y,x
            backimage.(['error' detno]) = zeros(inst_params.(['detector' detno]).pixels(2),inst_params.(['detector' detno]).pixels(1)); %y,x
        end
        history = [history, {['Background: No Background Subtraction']}];
    end


    %Get Cadmium data
    if status_flags.pa_correction.cad_check == 1  %i.e. use cadmium
        index = data_index(3);
        [cadmiumimage] = retrieve_data([index,nmbr,dpth]);  %cadmium data
        %Add Cadmium info to History
        if cadmiumimage.sum_flag ==1
            history = [history, {['Cadmium: Sum ' cadmiumimage.load_string ' , Loaded: ' cadmiumimage.load_string]}];
        else
            history = [history, {['Cadmium:  ' num2str(cadmiumimage.params1.numor) ' , Loaded: ' cadmiumimage.load_string]}];
        end
        %Normalise cadmium data (only if real data, not masks etc)
        cadmiumimage = normalize_data(cadmiumimage); %Data Normalisation, Attenuator correction and deadtime

        history = [history, {['Applying cadmium SANS data correction:  I = I - I_cd']}];
        i0 = pa_cadmium_data_correction(i0,cadmiumimage);
        i1 = pa_cadmium_data_correction(i1,cadmiumimage);
        backimage = pa_cadmium_data_correction(backimage,cadmiumimage);
    else
        history = [history, {['Cadmium: No Cadmium Subtraction']}];
    end



    %%%%%Background Correction %%%%

    %Get current transmission values, Ts, err_Ts, Te, err_Te
    [trans] = current_transmission; %These are scalar values for simple transmissions or matricies when doing transmission thickness correction.  Also gives back the current sample thickness based upon the trasmission locked indicators.
    history = [history, {[' ']}];
    history = [history, {['Transmissions:  Ts = ' num2str(trans.ts) ' +/- ' num2str(trans.err_ts) '  Te = ' num2str(trans.te) ' +/- ' num2str(trans.err_te)]}];

    i0 = pa_background_data_correction(i0, backimage,trans);
    i1 = pa_background_data_correction(i1, backimage,trans);


    %Do the SANSPOL Correction
    if status_flags.pa_correction.pa_check ==1&&i0.params1.array_counts~=0&&i1.params1.array_counts~=0;



        sigmafore = sanspol_correct(i0, i1, status_flags.pa_optimise.parameters.p,status_flags.pa_optimise.parameters.pf);
        for det = 1:inst_params.detectors
            detno=num2str(det);
            i0.(['data' detno]) = sigmafore.i0.(['data' detno]);
            i0.(['error' detno]) = sigmafore.i0.(['error' detno]);

            i1.(['data' detno]) = sigmafore.i1.(['data' detno]);
            i1.(['error' detno]) = sigmafore.i1.(['error' detno]);


        end

    else
        disp([' ']);
        disp(['NO SANSPOL Corrections:']);


    end



    %Set up output array 'foreimage';
    if status_flags.selector.fw == 22 %Sample I0 is displayed
        foreimage = i0;
    elseif status_flags.selector.fw == 23 %Sample I1 is displayed
        foreimage = i1;
    end  %}


    %Get Reference data
    if status_flags.selector.b_check == 1 %i.e. subtract reference
        if status_flags.selector.bw == 22 %Sample I0 is displayed
            refimage = i0;
        elseif status_flags.selector.bw == 23 %Sample I1 is displayed
            refimage = i1;
        else
            for det = 1:inst_params.detectors
                detno=num2str(det);
                refimage.(['data' detno]) = zeros(inst_params.(['detector' detno]).pixels(2),inst_params.(['detector' detno]).pixels(1)); %y,x
                refimage.(['error' detno]) = zeros(inst_params.(['detector' detno]).pixels(2),inst_params.(['detector' detno]).pixels(1)); %y,x
            end
        end



        %***** Various data representation algorithms *****
        %Check if doing substraction
        switch status_flags.algorithm
            
            case 'standard'
                %Do the standard SANS subtraction
                foreimage = pa_data_substraction(foreimage, refimage);
                history = [history, {['Applying  Substraction:  I =  I_fore   -  I_back ']}];
            case 'add'
                %Calculate [(I1+I0)/2]
                foreimage = pa_data_add(foreimage,refimage) ;
                history = [history, {['Applying (I_fore+I_back)/2']}];
            case 'ratio'
                %Calculate [(I1-I0) / (I1+I0)]
                [foreimage] = pa_polarisation_data(foreimage, refimage);
                history = [history, {['Applying [(I_fore-I_back) / (I_fore+I_back)]']}];
            case 'divide'
                %Divide Foreground & Background worksheets
                [foreimage] = divide_data_correction(foreimage, refimage);
                history = [history, {['Applying Dividing Foreground & Background worksheets:  I_corr = [I_s / I_bck]']}];
            otherwise
                beep
                disp('help, don''t know what to do in get_selector_result ');
        end
    else
        %DO NOT Divide Foreground & Background worksheets.  Simply provide FOREGROUND ONLY image
        history = [history, {['Foreground Image Only :  I_corr = I_s']}];
    end



    %***** Q Calculations *****
    %Beam centre (for the current foreground data)
    foreimage.cm = current_beam_centre; %Need to get the real beam centre here rather than relying on beamcentre in worksheet as it can be different due to beam centre lock
    %Add beam centre history
    history = [history, {[' ']}];
    for det = 1:inst_params.detectors
        detno=num2str(det);
        history = [history, {['Beam Centre' detno ' :  Cx = ' num2str(foreimage.cm.(['det' detno]).cm_pixels(1)) '  Cy = ' num2str(foreimage.cm.(['det' detno]).cm_pixels(2)) '       Cm Translation :  Tx = ' num2str(foreimage.cm.(['det' detno]).cm_translation(1)) '  Ty = ' num2str(foreimage.cm.(['det' detno]).cm_translation(2)) ' [mm]']}];
    end
    %Q-matrix for the foreground data
    foreimage = build_q_matrix(foreimage); %i.e. qx, qy, mod_q, q_angle, 2thetax, 2thetay, mod_2theta, solid angle




else %Conventional Analysis - Get foreground, background and cadmium selector data




%Get Foreground data
[foreimage] = retrieve_data('fore'); %foreground data, and flag - determines if data is 'data' or masks etc.
status_flags.selector.f_type = foreimage.type; %Flag to show what type of data is displayed, e.g. foreground,

history = [history, {['***** Sample, Backgrounds and Transmissions Data: *****']}];
history = [history, {['Subtitle:  ' foreimage.params1.subtitle]}];
history = [history, {['Start: ' foreimage.params1.start_date '  ' foreimage.params1.start_time '   End: ' foreimage.params1.end_date '  ' foreimage.params1.end_time]}];
history = [history, {[' ']}];

%Add Foreground info to History
if foreimage.sum_flag ==1
    history = [history, {['Foreground: Sum ' foreimage.load_string ' , Loaded: ' foreimage.load_string]}];
else
    history = [history, {['Foreground:  ' num2str(foreimage.params1.numor) ' , Loaded: ' foreimage.load_string]}];
end


%Normalize Data:  time, monitor, attenuators & deadtime
if foreimage.type ~= 7 && foreimage.type ~=99 %Normalise foreground data (only if real data, not masks etc)
    foreimage = normalize_data(foreimage);  %Data Normalisation, Attenuator correction and deadtime
end

%Get Background data
if status_flags.selector.b_check == 1 && (foreimage.type == 1 || foreimage.type == 2); %i.e. subtract background
    [backimage] = retrieve_data('back'); %background data
    %Add Background info to History
    if backimage.sum_flag ==1
        history = [history, {['Background: Sum ' backimage.load_string ' , Loaded: ' backimage.load_string]}];
    else
        history = [history, {['Background:  ' num2str(backimage.params1.numor) ' , Loaded: ' backimage.load_string]}];
    end
    %Normalise background data (only if real data, not masks etc)
    backimage = normalize_data(backimage);  %Data Normalisation, Attenuator correction and deadtime
else
    %Create empty effective backgrounds to subtract nothing in the data correction
    for det = 1:inst_params.detectors
        detno=num2str(det);
        backimage.(['data' detno]) = zeros(inst_params.(['detector' detno]).pixels(2),inst_params.(['detector' detno]).pixels(1)); %y,x
        backimage.(['error' detno]) = zeros(inst_params.(['detector' detno]).pixels(2),inst_params.(['detector' detno]).pixels(1)); %y,x
    end
    history = [history, {['Background: No Background Subtraction']}];
end


%Get Blocked beam data
if status_flags.selector.c_check == 1 && (foreimage.type == 1 || foreimage.type == 2); %i.e. use cadmium
    [cadmiumimage] = retrieve_data('cad'); %cadmium data
    %Add Cadmium info to History
    if cadmiumimage.sum_flag ==1
        history = [history, {['Blocked Beam: Sum ' cadmiumimage.load_string ' , Loaded: ' cadmiumimage.load_string]}];
    else
        history = [history, {['Blocked Beam:  ' num2str(cadmiumimage.params1.numor) ' , Loaded: ' cadmiumimage.load_string]}];
    end
    %Normalise cadmium data (only if real data, not masks etc)
    cadmiumimage = normalize_data(cadmiumimage); %Data Normalisation, Attenuator correction and deadtime
else
    %Create empty effective backgrounds to subtract nothing in the data correction
    for det = 1:inst_params.detectors
        detno=num2str(det);
        cadmiumimage.(['data' detno]) = zeros(inst_params.(['detector' detno]).pixels(2),inst_params.(['detector' detno]).pixels(1)); %y,x
        cadmiumimage.(['error' detno]) = zeros(inst_params.(['detector' detno]).pixels(2),inst_params.(['detector' detno]).pixels(1)); %y,x
    end
    history = [history, {['Blocked Beam: No Blocked Beam Subtraction']}];
end

%Add the normalisation history only once for the foreground data

%history = [history, {[foreimage.history{:}]}]; %add the normalization history





%***** Q Calculations *****
%Beam centre (for the current foreground data)
foreimage.cm = current_beam_centre; %Need to get the real beam centre here rather than relying on beamcentre in worksheet as it can be different due to beam centre lock
%Add beam centre history
history = [history, {[' ']}];
for det = 1:inst_params.detectors
    detno=num2str(det);
    history = [history, {['Beam Centre' detno ' :  Cx = ' num2str(foreimage.cm.(['det' detno]).cm_pixels(1)) '  Cy = ' num2str(foreimage.cm.(['det' detno]).cm_pixels(2)) '       Cm Translation :  Tx = ' num2str(foreimage.cm.(['det' detno]).cm_translation(1)) '  Ty = ' num2str(foreimage.cm.(['det' detno]).cm_translation(2)) ' [mm]']}];
end

%Q-matrix for the foreground data
foreimage = build_q_matrix(foreimage); %i.e. qx, qy, mod_q, q_angle, 2thetax, 2thetay, mod_2theta, solid angle


%Get current transmission values, Ts, err_Ts, Te, err_Te
[foreimage.trans] = current_transmission; %These are scalar values for simple transmissions or matricies when doing transmission thickness correction.  Also gives back the current sample thickness based upon the trasmission locked indicators.
history = [history, {['Transmissions:  Ts = ' num2str(foreimage.trans.ts) ' +/- ' num2str(foreimage.trans.err_ts) '  Te = ' num2str(foreimage.trans.te) ' +/- ' num2str(foreimage.trans.err_te)]}];

%Check if to make transmission thickness correction
if strcmp(status_flags.transmission.thickness_correction,'on')
    %Note:  if a thickness correction is made then new fields are added to
    %the foreimage structure containing and effective transmission for
    %every pixel for every detector
    foreimage = transmission_thickness_correction(foreimage);
end
history = [history, {['Transmissions Thickness Correction is:  ' status_flags.transmission.thickness_correction]}];

%***** Various data correction algorythms *****
%Check if doing standard SANS corrections
if (foreimage.type >= 1 && foreimage.type <= 3) %i.e. real data so do the usual SANS data correction
    
    if strcmp(status_flags.algorithm,'standard')
        %Do the standard SANS subtraction
        foreimage = standard_data_correction(foreimage, backimage, cadmiumimage);
        history = [history, {['Applying standard SANS data reduction:  I_corr = 1/[Ts Te] [I_s - I_cd]  - 1/[Te] [I_bck - I_cd]']}];
    elseif strcmp(status_flags.algorithm,'add')
        %Calculate [(I1+I0)/2]
        foreimage = pa_data_add(foreimage,backimage) ;
        history = [history, {['Applying (I_fore+I_back)/2']}];
    elseif strcmp(status_flags.algorithm,'ratio')
        %Calculate [(I1-I0) / (I1+I0)]
        [foreimage] = pa_polarisation_data(foreimage, backimage);
        history = [history, {['Applying [(I_fore-I_back) / (I_fore+I_back)]']}];
    elseif strcmp(status_flags.algorithm,'divide')
        if status_flags.selector.b_check ==1 %i.e. divide is activated in the checkbox
            %Divide Foreground & Background worksheets
            [foreimage] = divide_data_correction(foreimage, backimage);
            history = [history, {['Applying Dividing Foreground & Background worksheets:  I_corr = [I_s / I_bck]']}];
        else
            %DO NOT Divide Foreground & Background worksheets.  Simply provide FOREGROUND ONLY image
            history = [history, {['Foreground Image Only :  I_corr = I_s']}];
        end
    else
        beep
        disp('help, don''t know what to do in get_selector_result ');
    end
    
elseif foreimage.type == 7
    history = [history, {['Data Masks']}]; %Masks
    
elseif foreimage.type == 99
    history = [history, {['Detector Efficiency Map']}]; %Detector efficiency
    
elseif foreimage.type == 4 || foreimage.type == 5 || foreimage.type == 6 || foreimage.type == 8 || foreimage.type == 9 %i.e. Transmission or Direct Beam
    history = [history, {['Direct Beam or Transmission Data']}];
    history = [history, {['No Background Corrections Made']}];
end


end


%***** CALIRBATIONS ***** %***** CALIRBATIONS ***** %***** CALIRBATIONS *****
%Only do data calibrations for certain worksheet types described by flag:  i.e. fore, back, masks etc.
%AND check that the intensity matrix isn't empty
if ((foreimage.type >=1 && foreimage.type <=3 ) || (foreimage.type == 11)|| (foreimage.type >= 12 && foreimage.type <= 19)) || foreimage.type == 22 || foreimage.type == 23 && foreimage.params1.array_counts~=0
    
    %Check General Calibration options are ON
    if status_flags.calibration.calibrate_check == 1 %i.e. Calibration is switched on
        history = [history, {[' ']}];
        history = [history, {['***** Calibrations: *****']}];
        
        %Paralax Correction
        if status_flags.calibration.d22_tube_angle_check ==1
            
            if strcmp(grasp_env.inst,'ILL_d22')
                %Normalise D22 data by the detector response paralax correction
                foreimage = d22_paralax_correction(foreimage);
                history = [history, {['Data: Corrected for D22 Detector Paralax']}];
                
            elseif strcmp(grasp_env.inst,'ILL_d33')
                %Normalise D33 data by the detector response paralax correction
                foreimage = d33_paralax_correction(foreimage);
                history = [history, {['Data: Corrected for D33 Detector Paralax']}];
            end
        end
        
        %***** Divide by Detector Efficiency *****
        if status_flags.calibration.det_eff_check == 1
            %also returns a 'nan_mask' in the data structure
            foreimage = divide_detector_efficiency(foreimage);
            history = [history, {['Data: Corrected for Detector Efficiency']}];
        end
        
        %***** Divide by relative detector efficiency for multiple detectors e.g. D33 *****
        if inst_params.detectors >1
            if status_flags.calibration.relative_det_eff == 1
                foreimage = divide_relative_efficiency(foreimage);
                history = [history, {['Data: Corrected for Relative Detector Efficiency (variation between detector panels)']}];
            end
        end
        
        %***** Direct Beam Calibration *****
        if strcmp(status_flags.calibration.method,'beam') %beam, water or none
            [foreimage, history] = direct_beam_calibration(foreimage,history);
        elseif strcmp(status_flags.calibration.method,'water')
            [foreimage, history] = water_calibration(foreimage,history);
        end
    end
end

%***** Masking *****
%Prepare the final mask for data from each detector

%Final Mask is stored in foreimage as .mask1, mask2 etc. for each detector
for det = 1:inst_params.detectors
    detno=num2str(det);
    detector_params = inst_params.(['detector' detno]);
    foreimage.(['mask' detno]) = ones(detector_params.pixels(2),detector_params.pixels(1),'logical');
    
    %***** Instrument Mask - brought in the foreimage.imask from retrieve_data *****
    if status_flags.display.imask.check == 1 %apply instrument mask (this is not a user option, can only be controlled by this parameter)
        foreimage.(['mask' detno]) = foreimage.(['mask' detno]) .* foreimage.(['imask' detno]);
        if det ==1; history = [history, {['Applying Default Instrument Mask']}]; end
    else
        if det ==1; history = [history, {['No Default Instrument Mask']}]; end
    end
    
    %***** User Mask - brought in the foreimage.umask from retrieve_data *****
    if status_flags.display.mask.check == 1 %apply user mask
        foreimage.(['mask' detno]) = foreimage.(['mask' detno]) .* foreimage.(['umask' detno]);
        if det==1; history = [history, {['Applying User Defined Mask']}]; end
    end
    
    %Add the Nan or Inf mask, if it exists
    if isfield(foreimage,['nan_mask' detno])
        foreimage.(['mask' detno]) = foreimage.(['mask' detno]) .* foreimage.(['nan_mask' detno]);
        if det ==1; history = [history, {['Applying NanInf Mask']}]; end
    end
    
    %Add the Zero Mask, if it exists
    if isfield(foreimage,['zero_mask' detno])
        foreimage.(['mask' detno]) = foreimage.(['mask' detno]) .* foreimage.(['zero_mask' detno]);
        if det ==1; history = [history, {['Applying Zeros Mask']}]; end
    end
    
    if status_flags.display.mask.auto_check == 1
        if det ==1 %Main detector only for the moment
            %Automask
            current_image = foreimage.(['data' detno]);

            %Normalise Image
            image_max = max(max(current_image));
            image_min = min(min(current_image));
            current_image_norm = (current_image-image_min) / image_max;
            
            %Take derivative of image to find gradients in x and y
            [image_grad_x,image_grad_y] = gradient(current_image_norm);
            image_grad_x = abs(image_grad_x); image_grad_y = abs(image_grad_y);
            %Normalise to max gradient
            image_grad_x = image_grad_x / max(max(image_grad_x));
            image_grad_y = image_grad_y / max(max(image_grad_y));

            %x-direction
            [temp_x,~] = find(abs(image_grad_x) > status_flags.display.mask.auto_threshold);
            temp_mask_x = ones(detector_params.pixels(2),detector_params.pixels(1),'logical');
            temp_mask_x(min(temp_x):max(temp_x),:) = 0;
            
            %y-direction
            [~,temp_y] = find(abs(image_grad_y) > status_flags.display.mask.auto_threshold);
            temp_mask_y = ones(detector_params.pixels(2),detector_params.pixels(1),'logical');
            temp_mask_y(:,min(temp_y):max(temp_y)) = 0;
            
            %Take logical OR
            temp_mask = temp_mask_x | temp_mask_y;
            foreimage.(['mask' detno]) = foreimage.(['mask' detno]) .* temp_mask;
        end
    end
    
    
end


%***** End Masking *****


%***** Add final History to the 'intensity' structure *****
history = [history, {['Intensity units are:  ' foreimage.units]}];
history = [history, {[' ']}];

foreimage.history = history;
