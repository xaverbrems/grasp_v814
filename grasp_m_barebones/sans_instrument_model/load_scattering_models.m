sample_config.model_number = 2; %Default Sample Model
background_config.model_number = 1;
cadmium_config.model_number = 1;


%***** Sample Scattering Models *****
model = 0;

model=model+1;
sample_config.model(model).name = '<None>';
sample_config.model(model).pnames = [];
sample_config.model(model).structname = [];
sample_config.model(model).fn_eval = '0';

model=model+1;
sample_config.model(model).name = 'Sphere';
sample_config.model(model).pnames = [{'Radius [A]:'} {'Poly [%FWHM]:'} {'Contrast [A-2]:'} {'Scale:'} {'Background [cm-1]:'}];
sample_config.model(model).structname = [{'radius'} {'poly_fwhm'} {'contrast'} {'scale'} {'background'}];
sample_config.model(model).fn_eval = ['ff_sphere(q, sample_config.model(' num2str(model) ').radius, sample_config.model(' num2str(model) ').poly_fwhm, sample_config.model(' num2str(model) ').contrast, sample_config.model(' num2str(model) ').scale, sample_config.model(' num2str(model) ').background)'];
sample_config.model(model).radius = 60; %Angs
sample_config.model(model).poly_fwhm = 0;
sample_config.model(model).contrast = 6e-6; %A-2    6e-6 is roughly H Surfactant in D2O
sample_config.model(model).scale = 0.01; %Concentration
sample_config.model(model).background = 0;

model=model+1;
sample_config.model(model).name = 'Core-Shell Sphere';
sample_config.model(model).pnames = [{'Core Radius [A]:'} {'Core Poly [%FWHM]:'} {'Shell [A]'} {'rho_core [A-2]:'} {'rho_shell [A-2]:'} {'rho_matrix [A-2]:'} {'Scale:'} {'Background [cm-1]:'}];
sample_config.model(model).structname = [{'radius'} {'poly_fwhm'} {'shell'} {'rho_core'} {'rho_shell'} {'rho_matrix'} {'scale'} {'background'}];
sample_config.model(model).fn_eval = ['ff_core_shell_sphere(q, sample_config.model(' num2str(model) ').radius, sample_config.model(' num2str(model) ').poly_fwhm, sample_config.model(' num2str(model) ').shell, sample_config.model(' num2str(model) ').rho_core, sample_config.model(' num2str(model) ').rho_shell, sample_config.model(' num2str(model) ').rho_matrix, sample_config.model(' num2str(model) ').scale, sample_config.model(' num2str(model) ').background)'];
sample_config.model(model).radius = 50; %Angs
sample_config.model(model).poly_fwhm = 10;
sample_config.model(model).shell = 15;
sample_config.model(model).rho_core = 6.7e-6;
sample_config.model(model).rho_shell = 7.88e-8;
sample_config.model(model).rho_matrix = 5.22e-6;
sample_config.model(model).scale = 1; %Concentration
sample_config.model(model).background = 0;

model=model+1;
sample_config.model(model).name = 'Guinier';
sample_config.model(model).pnames = [{'Radius RG [A]'} {'I0:'} {'Background [cm-1]'}];
sample_config.model(model).structname = [{'rg'} {'i0'} {'background'}];
sample_config.model(model).fn_eval = ['ff_guinier(q, sample_config.model(' num2str(model) ').rg, sample_config.model(' num2str(model) ').i0, sample_config.model(' num2str(model) ').background)'];
sample_config.model(model).rg = 60; %Angs
sample_config.model(model).i0 = 1;
sample_config.model(model).background = 0;

model=model+1;
sample_config.model(model).name = 'Porod';
sample_config.model(model).pnames = [{'Spec. Surf. [A^2]'} {'Contrast [A-2]:'} {'Background [cm-1]'}];
sample_config.model(model).structname = [{'surf'} {'contrast'} {'background'}];
sample_config.model(model).fn_eval = ['ff_porod(q, sample_config.model(' num2str(model) ').surf, sample_config.model(' num2str(model) ').contrast, sample_config.model(' num2str(model) ').background)'];
sample_config.model(model).surf = 1; %Angs
sample_config.model(model).contrast = 1e-6;
sample_config.model(model).background = 0;

model=model+1;
sample_config.model(model).name = 'Flux Line Bragg Peak';
sample_config.model(model).pnames = [{'Magnetic Field [G]'} {'Rocking Width [degs]'} {'Az Correlation [microns]'} {'Rad Correlation [microns]'} {'Lambda_L [A]'} {'San [degs]'} {'Phi [degs]'} {'Orientation [degs]'}];
sample_config.model(model).structname = [{'field'} {'width'} {'az_cor'} {'rad_cor'} {'pen_depth'} {'san'} {'phi'} {'rot'}];
sample_config.model(model).fn_eval = ['ff_vortex(real_q_matrix, wav_matrix, sample_config.model(' num2str(model) ').field, sample_config.model(' num2str(model) ').width, sample_config.model(' num2str(model) ').az_cor, sample_config.model(' num2str(model) ').rad_cor, sample_config.model(' num2str(model) ').pen_depth, sample_config.model(' num2str(model) ').san, sample_config.model(' num2str(model) ').phi, sample_config.model(' num2str(model) ').rot)'];
sample_config.model(model).field = 1000; %gauss
sample_config.model(model).width = 0.5; %degrees
sample_config.model(model).az_cor = 0.5; %microns
sample_config.model(model).rad_cor = 1; %microns
sample_config.model(model).pen_depth = 1000; % Penetration Depth A
sample_config.model(model).san = 0; %San rocking angle
sample_config.model(model).phi = 0; %Phi rocking angle
sample_config.model(model).rot = 0; %FLL orientation

