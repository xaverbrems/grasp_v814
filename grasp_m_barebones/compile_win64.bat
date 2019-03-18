

copy f:\Matlab\grasp_m_barebones\instrument_ini\det_efficiency\ f:\Matlab\grasp_barebones_compiled\grasp_windows_compiled64\instrument_ini\det_efficiency\
copy f:\Matlab\grasp_m_barebones\instrument_ini\*.ini f:\Matlab\grasp_barebones_compiled\grasp_windows_compiled64\instrument_ini\
copy f:\Matlab\grasp_m_barebones\grasp_script\scripts\*.m f:\Matlab\grasp_barebones_compiled\grasp_windows_compiled64\grasp_script\
copy f:\Matlab\grasp_m_barebones\grasp_script\gs_help.pdf f:\Matlab\grasp_barebones_compiled\grasp_windows_compiled64\grasp_script\

matlab -r "cd f:\Matlab\grasp_m_barebones\; grasp_startup;cd f:\Matlab\grasp_barebones_compiled\grasp_windows_compiled64\;tic;mcc -m -v grasp; toc"

pause

"c:\Program Files\7-Zip\7z.exe" a -r "e:\ILL Cloud\Grasp\barebones\grasp_barebones_win64_R2018b.zip" f:\Matlab\grasp_barebones_compiled\grasp_windows_compiled64\*.*
