function  output = pa_analyser(selector)

global status_flags
global grasp_data


        p = status_flags.pa_optimise.parameters.p; %supermirror polarisation & error
        %pf = status_flags.pa_optimise.parameters.pf; %rf polarisation flipping & error
        opacity = status_flags.pa_optimise.parameters.opacity; %3He Opacity & error
        phe0 = status_flags.pa_optimise.parameters.phe0; %3He initial polarisation @ t0 &  error
        t_emptycell = status_flags.pa_optimise.parameters.t_emptycell; %transmission of empty 3He cell &  error
        t1 = status_flags.pa_optimise.parameters.t1; %3He time constant & error
        t0 = status_flags.pa_optimise.parameters.t0; %Time offset & error


        %Run through all the depths and calculate 3He Analyser status 
        
        
         
        %Find the worksheet we are dealing with
        wks = selector;      
        index = data_index(wks);
        nmbr = status_flags.selector.fn;
        total_depth = grasp_data(index).dpth{nmbr};
       % depth_start = status_flags.selector.fd; %remember the initial foreground depth
        
        disp(' ')
        disp(['Collecting time & Analyser Characteristics through depth for wks '  num2str(wks,'%5g') ' no ' num2str(nmbr,'%5g') ]);
        disp(['Depth #:  Mid-point Time Stamp: Duration (min):  3He cell time (h)']);
        output.pa_analyser.mid_point_time=zeros([total_depth,1]);
        output.pa_analyser.duration=zeros([total_depth,1]);
        output.pa_analyser.time=zeros([total_depth,1]);
        for n = 1:total_depth
         
          
            
        %Calculate time midpoint for measurement
        start_date = grasp_data(index).params1{nmbr}{n}.start_date;
        start_time = grasp_data(index).params1{nmbr}{n}.start_time;
        end_date = grasp_data(index).params1{nmbr}{n}.end_date;
        end_time = grasp_data(index).params1{nmbr}{n}.end_time;
        temp1 = datenum([start_date start_time]);
        temp2 = datenum([end_date end_time]);
        output.pa_analyser.mid_point_time(n) = temp1+(temp2-temp1)/2;
        output.pa_analyser.duration(n) = (temp2-temp1).* 24; %hrs
        

        
        %reference time (of first pa check measurement)
        reference_time = status_flags.pa_optimise.polarisation.absolute_time(1);
        %Time of current measurements being processed relative to 3He cell time-origin
        output.pa_analyser.time(n) = (output.pa_analyser.mid_point_time(n) - reference_time).* 24; %hrs
       
        %Display results in the comment window
        disp([num2str(n) char(9) datestr(output.pa_analyser.mid_point_time(n)) char(9) num2str(output.pa_analyser.duration(n)*60) char(9) num2str(output.pa_analyser.time(n))])
        end
        
        
        
        disp(['3He cell time is relative to first PA check']);  
        %Set selector back to where it was in the beginning
       % status_flags.selector.fd = depth_start;
     
        

        
        %Calculate Polarisation
        status_flags.pa_polarisation_analyser.polarisation = [];
        for n = 1:total_depth;
            temp = pa_cell_optimise_polarisation(opacity,phe0,t_emptycell,output.pa_analyser.time(n),output.pa_analyser.duration(n),t1,t0,p);
              
       
        
        output.pa_analyser.t_para(n)=temp.t_para;
        output.pa_analyser.t_anti(n)=temp.t_anti;
        output.pa_analyser.a(n)=temp.pol;
                
        output.pa_analyser.err_t_para(n)=temp.dt_para;
        output.pa_analyser.err_t_anti(n)=temp.dt_anti;
            
             
        end
       
        
        %Display Polarisation Data vs Time in the Text window
        disp(['3He Cell Transmission and Polarisation Power ']);
        disp('   T_para     T_anti   a');
        
        
        
        output.pa_analyser.tpara_list = zeros(total_depth, 2);
        output.pa_analyser.tanti_list = zeros(total_depth, 2);
        %tpara_list = []; 
        %tanti_list = []; 
        for n = 1:total_depth
            disp([ num2str(output.pa_analyser.t_para(n),'%5g') '  ' num2str(output.pa_analyser.t_anti(n),'%5g') '  ' num2str(output.pa_analyser.a(n),'%5g')])
            output.pa_analyser.tpara_list(n,:) = [output.pa_analyser.t_para(n), output.pa_analyser.err_t_para(n)];
            output.pa_analyser.tanti_list(n,:) = [output.pa_analyser.t_anti(n), output.pa_analyser.err_t_anti(n)];
        end
        %Calculate average 3He Transmission weighted with measured time
        output.pa_analyser.tpara_av = weighted_average_error(output.pa_analyser.tpara_list,output.pa_analyser.duration);
        output.pa_analyser.tanti_av = weighted_average_error(output.pa_analyser.tanti_list,output.pa_analyser.duration);
        disp(['average T_para: ' num2str(output.pa_analyser.tpara_av(1),'%5g') ' +- ' num2str(output.pa_analyser.tpara_av(2),'%5g')]);
        disp(['average T_anti: ' num2str(output.pa_analyser.tanti_av(1),'%5g') ' +- ' num2str(output.pa_analyser.tanti_av(2),'%5g')]);
          
        