function initialise_grasp_handles

%Initialises the Grasp handles structure.  Most of these are just added
%on the fly as needed.  Others, that are required straight away, even if
%just empty can be declared and initialised here

global grasp_handles
global status_flags

for det = 1:status_flags.instrument.detectors_max
    detno = num2str(det);
    grasp_handles.displayimage.(['image' detno]) = [];
    grasp_handles.displayimage.(['axis' detno]) = [];
end
grasp_handles.figure.subtitle = [];
grasp_handles.displayimage.colorbar =[];
%grasp_handles.displayimage.axis = [];

grasp_handles.window_modules.resolution_control_window.window = [];
grasp_handles.window_modules.contour_options.window = [];
grasp_handles.window_modules.color_sliders.window = [];
grasp_handles.window_modules.mask_edit.window = [];
grasp_handles.window_modules.detector_efficiency.window = [];
grasp_handles.window_modules.rundex.window = [];
grasp_handles.window_modules.radial_average.window = [];
grasp_handles.window_modules.sector.window = [];
grasp_handles.window_modules.sector.sketch_handles = [];
grasp_handles.window_modules.strips.window = [];
grasp_handles.window_modules.strips.sketch_handles = [];
grasp_handles.window_modules.box.window = [];
grasp_handles.window_modules.averaging_filters.window = [];
grasp_handles.window_modules.xtraplot.window = [];
grasp_handles.window_modules.bayes.window = [];
grasp_handles.window_modules.bayes.window_result = [];

grasp_handles.window_modules.box.sketch_handles = [];
grasp_handles.window_modules.sector_box.window = [];
grasp_handles.window_modules.sector_box.sketch_handles = [];
grasp_handles.window_modules.calibration.window = [];
% grasp_handles.window_modules.param_list = [];
grasp_handles.window_modules.about_grasp = [];
grasp_handles.window_modules.ancos2.window = [];
grasp_handles.window_modules.pa_tools.optimise_window = [];
grasp_handles.window_modules.pa_tools.polarisation_window = [];
grasp_handles.window_modules.parameter_patch_window = [];
% grasp_handles.window_modules.multi_beam.window = [];
 
grasp_handles.window_modules.calibration.beam.wks = [];
grasp_handles.window_modules.calibration.beam.nmbr = [];
grasp_handles.window_modules.calibration.beam.dpth = [];
grasp_handles.window_modules.calibration.det_eff_nmbr = [];
grasp_handles.window_modules.calibration.water.cal_scalar_value = [];

grasp_handles.window_modules.pa_correction.window = [];
grasp_handles.window_modules.pa_correction.bck_check = [];
grasp_handles.window_modules.pa_correction.cad_check = [];
grasp_handles.window_modules.pa_correction.pa_check = [];

grasp_handles.window_modules.curve_fit1d.window = [];
grasp_handles.window_modules.curve_fit2d.window = [];


