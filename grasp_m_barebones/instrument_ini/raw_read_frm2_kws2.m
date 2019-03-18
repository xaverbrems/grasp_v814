function numor_data = raw_read_frm2_kws2(fname)

%Usage:
%'fname' is the full data path AND filename
%
%Reads file Data Numor and outputs all information as a structure including fields:
%numor_data.data1    - 2D matrix of detector data from detector1
%          .data2    -  ...from detector 2 etc.
%          .error1   - sqrt(data1)
%          .params1  - Parameter array from detector1
%          .param_names1 - Parameter names
%          .subtitle - measurement subtitle
%          .numor    - File number indicated by header block
%          .info.user

global inst_params
global status_flags
global grasp_env

numor_data = [];
param = [];   %Parameters structure to be built

%Load In Data, Numor
fid=fopen(fname);
warning on
linestr = ''; line_counter = 0;
%line = 1;line_max = 1000; i_block = 0;

param.start_date = '';
param.start_time = '';
param.end_date = '';
param.end_time ='';
param.user = '';
while isempty(findstr(linestr,'$'))
    linestr = fgetl(fid);
    line_counter = line_counter +1;
    
    % find wavelength
    if findstr(linestr,'lambda='); l = length(linestr)-1; param.wav = str2num(linestr(findstr(linestr,'=')+1:l));  end
    % find Title
    if findstr(linestr,'lambda=');linestr = fgetl(fid); l = length(linestr); param.subtitle = linestr(1:l);  end
    
    %Search for Numor description
    if findstr(linestr,'Cyclus_Number')
        [pointers,~] = fscanf(fid,'%8g');
        param.numor = pointers(1);
    end
    
    %numor_data.subtitle = '';
    
    %Search for Collimation value
    if findstr(linestr,'Coll_Position')
        pointer = textscan(fid, '%s %s %s %s',  3);
        param.col = str2double(pointer{1}(2));
    end
    %Search for Detector value
    if findstr(linestr,'Offset')
        pointer = textscan(fid, '%s %s %s %s',  3);
        param.det = str2double(pointer{2}(2));
        offset = str2double(pointer{1}(2));
        param.detcalc = param.det + offset;
    end
    % selector, Monitor
    if findstr(linestr,'(* Selector and Monitor Counter *)')
        pointer = textscan(fid, '%s %s %s %s',  2);
        param.sel_rpm = str2double(pointer{1}(2));
        param.monitor = str2double(pointer{2}(2));
        param.monitor1 = str2double(pointer{2}(2));
        param.monitor2 = str2double(pointer{3}(2));
        param.moni3 = str2double(pointer{4}(2));
    end
    % measurement time
    if findstr(linestr,'(* Real measurement time for detector data *)')
        pointer = textscan(fid, '%s %s',  1);
        param.aq_time = str2double(pointer{1});
        param.ex_time = param.aq_time;
    end
end

%Some dummy defaults to make Grasp work
param.attenuation = 1;
param.source_ap_x = 50e-3;
param.source_ap_y = 50e-3;
param.deltawav = 0.1;


%New reading routine.  - Compiles but is slightly slower than the 'dlmread' version (1/2 the speed of the dlmread version)
data =fscanf(fid,'%g'); %Read all the rest of the file as string

%Turn data around
data = reshape(data,256,256);
%Trim data to detector size
x_shift = 56; y_shift = 56;
data = data([(y_shift+1):(y_shift+inst_params.detector1.pixels(2))], [(x_shift+1):(x_shift+inst_params.detector1.pixels(1))]);
size(data)


%data = rot90(data);
%data = flipud(data);

disp('Using SQRT(I) errors')
error_data = sqrt(data);
%Add extra parameter total counts actually counted from the data in the file
param.array_counts = sum(sum(data)); %The total Det counts as summed from the data array
%Close file
fclose(fid);

%Make final output structure
numor_data.data1 = data;
numor_data.error1 = error_data;
numor_data.params1{1} = param;



