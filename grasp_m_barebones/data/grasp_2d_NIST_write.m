function grasp_2d_NIST_write(directory,numor)

global grasp_env
global displayimage
global inst_params
global status_flags

%numor is numeric:  Pad with zeros to correct length
numor_str = num2str(numor)
numor_str = pad(numor_str,6,'left','0');
numor = str2num(numor_str);

%File Name
fname = fullfile(directory,[numor_str '.dat']);

%***** Open the file *****   
fid=fopen(fname,'wt');

%Check if file already exists, if so, delete first
warning off
try;delete(fname); end
warning on

disp(['Writing data to: ' fname]);

% %Run Number
% title_string = ['Run number: ',num2str(displayimage.params1(128)) '  Subtitle:  ' displayimage.subtitle ]
% fprintf(fid,title_string);
% fprintf(fid,'\n');
% fprintf(fid,'\n');
% fprintf(fid,'Data columns are Qx - Qy - I(Qx,Qy) - err(I) - Qz (dummy) - SigmaQ_parall (dummy) - SigmaQ_perp (dummy) - masked pixels');
% fprintf(fid,'\n');
% fprintf(fid,'\n');

fprintf(fid,'ASCII data');
fprintf(fid,'\n');
fprintf(fid,'\n');

%Loop though the number of detectors
for det = 1:inst_params.detectors
    detno=num2str(det);
    if status_flags.display.(['axis' detno '_onoff']) ==1; %i.e. Detector is Active
    %Data Size
    %data_size = size(displayimage.(['data' num2str(det)]));
    
    data_elements = numel(displayimage.(['data' detno]));
    %mask
    mask_data= reshape(displayimage.(['mask' detno]),[data_elements 1]);
    %Intensity
    det_data = reshape(displayimage.(['data' detno]),[data_elements 1]).*mask_data;
 
    %Intensity Error
    err_det_data = reshape(displayimage.(['error' detno]),[data_elements 1]).*mask_data;

    %qx
    qx_data = reshape(displayimage.(['qmatrix' detno])(:,:,3),[data_elements 1]).*mask_data;
 
    %qy
    qy_data = reshape(displayimage.(['qmatrix' detno])(:,:,4),[data_elements 1]).*mask_data;
    
    %qz dummy
    qz_data = zeros(data_elements, 1);
    %SigmaQ Parallel dummy
    qpar_data = zeros(data_elements, 1);
    %SigmaQ Perpendicular dummy
    qperp_data = zeros(data_elements, 1);
    %Nist data format
    %data_array = [qx_data, qy_data, det_data,err_det_data,qz_data,qpar_data,qperp_data,mask_data];
    %Data format actually used in SASview
    data_array = [qx_data, qy_data, det_data, err_det_data];
    
    %Delete all masked pixels 
    data_array(all(data_array' == 0),:) = [];
    
 
    
    dlmwrite(fname,data_array,'-append','delimiter','\t', 'newline', 'pc')
    
    end
end
fclose(fid);
