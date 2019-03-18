function [cm] = centre_of_mass(cm_image,axis_lims)

%calcualtes the center of mass of a given intensity matrix
%cm_image is a 2D matrix of intensity values
%axis_lims is [xmin xmax ymin ymax]


%Calcualte centre positions

%Centre_x
intensity_sum_x = sum(cm_image,1);  %Sum intensities vertically ~masses
x_array = [axis_lims(1):axis_lims(2)]; %Position indicies
moment = intensity_sum_x.*x_array;  %Intensity * position ~ moment
cm.cm(1) = sum(moment) / sum(intensity_sum_x); % Centre of mass = sum(moments) / sum(masses)

%Centre_y
intensity_sum_y = rot90(sum(cm_image,2));  %Sum intensities vertically ~masses (rotated 90 to match the y_array dimensions
y_array = [axis_lims(3):axis_lims(4)]; %Position indicies
moment = intensity_sum_y.*y_array;  %Intensity * position ~ moment
cm.cm(2) = sum(moment) / sum(intensity_sum_y); % Centre of mass = sum(moments) / sum(masses)

%Calculate Variance (standard deviation)
%variance_x_pixels = sum(intensity_sum_x.*(x_array - cm.cm(1)).^2)/(sum(intensity_sum_x));
%variance_y_pixels = sum(intensity_sum_y.*(y_array - cm.cm(2)).^2)/(sum(intensity_sum_y));
%cm.sigma_pixels = [sqrt(variance_x_pixels), sqrt(variance_y_pixels)];

%Keep a store of the normalised direct beam kernel shape
temp = x_array-cm.cm(1);
cm.x_kernel_x = zeros(1,128)*NaN; %Pad out to something much larger (e.g. 128) to avoid problems with variable size zoom box over beam
cm.x_kernel_x(1:length(temp)) = temp; %Centre Pixels (convert to q later)
%cm.x_kernel_x = x_array-cm.cm(1); %Centre Pixels (convert to q later)

temp = intensity_sum_x ./(sum(intensity_sum_x));
cm.x_kernel_weight = zeros(1,128)*NaN; %Pad out to something much larger (e.g. 128) to avoid problems with variable size zoom box over beam
cm.x_kernel_weight(1:length(temp)) = temp;
%cm.x_kernel_weight = intensity_sum_x ./(sum(intensity_sum_x));

temp = y_array-cm.cm(2);
cm.y_kernel_y = zeros(1,128)*NaN; %Pad out to something much larger (e.g. 128) to avoid problems with variable size zoom box over beam
cm.y_kernel_y(1:length(temp)) = temp;
%cm.y_kernel_y = y_array-cm.cm(2); %Centred Pixels (convert to q later)

temp = intensity_sum_y ./(sum(intensity_sum_y));
cm.y_kernel_weight = zeros(1,128)*NaN; %Pad out to something much larger (e.g. 128) to avoid problems with variable size zoom box over beam
cm.y_kernel_weight(1:length(temp)) = temp;
%cm.y_kernel_weight = intensity_sum_y ./(sum(intensity_sum_y));
