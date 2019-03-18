function numor_data = raw_read_llb_tpa(fname,numor)

global inst_params

%Open file
fid=fopen(fname);

%Read TPA XML format data
%Use our own file parser
linestr = ''; line_counter = 0;

loop_end = 0;
while loop_end ==0
    linestr = fgetl(fid);
    
    
    if strfind(linestr,'<Frame')
        %Parse the string to strip out all the parameters
        
        %Monitor
        temp = strfind(linestr,'Monitor=');
        temp2 = strfind(linestr,'"'); temp3 = find(temp2>temp);
        param.monitor = str2num(linestr(temp2(temp3(1))+1:temp2(temp3(2))-1));
        
        %Acquisition Time
        temp = strfind(linestr,'Monitor_Time=');
        temp2 = strfind(linestr,'"'); temp3 = find(temp2>temp);
        param.aq_time = str2num(linestr(temp2(temp3(1))+1:temp2(temp3(2))-1));
        param.ex_time = param.aq_time;
        
        %Detector Distance
        temp = strfind(linestr,'Detector_Distance=');
        temp2 = strfind(linestr,'"'); temp3 = find(temp2>temp);
        param.det1 = str2num(linestr(temp2(temp3(1))+1:temp2(temp3(2))-1))/1000;
        param.detcalc1 = param.det1;
        param.det = param.det1;
        param.detcalc = param.detcalc1;
        
        %Wavelength
        temp = strfind(linestr,' Lambda=');
        temp2 = strfind(linestr,'"');
        temp3 = find(temp2>=temp);
        param.wav = str2num(linestr(temp2(temp3(1))+1:temp2(temp3(2))-1));
        
        %Delta Wav
        temp = strfind(linestr,'DeltaLambdasurLambda=');
        temp2 = strfind(linestr,'"'); temp3 = find(temp2>temp);
        param.deltawav = str2num(linestr(temp2(temp3(1))+1:temp2(temp3(2))-1));

        %Collimation
        temp = strfind(linestr,'Collimator_Distance=');
        temp2 = strfind(linestr,'"'); temp3 = find(temp2>temp);
        param.col = str2num(linestr(temp2(temp3(1))+1:temp2(temp3(2))-1))/1000;
        
        %Source Aperture Size
        temp = strfind(linestr,'Collimator_Diaphragm_In=');
        temp2 = strfind(linestr,'"'); temp3 = find(temp2>temp);
        param.source_ap = str2num(linestr(temp2(temp3(1))+1:temp2(temp3(2))-1))/1000;
        
        
        %Subtitle
        temp = strfind(linestr,'Comment=');
        temp2 = strfind(linestr,'"'); temp3 = find(temp2>temp);
        param.subtitle = (linestr(temp2(temp3(1))+1:temp2(temp3(2))-1));

        %Date
        temp = strfind(linestr,' date=');
        temp2 = strfind(linestr,'"'); temp3 = find(temp2>temp);
        param.start_date  = (linestr(temp2(temp3(1))+1:temp2(temp3(2))-1));
        
        %Time
        temp = strfind(linestr,' time=');
        temp2 = strfind(linestr,'"'); temp3 = find(temp2>temp);
        param.start_time  = (linestr(temp2(temp3(1))+1:temp2(temp3(2))-1));
        
    end
    
    if strfind(linestr,'<Data')
        temp = strfind(linestr,'>');
        temp2 = linestr(temp(1)+1:length(linestr));
        temp3 = strrep(temp2,';',' ');
        temp4 = strrep(temp3,'</Data>','');
        temp5 = str2num(temp4);
        numor_data.data1 = rot90(reshape(temp5,[512,512]));
        disp('Using SQRT Errors');
        numor_data.error1 = sqrt(numor_data.data1);
   end
    
    if strfind(linestr,'</Acquisition')
        loop_end = 1; %quit loop and read detector array
    end
    
end

param.attenuation = 1;
param.source_ap_x = inst_params.guide_size(1);
param.source_ap_y = inst_params.guide_size(2);

%Total Counts
param.array_counts = sum(sum(numor_data.data1));

%Numor
param.numor = 0000;  %Usually stored as param 128

%BeamStop
param.bx = 0;
param.by = 0;

%Attenuator
param.att_type = 0;
param.att_status = 1;

%User Information
param.user = 'No Name';
%param.start_date = d.et.date_heure(1:10);
%param.start_time = d.et.date_heure(12:19);
param.end_date = [];
param.end_time = [];

numor_data.params1{1} = param;

