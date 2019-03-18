%***** Grasp Startup Parameters Required for Matlab Script Version *****
disp('Running Grasp_Startup');


% %***** Global variables availiable at the Matlab command prompt *****
global grasp_env;  %The general grasp environment variable
global status_flags %all the settings of menus etc.
global grasp_handles; %All the grasp graphic object handles
global inst_params;  %Contains the instrument description
global grasp_data %Contains all data arrays in a big structure containing: 'name', 'nmbr', 'dpth', 'data', 'dsum', 'params', 'parsub', 'lm'
global displayimage %A structure containing 'data', 'params', 'parsubm', 'lm' of the currently displayed image
global gs_fit_params


%***** Grasp Program Paths *****
% in this version the program assumes that the setup file is in the grasp
% directory

grasp_env.path.grasp_root = '../grasp_m_barebones/';






addpath(grasp_env.path.grasp_root);
addpath(fullfile(grasp_env.path.grasp_root,'main_interface'));
addpath(fullfile(grasp_env.path.grasp_root,'icons'));
addpath(fullfile(grasp_env.path.grasp_root,'data'));
addpath(fullfile(grasp_env.path.grasp_root,'callbacks'));
addpath(fullfile(grasp_env.path.grasp_root,'sans_math'));
addpath(fullfile(grasp_env.path.grasp_root,'math'));
addpath(fullfile(grasp_env.path.grasp_root,'sans_instrument'));
addpath(fullfile(grasp_env.path.grasp_root,'window_modules'));
addpath(fullfile(grasp_env.path.grasp_root,'grasp_plot'));
addpath(fullfile(grasp_env.path.grasp_root,'grasp_plot3'));
addpath(fullfile(grasp_env.path.grasp_root,'instrument_ini'));
addpath(fullfile(grasp_env.path.grasp_root,'colormaps'));
addpath(fullfile(grasp_env.path.grasp_root,'polarisation_analysis'));
addpath(fullfile(grasp_env.path.grasp_root,'sans_instrument_model'));
addpath(fullfile(grasp_env.path.grasp_root,'sans_instrument_model/form_factors'));
addpath(fullfile(grasp_env.path.grasp_root,'user_modules'));
addpath(fullfile(grasp_env.path.grasp_root,'user_modules','vortex_lattice'));
addpath(fullfile(grasp_env.path.grasp_root,'user_modules','rheology'));
addpath(fullfile(grasp_env.path.grasp_root,'user_modules','instrumentation'));
addpath(fullfile(grasp_env.path.grasp_root,'grasp_script'));

% addpath(fullfile(grasp_env.path.grasp_root,'user_modules','fll_math'));
% addpath(fullfile(grasp_env.path.grasp_root,'user_modules','d33'));
% addpath(fullfile(grasp_env.path.grasp_root,'grasp_changer'));
% addpath(fullfile(grasp_env.path.grasp_root,'sans_instrument_model'));

% addpath(fullfile(grasp_env.path.grasp_root,'user_modules','rheo'));





