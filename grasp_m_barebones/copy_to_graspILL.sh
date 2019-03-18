echo Modifying Permissions
chmod -R 755 ~/Desktop/Dropbox/Matlab/grasp_barebones_compiled/grasp_linux_compiled64/*
chmod -R 755 ~/Desktop/Dropbox/Matlab/grasp_barebones_compiled/grasp_windows_compiled64/*
chmod -R 755 ~/Desktop/Dropbox/Matlab/grasp_barebones_compiled/grasp_mac_compiled64/*

echo
echo Linux
echo
#scp -r ~/Desktop/Dropbox/Matlab/grasp_barebones_compiled/grasp_linux_compiled64/ grasp@d33lnx1.ill.fr:/home/lss/grasp/linux/barebones/
rsync -av --delete ~/Desktop/Dropbox/Matlab/grasp_barebones_compiled/grasp_linux_compiled64/ grasp@d33lnx1.ill.fr:/home/lss/grasp/linux/barebones/grasp_linux_compiled64/
echo
echo Windows
echo
#scp -r ~/Desktop/Dropbox/Matlab/grasp_barebones_compiled/grasp_windows_compiled64/ grasp@d33lnx1.ill.fr:/home/lss/grasp/windows/barebones/
rsync -av --delete ~/Desktop/Dropbox/Matlab/grasp_barebones_compiled/grasp_windows_compiled64/ grasp@d33lnx1.ill.fr:/home/lss/grasp/windows/barebones/grasp_windows_compiled64/
echo
echo Mac
echo
#scp -r ~/Desktop/Dropbox/Matlab/grasp_barebones_compiled/grasp_mac_compiled64/ grasp@d33lnx1.ill.fr:/home/lss/grasp/macOSX/barebones/
rsync -av --delete ~/Desktop/Dropbox/Matlab/grasp_barebones_compiled/grasp_mac_compiled64/ grasp@d33lnx1.ill.fr:/home/lss/grasp/macOSX/barebones/grasp_mac_compiled64/
echo
echo m-code
#rsync -av --exclude=".*" ~/Desktop/Dropbox/Matlab/grasp_m_barebones/* grasp@d33lnx1.ill.fr:/home/lss/grasp/grasp_m_barebones/
cd ~/Desktop/Dropbox/Matlab/
zip -r  ~/Desktop/Dropbox/Matlab/grasp_m_barebones.zip  grasp_m_barebones -x *.git*
scp ~/Desktop/Dropbox/Matlab/grasp_m_barebones.zip grasp@d33lnx1.ill.fr:/home/lss/grasp/
cp ~/Desktop/Dropbox/Matlab/grasp_m_barebones.zip "/Users/dewhurst/Desktop/ILL Cloud/Grasp/barebones/"
echo
