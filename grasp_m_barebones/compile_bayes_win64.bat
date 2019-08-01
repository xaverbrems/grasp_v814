

xcopy H:\Werkstudent\Grasp_Modifikation\Grasp_v814\grasp_m_barebones\instrument_ini\det_efficiency\ H:\Werkstudent\Grasp_Modifikation\Grasp_v814\grasp_barebones_bayes_compiled\grasp_windows_compiled64\instrument_ini\det_efficiency\
xcopy H:\Werkstudent\Grasp_Modifikation\Grasp_v814\grasp_m_barebones\instrument_ini\*.ini H:\Werkstudent\Grasp_Modifikation\Grasp_v814\grasp_barebones_bayes_compiled\grasp_windows_compiled64\instrument_ini\
xcopy H:\Werkstudent\Grasp_Modifikation\Grasp_v814\grasp_m_barebones\grasp_script\scripts\*.m H:\Werkstudent\Grasp_Modifikation\Grasp_v814\grasp_barebones_bayes_compiled\grasp_windows_compiled64\grasp_script\
xcopy H:\Werkstudent\Grasp_Modifikation\Grasp_v814\grasp_m_barebones\grasp_script\gs_help.pdf H:\Werkstudent\Grasp_Modifikation\Grasp_v814\grasp_barebones_bayes_compiled\grasp_windows_compiled64\grasp_script\
xcopy H:\Werkstudent\Grasp_Modifikation\Grasp_v814\grasp_m_barebones\ini\*.ini H:\Werkstudent\Grasp_Modifikation\Grasp_v814\grasp_barebones_bayes_compiled\grasp_windows_compiled64\ini\
matlab -r "cd H:\Werkstudent\Grasp_Modifikation\Grasp_v814\GRASP_Bayes_Holmes\New_Grasp_v8.07_code; grasp_startup_bayes_new; cd H:\Werkstudent\Grasp_Modifikation\Grasp_v814\grasp_barebones_bayes_compiled\grasp_windows_compiled64\;tic;mcc -m -v grasp; toc"

pause


