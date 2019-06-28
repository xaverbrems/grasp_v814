function grasp(inst)

if nargin<1; inst = []; end


%Declare functions required for Runtime

%***** Root Directory *****
%#function grasp

%***** Callbacks *****
%#function calibration_callbacks.m
%#function file_menu.m
%#function inst_menu_callbacks.m
%#function tool_callbacks.m
%#function calibration_window.m
%#function file_menu_image_export.m
%#function main_callbacks.m
%#function data_menu_callbacks.m
%#function grasp_movie.m
%#function menu_callbacks.m


%***** Colormaps *****
%#function army1.m
%#function aubergine.m
%#function bathtime.m
%#function blues.m
%#function damson.m
%#function harrier.m
%#function wolves.m
%#function army2.m
%#function barbie.m
%#function blueberry.m
%#function blush.m
%#function grass.m
%#function pond.m


%***** Data *****
%#function add_worksheet.m
%#function clear_wks_nmbr.m
%#function divide_detector_efficiency.m
%#function divide_relative_efficiency.m
%#function numor_parse.m
%#function two_d_tof_bin.m
%#function data_index.m
%#function ill_nexus_write.m
%#function place_data.m
%#function update_last_saved_project.m
%#function data_read.m
%#function initialise_data_arrays.m
%#function raw_save.m
%#function water_calibration.m
%#function direct_beam_calibration.m
%#function numor_decompress.m
%#function retrieve_data.m
%#function chuck_eval.m
%#function DLlirepax.m
%#function DLlireXY.m


%***** Grasp Plot *****
%#function grasp_plot_fit_window.m
%#function modify_grasp_plot_menu.m
%#function grasp_plot.m
%#function grasp_plot_image_export.m
%#function modify_grasp_plot_toolbar.m
%#function grasp_plot2.m
%#function grasp_plot_menu_callbacks.m
%#function ploterr.m
%#function xyerrorbar.m
%#function grasp_plot_fit_callbacks.m
%#function grasp_plot_resolutiont_callbacks.m
%#function pseudo_fn.m


%***** Grasp Script *****
%#function fit1d.m
%#function fit2d.m
%#function fit2d_spots.m
%#function gs.m


%***** Instrument_ini *****
%#function instrument_ini.m
%***** Compiled-in data loaders *****
%#function raw_read_legacy_ill_sans.m
%#function raw_read_nist_sans.m
%#function raw_read_sinq_sans1.m
%#function raw_read_ill_nexus.m
%#function raw_read_llb_tpa.m
%#function raw_read_ornl_sans.m
%#function raw_read_frm2_sans1.m


%***** Main Interface *****
%#function about_grasp.m
%#function grasp_update.m
%#function modify_main_menu_items.m
%#function update_data_summary.m
%#function circle.m
%#function hide_gui.m
%#function modify_main_tool_items.m
%#function update_display_options.m
%#function collect_points.m
%#function hide_stuff.m
%#function output_figure.m
%#function update_menus.m
%#function current_axis_limits.m
%#function initialise_2d_plots.m
%#function selector_build.m
%#function update_selectors.m
%#function display_params.m
%#function initialise_grasp_handles.m
%#function selector_build_values.m
%#function update_transmissions.m
%#function grasp_gui.m
%#function initialise_status_flags.m
%#function set_colormap.m
%#function update_window_options.m
%#function grasp_message.m
%#function live_coords.m
%#function update_beam_centre.m


%***** Math *****
%#function average_error.m
%#function double_chopper_kernel.m
%#function err_divide.m
%#function err_sub.m
%#function gauss_qkernel.m
%#function selector_kernel.m
%#function bindata.m
%#function err_acos.m
%#function err_ln.m
%#function err_sum.m
%#function mf_dfdp_grasp.m
%#function tophat_kernel_1d.m
%#function bindata2.m
%#function err_add.m
%#function err_multiply.m
%#function err_tan.m
%#function mf_lsqr_grasp.m
%#function trapezoid_kernel_1d.m
%#function circle_kernel_1d.m
%#function err_asin.m
%#function err_power.m
%#function gauss_kernel.m
%#function rand_trapezoid.m
%#function triangle_kernel_1d.m
%#function delta_kernel_1d.m
%#function err_cos.m
%#function err_sin.m
%#function gauss_kernel_1d.m
%#function rand_tri.m


%***** Sans Instrument *****
%#function d22_paralax_correction.m
%#function d33_paralax_correction.m
%#function grasp_paxy_read_wrapper.m


%***** Sans Instrument Model *****
%#function d11_model_component.m
%#function d33_model_component.m
%#function sans_instrument_model.m
%#function d22_flux_col_wav.m
%#function d33_model_data_write.m
%#function isalmost.m
%#function sans_instrument_model_build_q_matrix.m
%#function d22_model_component.m
%#function d33_parameters.m
%#function isodd.m
%#function sans_instrument_model_callbacks.m
%#function d22_parameters.m
%#function d33_rebin.m
%#function load_scattering_models.m
%#function sans_instrument_model_callbacks_bck.m
%#function d33_ill_sans_data_write.m
%#function sans_instrument_model_flux_col_wav.m

%***** Sans Instrument Model Form Factors *****
%#function ff_cadmium.m
%#function ff_d2o_cell.m
%#function ff_guinier.m
%#function ff_ribosome.m
%#function ff_vortex_rock.m
%#function ff_core_shell_sphere.m
%#function ff_empty_cell.m
%#function ff_mag_porod.m
%#function ff_sphere.m
%#function ff_water.m
%#function ff_cryostat_ox7t.m
%#function ff_gabel_protien.m
%#function ff_porod.m
%#function ff_vortex.m
%#function ff_water_cell.m


