function sigma = sanspol_correct(i0, i1, p, pf)


%Nomenclature is: + or 0 for Flipper off and - or 1 for Flipper on


%p = [value,error] Supermirror Polarisation (%), i.e.  (I+ - I-) / (I+ + I-)
%pf = [value,error] flipper1 polarisation

%I0 =  (1+p)/2 sigma0 + (1-p)/2 sigma1
%I1 =  (1- p*pf)/2 sigma0 + (1+ p*pf)/2 sigma1
%I = Inverse[P] Sigma




				   

global inst_params

%Correction Matricies 

P = (1./(p(1).*(1+pf(1)))).*[(1+p(1).*pf(1)) (p(1)-1);(p(1).*pf(1)-1) (1+p(1))];



%Derivative of Correction Matricies (compare eq. 15 in Wildes Paper)
dP_dp =(1./((1+pf(1)).*p(1).^2)).*[-1 1;1 -1];
dP_dpf = (1./(p(1).*(1+pf(1)).^2)).*[(p(1)-1) (1-p(1));(1+p(1)) (-1-p(1))];





%Loop though the instruments detectors
for det = 1:inst_params.detectors
    detno=num2str(det);
    temp = size(i0.(['data' detno]));
    
    %Switch to temporary variables - quicker than using structure addressing in the loop
    sigma_i0_data = zeros(temp(1),temp(2));
    sigma_i1_data = zeros(temp(1),temp(2));
   
    
    sigma_i0_error = zeros(temp(1),temp(2));
    sigma_i1_error = zeros(temp(1),temp(2));
  
    
    i0_data = i0.(['data' detno]);
    i1_data = i1.(['data' detno]);
 
    
    i0_error = i0.(['error' detno]);
    i1_error = i1.(['error' detno]);
   

    %Need to loop though the detector matrix one by one as each pixel
    %correction is a matrix operation in itself.
    for n = 1:temp(1);
        for m = 1:temp(2);
            I = [i0_data(n,m);i1_data(n,m)];
            sigma_temp = P*I;
            
            sigma_i0_data(n,m) = sigma_temp(1); 
            sigma_i1_data(n,m) = sigma_temp(2);
           
            
            %Error Propogation compare eq.15 Wildes
            
            dsigma_temp1 = (p(2)*dP_dp*I).^2;
            dsigma_temp2 = (pf(2)*dP_dpf*I).^2;
            
            dI = [i0_error(n,m);i1_error(n,m)]; 
            dI_squared = dI.^2;
            dsigma_temp3 = ((P).^2)*dI_squared;
            
         
            
            dsigma_temp_squared = dsigma_temp1 + dsigma_temp2 + dsigma_temp3;
            dsigma_temp = sqrt(dsigma_temp_squared);

            sigma_i0_error(n,m) = dsigma_temp(1); 
            sigma_i1_error(n,m) = dsigma_temp(2);
            end
    end
    
    %Assemble into final output matrix structure
    sigma.i0.(['data' detno]) = sigma_i0_data;
    sigma.i1.(['data' detno]) = sigma_i1_data;
  
    
    sigma.i0.(['error' detno]) = sigma_i0_error;
    sigma.i1.(['error' detno]) = sigma_i1_error;
 

    
end







