function centre = current_beam_centre

%Reads back the current beam centre associated with the current displayed worksheet

global grasp_data
global status_flags
global inst_params

%Find the pointers and type of the current displayed worksheet
number = status_flags.beamcentre.cm_number;  depth = status_flags.beamcentre.cm_depth;

index = data_index(1); %Beam centres are stored with the sample scattering worksheet

%Correct depths for SUM worksheets
depth = depth-grasp_data(index).sum_allow;
if depth ==0; depth = 1; end %incase the worksheet was already on 'sum'

%Read back current beam centre for all detectors
centre = [];
for det = 1:inst_params.detectors
    detno=num2str(det);
    %Check that there are enough cm depths in the foreground worksheet
    if depth > size(grasp_data(index).(['cm' detno]){number}.cm_pixels,1);
        cm_depth = 1;
    else
        cm_depth = depth;
    end
    
    centre.(['det' detno]).cm_pixels = grasp_data(index).(['cm' detno]){number}.cm_pixels(cm_depth,:);
    centre.(['det' detno]).cm_translation = grasp_data(index).(['cm' detno]){number}.cm_translation(cm_depth,:);
    if isfield(grasp_data(index).(['cm' detno]){number},'cm_sigma_pixels');
        centre.(['det' detno]).cm_sigma_pixels = grasp_data(index).(['cm' detno]){number}.cm_sigma_pixels(cm_depth,:);
    end
    if isfield(grasp_data(index).(['cm' detno]){number},'x_kernel_x');
        if not(isempty(grasp_data(index).(['cm' detno]){number}.x_kernel_x));
        centre.(['det' detno]).x_kernel_x = grasp_data(index).(['cm' detno]){number}.x_kernel_x(cm_depth,:);
        centre.(['det' detno]).x_kernel_q = grasp_data(index).(['cm' detno]){number}.x_kernel_q(cm_depth,:);
        centre.(['det' detno]).x_kernel_weight = grasp_data(index).(['cm' detno]){number}.x_kernel_weight(cm_depth,:);
        centre.(['det' detno]).y_kernel_y = grasp_data(index).(['cm' detno]){number}.y_kernel_y(cm_depth,:);
        centre.(['det' detno]).y_kernel_q = grasp_data(index).(['cm' detno]){number}.y_kernel_q(cm_depth,:);
        centre.(['det' detno]).y_kernel_weight = grasp_data(index).(['cm' detno]){number}.y_kernel_weight(cm_depth,:);
        end
    end
end
    

