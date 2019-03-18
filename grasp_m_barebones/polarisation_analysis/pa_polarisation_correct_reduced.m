function sigma = pa_polarisation_correct_reduced(i00, i10,  p, pf, T00_para, T00_anti,T10_para, T10_anti)

%Spin leakage for only two spin states. Assumption that NSF scattering both equal and SF
%equal.
%Nomenclature is: + or 0 for Flipper off and - or 1 for Flipper on
%

%p = [value,error] Supermirror Polarisation (%), i.e.  (I+ - I-) / (I+ + I-)
%Txx_para/anti = [value,error] Analyser transmission for neutron spin parallel/antiparallel to 3He nuclei at data collection time of the 'xx' channel
%pf = [value,error] flipper1 polarisation

%i00, i10 are the full selector structures, e.g. i00.data1, i00.error1 etc




				   

global inst_params

%Correction Matrice
A=[T10_para(1)./(-T00_anti(1).*T10_anti(1) + T00_para(1).*T10_para(1)) (-T00_anti(1)./(-T00_anti(1).*T10_anti(1) + T00_para(1).*T10_para(1))); (-T10_anti(1)./(-T00_anti(1).*T10_anti(1) + T00_para(1).*T10_para(1))) T00_para(1)./(-T00_anti(1).*T10_anti(1) + T00_para(1).*T10_para(1))];
 
Pf = (1./(1+pf(1))).*[(1+pf(1)) 0; (pf(1)-1) 2];
P = (1./(2*p(1))).*[(1+p(1)) (p(1)-1);(p(1)-1) (1+p(1))];



%Derivative of Correction Matricies (compare eq. 15 in Wildes Paper)
dPf_dpf =(2/(1+pf(1)).^2).* [0 0; 1 -1];
dP_dp = (1./(2*(p(1)).^2)).* [-1 1 ; 1 -1];


dA_dT00para = (1./((T00_anti(1)-T00_para(1)).^2)).* [-1 2.*T00_anti(1)./(T10_anti(1)+T10_para(1));1 (-2.*T00_anti(1))./(T10_anti(1)+T10_para(1))];
dA_dT00anti = (1./((T00_anti(1)-T00_para(1)).^2)).*[1 (-2.*T00_para(1)./(T10_anti(1)+T10_para(1)));-1 (2.*T00_anti(1))./(T10_anti(1)+T10_para(1))];

dA_dT10para = (1./(T00_anti(1)-T00_para(1))./((T10_anti(1)+T10_para(1)).^2)).* [0 -2.*T00_anti(1);0 2.*T00_para(1)];
dA_dT10anti = (1./(T00_anti(1)-T00_para(1))./((T10_anti(1)+T10_para(1)).^2)).* [0 -2.*T00_anti(1);0 2.*T00_para(1)];



%Loop though the instruments detectors
for det = 1:inst_params.detectors
    detno=num2str(det);
    temp = size(i00.(['data' detno]));
    
    %Switch to temporary variables - quicker than using structure addressing in the loop
    sigma_i00_data = zeros(temp(1),temp(2));
    sigma_i10_data = zeros(temp(1),temp(2));
  
    
    sigma_i00_error = zeros(temp(1),temp(2));
    sigma_i10_error = zeros(temp(1),temp(2));

    
    i00_data = i00.(['data' detno]);
    i10_data = i10.(['data' detno]);
   
    
    i00_error = i00.(['error' detno]);
    i10_error = i10.(['error' detno]);
    

    %Need to loop though the detector matrix one by one as each pixel
    %correction is a matrix operation in itself.
    for n = 1:temp(1);
        for m = 1:temp(2);
            I = [i00_data(n,m);i10_data(n,m)];
            sigma_temp = P*Pf*A*I;
            
            sigma_i00_data(n,m) = sigma_temp(1); 
            sigma_i10_data(n,m) = sigma_temp(2);
            
            
            %Error Propogation compare eq.15 Wildes
            
            dsigma_temp1 = (p(2)*dP_dp*Pf*A*I).^2;
            dsigma_temp2 = (pf(2)*P*dPf_dpf*A*I).^2;
            
            dI = [i00_error(n,m);i10_error(n,m)]; 
            dI_squared = dI.^2;
            dsigma_temp3 = ((P*Pf*A).^2)*dI_squared;
            
            dsigma_temp00p = (T00_para(2)*P*Pf*dA_dT00para*I).^2;
            dsigma_temp00a = (T00_anti(2)*P*Pf*dA_dT00anti*I).^2;
            
            dsigma_temp10p = (T10_para(2)*P*Pf*dA_dT10para*I).^2;
            dsigma_temp10a = (T10_anti(2)*P*Pf*dA_dT10anti*I).^2;
            
            
            
            dsigma_temp_squared = dsigma_temp1 + dsigma_temp2 + dsigma_temp3 + dsigma_temp00p + dsigma_temp00a + dsigma_temp10p + dsigma_temp10a ;
            dsigma_temp = sqrt(dsigma_temp_squared);

            sigma_i00_error(n,m) = dsigma_temp(1); 
            sigma_i10_error(n,m) = dsigma_temp(2);
            
        end
    end
    
    %Assemble into final output matrix structure
    sigma.i00.(['data' num2str(det)]) = sigma_i00_data;
    sigma.i10.(['data' num2str(det)]) = sigma_i10_data;
   
    
    sigma.i00.(['error' num2str(det)]) = sigma_i00_error;
    sigma.i10.(['error' num2str(det)]) = sigma_i10_error;


    
end