%***** Sans Math *****
%#function build_q_matrix.m
%#function current_beam_centre.m
%#function get_selector_result.m
%#function rebin.m
%#function build_resolution_kernels.m
%#function current_transmission.m
%#function current_thickness.m
%#function isodd.m
%#function standard_data_correction.m
%#function centre_of_mass.m
%#function divide_data_correction.m
%#function normalize_data.m
%#function transmission_thickness_correction.m


%***** User Modules *****
%#function d33_chopper_settings.m
%#function tof_calculator_callbacks.m
%#function d33_chopper_time_distance.m
%#function d33_chopper_time_distance_callbacks.m
%#function tof_calculator_window.m
%#function deflector_transmission.m
%#function deflector_callbacks.m
%#function xtraplot_window.m
%#function xtraplot_callbacks.m

%#function Af_pseudo_fn.m
%#function bindata.m
%#function rheo_anisotropy_callbacks.m
%#function rheo_anisotropy_window.m

%#function fll_angle_between_spots.m
%#function fll_anisotropy_callbacks.m
%#function fll_int_int.m
%#function fll_spot_angle_average_callbacks.m
%#function fll_angle_callbacks.m
%#function fll_beam_centre_callbacks.m
%#function fll_int_to_lambda.m
%#function fll_spot_angle_average_window.m
%#function fll_angle_window.m
%#function fll_beam_centre_window.m
%#function fll_rapid_beam_centre_callbacks.m
%#function fll_window.m
%#function fll_anisotropy_calculate_window.m
%#function fll_callbacks.m
%#function fll_rapid_beam_centre_window.m

%***** Bayes Stuff *****
%#function run_Bayes.m
%#function Bayesian_Rock_new.m
%#function bayes_window.m
%#function bayes_callbacks.m
%#function bayes_result_window.m


%***** Window Modules *****
%#function ancos2_callbacks.m
%#function ancos2_pseudo_fn.m
%#function ancos2_window.m
%#function box_callbacks.m
%#function curve_fit_2d_callbacks.m
%#function mask_edit_window.m
%#function resolution_control_callbacks.m
%#function sector_callbacks.m
%#function box_window.m
%#function curve_fit_window_2d.m
%#function parameter_patch_callbacks.m
%#function resolution_control_window.m
%#function sector_window.m
%#function color_sliders.m
%#function detector_efficiency_callbacks.m
%#function parameter_patch_window.m	rundex_callbacks.m
%#function strips_callbacks.m
%#function color_sliders_callbacks.m
%#function detector_efficiency_window.m
%#function pseudo_fn2d.m
%#function rundex_window.m
%#function strips_window.m
%#function contour_options_callbacks.m
%#function functions2d.fn
%#function radial_average_callbacks.m
%#function sector_box_callbacks.m
%#function contour_options_window.m
%#function mask_edit_callbacks.m
%#function radial_average_window.m
%#function sector_box_window.m


%***** Polarisation Modules *****
%#function pa_analyser.m
%#function pa_background_data_correction.m
%#function pa_cadmium_data_correction.m
%#function pa_cell_optimise_polarisation.m
%#function pa_correction_callbacks.m
%#function pa_correction_window.m
%#function pa_data_add.m
%#function pa_data_substraction.m
%#function pa_optimise_callbacks.m
%#function pa_optimise_window.m
%#function pa_polarisation.m
%#function pa_polarisation_callbacks.m
%#function pa_polarisation_correct.m
%#function pa_polarisation_correct_reduced.m
%#function pa_polarisation_data.m
%#function pa_polarisation_window.m
%#function pa_supermirror_check.m
%#function sanspol_correct.m


global grasp_env
global grasp_handles

set(groot,'defaultTextColor',[1,1,1]);
set(groot,'defaultAxesXColor',[1,1,1]);
set(groot,'defaultAxesYColor',[1,1,1]);
set(groot,'defaultAxesZColor',[1,1,1]);
set(groot,'defaultAxesGridColor',[1,1,1]);
set(groot,'defaultAxesMinorGridColor',[1,1,1]);

%***** Grasp Version Number ******
grasp_env.grasp_version = '8.14';
grasp_env.grasp_version_date = '21st January 2019';
grasp_env.grasp_name = 'GRASP_Barebones';


%***** Check to see if window is already open *****
h=findobj('Tag','grasp_main');
if not(isempty(h))
    disp('GRASP is already running');
    figure(h);
else
    
    initialise_status_flags  
    grasp_ini     %Load user-configurable environment params from grasp.ini
    %Override instrument in grasp_ini if provided as start argument
    if ~isempty(inst); grasp_env.inst = inst; end
    
    %Build Grasp GUI
    grasp_gui

    %Note, instrument configs are built in modify_main_menu_items called via grasp_gui
    initialise_grasp_handles
    initialise_data_arrays

    %Build selector menus
    selector_build;
    selector_build_values('all');
    
    initialise_2d_plots

    grasp_update

    update_last_saved_project
end

if isdeployed
    about_grasp
    drawnow
    pause(5)
    if ishandle(grasp_handles.window_modules.about_grasp) %Check it is still there.
        close(grasp_handles.window_modules.about_grasp);
        grasp_handles.window_modules.about_grasp=[];
    end
end

