function sans_instrument_model(inst)

global inst_config
global inst_component
global sans_instrument_model_handles
global sans_instrument_model_params
global sample_config
global background_config
global cadmium_config

if nargin ==0
    inst = 'ILL_d33'; %Default instrument
end

set(0,'defaultfigurepapertype','a4');
colordef black; %Window bacground

%***** Load up all the scattering models configurations *****
load_scattering_models;




%***** Program Parameters *****
sans_instrument_model_params.data_dir = [];
sans_instrument_model_params.font = 'Arial';
sans_instrument_model_params.fontsize = 8;
sans_instrument_model_params.background_color = [0.1000    0.2600    0.2100];
sans_instrument_model_params.foreground_color = [1 1 1];
sans_instrument_model_params.hold_images_check = 0;
sans_instrument_model_params.hold_count = 1;
sans_instrument_model_params.hold_stagger_plots = 0;
sans_instrument_model_params.det_image = 'Detector_Image';
sans_instrument_model_params.det_image_log_check = 1;
sans_instrument_model_params.det_image_tof_frame = 1;
sans_instrument_model_params.col_in_color = [0.2, 0.4, 1];
sans_instrument_model_params.col_out_color = [1, 0, 0];
sans_instrument_model_params.det_image_tof_frame = 1;
sans_instrument_model_params.auto_calculate = 0; %1 = on, 0 = off
sans_instrument_model_params.measurement_time = 600; %seconds
sans_instrument_model_params.sample_thickness = 0.1; %cm
sans_instrument_model_params.sample_area = 1; %cm^2
sans_instrument_model_params.monitor = 0; %Some beam monitor fraction of the incoming beam intensity
sans_instrument_model_params.poissonian_noise_check = 1;
sans_instrument_model_params.divergence_check = 0;
sans_instrument_model_params.delta_lambda_check = 0;
sans_instrument_model_params.smearing_pos = 4; %position on the popupmenu
sans_instrument_model_params.smearing = 10; %Smearing itterations
sans_instrument_model_params.subtitle = 'Sample';
sans_instrument_model_params.square_tri_selector_check = 0;

%***** Initialise Handles *****
sans_instrument_model_handles.iq_plot1 = [];
sans_instrument_model_handles.iq_plot2 = [];
sans_instrument_model_handles.iq_plot3 = [];
sans_instrument_model_handles.iq_plot4 = [];
sans_instrument_model_handles.iq_plot5 = [];
sans_instrument_model_handles.q_boundaries1 = [];
sans_instrument_model_handles.q_boundaries2 = [];
sans_instrument_model_handles.q_boundaries3 = [];
sans_instrument_model_handles.q_boundaries4 = [];
sans_instrument_model_handles.q_boundaries5 = [];
sans_instrument_model_handles.q_resolution1 = [];
sans_instrument_model_handles.q_resolution2 = [];
sans_instrument_model_handles.q_resolution3 = [];
sans_instrument_model_handles.q_resolution4 = [];
sans_instrument_model_handles.q_resolution5 = [];
sans_instrument_model_handles.q_resolution6 = [];
sans_instrument_model_handles.q_resolution7 = [];
sans_instrument_model_handles.q_resolution8 = [];
sans_instrument_model_handles.q_resolution9 = [];
sans_instrument_model_handles.q_resolution10 = [];
sans_instrument_model_handles.q_resolution11 = [];
sans_instrument_model_handles.scattering_model_gui = [];
sans_instrument_model_handles.background_model_gui = [];
sans_instrument_model_handles.cadmium_model_gui = [];


%***** Load the Instrument Configuration *****
if strcmp(inst,'ILL_d22')
    [inst_config, inst_component] = d22_model_component;
elseif strcmp(inst,'ILL_d11')
    [inst_config, inst_component] = d11_model_component;
% elseif strcmp(inst,'SINQ_SANS_I')
%     [inst_config, inst_component] = sinq_sans1_model_component;
% elseif strcmp(inst,'SINQ_SANS_II')
%     [inst_config, inst_component] = sinq_sans2_model_component;
% elseif strcmp(inst,'NIST_ng3')
%     [inst_config, inst_component] = nist_ng3_model_component;
% elseif strcmp(inst,'NIST_ng7')
%     [inst_config, inst_component] = nist_ng7_model_component;
% elseif strcmp(inst,'ORNL_cg2')
%     [inst_config, inst_component] = ornl_cg2_model_component;
else %D33
    [inst_config, inst_component] = d33_model_component;
    inst = 'ILL_d33';

end
inst_config.inst = inst;


%***** Draw Instrument *****
%Open figure window
sans_instrument_model_handles.detector_model_figure = figure('units','normalized', 'position',[0.05 0.1 0.9 0.8],'color',sans_instrument_model_params.background_color,'toolbar','figure','name',['Instrument Configuration:  ' inst]);

