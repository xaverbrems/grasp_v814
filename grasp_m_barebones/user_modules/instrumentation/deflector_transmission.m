function deflector_transmission


global deflector
%Default Starting parameters
deflector.m_guide = 1;
deflector.mirror_angle = 1.2; %degrees
deflector.deflector_series = 1; % # deflectors in series
deflector.m_mirror = 7;
deflector.wav_min = 0;
deflector.wav_max = 20;
deflector.type1 = 1;
deflector.type2 = 0;
deflector.show_ref = 1;
deflector.show_geo = 1;
deflector.show_si_trans = 1;
deflector.show_si_backref = 1;
deflector.hold_plots = 0;
deflector.grid = 1;
deflector.legend = 1;
deflector.si_thickness = 0.3; %[mm]
deflector.polarized = 0;
deflector.wrongspin = [0.011  0.5 5.0e-3  3.0];
deflector.rightspin = [0.023  3.0 1.7e-3  3.0];
deflector.simple_detailed_ref = 0;  %0 = simple reflectivity, 1 = detailed reflectivity model (from A. Wildes)


temp = get(groot,'Default');
default_color = temp.defaultFigureColor;

%***** Draw interface ****
temp = findobj('tag','deflector_transmission');
if ~isempty(temp);delete(temp); end

deflector_figure = figure('tag','deflector_transmission','units','normalized','position',[0.3, 0.3, 0.5, 0.5],'units','normalized');
%wav_min
uicontrol(deflector_figure,'style','edit','units','normalized','position',[0.1, 0.1, 0.05, 0.05],'string',num2str(deflector.wav_min),'callback','deflector_callbacks(''wav_min'');');
%wav_max
uicontrol(deflector_figure,'style','edit','units','normalized','position',[0.7, 0.1, 0.05, 0.05],'string',num2str(deflector.wav_max),'callback','deflector_callbacks(''wav_max'');');
%Guide m
uicontrol(deflector_figure,'style','text','units','normalized','position',[0.8, 0.89, 0.2, 0.05],'string','Guide_m','backgroundcolor',default_color,'foregroundcolor','white','horizontalalignment','left')
uicontrol(deflector_figure,'style','edit','units','normalized','position',[0.8, 0.85, 0.1, 0.05],'string',num2str(deflector.m_guide),'callback','deflector_callbacks(''m_guide'');');
%Deflector m
uicontrol(deflector_figure,'style','text','units','normalized','position',[0.8, 0.79, 0.2, 0.05],'string','Deflector_m','backgroundcolor',default_color,'foregroundcolor','white','horizontalalignment','left')
uicontrol(deflector_figure,'style','edit','units','normalized','position',[0.8, 0.75, 0.1, 0.05],'string',num2str(deflector.m_mirror),'callback','deflector_callbacks(''m_mirror'');');
%Deflector angle
uicontrol(deflector_figure,'style','text','units','normalized','position',[0.8, 0.69, 0.2, 0.05],'string','Deflector_Angle [degs]','backgroundcolor',default_color,'foregroundcolor','white','horizontalalignment','left')
uicontrol(deflector_figure,'style','edit','units','normalized','position',[0.8, 0.65, 0.1, 0.05],'string',num2str(deflector.mirror_angle),'callback','deflector_callbacks(''mirror_angle'');');
%Deflectors in series
uicontrol(deflector_figure,'style','text','units','normalized','position',[0.8, 0.59, 0.2, 0.05],'string','# Deflectors in Series','backgroundcolor',default_color,'foregroundcolor','white','horizontalalignment','left')
uicontrol(deflector_figure,'style','edit','units','normalized','position',[0.8, 0.55, 0.1, 0.05],'string',num2str(deflector.deflector_series),'callback','deflector_callbacks(''deflector_series'');');
%Type1
uicontrol(deflector_figure,'style','text','units','normalized','position',[0.8, 0.49, 0.1, 0.05],'string','Type1','backgroundcolor',default_color,'foregroundcolor','white','horizontalalignment','left')
uicontrol(deflector_figure,'style','checkbox','units','normalized','position',[0.8, 0.45, 0.05, 0.05],'value',deflector.type1,'callback','deflector_callbacks(''deflector_type1'');','backgroundcolor',default_color);
%Type2
uicontrol(deflector_figure,'style','text','units','normalized','position',[0.9, 0.49, 0.2, 0.05],'string','Type2','backgroundcolor',default_color,'foregroundcolor','white','horizontalalignment','left')
uicontrol(deflector_figure,'style','checkbox','units','normalized','position',[0.9, 0.45, 0.05, 0.05],'value',deflector.type2,'callback','deflector_callbacks(''deflector_type2'');','backgroundcolor',default_color);
%HoldPlots
uicontrol(deflector_figure,'style','checkbox','units','normalized','position',[0.03, 0.93, 0.25, 0.05],'string','Hold:','foregroundcolor','white','value',deflector.hold_plots,'callback','deflector_callbacks(''hold_plots'');','backgroundcolor',default_color);
%Grid
uicontrol(deflector_figure,'style','checkbox','units','normalized','position',[0.13, 0.93, 0.25, 0.05],'string','Grid:','foregroundcolor','white','value',deflector.grid,'callback','deflector_callbacks(''grid'');','backgroundcolor',default_color);
%Legend
uicontrol(deflector_figure,'style','checkbox','units','normalized','position',[0.23, 0.93, 0.25, 0.05],'string','Legend:','foregroundcolor','white','value',deflector.legend,'callback','deflector_callbacks(''legend'');','backgroundcolor',default_color);
%Polarized
uicontrol(deflector_figure,'style','checkbox','units','normalized','position',[0.7, 0.93, 0.1, 0.05],'string','Polarized:','foregroundcolor','white','value',deflector.polarized,'callback','deflector_callbacks(''polarized'');','backgroundcolor',default_color);
%Simple / Detailed Ref Model
uicontrol(deflector_figure,'style','checkbox','units','normalized','position',[0.90, 0.75, 0.25, 0.05],'string','Simple/Detailed Ref:','foregroundcolor','white','value',deflector.simple_detailed_ref,'callback','deflector_callbacks(''simple_detailed_ref'');','backgroundcolor',default_color);

