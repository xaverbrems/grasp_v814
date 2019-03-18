function numor_data = grasp_paxy_read_wrapper(fname)

global inst_params

%Read the PAXY data using LLB's own data reader
d = DLlirePAX(fname,128,'int32');


%Multi detector data
numor_data.data1 = d.m;
disp('Using SQRT(n) Errors');
numor_data.error1 = sqrt(d.m);


%User Information
param.user = 'No Name';
param.start_date = d.et.date_heure(1:10);
param.start_time = d.et.date_heure(12:19);
param.end_date = [];
param.end_time = [];
param.subtitle = d.et.commentaire;

%Numor
param.numor = d.et.numero;  %Usually stored as param 128
%Acquisition Time
param.aq_time = d.et.temps; %Seconds
param.ex_time = param.aq_time;
%Detector Distance
param.det1 = d.et.distance/1000; %m
param.det = param.det1;
param.detcalc1 = param.det1; %m
%Wavelength
param.wav = d.et.lambda; %Angs
param.deltawav = d.et.dlsurl*2; %Fraction 2* to go from half-width to FWHM
param.sel_rpm = d.et.vitesse_selecteur; %RPM
%BeamStop
param.bx = 0;
param.by = 0;
%Attenuator
param.att_type = 0;
param.att_status = 1;
param.attenuation = 1;
%Collimation
param.col = d.et.dc /1000; %m;
%Collimation Source Size
param.source_ap = d.et.r1*2 / 1000 ; %m *2 to make diameter
param.source_ap_x = param.source_ap;
param.source_ap_y = param.source_ap;


%Monitor
param.monitor = d.et.moniteur;
%Total Counts
param.array_counts = sum(sum(numor_data.data1));
numor_data.params1{1} = param;

