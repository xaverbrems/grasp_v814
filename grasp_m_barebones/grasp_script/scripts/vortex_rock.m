%Example Grasp Script

%Set Instrument config
gs('set_instrument','ILL','d22_legacy')

%Set scattering data directory
gs('set_data_dir','/Users/dewhurst/Desktop/Dropbox/Grasp Test Data/ex2_data');

%Load foreground data
gs('load',1,1,'88144{21}') %sample worksheet 1

%Load background data
gs('load',2,1,'88526{21}') %background worksheet 1

%Switch display back to sample worksheet 1 sum
gs('display',1,1,0)

%Subtract background from foreground
gs('bg','on')

%Calculate beam centre from current image
gs('cm')

%Sector Box Two Bragg peaks
gs('sector_boxit','san',[15,25,90,20],[15,25,270,20])

%Box Two Bragg peaks
%gs('boxit','san',[43,48,60,65,1],[78,84,60,65,1])

%Export rocking curbe(s)
gs('set_project_dir','/Users/dewhurst/Desktop/');
gs('export_grasp_plot_data')

%Turn on fit_parameter logging
gs('fit_memory','on')

%Fit the two peaks with auto-guess
%Curve1
gs('fit1d','Gaussian',1,1)
%Curve2
gs('fit1d','Gaussian',2,1)

%Save fit results to file
gs('save_fit_params','/Users/dewhurst/Desktop/fit_data.dat')

%Clear fit_parameter log and switch off
gs('fit_memory','off')
gs('fit_memory','clear')

%Close the grasp_plot
gs('close')

%Close the fit window
gs('close','all','Curve Fit Control')

%Close the box window
gs('close','all','Boxes')
