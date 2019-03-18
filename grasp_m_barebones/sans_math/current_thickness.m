function [thickness] = current_thickness

%Reads back the current sample thickness associated with the worksheet, taking into acount thickness lock

global grasp_data
global status_flags

%Find the pointers and type of the current displayed worksheet
thickness_lock = status_flags.thickness.thickness_lock;
thickness_number = status_flags.thickness.thickness_number;
thickness_depth = status_flags.thickness.thickness_depth;

flag = status_flags.selector.fw;  %This is the type of worksheet we are dealing with: foregrounds or calibrations
if flag >=1 && flag <= 7 %Then usual sample data;
    thickness_worksheet = 1;
elseif flag >= 12 && flag <= 19 %PA00, 10, 11, 01 Sample & Backgrounds
    thickness_worksheet = 12;
elseif flag >=22 && flag <= 23 %Sanspol Sample I0,I1
    thickness_worksheet = 1;
else %All other cases such as detector efficiency
    thickness = 0.1; %default
    return
end

index = data_index(thickness_worksheet);

%Correct depths for SUM worksheets
thickness_depth = thickness_depth-grasp_data(index).sum_allow;
if thickness_depth ==0; thickness_depth = 1; end %The sum worksheet for the time being uses the thickness of the 1st depth

%Retrieve thickness


thickness = grasp_data(index).thickness{thickness_number}(thickness_depth);