%Export Button
uicontrol(deflector_figure,'style','pushbutton','units','normalized','position',[0.85, 0.05, 0.1, 0.05],'string','Export','callback','deflector_callbacks(''Export'');');




%Show - Reflectivity
uicontrol(deflector_figure,'style','checkbox','units','normalized','position',[0.8, 0.35, 0.25, 0.05],'string','Show Reflectivity','foregroundcolor','white','value',deflector.show_ref,'callback','deflector_callbacks(''show_ref'');','backgroundcolor',default_color);
%Show - Geometric
uicontrol(deflector_figure,'style','checkbox','units','normalized','position',[0.8, 0.3, 0.25, 0.05],'string','Show Geometric Factor','foregroundcolor','white','value',deflector.show_geo,'callback','deflector_callbacks(''show_geo'');','backgroundcolor',default_color);
%Show - Silicon tranmission
uicontrol(deflector_figure,'style','checkbox','units','normalized','position',[0.8, 0.25, 0.25, 0.05],'string','Show Silicon Trans','foregroundcolor','white','value',deflector.show_si_trans,'callback','deflector_callbacks(''show_si_trans'');','backgroundcolor',default_color);
%Show - Silicon back reflection
uicontrol(deflector_figure,'style','checkbox','units','normalized','position',[0.8, 0.20, 0.25, 0.05],'string','Show Silicon Back_Ref','foregroundcolor','white','value',deflector.show_si_backref,'callback','deflector_callbacks(''show_si_backref'');','backgroundcolor',default_color);
%Silicon Thickness
uicontrol(deflector_figure,'style','text','units','normalized','position',[0.8, 0.14, 0.1, 0.07],'string','Silicon thickness [mm]','backgroundcolor',default_color,'foregroundcolor','white','horizontalalignment','left')
uicontrol(deflector_figure,'style','edit','units','normalized','position',[0.93, 0.15, 0.05, 0.05],'string',num2str(deflector.si_thickness),'callback','deflector_callbacks(''si_thickness'');');


%Graph axis
deflector_axis = axes(deflector_figure,'tag','deflector_axis','units','normalized','position',[0.1,0.2,0.65,0.7]);
hold on
temp = legend;
set(temp,'tag','deflector_legend','units','normalized','position',[0.5000 0.3 0.2 0.15])
xlabel(deflector_axis,'Wavelength [angs]')
ylabel(deflector_axis,'Transmission')

%Update the plot
deflector_callbacks;











