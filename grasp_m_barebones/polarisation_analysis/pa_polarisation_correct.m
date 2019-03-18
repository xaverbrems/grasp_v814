function sigma = pa_polarisation_correct(i00, i10, i11, i01, p, pf, T00_para, T00_anti,T10_para, T10_anti,T11_para, T11_anti,T01_para, T01_anti)

%based on Wildes - Pol & Annal made easy and Krycka Pol-Corr J. Appl. Cryst. (2012). 45, 546–553
%Nomenclature is: + or 0 for Flipper off and - or 1 for Flipper on
%with [I] =Inverse[[P][Pf][A]][Sigma] 

%p = [value,error] Supermirror Polarisation (%), i.e.  (I+ - I-) / (I+ + I-)
%Txx_para/anti = [value,error] Analyser transmission for neutron spin parallel/antiparallel to 3He nuclei at data collection time of the 'xx' channel
%pf = [value,error] flipper1 polarisation

%i00, i01 etc are the full selector structures, e.g. i00.data1, i00.error1 etc




				   

global inst_params

%Correction Matricies (eq. 4a)
Pf = (1./(1+pf(1))).*[(1+pf(1)) 0 0 0; (pf(1)-1) 2 0 0;0 0 2 (pf(1)-1); 0 0 0 (pf(1)+1)];
P = (1./(2*p(1))).*[(1+p(1)) (p(1)-1) 0 0;(p(1)-1) (1+p(1)) 0 0 ;0 0 (1+p(1)) (p(1)-1); 0 0 (p(1)-1) (1+p(1))];
A = [T01_para(1)./(T00_para(1).*T01_para(1)-T00_anti(1).*T01_anti(1)) 0 0 (-T00_anti(1)./(T00_para(1).*T01_para(1)-T00_anti(1).*T01_anti(1)));0 T11_para(1)./(T10_para(1).*T11_para(1)-T10_anti(1).*T11_anti(1))  (-T10_anti(1)./(T10_para(1).*T11_para(1)-T10_anti(1).*T11_anti(1))) 0;0 (-T11_anti(1)./(T10_para(1).*T11_para(1)-T10_anti(1).*T11_anti(1)))  T10_para(1)./(T10_para(1).*T11_para(1)-T10_anti(1).*T11_anti(1)) 0;(-T01_anti(1)./(T00_para(1).*T01_para(1)-T00_anti(1).*T01_anti(1))) 0 0 T00_para(1)./(T00_para(1).*T01_para(1)-T00_anti(1).*T01_anti(1))];



%Derivative of Correction Matricies (compare eq. 15 in Wildes Paper)
dPf_dpf =(2/(1+pf(1)).^2).* [0 0 0 0; 1 -1 0 0;0 0 -1 1; 0 0 0 0];
dP_dp = (1./(2*(p(1)).^2)).* [-1 1 0 0; 1 -1 0 0; 0 0 -1 1; 0 0 1 -1];


dA_dT00para = (1./((T00_para(1).*T01_para(1)-T00_anti(1).*T01_anti(1)).^2)).* [-T01_para(1).^2 0 0 T01_para(1).*T00_anti(1);0 0 0 0;0 0 0 0;T01_para(1).*T01_anti(1) 0 0 -T00_anti(1).*T01_anti(1)];
dA_dT00anti = (1./((T00_para(1).*T01_para(1)-T00_anti(1).*T01_anti(1)).^2)).* [T01_para(1).*T01_anti(1) 0 0 -T00_para(1).*T01_para(1);0 0 0 0;0 0 0 0;-T01_anti(1).^2 0 0 T00_para(1).*T01_anti(1)];

dA_dT01para = (1./((T00_para(1).*T01_para(1)-T00_anti(1).*T01_anti(1)).^2)).* [-T00_anti(1).*T01_anti(1) 0 0 T00_para(1).*T00_anti(1);0 0 0 0;0 0 0 0;T00_para(1).*T01_anti(1) 0 0 -T00_para(1).^2];
dA_dT01anti = (1./((T00_para(1).*T01_para(1)-T00_anti(1).*T01_anti(1)).^2)).* [T01_para(1).*T00_anti(1) 0 0 -T00_anti(1).^2;0 0 0 0;0 0 0 0;-T01_para(1).*T00_para(1) 0 0 T00_para(1).*T00_anti(1)];

dA_dT10para = (1./((T10_para(1).*T11_para(1)-T10_anti(1).*T11_anti(1)).^2)).* [0 0 0 0;0 -T11_para(1).^2 T11_para(1).*T10_anti(1) 0;0 T11_para(1).*T11_anti(1) -T10_anti(1).*T11_anti(1) 0;0 0 0 0];
dA_dT10anti = (1./((T10_para(1).*T11_para(1)-T10_anti(1).*T11_anti(1)).^2)).* [0 0 0 0;0 T11_para(1).*T11_anti(1) -T10_para(1).*T11_para(1) 0;0 -T11_anti(1).^2 T10_para(1).*T11_anti(1) 0;0 0 0 0];

