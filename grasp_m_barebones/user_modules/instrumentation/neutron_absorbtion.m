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

if silent == 1;
    disp(' ')
    disp(['Absorbtion Length = ' num2str(absorbtion_length) ' cm @ ' num2str(wavelength) '�']);
    disp(' ')
    disp(['Neutron Transmission = ' num2str(transmission) ' @ ' num2str(thickness) ' cm']);
    disp(' ')
end