%Draw Casemate & Collimation Axes
sans_instrument_model_params.collimation_view_axes = [0.0350    0.7456    0.8586    0.2000];
sans_instrument_model_handles.casemate_collimation_view = axes('position',sans_instrument_model_params.collimation_view_axes);
%find axis limits
col_xlim = 0;
det_xlim = 0;
for n = 1:length(inst_component)
    if (inst_component(n).position + inst_component(n).length) < col_xlim
        col_xlim = (inst_component(n).position + inst_component(n).length);
    end
    if strfind(inst_component(n).name,'Detector')
        if inst_component(n).parameters.position_max > det_xlim; det_xlim = 1.1 * inst_component(n).parameters.position_max; end
    end
end
sans_instrument_model_params.collimation_axes_limits = [col_xlim, 0, -0.25, +0.25];
axis(sans_instrument_model_handles.casemate_collimation_view,sans_instrument_model_params.collimation_axes_limits);

%Draw Detector Side View Axes
sans_instrument_model_params.det_side_view_axes = [0.2    0.45    0.6    0.2];
sans_instrument_model_handles.det_side_view = axes('position',sans_instrument_model_params.det_side_view_axes);
sans_instrument_model_params.det_side_axes_limits = [0, det_xlim, -inst_config.tube_diameter/2, +inst_config.tube_diameter/2];
axis(sans_instrument_model_handles.det_side_view,sans_instrument_model_params.det_side_axes_limits);
%Tube boundary
rectangle('position',[0, -inst_config.tube_diameter/2, inst_config.tube_length, inst_config.tube_diameter],'edgecolor','red');

%Draw Detector Front View Axes
sans_instrument_model_params.det_front_view = [0    0.45    0.2    0.2];
sans_instrument_model_handles.det_front_view = axes('position',sans_instrument_model_params.det_front_view);
sans_instrument_model_params.det_front_axes_limits = [-inst_config.tube_diameter/2, +inst_config.tube_diameter/2, -inst_config.tube_diameter/2, +inst_config.tube_diameter/2];
axis(sans_instrument_model_handles.det_front_view,sans_instrument_model_params.det_front_axes_limits);
axis square

%Draw Tube boundary
angle = 0:0.1:2*pi;
radius = inst_config.tube_diameter/2;
[x,y] = pol2cart(angle,radius);
axes(sans_instrument_model_handles.det_front_view);
h=line(x,y);
set(h,'color','red');

