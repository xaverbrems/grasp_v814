function inst_config = instrument_ini(fname)

inst_config = [];

fid=fopen(fname); %Open default instrument .ini file
line = 1;
line2 = 1;
runcode = [];
warning off

if not(fid==-1)
    disp(['Loading Instrument Configuration from ' fname]);
    
    while line~=-1
        line = fgets(fid);

        %Facility
        if findstr(line,'Facility=')
            eqpos = findstr(line,'=');
            len = length(line);
            inst_config.facility = strtok(line(eqpos+1:len));
        end
        
        %Instrument
        if findstr(line,'Instrument=')
            eqpos = findstr(line,'=');
            len = length(line);
            inst_config.instrument = strtok(line(eqpos+1:len));
        end
        
        %Instrument Config RunCode
        if findstr(line,'RunCode')
            line = fgets(fid);            
            while line~=-1 & not(strcmp(line,'EndRunCode'))
                runcode = [runcode ';' line];
                line = fgets(fid);
            end
            inst_config.runcode = runcode;
            
        end
        
    end
end
fclose(fid);
warning on
