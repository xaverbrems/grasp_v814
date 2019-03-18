function two_d_tof_bin

global displayimage
global inst_params
global status_flags
global grasp_data

%(1) pixel_x
%(2) pixel_y
%(3) qx
%(4) qy
%(5) mod q
%(6) q angle
%(7) 2theta_x
%(8) 2theta_y
%(9) mod_2theta
%(10) solid_angle
%(11) delta_q_lambda
%(12) delta_q_theta
%(13) delta_q
%(14) radius_x
%(15) radius_y
%(16) mod_radius  (m)
%(17) delta_theta
%(18) delta_q_pixel
%(19) detla_q_sample_aperture
%(20) qx/pixelx
%(21) qy/pixely


%Simple q-space plot
figure
hold on

index = data_index(status_flags.selector.fw);

qx=[];
qy=[];
I=[];

%Turn off graphic and command display for speed if required
status_flags.command_window.display_params=0; status_flags.display.refresh = 0;

depths = [5:1:80];
for n = depths
    n
    status_flags.selector.fd = n+grasp_data(index).sum_allow;
    main_callbacks('depth_scroll'); %Scroll all linked depths and update
    
    for det = 1:5
        detno = num2str(det);
        
        
        qxx= displayimage.(['qmatrix' detno])(:,:,3); %qx
        qyy= displayimage.(['qmatrix' detno])(:,:,4); %qy
        II = displayimage.(['data' detno])(:,:);
        pcolor(qxx,qyy,real(log(II))); shading interp
        
        
        
        
        mask = displayimage.(['mask' detno]);  %This is the combined user & instrument mask
        temp1= displayimage.(['qmatrix' detno])(:,:,3); %qx
        temp2= displayimage.(['qmatrix' detno])(:,:,4); %qy
        temp3 = displayimage.(['data' detno])(:,:);
        qx = [qx; reshape(temp1(logical(mask)),[],1)];
        qy = [qy; reshape(temp2(logical(mask)),[],1)];
        I = [I; reshape(temp3(logical(mask)),[],1)];
        
        
        
        
        
        
        
    end
end
I = double(I);


%Polar Binning, R-Theta
[th,r] = cart2pol(qx,qy);

q_max = 1.2; q_min = 0.001;
rbin = logspace(log10(q_min),log10(q_max),100); %Log radial bins
thbin = linspace(-pi,pi,360); %Linear Angular bins

rdif = diff(rbin)/2;
rcentres = rbin(1:end-1)+rdif;
thdif = diff(thbin)/2;
thcentres = thbin(1:end-1)+thdif;

[ym,~] = bindata2(I,th,r,thbin,rbin);
figure
h = pcolor(rcentres,thcentres,real((ym))); shading interp
set(h,'AlphaData',~isnan(ym));
hh = get(h,'parent'); set(hh,'xscale','log')

figure
h = pcolor(rcentres,thcentres,real(log10(ym))); shading interp
set(h,'AlphaData',~isnan(ym)); box off;

[thgrid,rgrid] = meshgrid(rcentres,thcentres);
[qxbuild,qybuild] = pol2cart(rgrid,thgrid);

figure
h = pcolor(qxbuild,qybuild,real((ym))); shading interp
set(h,'AlphaData',~isnan(ym)); box off;



%Cartesian Binning, qx, qy
q_max = 1.2; q_min = 0.001;
qxbin = linspace(q_min,q_max,100);
qybin = linspace(q_min,q_max,100);
qxbin = [-fliplr(qxbin), qxbin];
qybin = [-fliplr(qybin), qybin];

qxdif = diff(qxbin)/2;
qxcentres =qxbin(1:end-1)+qxdif;
qydif = diff(qybin)/2;
qycentres =qybin(1:end-1)+qydif;

[ym,~] = bindata2(I,qx,qy,qxbin,qybin);

figure
h = pcolor(qxcentres,qycentres,real((ym))); shading interp
set(h,'AlphaData',~isnan(ym));


%Turn off graphic and command display for speed if required
status_flags.command_window.display_params=1; status_flags.display.refresh = 1;




