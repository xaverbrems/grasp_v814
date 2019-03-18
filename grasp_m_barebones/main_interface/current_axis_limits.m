function axis_lims = current_axis_limits(limits)

%Returns the current axis limits in all options, pixels, q and 2theta
%for all detectors
%Output structure looks like:   axis_lims.det1.pixels
%                                        .det1.q
%                                        .det1.theta2

global grasp_handles
global status_flags
global displayimage
global inst_params


axis_lims = [];
current_axis_units = status_flags.axes.current;

%loop though the detectors
for det = 1:inst_params.detectors
    detno=num2str(det);
    
    
    if strcmp(current_axis_units,'p') || strcmp(current_axis_units,'q') || strcmp(current_axis_units,'t')
        
        if nargin ==0
            %Retrieve current axis limits from axis
            xlims = get(grasp_handles.displayimage.(['axis' detno]),'xlim');
            ylims = get(grasp_handles.displayimage.(['axis' detno]),'ylim');
        else
            xlims = limits(1:2);
            ylims = limits(3:4);
        end
        
        %Now re-convert the given axis limits back to all units, pixels, q, 2theta
        switch current_axis_units
            case 'p'
        
                x1_difference = abs(displayimage.(['qmatrix' detno])(1,:,1) - xlims(1));
                [~, x1_index] = min(x1_difference);
                x2_difference = abs(displayimage.(['qmatrix' detno])(1,:,1) - xlims(2));
                [~, x2_index] = min(x2_difference);
                
                y1_difference = abs(displayimage.(['qmatrix' detno])(:,1,2) - ylims(1));
                [~, y1_index] = min(y1_difference);
                y2_difference = abs(displayimage.(['qmatrix' detno])(:,1,2) - ylims(2));
                [~, y2_index] = min(y2_difference);
                
            case 'q'
                x1_difference = abs(displayimage.(['qmatrix' detno])(1,:,3) - xlims(1));
                [~, x1_index] = min(x1_difference);
                x2_difference = abs(displayimage.(['qmatrix' detno])(1,:,3) - xlims(2));
                [~, x2_index] = min(x2_difference);
                
                y1_difference = abs(displayimage.(['qmatrix' detno])(:,1,4) - ylims(1));
                [~, y1_index] = min(y1_difference);
                y2_difference = abs(displayimage.(['qmatrix' detno])(:,1,4) - ylims(2));
                [~, y2_index] = min(y2_difference);
            
            case 't'
                x1_difference = abs(displayimage.(['qmatrix' detno])(1,:,7) - xlims(1));
                [~, x1_index] = min(x1_difference);
                x2_difference = abs(displayimage.(['qmatrix' detno])(1,:,7) - xlims(2));
                [~, x2_index] = min(x2_difference);
                
                y1_difference = abs(displayimage.(['qmatrix' detno])(:,1,8) - ylims(1));
                [~, y1_index] = min(y1_difference);
                y2_difference = abs(displayimage.(['qmatrix' detno])(:,1,8) - ylims(2));
                [~, y2_index] = min(y2_difference);
        end
        
        axis_lims.(['det' detno]).pixels = [displayimage.(['qmatrix' detno])(1,x1_index,1), displayimage.(['qmatrix' detno])(1,x2_index,1), displayimage.(['qmatrix' detno])(y1_index,1,2), displayimage.(['qmatrix' detno])(y2_index,1,2)];
        axis_lims.(['det' detno]).q = [displayimage.(['qmatrix' detno])(1,x1_index,3), displayimage.(['qmatrix' detno])(1,x2_index,3), displayimage.(['qmatrix' detno])(y1_index,1,4), displayimage.(['qmatrix' detno])(y2_index,1,4)];
        axis_lims.(['det' detno]).theta2 = [displayimage.(['qmatrix' detno])(1,x1_index,7), displayimage.(['qmatrix' detno])(1,x2_index,7), displayimage.(['qmatrix' detno])(y1_index,1,8), displayimage.(['qmatrix' detno])(y2_index,1,8)];
        %Unwrapped angle-radius
        [xmapping,ymapping] = cart2pol(displayimage.(['qmatrix' detno])(:,:,3),displayimage.(['qmatrix' detno])(:,:,4));
        axis_lims.(['det' detno]).a = [min(min(xmapping)), max(max(xmapping)),min(min(ymapping)),max(max(ymapping))];

        
    elseif strcmp(current_axis_units,'a')
        %Unwrapped angle-radius
        [xmapping,ymapping] = cart2pol(displayimage.(['qmatrix' detno])(:,:,3),displayimage.(['qmatrix' detno])(:,:,4));
        axis_lims.(['det' detno]).a = [min(min(xmapping)), max(max(xmapping)),min(min(ymapping)),max(max(ymapping))];
        %Pixels
        xmin = min(displayimage.(['qmatrix' num2str(det)])(1,:,1)); xmax = max(displayimage.(['qmatrix' num2str(det)])(1,:,1));
        ymin = min(displayimage.(['qmatrix' num2str(det)])(:,1,2)); ymax = max(displayimage.(['qmatrix' num2str(det)])(:,1,2));
        axis_lims.(['det' detno]).pixels= [xmin,xmax,ymin,ymax];
        %q
        xmin = min(displayimage.(['qmatrix' num2str(det)])(1,:,3)); xmax = max(displayimage.(['qmatrix' num2str(det)])(1,:,3));
        ymin = min(displayimage.(['qmatrix' num2str(det)])(:,1,4)); ymax = max(displayimage.(['qmatrix' num2str(det)])(:,1,4));
        axis_lims.(['det' detno]).q = [xmin,xmax,ymin,ymax];
        %2theta
        xmin = min(displayimage.(['qmatrix' num2str(det)])(1,:,7)); xmax = max(displayimage.(['qmatrix' num2str(det)])(1,:,7));
        ymin = min(displayimage.(['qmatrix' num2str(det)])(:,1,8)); ymax = max(displayimage.(['qmatrix' num2str(det)])(:,1,8));
        axis_lims.(['det' detno]).theta2 = [xmin,xmax,ymin,ymax];
        
        
    end
end
    
    
