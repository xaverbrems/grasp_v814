%graspscript Test
% T = Transmission, S = Scattering, EB = empty beam, CD = Cadmium, SAM =
% sample, EC = empty cell (water), H2O = water, 1,2,3 = corresponding
% geometry
% fill in the numors of the corresponding data into the following variables


%transmission data
T_EB_1 = '646698';
T_EB_2 = '646706';
T_EB_3 = '646717';
T_CD   = '646709';
T_SAM  = '646712';
T_EC   = '646708';
T_H2O  = '646707';


%scattering data Geo 1
S_H2O_1 = '646691';
S_EC_1  = '646692';
S_CD_1  = '646693';
S_EB_1  = '646697';
S_SAM_1 = '646694';

%scattering data Geo 2
S_H2O_2 = '646699';
S_EC_2  = '646700';
S_CD_2  = '646701';
S_EB_2  = '646705';
S_SAM_2 = '646702';

%scattering data Geo 3
% S_H2O_3 = ''; not measured in this geo
% S_EC_3  = ''; not measured in this geo
S_CD_3  = '646710';
S_EB_3  = '646718';
S_SAM_3 = '646714';



% load empty beam transmission data into woorksheets and determine the beam center
% the values for the beam center are stored in the corresponding worksheet
% number

gs('load',6,1,T_EB_1)
gs('cm',[60,70,60,70])
gs('load',6,2,T_EB_2)
gs('cm', [60,71,60,70])
gs('load',6,3,strcat(T_EB_3))
gs('cm', [60,70,60,70])
gs('axis_rescale')


% Load H2O and Sample Transmission data into 'Transmission Sample' depth 1 and
% depth 2
gs('load',4,3, strcat(T_H2O,',',T_SAM))

% Load EC Transmission data (EC for water and EB_3 for sample) into 'Transmission EC'
gs('load',5,3, strcat(T_EC,',',T_EB_3))


% load cadmium data into 'Blocked Beam'
gs('load',3,3,strcat(T_CD))



