function file_name_path = numor_decompress(file_name_path)

% Checks if the numor file exists. 
fid = fopen([file_name_path]); 
if fid == -1
    disp('Can''t find file:  Check Data Directory is Set and File exists');
    file_name_path = [];
    return
end
fclose(fid);

%Remove any compression extension from the extension
temp = length(file_name_path);
compress = [];
if strcmpi(file_name_path(temp-1:temp),'.z')
    compress = file_name_path(temp-1:temp);
    file_name_path = file_name_path(1:temp-2);
    decompress;
elseif strcmpi(file_name_path(temp-2:temp),'.gz')
    compress = file_name_path(temp-2:temp);
    file_name_path = file_name_path(1:temp-3);
    decompress;
end




%Decompression performed for zipped data only. 
function decompress
     
%If decompressing
%Copy compressed File to temporay local location and Uncompress
%Requires gunzip to be in the current dos path
disp('Decompressing Data');
if isunix
    eval(['!cp "' file_name_path compress '" ' tempdir 'grasp_temp' compress]);
else
    %copyfile([fname compress],[tempdir addzeros numorstr compress]); %Use This for General Purpose Matlab Code
    eval(['!copy ' '"' file_name_path compress '"' ' ' tempdir 'grasp_temp' compress]); %Use this for Compiled PC code
end

eval(['!gzip -f -d -q ' tempdir 'grasp_temp' compress]);
file_name_path = [tempdir 'grasp_temp'];
end
end