%Draw Instrument Obejcts
collimation_string = {}; collimation_counter = 0;
chopper_positions_store = [];
for n = 1:length(inst_component)
    x0 = inst_component(n).position;

    if x0<=0   %Collimation Side
        y0 = inst_component(n).drawcntr(2) - inst_component(n).drawdim(2)/2 ;
        dx = inst_component(n).length;
        if dx ==0; dx = 0.1; end
        dy = inst_component(n).drawdim(2);
        color = inst_component(n).color;
        if dx <0; x0 = x0 + dx; dx = -dx; end

        axes(sans_instrument_model_handles.casemate_collimation_view);
        inst_component(n).handle = rectangle('position',[x0, y0, dx, dy],'facecolor',color);

        %Special Instrument Controls
        %Apertures
        if findstr(inst_component(n).name,'Aperture')
            aperture_string = [];
            %Build Aperture Selector
            for m = 1:length(inst_component(n).xydim) %Build aperture description string for popup
                if length(inst_component(n).xydim{m}) == 1 %Circular
                    aperture_string{m} = [num2str(m) ': ' num2str(inst_component(n).xydim{m}*1000) 'mm Dia'];
                elseif length(inst_component(n).xydim{m}) == 2 %rectangular or square
                    aperture_string{m} = [num2str(m) ': ' num2str(inst_component(n).xydim{m}(1)*1000) 'x' num2str(inst_component(n).xydim{m}(2)*1000) ' mm'];
                end
            end
            %Place Aperture Popup
            position = sans_instrument_model_params.collimation_view_axes(1)+sans_instrument_model_params.collimation_view_axes(3)+inst_component(n).position*0.9/(sans_instrument_model_params.collimation_axes_limits(3)-sans_instrument_model_params.collimation_axes_limits(1));
            uicontrol('units','normalized','Position',[position    0.975   0.06    0.018],'ForegroundColor',sans_instrument_model_params.foreground_color,'BackgroundColor',sans_instrument_model_params.background_color,'Style','text','string','Aperture','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize);
            inst_component(n).ui_handle = uicontrol('units','normalized','Position',[position    0.9522    0.06   0.018],'Style','popupmenu','string',aperture_string,'fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'value',inst_component(n).value,'userdata',n,'enable','off','callback','sans_instrument_model_callbacks(''app_popup'')');
        end

        if findstr(inst_component(n).name,'Chopper:')
            chopper_positions_store = [chopper_positions_store, inst_component(n).position];
            
            %Number choppers
            chopper_number_str = strtok(inst_component(n).name,'Chopper: ');
            chopper_number = str2num(chopper_number_str);
            text(x0, 0, chopper_number_str,'fontweight','bold','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize)
            %Make blank chopper parameters
            if isodd(chopper_number); y0 = -0.1; else y0 = -0.2; end
            temp = text(x0,y0,'','fontweight','bold','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize);
            sans_instrument_model_handles = setfield(sans_instrument_model_handles,['chopper' num2str(chopper_number) 'text'],temp);
        end

        %Build Collimation Selector String
        if findstr(inst_component(n).name,'Collimation')
            collimation_counter = collimation_counter + (-inst_component(n).length);
            collimation_string = [collimation_string, {num2str(collimation_counter)}];
        end

    else %Detector side
        if findstr(inst_component(n).name,'Detector')
            for m = 1:inst_component(n).pannels
                pannel_struct = getfield(inst_component(n),['pannel' num2str(m)]);
                x00 = x0 + pannel_struct.relative_position;
                if strcmp(pannel_struct.name,'Top') || strcmp(pannel_struct.name,'Bottom')
                    y0 = pannel_struct.drawcntr(2) - pannel_struct.drawdim(2)/2 + pannel_struct.parameters.opening(2);
                else
                    y0 = pannel_struct.drawcntr(2) - pannel_struct.drawdim(2)/2;
                end

                dx = pannel_struct.length;
                if dx ==0; dx = 0.1; end
                dy = pannel_struct.drawdim(2);
                color = pannel_struct.color;
                if dx <0; x0 = x0 + dx; dx = -dx; end

                %Plot Detector Side View
                axes(sans_instrument_model_handles.det_side_view);
                pannel_struct.draw_handle_side_view = rectangle('position',[x00, y0, dx, dy],'facecolor',color);

                %Plot Detector Front View
                detector_size = pannel_struct.parameters.pixels.* pannel_struct.parameters.pixel_size;
                axes(sans_instrument_model_handles.det_front_view);
                pannel_struct.draw_handle_front_view = rectangle('position',[-detector_size(1)/2+pannel_struct.parameters.opening(1), -detector_size(2)/2+pannel_struct.parameters.opening(2), detector_size(1), detector_size(2)],'facecolor',pannel_struct.color);

                %Special D33 Pannel moving sliders
                if findstr(pannel_struct.name,'Top')
                    pannel_struct.pannel_slider_handle = uicontrol('units','normalized','Position',[0.17    0.5133    0.0065    0.1372],'Style','slider','Tag','det1_slider','Value',1,'userdata',[n, m],'callback','sans_instrument_model_callbacks(''pannel_slider'')');
                    pannel_struct.pannel_editbox_handle = uicontrol('units','normalized','Position',[0.17    0.6556    0.0200    0.0200],'Style','edit','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'userdata',[n, m],'callback','sans_instrument_model_callbacks(''pannel_edit'')');
                    %group opening checkbox
                    inst_component(n).pannel_group_handle = uicontrol('units','normalized','position',[0.0079    0.6589    0.0200    0.0200],'style','checkbox','value',inst_component(n).pannel_group,'userdata',[n, m],'callback','sans_instrument_model_callbacks(''pannel_group_check'');');
                elseif findstr(pannel_struct.name,'Bottom')
                    pannel_struct.pannel_slider_handle = uicontrol('units','normalized','Position',[0.007    0.4477    0.0065    0.1372],'Style','slider','Tag','det1_slider','Value',1,'userdata',[n, m],'callback','sans_instrument_model_callbacks(''pannel_slider'')');
                    pannel_struct.pannel_editbox_handle = uicontrol('units','normalized','Position',[0.007    0.6044    0.0200    0.0200],'Style','edit','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'userdata',[n, m],'callback','sans_instrument_model_callbacks(''pannel_edit'')');
                elseif findstr(pannel_struct.name,'Left')
                    pannel_struct.pannel_slider_handle = uicontrol('units','normalized','Position',[0.0350    0.4128    0.0986    0.0100],'Style','slider','Tag','det1_slider','Value',1,'userdata',[n, m],'callback','sans_instrument_model_callbacks(''pannel_slider'')');
                    pannel_struct.pannel_editbox_handle = uicontrol('units','normalized','Position',[0.1379    0.4022    0.0200    0.0200],'Style','edit','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'userdata',[n,m],'callback','sans_instrument_model_callbacks(''pannel_edit'')');
                elseif findstr(pannel_struct.name,'Right')
                    pannel_struct.pannel_slider_handle = uicontrol('units','normalized','Position',[0.0657    0.6594    0.0986    0.0100],'Style','slider','Tag','det1_slider','Value',1,'userdata',[n, m],'callback','sans_instrument_model_callbacks(''pannel_slider'')');
                    pannel_struct.pannel_editbox_handle = uicontrol('units','normalized','Position',[0.04    0.6556    0.0200    0.0200],'Style','edit','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'userdata',[n, m],'callback','sans_instrument_model_callbacks(''pannel_edit'')');
                end
                
                %Special D22 Detector Offset
                if findstr(pannel_struct.name,'Rear')
                    if isfield(pannel_struct.parameters,'centre_translation_max')
                    pannel_struct.pannel_slider_handle = uicontrol('units','normalized','Position',[0.0350    0.37   0.0986    0.0100],'Style','slider','Tag','det__offset_slider','Value',0,'userdata',[n, m],'callback','sans_instrument_model_callbacks(''det_offset_slider'')');
                    pannel_struct.pannel_editbox_handle = uicontrol('units','normalized','Position',[0.1379    0.36    0.0200    0.0200],'Style','edit','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'userdata',[n,m],'callback','sans_instrument_model_callbacks(''det_offset_edit'')');
                    end
                end

                %Put the modified pannel structur back into the instrument component
                inst_component(n) = setfield(inst_component(n),['pannel' num2str(m)], pannel_struct);
            end

            %Build Detector Position Slider for Each Detector
            inst_component(n).gui_handle_slider = uicontrol('units','normalized','Position',[ 0.2    0.4-(0.01*(m-1))    0.6    0.01],'Style','slider','Value',1,'userdata',n,'callback','sans_instrument_model_callbacks(''det_slider'')');
            inst_component(n).gui_handle_editbox = uicontrol('units','normalized','Position',[ 0.175   0.4-(0.01*(m-1))    0.02    0.018],'Style','edit','userdata',n,'fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'callback','sans_instrument_model_callbacks(''det_edit'')');
        end
    end
end

%Build Collimation Selector
uicontrol('units','normalized','Position',[0.5    0.7    0.09    0.0200],'ForegroundColor',sans_instrument_model_params.foreground_color,'BackgroundColor',sans_instrument_model_params.background_color,'Style','text','string','Collimation Length (m)','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize);
sans_instrument_model_handles.col_length_popup = uicontrol('units','normalized','Position',[0.6    0.7    0.0350    0.0200],'Style','popupmenu','string',collimation_string,'value',1,'userdata',' ','callback','sans_instrument_model_callbacks(''col_length_popup'')');

%Build Wavelength Selectors, TOF & Edit Boxes
sans_instrument_model_handles.wavelength_mono_tof = uicontrol('units','normalized','Position',[0.005    0.975    0.035    0.018],'Style','popupmenu','string',inst_config.wav_modes,'value',1,'callback','sans_instrument_model_callbacks(''mono_tof'')');

for n = 1:length(inst_config.wav_modes)
    if strfind(inst_config.wav_modes{n},'Mono')
        %Mono Wavelength edit boxs
        sans_instrument_model_handles.wavelength_text1 = uicontrol('units','normalized','Position',[0.05    0.975   0.02    0.018],'ForegroundColor',sans_instrument_model_params.foreground_color,'BackgroundColor',sans_instrument_model_params.background_color,'Style','text','string','l','fontname','symbol','fontsize',sans_instrument_model_params.fontsize);
        sans_instrument_model_handles.wavelength_edit = uicontrol('units','normalized','Position',[0.05    0.9522    0.0200    0.018],'Style','edit','string',inst_config.mono_wav,'callback','sans_instrument_model_callbacks(''selector_wavelength'')');
        sans_instrument_model_handles.wavelength_text2 = uicontrol('units','normalized','Position',[0.072    0.975   0.02    0.018],'ForegroundColor',sans_instrument_model_params.foreground_color,'BackgroundColor',sans_instrument_model_params.background_color,'Style','text','string','Dl%','fontname','symbol','fontsize',sans_instrument_model_params.fontsize);
        sans_instrument_model_handles.wavelength_res_edit = uicontrol('units','normalized','Position',[0.072    0.9522    0.0200    0.018],'Style','edit','string',inst_config.mono_dwav,'callback','sans_instrument_model_callbacks(''selector_wavelength_res'')');
    end

    if strfind(inst_config.wav_modes{n},'TOF')
        %TOF Wavelength edit boxes
        sans_instrument_model_handles.tof_text1 = uicontrol('units','normalized','Position',[0.05    0.975   0.02    0.018],'ForegroundColor',sans_instrument_model_params.foreground_color,'BackgroundColor',sans_instrument_model_params.background_color,'Style','text','string','Min','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize);
        sans_instrument_model_handles.tof_min_edit = uicontrol('units','normalized','Position',[0.05    0.9522    0.0200    0.018],'Style','edit','string',inst_config.tof_wav_min,'callback','sans_instrument_model_callbacks(''tof_lambda_min'')');
        sans_instrument_model_handles.tof_text2 = uicontrol('units','normalized','Position',[0.072    0.975   0.02    0.018],'ForegroundColor',sans_instrument_model_params.foreground_color,'BackgroundColor',sans_instrument_model_params.background_color,'Style','text','string','Max','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize);
        sans_instrument_model_handles.tof_max_edit = uicontrol('units','normalized','Position',[0.072    0.9522    0.0200    0.018],'Style','edit','string',inst_config.tof_wav_max,'callback','sans_instrument_model_callbacks(''tof_lambda_max'')');

        res_string = {'1-4','1-3','1-2','2-4','2-3','3-4'};
        sans_instrument_model_handles.tof_text3 = uicontrol('units','normalized','Position',[0.1    0.975   0.04    0.018],'ForegroundColor',sans_instrument_model_params.foreground_color,'BackgroundColor',sans_instrument_model_params.background_color,'Style','text','string','Resolution','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize);
        sans_instrument_model_handles.tof_res_popup = uicontrol('units','normalized','Position',[0.1    0.9522    0.04    0.018],'Style','popupmenu','string',res_string,'value',inst_config.tof_resolution_setting,'callback','sans_instrument_model_callbacks(''tof_res'')');
        sans_instrument_model_handles.tof_spacing_text = uicontrol('units','normalized','Position',[0.14    0.95   0.03    0.018],'ForegroundColor',sans_instrument_model_params.foreground_color,'BackgroundColor',sans_instrument_model_params.background_color,'Style','text','string','x','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize);
        sans_instrument_model_handles.tof_resolution_rear_text = uicontrol('units','normalized','Position',[0.17    0.96   0.06    0.018],'ForegroundColor',sans_instrument_model_params.foreground_color,'BackgroundColor',sans_instrument_model_params.background_color,'Style','text','string','x','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize);
        sans_instrument_model_handles.tof_resolution_front_text = uicontrol('units','normalized','Position',[0.17    0.945   0.06    0.018],'ForegroundColor',sans_instrument_model_params.foreground_color,'BackgroundColor',sans_instrument_model_params.background_color,'Style','text','string','x','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize);

        %Calculate TOF Parameters
        %For smallest to largest spacing (going backwards)
        temp = sort(abs(diff(chopper_positions_store)),'ascend');
        a = temp(1); b = temp(2); c = temp(3);

        inst_config.chopper_spacing_matrix = [a+b+c,b+c,c,a+b,b,a];
        inst_config.chopper_spacing_offset_matrix = [0,a,b+a,0,a,0];%To take into accout the extra flight path due to the positioning of the choppers and which pair is actually being used
    end
end


%***** Open Scattering Data Plot *****
sans_instrument_model_handles.scatter_data =axes;
set(sans_instrument_model_handles.scatter_data,'units','normalized','position',[0.78  0.058  0.2 0.25]);
set(sans_instrument_model_handles.scatter_data,'yscale','log','xscale','log');
xlabel(sans_instrument_model_handles.scatter_data,'|q| A^-1');
ylabel(sans_instrument_model_handles.scatter_data,'Intensity [AU]');
title(sans_instrument_model_handles.scatter_data,'Model Scattering Data');

%***** Open q range Plot *****
sans_instrument_model_handles.q_boundaries = axes;
set(sans_instrument_model_handles.q_boundaries,'units','normalized','position',[0.20  0.08  0.13  0.22]);
set(sans_instrument_model_handles.q_boundaries,'xscale','log');
xlabel(sans_instrument_model_handles.q_boundaries,'|q| A^-1');
ylabel(sans_instrument_model_handles.q_boundaries,'');
title(sans_instrument_model_handles.q_boundaries,'q-range')

%***** Open q-resolution Plot *****
sans_instrument_model_handles.inst_resolution = axes;
set(sans_instrument_model_handles.inst_resolution,'units','normalized','position',[0.04   0.08  0.13  0.22]);
xlabel(sans_instrument_model_handles.inst_resolution,'|q| A^-1');
ylabel(sans_instrument_model_handles.inst_resolution,'Dq/q, Dl/l, Dth/th');
title('q-resolution')


%**** Open Detector(s) image *****
%Detector image popup
for n = 1:length(inst_component)
    if findstr(inst_component(n).name,'Detector')
        for m = 1:inst_component(n).pannels
            pannel_struct = getfield(inst_component(n),['pannel' num2str(m)]);
            if findstr(pannel_struct.name,'Rear')
                pannel_struct.axis_2d_handle = axes;
                pannel_struct.pcolor_2d_handle = pcolor(rand(pannel_struct.parameters.pixels(2),pannel_struct.parameters.pixels(1)));
                pannel_struct.pcolor_context_menu = uicontextmenu;
                pannel_struct.pcolor_context_menu_save_data = uimenu(pannel_struct.pcolor_context_menu,'label','Export Detector Data','callback','sans_instrument_model_callbacks(''export_2d_data'')');
                set(pannel_struct.pcolor_2d_handle,'uicontextmenu',pannel_struct.pcolor_context_menu);
                pannel_struct.pcolor_axes_2d_handle = get(pannel_struct.pcolor_2d_handle,'parent');
                shading interp; axis off;
                axis([0,pannel_struct.parameters.pixels(1),0,pannel_struct.parameters.pixels(2)]);
                set(pannel_struct.pcolor_axes_2d_handle,'units','normalized','position',[0.85, 0.46, 0.10, 0.18]);
                inst_component(n) = setfield(inst_component(n),['pannel' num2str(m)], pannel_struct); %Set the modified pannel struct back to the inst_component structure
            end
            if findstr(pannel_struct.name,'Left')
                pannel_struct.axis_2d_handle = axes;
                pannel_struct.pcolor_2d_handle = pcolor(rand(pannel_struct.parameters.pixels(2),pannel_struct.parameters.pixels(1)));
                pannel_struct.pcolor_axes_2d_handle = get(pannel_struct.pcolor_2d_handle,'parent');
                shading interp; axis off;
                axis([0,pannel_struct.parameters.pixels(1),0,pannel_struct.parameters.pixels(2)]);
                set(pannel_struct.pcolor_axes_2d_handle,'units','normalized','position',[0.823, 0.46, 0.025, 0.18]);
                inst_component(n) = setfield(inst_component(n),['pannel' num2str(m)], pannel_struct); %Set the modified pannel struct back to the inst_component structure
            end
            if findstr(pannel_struct.name,'Right')
                pannel_struct.axis_2d_handle = axes;
                pannel_struct.pcolor_2d_handle = pcolor(rand(pannel_struct.parameters.pixels(2),pannel_struct.parameters.pixels(1)));
                pannel_struct.pcolor_axes_2d_handle = get(pannel_struct.pcolor_2d_handle,'parent');
                shading interp; axis off;
                axis([0,pannel_struct.parameters.pixels(1),0,pannel_struct.parameters.pixels(2)]);
                set(pannel_struct.pcolor_axes_2d_handle,'units','normalized','position',[0.952, 0.46, 0.025, 0.18]);
                inst_component(n) = setfield(inst_component(n),['pannel' num2str(m)], pannel_struct); %Set the modified pannel struct back to the inst_component structure
            end
            if findstr(pannel_struct.name,'Top')
                pannel_struct.axis_2d_handle = axes;
                pannel_struct.pcolor_2d_handle = pcolor(rand(pannel_struct.parameters.pixels(2),pannel_struct.parameters.pixels(1)));
                pannel_struct.pcolor_axes_2d_handle = get(pannel_struct.pcolor_2d_handle,'parent');
                shading interp; axis off;
                axis([0,pannel_struct.parameters.pixels(1),0,pannel_struct.parameters.pixels(2)]);
                set(pannel_struct.pcolor_axes_2d_handle,'units','normalized','position',[0.85, 0.642, 0.10, 0.045]);
                inst_component(n) = setfield(inst_component(n),['pannel' num2str(m)], pannel_struct); %Set the modified pannel struct back to the inst_component structure
            end
            if findstr(pannel_struct.name,'Bottom')
                pannel_struct.axis_2d_handle = axes;
                pannel_struct.pcolor_2d_handle = pcolor(rand(pannel_struct.parameters.pixels(2),pannel_struct.parameters.pixels(1)));
                pannel_struct.pcolor_axes_2d_handle = get(pannel_struct.pcolor_2d_handle,'parent');
                shading interp; axis off;
                axis([0,pannel_struct.parameters.pixels(1),0,pannel_struct.parameters.pixels(2)]);
                set(pannel_struct.pcolor_axes_2d_handle,'units','normalized','position',[0.85, 0.413, 0.10, 0.045]);
                inst_component(n) = setfield(inst_component(n),['pannel' num2str(m)], pannel_struct); %Set the modified pannel struct back to the inst_component structure
            end
        end
    end
end


%Build 2D image selector
det_image_string = {'Mod_q' 'q_x' 'q_y' 'q_Angle' 'Solid_Angle' 'Detector_Image' 'Direct_Beam'};
value = find(strcmp(det_image_string,sans_instrument_model_params.det_image));
if isempty(value); value = 1; sans_instrument_model_params.det_image = 'Mod_q'; end
sans_instrument_model_handles.detector_image_popup = uicontrol('units','normalized','Position',[0.8957    0.3933    0.1000    0.018],'Style','popupmenu','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'string',det_image_string,'value',value,'callback','sans_instrument_model_callbacks(''det_image_popup'')');

%Wavelength selector to display
sans_instrument_model_handles.detector_image_tof_wav = uicontrol('units','normalized','Position',[0.8957    0.3533    0.1000    0.018],'Style','popupmenu','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'string',' ','value',1,'callback','sans_instrument_model_callbacks(''det_image_tof_wav'')');

%Log detector image checkbox
sans_instrument_model_handles.log_detector_image_check = uicontrol('units','normalized','Position',[0.86    0.3933    0.03    0.018],'Style','checkbox','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'string','Log:','value',sans_instrument_model_params.det_image_log_check,'callback','sans_instrument_model_callbacks(''det_image_log_check'')');

%Hold Graphs CheckBox
sans_instrument_model_handles.hold_image_check = uicontrol('units','normalized','Position',[0.88    0.01    0.04    0.018],'Style','checkbox','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'string','Hold:','value',sans_instrument_model_params.hold_images_check,'callback','sans_instrument_model_callbacks(''hold_images_check'')');
if sans_instrument_model_params.hold_images_check ==1;
    enable = 'on';
else
    enable = 'off';
end

%Plot Stagger checkBox
sans_instrument_model_handles.hold_image_stagger_check = uicontrol('units','normalized','Position',[0.93    0.01    0.05    0.018],'Style','checkbox','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'string','Stagger:','value',sans_instrument_model_params.hold_stagger_plots,'enable',enable,'callback','sans_instrument_model_callbacks(''hold_images_stagger'')');


%Build Scattering Model List
fns_string = [];
for n = 1:length(sample_config.model)
    fns_string = [fns_string {sample_config.model(n).name}];
end
uicontrol('units','normalized','Position',[0.33   0.33   0.06    0.018],'ForegroundColor',sans_instrument_model_params.foreground_color,'HorizontalAlignment','right','BackgroundColor',sans_instrument_model_params.background_color,'Style','text','string','Scattering Model:','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize);
sans_instrument_model_handles.scattering_model = uicontrol('units','normalized','Position',[0.4   0.33    0.05   0.018],'Style','popupmenu','string',fns_string,'fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'value',sample_config.model_number,'callback','sans_instrument_model_callbacks(''change_scattering_model'')');
sans_instrument_model_callbacks('build_scattering_model');


%Build Background Model List
fns_string = [];
for n = 1:length(background_config.model)
    fns_string = [fns_string {background_config.model(n).name}];
end
uicontrol('units','normalized','Position',[0.46   0.33   0.065    0.018],'ForegroundColor',sans_instrument_model_params.foreground_color,'HorizontalAlignment','right','BackgroundColor',sans_instrument_model_params.background_color,'Style','text','string','Background Model:','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize);
sans_instrument_model_handles.background_model = uicontrol('units','normalized','Position',[0.535   0.33    0.05   0.018],'Style','popupmenu','string',fns_string,'fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'value',background_config.model_number,'callback','sans_instrument_model_callbacks(''change_background_model'')');
sans_instrument_model_callbacks('build_background_model');

%Build Cadmium Model List
fns_string = [];
for n = 1:length(cadmium_config.model)
    fns_string = [fns_string {cadmium_config.model(n).name}];
end
uicontrol('units','normalized','Position',[0.59   0.33   0.065    0.018],'ForegroundColor',sans_instrument_model_params.foreground_color,'HorizontalAlignment','right','BackgroundColor',sans_instrument_model_params.background_color,'Style','text','string','Blocked Model:','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize);
sans_instrument_model_handles.cadmium_model = uicontrol('units','normalized','Position',[0.665   0.33    0.05   0.018],'Style','popupmenu','string',fns_string,'fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'value',cadmium_config.model_number,'callback','sans_instrument_model_callbacks(''change_cadmium_model'')');
sans_instrument_model_callbacks('build_cadmium_model');

%Measurement Subtitle
uicontrol('units','normalized','Position',[0.33   0.03   0.06    0.018],'ForegroundColor',sans_instrument_model_params.foreground_color,'HorizontalAlignment','right','BackgroundColor',sans_instrument_model_params.background_color,'Style','text','string','Subtitle:','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize);
sans_instrument_model_handles.subtitle = uicontrol('units','normalized','Position',[0.4   0.03    0.05   0.018],'horizontalalignment','right','Style','edit','string',sans_instrument_model_params.subtitle,'fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'callback','sans_instrument_model_callbacks(''change_subtitle'')');



%Auto Calculate On/Off Button
sans_instrument_model_handles.auto_calculate_button = uicontrol('units','normalized','Position',[0.92    0.95    0.06    0.018],'Style','pushbutton','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'value',sans_instrument_model_params.det_image_log_check,'callback','sans_instrument_model_callbacks(''auto_calculate_button'')');
%Single Shot Calculate Button
sans_instrument_model_handles.single_shot_calculate_button = uicontrol('units','normalized','Position',[0.92    0.922    0.06    0.018],'Style','pushbutton','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'string','Calculate','value',sans_instrument_model_params.det_image_log_check,'callback','sans_instrument_model_callbacks(''single_shot_calculate'')');
%Smearing Dropdown
sans_instrument_model_handles.smearing_text = uicontrol('units','normalized','Position',[0.895    0.87    0.08    0.018],'Style','text','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'BackgroundColor',sans_instrument_model_params.background_color,'ForegroundColor',sans_instrument_model_params.foreground_color,'string','M.C. Itterations (/pixel)');
smearing_string = {'1','2','5','10','25','50','100','250','500','1000'};
sans_instrument_model_handles.smearing_dropdown = uicontrol('units','normalized','Position',[0.975    0.87    0.025    0.018],'Style','popupmenu','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'string',smearing_string,'value',sans_instrument_model_params.smearing_pos,'userdata',smearing_string,'callback','sans_instrument_model_callbacks(''smearing_itterations'')');
%Measurement Time Edit box
sans_instrument_model_handles.measurement_time_text = uicontrol('units','normalized','Position',[0.895    0.84    0.08    0.018],'Style','text','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'BackgroundColor',sans_instrument_model_params.background_color,'ForegroundColor',sans_instrument_model_params.foreground_color,'string','Measurement Time (s)');
sans_instrument_model_handles.measurement_time_edit = uicontrol('units','normalized','Position',[0.975    0.84    0.02    0.018],'Style','edit','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'string',num2str(sans_instrument_model_params.measurement_time),'callback','sans_instrument_model_callbacks(''measurement_time'')');
%Sample thickness edit box
sans_instrument_model_handles.sample_thickness_text = uicontrol('units','normalized','Position',[0.895    0.81    0.08    0.018],'Style','text','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'BackgroundColor',sans_instrument_model_params.background_color,'ForegroundColor',sans_instrument_model_params.foreground_color,'string','Sample Thickness(cm)');
sans_instrument_model_handles.sample_thickness_edit = uicontrol('units','normalized','Position',[0.975    0.81    0.02    0.018],'Style','edit','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'string',num2str(sans_instrument_model_params.sample_thickness),'callback','sans_instrument_model_callbacks(''sample_thickness'')');
%Sample area edit box
sans_instrument_model_handles.sample_area_text = uicontrol('units','normalized','Position',[0.895    0.78    0.08    0.018],'Style','text','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'BackgroundColor',sans_instrument_model_params.background_color,'ForegroundColor',sans_instrument_model_params.foreground_color,'string','Sample Area(cm^2)');
sans_instrument_model_handles.sample_area_edit = uicontrol('units','normalized','Position',[0.975    0.78    0.02    0.018],'Style','edit','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'string',num2str(sans_instrument_model_params.sample_area),'callback','sans_instrument_model_callbacks(''sample_area'')');
%Poissonian Noise
sans_instrument_model_handles.poissonian_text = uicontrol('units','normalized','Position',[0.895    0.75    0.08    0.018],'Style','text','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'BackgroundColor',sans_instrument_model_params.background_color,'ForegroundColor',sans_instrument_model_params.foreground_color,'string','Add Poissonian Noise');
sans_instrument_model_handles.poissonian_check = uicontrol('units','normalized','Position',[0.975    0.75    0.02    0.018],'Style','checkbox','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'BackgroundColor',sans_instrument_model_params.background_color,'value',sans_instrument_model_params.poissonian_noise_check,'callback','sans_instrument_model_callbacks(''poissonian_noise_check'')');
%Switch off divergence
sans_instrument_model_handles.divergence_text = uicontrol('units','normalized','Position',[0.895    0.72    0.08    0.018],'Style','text','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'BackgroundColor',sans_instrument_model_params.background_color,'ForegroundColor',sans_instrument_model_params.foreground_color,'string','Divergence OFF');
sans_instrument_model_handles.divergence_check = uicontrol('units','normalized','Position',[0.975    0.72    0.02    0.018],'Style','checkbox','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'BackgroundColor',sans_instrument_model_params.background_color,'value',sans_instrument_model_params.divergence_check,'callback','sans_instrument_model_callbacks(''divergence_check'')');
%Switch off delta_lambda
sans_instrument_model_handles.delta_lambda_text = uicontrol('units','normalized','Position',[0.895    0.69    0.08    0.018],'Style','text','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'BackgroundColor',sans_instrument_model_params.background_color,'ForegroundColor',sans_instrument_model_params.foreground_color,'string','Delta_Lambda OFF');
sans_instrument_model_handles.delta_lambda_check = uicontrol('units','normalized','Position',[0.975    0.69    0.02    0.018],'Style','checkbox','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'BackgroundColor',sans_instrument_model_params.background_color,'value',sans_instrument_model_params.delta_lambda_check,'callback','sans_instrument_model_callbacks(''delta_lambda_check'')');
%Square or Triangle Selector profile
sans_instrument_model_handles.square_tri_selector_text = uicontrol('units','normalized','Position',[0.895    0.66    0.08    0.018],'Style','text','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'BackgroundColor',sans_instrument_model_params.background_color,'ForegroundColor',sans_instrument_model_params.foreground_color,'string','Selector: Tri [] or Square [x]');
sans_instrument_model_handles.square_tri_selector_check = uicontrol('units','normalized','Position',[0.975    0.66    0.02    0.018],'Style','checkbox','fontname',sans_instrument_model_params.font,'fontsize',sans_instrument_model_params.fontsize,'BackgroundColor',sans_instrument_model_params.background_color,'value',sans_instrument_model_params.delta_lambda_check,'callback','sans_instrument_model_callbacks(''square_tri_selector_check'')');


%Thinking!
sans_instrument_model_handles.thinking = uicontrol('units','normalized','Position',[0.3    0.1   0.4    0.2],'ForegroundColor',[1,0,0],'BackgroundColor',sans_instrument_model_params.background_color,'Style','text','string','Thinking!','visible','off','fontname',sans_instrument_model_params.font,'fontsize',50);

%Numor!
sans_instrument_model_handles.numor = uicontrol('units','normalized','Position',[0.35    0.1   0.2    0.2],'ForegroundColor',[1,0,0],'BackgroundColor',sans_instrument_model_params.background_color,'Style','text','string','000000!','visible','off','fontname',sans_instrument_model_params.font,'fontsize',50);

%***** Refresh Model *****
sans_instrument_model_callbacks;
