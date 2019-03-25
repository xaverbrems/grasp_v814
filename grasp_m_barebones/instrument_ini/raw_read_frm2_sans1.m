function numor_data = raw_read_frm2_sans1(fname,numor)

global inst_params

numor_data = [];
param = [];

%Load In Data, Numor
fid=fopen(fname);
warning on
%Read HMI format data
linestr = ''; line_counter = 0;

numor_data.info.start_date = '';
numor_data.info.start_time = '';
numor_data.info.end_date = '';
numor_data.info.end_time ='';
numor_data.info.user = '';

while isempty(findstr(linestr,'%Counts'))
    linestr = fgetl(fid);
    line_counter = line_counter +1;
    
    if findstr(linestr,'FromDate='); l = length(linestr); param.start_date = linestr(findstr(linestr,'=')+1:l); end
    if findstr(linestr,'FromTime='); l = length(linestr); param.start_time = linestr(findstr(linestr,'=')+1:l); end
    if findstr(linestr,'ToDate='); l = length(linestr); param.end_date = linestr(findstr(linestr,'=')+1:l); end
    if findstr(linestr,'ToTime='); l = length(linestr); param.end_time = linestr(findstr(linestr,'=')+1:l); end
    if findstr(linestr,'User='); l = length(linestr); param.user = linestr(findstr(linestr,'=')+1:l); end
    
    if findstr(linestr,'FileName=')
        numor_str = strtok(linestr,'FileName=');
        numor_str = strtok(numor_str,'D');
        numor_str = numor_str(1:inst_params.filename.numeric_length);
        param.numor = str2double(numor_str);
    end

    if findstr(linestr,'Title'); l=length(linestr); param.subtitle = linestr(7:l); end

    if findstr(linestr,'Time='); a = findstr(linestr,'Time=');
        if a==1
            l = length(linestr);
            param.aq_time = str2double(linestr(findstr(linestr,'=')+1:l));
            param.ex_time = param.aq_time;
        end
    end
   
    if findstr(linestr,'Moni1')==1; l = length(linestr); param.monitor1 = str2double(linestr(findstr(linestr,'=')+1:l));     param.monitor = param.monitor1; end

    if findstr(linestr,'Moni2')==1; l = length(linestr); param.monitor2 = str2double(linestr(findstr(linestr,'=')+1:l)); end
        
    if findstr(linestr,'BeamstopX=')
        l = length(linestr); param.bx = str2double(linestr(findstr(linestr,'=')+1:l)); end
    if findstr(linestr,'BeamstopY='); l = length(linestr); param.by = str2double(linestr(findstr(linestr,'=')+1:l)); end
    if findstr(linestr,'SD=')
        l = length(linestr); param.det = str2double(linestr(findstr(linestr,'=')+1:l));
        param.detcalc = param.det;
    end
    if findstr(linestr,'Lambda='); l = length(linestr); param.wav = str2double(linestr(findstr(linestr,'=')+1:l)); end
    param.deltawav = 0.1; %Default 10%

%     if findstr(linestr,'LambdaC=')
%         l = length(linestr);
%         rpm = str2double(linestr(findstr(linestr,'=')+1:l));
%         param.sel_rpm = rpm;
%         wav =  0.03 + 125800 / rpm;
%         param.wav = wav;
%     end

    if findstr(linestr,'Collimation='); l = length(linestr); param.col = str2double(linestr(findstr(linestr,'=')+1:l)); end
    if findstr(linestr,'Attenuator=')
        l = length(linestr);
        temp = str2double(linestr(findstr(linestr,'=')+1:l));
        if ~isempty(temp)
            param.att_type = temp;
        else 
            param.att_type = 0;
        end
        param.att_status = 0;
    end
    param.attenuation = 1;
    
    param.source_ap_x = inst_params.guide_size(1);
    param.source_ap_y = inst_params.guide_size(2);
    

    %Sample Environment
    if findstr(linestr,'Temperature='); a = findstr(linestr,'Temperature='); if a==1; l = length(linestr); param.temp = str2double(linestr(findstr(linestr,'=')+1:l));end  ; end
    if findstr(linestr,'Magnet='); a = findstr(linestr,'Magnet='); if a==1; l = length(linestr); param.field = str2double(linestr(findstr(linestr,'=')+1:l));end  ; end

    if findstr(linestr,'Position='); l = length(linestr); param.chpos = str2double(linestr(findstr(linestr,'=')+1:l)); end
    %san, phi and chi was used instead of omega-2b, phi-2b and chi-2b to ensure compatibility with the other
    %functions
    if findstr(linestr,'omega-2b='); l = length(linestr); param.san = str2double(linestr(findstr(linestr,'=')+1:l)); end
    if findstr(linestr,'chi-2b='); l = length(linestr); param.chi = str2double(linestr(findstr(linestr,'=')+1:l)); end
    if findstr(linestr,'phi-2b='); l = length(linestr); param.phi = str2double(linestr(findstr(linestr,'=')+1:l)); end
    if findstr(linestr,'x-2b='); l = length(linestr); param.x_2b = str2double(linestr(findstr(linestr,'=')+1:l));  end
    if findstr(linestr,'y-2b='); l = length(linestr); param.y_2b = str2double(linestr(findstr(linestr,'=')+1:l));    end
    if findstr(linestr,'z-2b='); l = length(linestr); param.z_2b = str2double(linestr(findstr(linestr,'=')+1:l));     end
    if findstr(linestr,'x-2a='); l = length(linestr); param.x_2a = str2double(linestr(findstr(linestr,'=')+1:l));     end
    if findstr(linestr,'y-2a='); l = length(linestr); param.y_2a = str2double(linestr(findstr(linestr,'=')+1:l));   end
    if findstr(linestr,'z-2a='); l = length(linestr); param.z_2a = str2double(linestr(findstr(linestr,'=')+1:l));  end
end


%New reading routine.  - Compiles but is slightly slower than the 'dlmread' version (1/2 the speed of the dlmread version)
temp =fscanf(fid,'%c',[inf]); %Read all the rest of the file as string
data_end = findstr(temp,'%Counter'); %Find where the data ends: SINQ add extra at the end of file.
data_end = findstr(temp,'%Errors'); 
error_end = length(temp);
if isempty(data_end); data_end = length(temp); end %Find where the data ends for real HMI file.

%data = str2double(temp(1,1:data_end-1)); %Extract the data from the remaining string by str2double'ing
temp = strrep(temp,',',' '); %Replace commas with spaces so that sscanf works.
data = sscanf(temp(1,1:data_end-1),'%g');

%Turn data around 
data = reshape(data,inst_params.detector1.pixels(1),inst_params.detector1.pixels(2));
data = rot90(data);
data = flipud(data);

disp('Using SQRT(I) errors')
error_data = sqrt(data);

%Close file
fclose(fid);


%Make final output structure
numor_data.data1 = data;
param.array_counts = sum(sum(data));
numor_data.error1 = error_data;
numor_data.params1{1} = param;

