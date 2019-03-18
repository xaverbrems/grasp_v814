#!/usr/bin/env sh
cp -r /Users/dewhurst/Desktop/Dropbox/Matlab/grasp_m_barebones/instrument_ini/det_efficiency/ /Users/dewhurst/Desktop/Dropbox/Matlab/grasp_barebones_compiled/grasp_mac_compiled64/instrument_ini/det_efficiency/
cp -r /Users/dewhurst/Desktop/Dropbox/Matlab/grasp_m_barebones/instrument_ini/*.ini /Users/dewhurst/Desktop/Dropbox/Matlab/grasp_barebones_compiled/grasp_mac_compiled64/instrument_ini/
cp -r /Users/dewhurst/Desktop/Dropbox/Matlab/grasp_m_barebones/grasp_script/scripts/*.m /Users/dewhurst/Desktop/Dropbox/Matlab/grasp_barebones_compiled/grasp_mac_compiled64/grasp_script/
cp -r /Users/dewhurst/Desktop/Dropbox/Matlab/grasp_m_barebones/grasp_script/gs_help.pdf /Users/dewhurst/Desktop/Dropbox/Matlab/grasp_barebones_compiled/grasp_mac_compiled64/grasp_script/

# run Matlab, install GRASP env, and create stand-alone
/Applications/MATLAB_R2017b.app/bin/matlab -maci64 -r  "cd /Users/dewhurst/Desktop/Dropbox/Matlab/grasp_m_barebones; grasp_startup; cd ../grasp_barebones_compiled/grasp_mac_compiled64; mcc -m grasp; exit"

# create the GRASP launcher with Matlab RT being installed in 
#    /Applications/MATLAB/MATLAB_Compiler_Runtime/v84
cd /Users/dewhurst/Desktop/Dropbox/Matlab/grasp_barebones_compiled
echo '#!/usr/bin/env sh'  > grasp_mac_compiled64/go_grasp.sh
echo ./run_grasp.sh /Applications/MATLAB/MATLAB_Runtime/v93 >>  grasp_mac_compiled64/go_grasp.sh

# create the DMG
hdiutil create "/Users/dewhurst/Desktop/ILL Cloud/Grasp/barebones/grasp_barebones_mac64_R2018b.dmg" -srcfolder grasp_mac_compiled64 -ov
