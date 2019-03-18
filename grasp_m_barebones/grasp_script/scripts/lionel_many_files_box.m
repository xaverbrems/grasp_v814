%Example Grasp Script

%Set Instrument config
gs('set_instrument','ILL','d22_legacy')

%Set scattering data directory
gs('set_data_dir','/Users/dewhurst/Desktop/Dropbox/Grasp Test Data/ex2_data');

%Load background data - this remains constant though the following
gs('load',2,1,'88526(21)') %background worksheet 1

%Subtract background from foreground
gs('bg','on')


%Turn on Box store logging
gs('box_memory','clear')
gs('box_memory','on')

%Loop though all the foregrounds - blocks of 7 at a time
block_size = 7;
for numor = 88144:block_size:88164
    
    
    %Load foreground data
    gs('load',1,1,[num2str(numor) '{' num2str(block_size) '}']) %sample worksheet 1
    
    %Switch display back to sample worksheet 1 sum
    %gs('display',1,1,0)
    
    %Sector Box Two Bragg peaks
    %gs('sector_boxit','san',[15,25,90,20],[15,25,270,20],'plot_off')
    
    %or
    
    %Box Two Bragg peaks
    gs('boxit','san',[43,49,59,65],[78,85,59,65],'plot_off')
    
    
end

%Display Box data in command window
global gs_box_data
gs_box_data

%Plot Box Data using Grasp_plot3
grasp_plot3(gs_box_data(:,1),gs_box_data(:,2),gs_box_data(:,3),gs_box_data(:,4),gs_box_data(:,5),gs_box_data(:,6),'columnformat','xyexye','title','Lionel Plot','xlabel','San Angle','ylabel','counts')

%Export box data
fname = '/Users/dewhurst/Desktop/test.dat';
gs('export_box_data',fname)