dA_dT11para = (1./((T10_para(1).*T11_para(1)-T10_anti(1).*T11_anti(1)).^2)).* [0 0 0 0;0 -T10_anti(1).*T11_anti(1) T10_para(1).*T10_anti(1) 0;0 T10_para(1).*T11_anti(1) -T10_para(1).^2 0;0 0 0 0];
dA_dT11anti = (1./((T10_para(1).*T11_para(1)-T10_anti(1).*T11_anti(1)).^2)).* [0 0 0 0;0 T11_para(1).*T10_anti(1) -T10_anti(1).^2 0;0 -T10_para(1).*T11_para(1) T10_para(1).*T10_anti(1) 0;0 0 0 0];


%Loop though the instruments detectors
for det = 1:inst_params.detectors
    detno=num2str(det);
    temp = size(i00.(['data' detno]));
    
    %Switch to temporary variables - quicker than using structure addressing in the loop
    sigma_i00_data = zeros(temp(1),temp(2));
    sigma_i10_data = zeros(temp(1),temp(2));
    sigma_i11_data = zeros(temp(1),temp(2));
    sigma_i01_data = zeros(temp(1),temp(2));
    
    sigma_i00_error = zeros(temp(1),temp(2));
    sigma_i10_error = zeros(temp(1),temp(2));
    sigma_i11_error = zeros(temp(1),temp(2));
    sigma_i01_error = zeros(temp(1),temp(2));
    
    i00_data = i00.(['data' detno]);
    i10_data = i10.(['data' detno]);
    i11_data = i11.(['data' detno]);
    i01_data = i01.(['data' detno]);
    
    i00_error = i00.(['error' detno]);
    i10_error = i10.(['error' detno]);
    i11_error = i11.(['error' detno]);
    i01_error = i01.(['error' detno]);

    %Need to loop though the detector matrix one by one as each pixel
    %correction is a matrix operation in itself.
    for n = 1:temp(1);
        for m = 1:temp(2);
            I = [i00_data(n,m);i10_data(n,m);i11_data(n,m);i01_data(n,m)];
            sigma_temp = P*Pf*A*I;
            
            sigma_i00_data(n,m) = sigma_temp(1); 
            sigma_i10_data(n,m) = sigma_temp(2);
            sigma_i11_data(n,m) = sigma_temp(3);
            sigma_i01_data(n,m) = sigma_temp(4);
            
            %Error Propogation compare eq.15 Wildes
            
            dsigma_temp1 = (p(2)*dP_dp*Pf*A*I).^2;
            dsigma_temp2 = (pf(2)*P*dPf_dpf*A*I).^2;
            
            dI = [i00_error(n,m);i10_error(n,m);i11_error(n,m);i01_error(n,m)]; 
            dI_squared = dI.^2;
            dsigma_temp3 = ((P*Pf*A).^2)*dI_squared;
            
            dsigma_temp00p = (T00_para(2)*P*Pf*dA_dT00para*I).^2;
            dsigma_temp00a = (T00_anti(2)*P*Pf*dA_dT00anti*I).^2;
            
            dsigma_temp10p = (T10_para(2)*P*Pf*dA_dT10para*I).^2;
            dsigma_temp10a = (T10_anti(2)*P*Pf*dA_dT10anti*I).^2;
            
            dsigma_temp11p = (T11_para(2)*P*Pf*dA_dT11para*I).^2;
            dsigma_temp11a = (T11_anti(2)*P*Pf*dA_dT11anti*I).^2;
            
            dsigma_temp01p = (T01_para(2)*P*Pf*dA_dT01para*I).^2;
            dsigma_temp01a = (T01_anti(2)*P*Pf*dA_dT01anti*I).^2;
            
            dsigma_temp_squared = dsigma_temp1 + dsigma_temp2 + dsigma_temp3 + dsigma_temp00p + dsigma_temp00a + dsigma_temp10p + dsigma_temp10a + dsigma_temp11p + dsigma_temp11a + dsigma_temp01p + dsigma_temp01a;
            dsigma_temp = sqrt(dsigma_temp_squared);

            sigma_i00_error(n,m) = dsigma_temp(1); 
            sigma_i10_error(n,m) = dsigma_temp(2);
            sigma_i11_error(n,m) = dsigma_temp(3);
            sigma_i01_error(n,m) = dsigma_temp(4);
        end
    end
    
    %Assemble into final output matrix structure
    sigma.i00.(['data' detno]) = sigma_i00_data;
    sigma.i10.(['data' detno]) = sigma_i10_data;
    sigma.i11.(['data' detno]) = sigma_i11_data;
    sigma.i01.(['data' detno]) = sigma_i01_data;
    
    sigma.i00.(['error' detno]) = sigma_i00_error;
    sigma.i10.(['error' detno]) = sigma_i10_error;
    sigma.i11.(['error' detno]) = sigma_i11_error;
    sigma.i01.(['error' detno]) = sigma_i01_error;

    
end







