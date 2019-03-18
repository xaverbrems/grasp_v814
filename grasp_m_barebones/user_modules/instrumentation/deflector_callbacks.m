function deflector_callbacks(to_do)

if nargin ==0; to_do = ''; end

global deflector_transmission

global deflector
deflector_axis = findobj('tag','deflector_axis');
deflector_axis = deflector_axis(1);


switch to_do
    
    case 'grid'
        deflector.grid = get(gcbo,'value');
    
    case 'simple_detailed_ref'
        deflector.simple_detailed_ref = get(gcbo,'value');
        
    case 'wav_min'
        temp = str2num(get(gcbo,'string'));
        if ~isempty(temp)
            deflector.wav_min = temp;
        end
        set(gcbo,'string',num2str(deflector.wav_min));
        
    case 'wav_max'
        temp = str2num(get(gcbo,'string'));
        if ~isempty(temp)
            deflector.wav_max = temp;
        end
        set(gcbo,'string',num2str(deflector.wav_max));
        
    case 'm_guide'
        temp = str2num(get(gcbo,'string'));
        if ~isempty(temp)
            deflector.m_guide = temp;
        end
        set(gcbo,'string',num2str(deflector.m_guide));
        
    case 'm_mirror'
        temp = str2num(get(gcbo,'string'));
        if ~isempty(temp)
            deflector.m_mirror = temp;
        end
        set(gcbo,'string',num2str(deflector.m_mirror));
        
    case 'mirror_angle'
        temp = str2num(get(gcbo,'string'));
        if ~isempty(temp)
            deflector.mirror_angle = temp;
        end
        set(gcbo,'string',num2str(deflector.mirror_angle));
        
    case 'deflector_series'
        temp = str2num(get(gcbo,'string'));
        if ~isempty(temp)
            deflector.deflector_series = temp;
        end
        set(gcbo,'string',num2str(deflector.deflector_series));
        
    case 'deflector_type1'
        deflector.type1 = get(gcbo,'value');
        
    case 'deflector_type2'
        deflector.type2 = get(gcbo,'value');
        
    case 'show_ref'
        deflector.show_ref = get(gcbo,'value');
        
    case 'show_geo'
        deflector.show_geo = get(gcbo,'value');
        
    case 'show_si_trans'
        deflector.show_si_trans = get(gcbo,'value');
        
    case 'show_si_backref'
        deflector.show_si_backref = get(gcbo,'value');
        
    case 'hold_plots'
        deflector.hold_plots = get(gcbo,'value');
        return
        
    case 'legend'
        deflector.legend = get(gcbo,'value');
        temp = findobj('tag','deflector_legend');
        if deflector.legend ==0
            set(temp,'visible','off');
            return;
        else
            set(temp,'visible','on')
        end
        
    case 'polarized'
        deflector.polarized = get(gcbo,'value');
        
    case 'si_thickness'
        temp = str2num(get(gcbo,'string'));
        if ~isempty(temp)
            deflector.si_thickness = temp;
        end
        set(gcbo,'string',num2str(deflector.si_thickness));
        
    case 'Export'
        [fname, directory] = uiputfile(['/deflector_data.txt'],'Save Deflector Model Data');
        fid=fopen([directory fname],'w'); %Open File
        disp(['Exporting Deflector Model Data to: ' directory fname]);
        textstring = 'Deflector Parameters:';
        fprintf(fid,'%s \n',textstring);
        textstring = ['Guide_m: ' num2str(deflector.m_guide)];
        fprintf(fid,'%s \n',textstring);
        textstring = ['Deflector_m: ' num2str(deflector.m_mirror)];
        fprintf(fid,'%s \n',textstring);
        textstring = ['Deflector Angle [degs]: ' num2str(deflector.mirror_angle)];
        fprintf(fid,'%s \n',textstring);
        textstring = ['Silicon thickness (Type 2) [mm]: ' num2str(deflector.si_thickness)];
        fprintf(fid,'%s \n',textstring);
        fprintf(fid,'%s \n',' ');
        
        %Build export array
        deflector_matrix = [deflector_transmission.wav'];
        textstring = ['Wavelength'];
        if deflector.type1 == 1
            if deflector.polarized ==0 %Non-Polarizing
                deflector_matrix = [deflector_matrix, deflector_transmission.type1'];
                textstring = [textstring,' Type1'];
            else %Polarizing
                deflector_matrix = [deflector_matrix, deflector_transmission.type1_pol_trans', deflector_transmission.polarisation', deflector_transmission.type1_p2t'];
                textstring = [textstring,' Type1_PolTrans', ' Polarization', ' Type1_P2T'];
            end
        end
        
        if deflector.type2 == 1
            if deflector.polarized ==0 %Non-Polarizing
                deflector_matrix = [deflector_matrix, deflector_transmission.type2'];
                textstring = [textstring,' Type2'];
            else %Polarizing
                deflector_matrix = [deflector_matrix, deflector_transmission.type2_pol_trans', deflector_transmission.polarisation', deflector_transmission.type2_p2t'];
                textstring = [textstring,' Type2_PolTrans', 'Polarization', ' Type2_P2T'];
            end
        end
        
        if deflector.show_ref ==1
            if deflector.polarized ==0 %Non-Polarizing
                deflector_matrix = [deflector_matrix, deflector_transmission.reflectivity'];
                textstring = [textstring,' Reflectivity'];
            else %Polarizing
                deflector_matrix = [deflector_matrix, deflector_transmission.reflectivity_right', deflector_transmission.reflectivity_wrong'];
                textstring = [textstring,' Ref1', ' Ref2'];
            end
        end
        
        if deflector.show_geo ==1 && deflector.type1 == 1
            deflector_matrix = [deflector_matrix, deflector_transmission.geometry'];
            textstring = [textstring,' Geometry'];
        end
        if deflector.show_si_trans ==1 && deflector.type2 == 1
            deflector_matrix = [deflector_matrix, deflector_transmission.silicon_losses'];
            textstring = [textstring,' SiliconLoss'];
        end
        if deflector.show_si_backref ==1 && deflector.type2 == 1
            deflector_matrix = [deflector_matrix, deflector_transmission.silicon_backreflection'];
            textstring = [textstring,' SiliconBackRef'];
        end
        fprintf(fid,'%s \n',textstring);
        fclose(fid);
        dlmwrite([directory fname],deflector_matrix,'-append','delimiter','\t','precision','%.4f')
   
end



%Re-Calculate
%***** Silicon blade constants *****
silicon_thickness = deflector.si_thickness *1e-3; % [m]
density = 2.33; %g/cm3
atomic_mass = 28.0855;
ab_xsection = 0.171e-24; %cm2
ref_wavelength = 1.7982;

deflector_transmission.reflectivity = [];
deflector_transmission.reflectivity_right = [];
deflector_transmission.reflectivity_wrong = [];
deflector_transmission.geometry = [];
deflector_transmission.silicon_losses = [];
deflector_transmission.silicon_backreflection = [];

deflector_transmission.wav = deflector.wav_min:0.1:deflector.wav_max;
%Loop over wavelength
counter = 1;
for wav = deflector_transmission.wav
    
    %Mirror reflectivity
    m_mirror = deflector.mirror_angle / (0.1*wav);
    m_eff = m_mirror-deflector.m_guide:2*deflector.m_guide/100:m_mirror+deflector.m_guide;
    
    if deflector.polarized ==0 %Non-Polarizing
        %***** Non Polarizing Deflector Reflectivity - averaged over divergence and as a function of wavelength
        if deflector.simple_detailed_ref == 0 %Simple reflectivity model
            R = reflectivity(m_eff,deflector.m_mirror);
        else %Detailed reflectivity model
            deflector.rightspin(2) = deflector.m_mirror;
            R = mc_reflectivity(m_eff,deflector.rightspin);
        end
        R = R.^deflector.deflector_series;
        deflector_transmission.reflectivity(counter) = mean(R);
        
    else %Polarized
        %***** Polarized Reflectivities - Right and Wrong Spin - averaged over divergence as function of wavelength
        if deflector.simple_detailed_ref == 0 %Simple reflectivity model
            R_right = reflectivity(m_eff,deflector.m_mirror);
            R_wrong = reflectivity(m_eff,deflector.wrongspin(2));
        else %Detailed reflectivity model
            deflector.rightspin(2) = deflector.m_mirror;
            R_right = mc_reflectivity(m_eff,deflector.rightspin);
            R_wrong = mc_reflectivity(m_eff,deflector.wrongspin);
        end
        R_right = R_right.^deflector.deflector_series;
        R_wrong = R_wrong.^deflector.deflector_series;
        deflector_transmission.reflectivity_right(counter) = mean(R_right);
        deflector_transmission.reflectivity_wrong(counter) = mean(R_wrong);
    end
    
    
    %***** Geometric Losses associated with 'Type1' deflector, i.e. classic IN15 type
    th_max = 0.1*deflector.m_guide*wav;
    G_loss = 0.5*sin(th_max*pi/180) / sin(2*deflector.mirror_angle*pi/180); %Loss due to one missing triangle of phase space
    %But,there are two of these should should be x2
    %However, the area of phase space extends to -ve and +ve theta_c
    %So, below would be 2-G_loss*2.
    G_trans= 1-G_loss; %Ok as this if not multiplied by 2 above
    deflector_transmission.geometry(counter) = G_trans.^deflector.deflector_series;
    
    %***** Transmission losses associated with Si blades for 'Type2' deflector
    guide_critical_angle = 0.1*deflector.m_guide*wav;
    incident_angle_range = [-guide_critical_angle:2*guide_critical_angle/100:guide_critical_angle];
    path_length = silicon_thickness ./ abs(sin(  (2.*deflector.mirror_angle + incident_angle_range) .*pi./180)); %remember Si blades are at twice the mirror angle
    thickness = path_length*100; %convert m to cm
    [~,transmission] = neutron_absorbtion(density, atomic_mass, ab_xsection, wav, ref_wavelength,thickness,0);
    Si_trans = mean(transmission);
    Si_trans = Si_trans.*Si_trans;  %because there are two of these blades
    Si_trans = Si_trans.^deflector.deflector_series;
    deflector_transmission.silicon_losses(counter) = Si_trans;
    
    %***** Back-reflection from Si blades for 'Type2' deflector
    incident_m_range = (2.*deflector.mirror_angle + incident_angle_range)/(0.1*wav);
    R = reflectivity(incident_m_range,deflector.m_guide);
    deflector_transmission.silicon_backreflection(counter) = mean(1-R).^deflector.deflector_series; %1-R because we are interested in the transmission, not reflection
    
    counter = counter +1;
end


%Final Transmission
if deflector.polarized ==0 %Non-polarized
    deflector_transmission.type1 = deflector_transmission.reflectivity.*deflector_transmission.geometry;
    deflector_transmission.type2 = deflector_transmission.reflectivity.*deflector_transmission.silicon_losses.*deflector_transmission.silicon_backreflection;
    
else %Polarized
    %Polarisation and FR
    %Geometric or Si transmission term of either deflector cancels
    deflector_transmission.polarisation = (deflector_transmission.reflectivity_right - deflector_transmission.reflectivity_wrong) ./ (deflector_transmission.reflectivity_right + deflector_transmission.reflectivity_wrong);
    
    %Total transmission & Figure of merit - need the geometric transmission or Si absorbtion term here depending on deflector type
    deflector_transmission.type1_pol_trans = ((deflector_transmission.reflectivity_right + deflector_transmission.reflectivity_wrong)./2) .* deflector_transmission.geometry;
    deflector_transmission.type2_pol_trans = ((deflector_transmission.reflectivity_right + deflector_transmission.reflectivity_wrong)./2) .* deflector_transmission.silicon_losses.*deflector_transmission.silicon_backreflection;
    deflector_transmission.type1_p2t = deflector_transmission.type1_pol_trans .* deflector_transmission.polarisation.^2;
    deflector_transmission.type2_p2t = deflector_transmission.type2_pol_trans .* deflector_transmission.polarisation.^2;
end



%***** Redraw *****

%Delete previous plots
if deflector.hold_plots ==0
    temp = findobj('tag','deflector_plot');
    if ~isempty(temp); delete(temp);end
end

%Plot new curves
if deflector.show_ref ==1
    if deflector.polarized ==0 %Non polarized
        plot(deflector_axis,deflector_transmission.wav,deflector_transmission.reflectivity,'.y','displayname',['Deflector Ref: phi=' num2str(deflector.mirror_angle) ', mg=' num2str(deflector.m_guide)],'tag','deflector_plot')
    else %Polarized
        plot(deflector_axis,deflector_transmission.wav,deflector_transmission.reflectivity_right,'.c','displayname',['Deflector PolRef1: phi=' num2str(deflector.mirror_angle) ', mg=' num2str(deflector.m_guide)],'tag','deflector_plot')
        plot(deflector_axis,deflector_transmission.wav,deflector_transmission.reflectivity_wrong,'.r','displayname',['Deflector PolRef2: phi=' num2str(deflector.mirror_angle) ', mg=' num2str(deflector.m_guide)],'tag','deflector_plot')
    end
end

if deflector.show_geo ==1 && deflector.type1 == 1
    plot(deflector_axis,deflector_transmission.wav,deflector_transmission.geometry,'.g','displayname',['Geomtric Losses: phi=' num2str(deflector.mirror_angle) ', mg=' num2str(deflector.m_guide)],'tag','deflector_plot')
end

if deflector.show_si_trans ==1 && deflector.type2 == 1
    plot(deflector_axis,deflector_transmission.wav,deflector_transmission.silicon_losses,'.r','displayname',['Silicon Losses: phi=' num2str(deflector.mirror_angle) ', mg=' num2str(deflector.m_guide)],'tag','deflector_plot')
end

if deflector.show_si_backref ==1 && deflector.type2 == 1
    plot(deflector_axis,deflector_transmission.wav,deflector_transmission.silicon_backreflection,'.m','displayname',['Silicon Back Reflection: phi=' num2str(deflector.mirror_angle) ', mg=' num2str(deflector.m_guide)],'tag','deflector_plot')
end

if deflector.type1 == 1
    if deflector.polarized ==0 %Non polarized
        plot(deflector_axis,deflector_transmission.wav,deflector_transmission.type1,'.w','displayname',['Type1: phi=' num2str(deflector.mirror_angle) ', mg=' num2str(deflector.m_guide)],'tag','deflector_plot')
    else %Polarized
        plot(deflector_axis,deflector_transmission.wav,deflector_transmission.type1_pol_trans,'.w','displayname',['Type1 Polarizer Trans: phi=' num2str(deflector.mirror_angle) ', mg=' num2str(deflector.m_guide)],'tag','deflector_plot')
        plot(deflector_axis,deflector_transmission.wav,deflector_transmission.polarisation,'.y','displayname',['Type1 Polarization: phi=' num2str(deflector.mirror_angle) ', mg=' num2str(deflector.m_guide)],'tag','deflector_plot')
        plot(deflector_axis,deflector_transmission.wav,deflector_transmission.type1_p2t,'.m','displayname',['Type1 P2T: phi=' num2str(deflector.mirror_angle) ', mg=' num2str(deflector.m_guide)],'tag','deflector_plot')
    end
end

if deflector.type2 == 1
    if deflector.polarized ==0 %Non polarized
        plot(deflector_axis,deflector_transmission.wav,deflector_transmission.type2,'.c','displayname',['Type2: phi=' num2str(deflector.mirror_angle) ', mg=' num2str(deflector.m_guide)],'tag','deflector_plot')
    else %Polarized
        plot(deflector_axis,deflector_transmission.wav,deflector_transmission.type2_pol_trans,'.w','displayname',['Type2 Polarizer Trans: phi=' num2str(deflector.mirror_angle) ', mg=' num2str(deflector.m_guide)],'tag','deflector_plot');
        plot(deflector_axis,deflector_transmission.wav,deflector_transmission.polarisation,'.y','displayname',['Type2 Polarization: phi=' num2str(deflector.mirror_angle) ', mg=' num2str(deflector.m_guide)],'tag','deflector_plot')
        plot(deflector_axis,deflector_transmission.wav,deflector_transmission.type2_p2t,'.m','displayname',['Type2 P2T: phi=' num2str(deflector.mirror_angle) ', mg=' num2str(deflector.m_guide)],'tag','deflector_plot');
    end
end

if deflector.legend == 0; legend('off'); end

if deflector.grid == 0; grid(deflector_axis,'off');
else; grid(deflector_axis,'on');
end


end



function R = reflectivity(m,m_max)

if nargin<2; m_max = 7; end

R = zeros(size(m));

temp = find(m > 1 & m <= m_max);
R(temp) = 1.06 - 0.07*m(temp);

temp = m<=1;
R(temp) = 0.99;

temp = m>m_max;
R(temp) = 0;

end

function R = mc_reflectivity(m,mpars)

%Convert the incoming 'm' to q (small angle approximation

q = m * 0.1* 4 * pi^2 / 180;

% MATLAB function to calculate the reflectivity of a supermirror
% using the McSTAS expression
% c.f. McSTAS components documentation, page 52
% The assumption is that R0 (maximum reflectivity) = 1
% Requred inputs:
%   q = input Q-range
%   mpars = McSTAS parameters:
%       mpars(1) = Qc    (critical Q for single layer of mirror)
%       mpars(2) = m_max (m-number for reflectivity cut-off)
%       mpars(3) = W     (width of cut-off)
%       mpars(4) = alfa  (slope of supermirror reflectivity)
%
%  e.g. mpars = [0.023  3.0 1.7e-3  3.0];        m=3 Fe/Si "good" polarization
%       mpars = [0.011  0.5 5.0e-3  3.0];       m=3 Fe/Si "bad" polarization
%
% ARW 12.3.18

R = zeros(size(q));

Qc_Ni = 0.0217;  % Critical Q for natural Ni

Qc = mpars(1);
Mx = mpars(2)*Qc_Ni/Qc;
W = mpars(3);
Alf = mpars(4);

R = 0.5 * (1-tanh((q-Mx*Qc)/W)).*(1-Alf*(q-Qc));
R(q <= Qc) = 1;


end


function [absorbtion_length,transmission] = neutron_absorbtion(density, atomic_mass, ab_xsection, wavelength, ref_wavelength,thickness,silent)

%Usage:
%[absorbtion_length] = neutron_absorbtion(density, atomic_mass, ab_xsection, lambda, ref_lambda,thickness,silent);
%
%All units should be cm, cm^2 etc.
%lambda and ref_lambda (optional) are the wavelength and reference
%thickness (optional) is the material thickness
%silent (optional) 0,1 determines whether to print output or not
%wavelength for the quoted absorbtion xsection
%
%E.g.   Element Rhodium (Rh) Density 12.41 g/cm^3;  Atomic mass number 103,
%       Absorbtion crossection 144.8x10^-24 cm^2 (144.8 barns)
%
%>neutron_absorbtion(12.41,103,144.8e-24,1.792,1.792,0.1);
%
%Absorbtion Length = 0.095214 cm @ 1.792�
%
%Neutron Transmission = 0.34984 @ 0.1 cm
%

if nargin < 7; silent = 1; end %Whether to run in silent mode or not.
if nargin < 6; thickness = 0.1; end %Default material thickness
if nargin < 5; ref_wavelength = 1.7982; end %2200m/s neutrons
if nargin < 4; wavelength = 1.7982; end %2200m/s neutrons

%Constants
Na = 6.02*10^23;

%Calculate absorbtion length
absorbtion_length = atomic_mass / (density * Na * ab_xsection);
%Correct for wavelength dependence
absorbtion_length = absorbtion_length * ref_wavelength / wavelength;
%Calculate neutron transmission
transmission = exp(- thickness / absorbtion_length);

if silent == 1
    disp(' ')
    disp(['Absorbtion Length = ' num2str(absorbtion_length) ' cm @ ' num2str(wavelength) '�']);
    disp(' ')
    disp(['Neutron Transmission = ' num2str(transmission) ' @ ' num2str(thickness) ' cm']);
    disp(' ')
end

end
