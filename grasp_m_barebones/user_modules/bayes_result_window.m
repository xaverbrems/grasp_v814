function bayes_window_result

global grasp_env
global grasp_handles
global status_flags

%***** Open Mask Editor Window *****

%Delete old window if it exists
if ishandle(grasp_handles.window_modules.bayes.window_result)
    delete(grasp_handles.window_modules.bayes.window_result);
end

fig_position = ([0.1, 0.1, 0.3, 0.4]).* grasp_env.screen.screen_scaling;
grasp_handles.window_modules.bayes.window_result = figure(....
    'units','normalized',....
    'Position',fig_position,....
    'Name','Bayes Results' ,....
    'NumberTitle', 'off',....
    'Tag','bayes_window',....
    'color',grasp_env.background_color,...
    'menubar','none',....
    'resize','on',....
    'closerequestfcn','closereq');
figure_handle = grasp_handles.window_modules.bayes.window_result;

uicontrol(figure_handle,'units','normalized','Position',[0.1 0.82 0.4 0.1],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','text','string',['Label: ' status_flags.user_modules.bayes.input_name],'HorizontalAlignment','left','Visible','on','backgroundcolor',grasp_env.background_color,'ForegroundColor', [1 1 1]);


uicontrol(figure_handle,'units','normalized','Position',[0.1 0.62 0.4 0.1],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','text','string',['Sanoffset: ' num2str(status_flags.user_modules.bayes.results.sanoffset)],'HorizontalAlignment','left','Visible','on','backgroundcolor',grasp_env.background_color,'ForegroundColor', [1 1 1]);
uicontrol(figure_handle,'units','normalized','Position',[0.4 0.62 0.8 0.1],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','text','string',['Sanoffset error: ' num2str(status_flags.user_modules.bayes.results.sanoffset_err)],'HorizontalAlignment','left','Visible','on','backgroundcolor',grasp_env.background_color,'ForegroundColor', [1 1 1]);
uicontrol(figure_handle,'units','normalized','Position',[0.1 0.42 0.4 0.1],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','text','string',['Phioffset: ' num2str(status_flags.user_modules.bayes.results.phioffset)],'HorizontalAlignment','left','Visible','on','backgroundcolor',grasp_env.background_color,'ForegroundColor', [1 1 1]);
uicontrol(figure_handle,'units','normalized','Position',[0.4 0.42 0.8 0.1],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','text','string',['Phioffset error: ' num2str(status_flags.user_modules.bayes.results.phioffset_err)],'HorizontalAlignment','left','Visible','on','backgroundcolor',grasp_env.background_color,'ForegroundColor', [1 1 1]);

uicontrol(figure_handle,'units','normalized','Position',[0.1 0.22 0.4 0.1],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','text','string',['Eta 0: ' num2str(status_flags.user_modules.bayes.results.eta_0)],'HorizontalAlignment','left','Visible','on','backgroundcolor',grasp_env.background_color,'ForegroundColor', [1 1 1]);
uicontrol(figure_handle,'units','normalized','Position',[0.4 0.22 0.8 0.1],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','text','string',['Eta 0 error: ' num2str(status_flags.user_modules.bayes.results.eta_0_err)],'HorizontalAlignment','left','Visible','on','backgroundcolor',grasp_env.background_color,'ForegroundColor', [1 1 1]);
uicontrol(figure_handle,'units','normalized','Position',[0.1 0.12 0.4 0.1],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','text','string',['FWHM: ' num2str(status_flags.user_modules.bayes.results.fwhm)],'HorizontalAlignment','left','Visible','on','backgroundcolor',grasp_env.background_color,'ForegroundColor', [1 1 1]);
uicontrol(figure_handle,'units','normalized','Position',[0.4 0.12 0.8 0.1],'FontName',grasp_env.font,'FontSize',grasp_env.fontsize,'Style','text','string',['FWHM error: ' num2str(status_flags.user_modules.bayes.results.fwhm_err)],'HorizontalAlignment','left','Visible','on','backgroundcolor',grasp_env.background_color,'ForegroundColor', [1 1 1]);








%             status_flags.user_modules.bayes.results.sanoffset = A.posterior.sanoffset.mean*180/pi
%             status_flags.user_modules.bayes.results.sanoffset_err = A.posterior.sanoffset.sd*180/pi
%             status_flags.user_modules.bayes.results.phioffset = A.posterior.phioffset.mean*180/pi
%             status_flags.user_modules.bayes.results.phioffset_err = A.posterior.phioffset.sd*180/pi
%             status_flags.user_modules.bayes.results.eta_0 = eta0_post
%             status_flags.user_modules.bayes.results.eta_0_err = eta0_post_err
%             status_flags.user_modules.bayes.results.fwhm = A.posterior.rocking_fwhm.mean
%             status_flags.user_modules.bayes.results.fwhm_err = A.posterior.rocking_fwhm.sd


bayes_callbacks;