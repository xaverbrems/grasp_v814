function pa_cell = pa_cell_optimise_polarisation(opacity,phe0,t_emptycell,time,duration,t1,t0,p)

if nargin<8;
   p = [1 0]; %pol = supermirror polarisation
   
end

if nargin<7;
   t0 = [0 0]; %t0 = time offset 
end
if nargin<6;
   t1 = [1 0]; %t1 = 3he decay constant 
end
if nargin<5;
   duration = 0; %duration of measurement [hrs]
end
if nargin<4;
   time = 0; %time = time relative to origin of 3He cell [hrs]
end
if nargin<3;
   t_emptycell = [1 0]; %Transmission of empty cell
   
end
if nargin<2;
    phe0 = [0.75 0]; %3He Polarisation
end    




%Constants
sigma_a = 5333; %Barns   absorbtion cross-section for unpolarised neutrons
sigma_a = sigma_a * 1e-28; %m^2
wav0 = 1.7982; %angs
Na = 6.02214179*10^23; %Avagadro
R = 8.314;  %Molar gas constant
T = 300;  %(K) Cell Temperature
cons_cell = 100000*(Na/(R*T*100))*(sigma_a/wav0);

%Keep a store of the opacity array for future use
pa_cell.opacity_array = opacity(1);

%Keep a store of the time array for future use
pa_cell.time_array = time;

%Model Cell Polarisation Decay
pa_cell.phe = phe0(1) *exp(-(time+t0(1))/t1(1));

%Model Cell Transmission Parallel and Anti-Parallel
pa_cell.t_para= 0.5*t_emptycell(1)*exp(-opacity(1)*cons_cell*(1-pa_cell.phe));
pa_cell.t_anti = 0.5*t_emptycell(1)*exp(-opacity(1)*cons_cell*(1+pa_cell.phe));

%Error Propogation in Cell Transmission
pa_cell.dt_temp1 = (t_emptycell(2)/t_emptycell(1)).^2;
pa_cell.dt_temp3 = (phe0(2)*cons_cell*opacity(1)*exp(-(time+t0(1))/t1(1))).^2;
pa_cell.dt_temp4 = (-duration/t1(1)*phe0(1)*cons_cell*opacity(1)*exp(-(time+t0(1))/t1(1))).^2;
pa_cell.dt_temp5 = (-t0(2)/t1(1)*phe0(1)*cons_cell*opacity(1)*exp(-(time+t0(1))/t1(1))).^2;
pa_cell.dt_temp6 = (-t1(2)*(time(1)+t0(1))/t1(1)/t1(1)*phe0(1)*cons_cell*opacity(1)*exp(-(time+t0(1))/t1(1))).^2;

pa_cell.dt_para_temp2 = (opacity(2)*cons_cell*(-1+phe0(1)*exp(-(time+t0(1))/t1(1)))).^2;
pa_cell.dt_anti_temp2 = (-opacity(2)*cons_cell*(1+phe0(1)*exp(-(time+t0(1))/t1(1)))).^2;

pa_cell.dt_para_squared = (pa_cell.dt_temp1 + pa_cell.dt_para_temp2 + pa_cell.dt_temp3 + pa_cell.dt_temp4+ pa_cell.dt_temp5+ pa_cell.dt_temp6).*pa_cell.t_para.^2 ;
pa_cell.dt_para = sqrt(pa_cell.dt_para_squared);

pa_cell.dt_anti_squared = (pa_cell.dt_temp1 + pa_cell.dt_anti_temp2 + pa_cell.dt_temp3 + pa_cell.dt_temp4+ pa_cell.dt_temp5+ pa_cell.dt_temp6).*pa_cell.t_anti.^2 ;
pa_cell.dt_anti = sqrt(pa_cell.dt_para_squared);


%Total Transmission
pa_cell.t_total = pa_cell.t_para + pa_cell.t_anti;


%Polarisation of an unpolarised neutron beam
pa_cell.pol = (pa_cell.t_para-pa_cell.t_anti)./(pa_cell.t_para+pa_cell.t_anti);
pa_cell.pol_anti = (pa_cell.t_anti-pa_cell.t_para)./(pa_cell.t_para+pa_cell.t_anti);
%combined polarisation of Supermirror Polarizer and 3He cell
 pa_cell.phi=p(1).*pa_cell.pol;
%Figure of Merit P^2 T
pa_cell.fom = pa_cell.t_total.*pa_cell.pol.^2;

