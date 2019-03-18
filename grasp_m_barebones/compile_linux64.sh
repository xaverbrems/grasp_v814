#!/bin/bash
cp -r /media/sf_Dropbox/Matlab/grasp_m_barebones/instrument_ini/det_efficiency/* /media/sf_Dropbox/Matlab/grasp_barebones_compiled/grasp_linux_compiled64/instrument_ini/det_efficiency/
cp -r /media/sf_Dropbox/Matlab/grasp_m_barebones/instrument_ini/*.ini /media/sf_Dropbox/Matlab/grasp_barebones_compiled/grasp_linux_compiled64/instrument_ini/
cp -r /media/sf_Dropbox/Matlab/grasp_m_barebones/grasp_script/scripts/*.m /media/sf_Dropbox/Matlab/grasp_barebones_compiled/grasp_linux_compiled64/grasp_script/
cp -r /media/sf_Dropbox/Matlab/grasp_m_barebones/grasp_script/gs_help.pdf /media/sf_Dropbox/Matlab/grasp_barebones_compiled/grasp_linux_compiled64/grasp_script/

# run Matlab, install GRASP env, and create stand-alone
/usr/local/MATLAB/R2017b/bin/matlab -r "cd /media/sf_Dropbox/Matlab/grasp_m_barebones/; grasp_startup; cd /media/sf_Dropbox/Matlab/grasp_barebones_compiled/grasp_linux_compiled64/;mcc -m grasp; exit"

cd /media/sf_Dropbox/Matlab/grasp_barebones_compiled
zip -r "/media/sf_Desktop/ILL Cloud/Grasp/barebones/grasp_barebones_linux64_R2018b.zip" grasp_linux_compiled64/