model=model+1;
sample_config.model(model).name = 'Porod + Magnetic Porod';
sample_config.model(model).pnames = [{'Spec. Surf. NonMag [A^2]'} {'Contrast NonMag [A-2]:'} {'Spec. Surf. Magnetic [A^2]'} {'Contrast Magnetic [A-2]:'} {'Background [cm-1]'}];
sample_config.model(model).structname = [{'surf'} {'contrast'} {'magsurf'} {'magcontrast'} {'background'}];
sample_config.model(model).fn_eval = ['ff_mag_porod(q, real_q_matrix, sample_config.model(' num2str(model) ').surf, sample_config.model(' num2str(model) ').contrast, sample_config.model(' num2str(model) ').magsurf, sample_config.model(' num2str(model) ').magcontrast, sample_config.model(' num2str(model) ').background)'];
sample_config.model(model).surf = 1; %Angs
sample_config.model(model).contrast = 1e-6;
sample_config.model(model).magsurf = 1; %Angs
sample_config.model(model).magcontrast = 1e-6;
sample_config.model(model).background = 0;

model=model+1;
sample_config.model(model).name = 'Water';
sample_config.model(model).pnames = [];
sample_config.model(model).structname = [];
sample_config.model(model).fn_eval = 'ff_water(q)';

model=model+1;
sample_config.model(model).name = 'Ribosome';
sample_config.model(model).pnames = [];
sample_config.model(model).structname = [];
sample_config.model(model).fn_eval = 'ff_ribosome(q)';

model=model+1;
sample_config.model(model).name = 'Gabel Protien';
sample_config.model(model).pnames = [];
sample_config.model(model).structname = [];
sample_config.model(model).fn_eval = 'ff_gabel_protien(q)';

model=model+1;
sample_config.model(model).name = 'Empty Cell';
sample_config.model(model).pnames = [];
sample_config.model(model).structname = [];
sample_config.model(model).fn_eval = 'ff_empty_cell(q)';

model=model+1;
sample_config.model(model).name = 'Water + Cell';
sample_config.model(model).pnames = [];
sample_config.model(model).structname = [];
sample_config.model(model).fn_eval = 'ff_water_cell(q)';

model=model+1;
sample_config.model(model).name = 'D2O + Cell';
sample_config.model(model).pnames = [];
sample_config.model(model).structname = [];
sample_config.model(model).fn_eval = 'ff_d2o_cell(q)';

model=model+1;
sample_config.model(model).name = 'Blocked Beam';
sample_config.model(model).pnames = [];
sample_config.model(model).structname = [];
sample_config.model(model).fn_eval = 'ff_cadmium(q)';




%***** Background Scattering Models *****
model=0;

model=model+1;
background_config.model(model).name = '<None>';
background_config.model(model).pnames = [];
background_config.model(model).structname = [];
background_config.model(model).fn_eval = '0';

model=model+1;
background_config.model(model).name = 'Empty Cell';
background_config.model(model).pnames = [];
background_config.model(model).structname = [];
background_config.model(model).fn_eval = 'ff_empty_cell(q)';

model=model+1;
background_config.model(model).name = 'Water + Cell';
background_config.model(model).pnames = [];
background_config.model(model).structname = [];
background_config.model(model).fn_eval = 'ff_water_cell(q)';

model=model+1;
background_config.model(model).name = 'D2O + Cell';
background_config.model(model).pnames = [];
background_config.model(model).structname = [];
background_config.model(model).fn_eval = 'ff_d2o_cell(q)';

model=model+1;
background_config.model(model).name = 'Cryostat Ox7T';
background_config.model(model).pnames = [];
background_config.model(model).structname = [];
background_config.model(model).fn_eval = 'ff_cryostat_ox7t(q)';

model=model+1;
background_config.model(model).name = 'Blocked Beam';
background_config.model(model).pnames = [];
background_config.model(model).structname = [];
background_config.model(model).fn_eval = 'ff_cadmium(q)';



%***** Blocked Beam Scattering Models *****
model=0;

model=model+1;
cadmium_config.model(model).name = '<None>';
cadmium_config.model(model).pnames = [];
cadmium_config.model(model).structname = [];
cadmium_config.model(model).fn_eval = '0';

model=model+1;
cadmium_config.model(model).name = 'Blocked Beam';
cadmium_config.model(model).pnames = [];
cadmium_config.model(model).structname = [];
cadmium_config.model(model).fn_eval = 'ff_cadmium(q)';