function numor_data = raw_read_ansto_sans(fname,numor)

global inst_params

%***** Raw Data Load Routine for QUOKKA *****
param = [];   %Parameters structure to be built

%Read OPAL QuOKKA format data
warning on
fileinfo=hdf5info(fname);
entryName =  fileinfo.GroupHierarchy.Groups(1).Name;
numor = str2num(entryName(5:length(entryName)));
if isempty(numor); numor = 0; end


%User Information
try
    temp1 = hdf5read(fname,strcat(entryName,'/user/name'));
    param.user = temp1.Data;
catch
    param.user = 'No Name';
end

% Date and time from start_time (if available)!
temp1 = hdf5read(fname,strcat(entryName,'/start_time'));

param.start_date = temp1.Data(1:10);
param.start_time = temp1.Data(12:19);
temp1 = hdf5read(fname,strcat(entryName,'/end_time'));
param.end_date = temp1.Data(1:10);
param.end_time = temp1.Data(12:19);
 
%Subtitle

try
    temp1 = hdf5read(fname,strcat(entryName,'/sample/name'));
    param.subtitle = temp1.Data;
catch
    param.subtitle = 'No Subtitle';
end

%Acquisition Time
try param.aq_time = hdf5read(fname,strcat(entryName,'/monitor/time')); %Seconds
catch; param.aq_time =1; end

%Time and Monitor
param.time = hdf5read(fname,strcat(entryName,'/monitor/bm1_time')); %Seconds
param.ex_time = param.time;
param.monitor = hdf5read(fname,strcat(entryName,'/monitor/bm1_counts')); %Beam Monitor 1

%Temperature
try; param.temp = hdf5read(fname,strcat(entryName,'/sample/temperature'));%Temperature
catch;disp('Could not read sample temperature from data file'); end

%Magnetic field
try; param.field = hdf5read(fname,strcat(entryName,'/sample/magnetic_field')); %Magnetic field
catch;disp('Could not read magnetic filed temperature from data file'); end

%Lambda, delta_lambda, Sample angles
param.wav = hdf5read(fname,strcat(entryName,'/data/wavelength')); %Wavelength
param.deltawav = hdf5read(fname,strcat(entryName,'/instrument/velocity_selector/wavelength_spread')); %Delta Lambda
param.sel_rpm = hdf5read(fname,strcat(entryName,'/instrument/velocity_selector/rspeed')); %Selector Speed RPM


%Collimation
param.col = 0.001*hdf5read(fname,strcat(entryName,'/instrument/parameters/L1')); %L1 in metres

%Sample Motors
try param.san = hdf5read(fname,strcat(entryName,'/sample/sample_theta')); catch; end %Sample rotation
try param.phi = hdf5read(fname,strcat(entryName,'/sample/sample_phi')); catch; end %Sample upper tilt
try param.chi = hdf5read(fname,strcat(entryName,'/sample/sample_chi')); catch; end %Sample lower tilt

%Detector Parameters
param.det = 0.001*hdf5read(fname,strcat(entryName,'/instrument/parameters/L2')); %Detector distance (in m)
param.bx = hdf5read(fname,strcat(entryName,'/instrument/detector/bsx')); %BeamStop x 
param.by = hdf5read(fname,strcat(entryName,'/instrument/detector/bsz')); %BeamStop y

%Attenuator position
try
    param.att_type = h5read(fname,strcat(entryName,'/instrument/collimator/att'));
catch
    param.att_type = 0; %default out
end

%Attenuation1 Value
try param.attenuation = 1/h5read(fname,strcat(entryName,'/instrument/parameters/AttFactor')); catch; end %

%Source Size
try
    param.source_ap_x = double((h5read(fname,strcat(entryName,'/instrument/parameters/EApX'))))/1000; %m
    param.source_ap_y = double((h5read(fname,strcat(entryName,'/instrument/parameters/EApZ'))))/1000; %m
catch
    disp('Warning:  Source size is not defined in the data file')
    try
        disp('Trying guide_size specified in instrument config as default source size (inst_params.guide_size = [x,y];')
        param.source_ap_x = inst_params.guide_size(1);
        param.source_ap_y = inst_params.guide_size(2);
        
    catch
        disp('Failed:  Using default source size of 50 x 50 mm')
        param.source_ap_x = 50e-3;
        param.source_ap_y = 50e-3;
    end
end

%Read the data array.
numor_data.data1 = double(hdf5read(fname,strcat(entryName,'/data/hmm_xy')));
%turn the data around to be viewed from reactor
numor_data.data1 = rot90(numor_data.data1);
numor_data.data1 = flipud(numor_data.data1);


try param.array_counts = hdf5read(fname,strcat(entryName,'/data/total_counts')); catch; end
param.numor = numor; 

%numor_data.params1 = param;

disp('Using SQRT(I) errors')
numor_data.error1 = sqrt(numor_data.data1);


%RF Flipper condition
try param.flipper_i = (h5read(fname,strcat(entryName,'/instrument/flipper/flip_current'))); catch; end
try param.flipper_v = (h5read(fname,strcat(entryName,'/instrument/flipper/flip_voltage'))); catch; end

%Electromagnet Parameter
try param.ps1_1 = (h5read(fname,strcat(entryName,'/sample/ma1/sensor/nominal_outp_current'))); catch; end

    
    
% Things that exist in the file in case you want to know
try param.thickness = hdf5read(fname,strcat(entryName,'/sample/SampleThickness')); catch; end %in mm
try param.thickness = hdf5read(fname,strcat(entryName,'/sample/SampleThickness')); catch; end %in mm
try param.aperture_size  = hdf5read(fname,strcat(entryName,'/sample/diameter')); catch; end % in mm
try param.bs_number = hdf5read(fname,strcat(entryName,'/instrument/parameters/BeamStop')); catch; end 
try param.bs_size = hdf5read(fname,strcat(entryName,'/instrument/parameters/BSdiam')); catch; end %Beamstop diameter in mm

numor_data.params1{1} = param;
