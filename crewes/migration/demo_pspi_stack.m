%%
%exploding reflector model of thrust

dt=.004;
dtstep=.001;
tmax=2.0;
dx=5;

[vel,x,z]=thrustmodel(dx);

%[seisthrust,seis,t]=afd_explode(dx,dtstep,dt,tmax,vel,x,zeros(size(x)),[5 10 40 50],0,2);
[w,tw]=wavemin(dtstep,30,.4);
[seisthrust,t]=afd_explode_alt(dx,dtstep,dt,tmax,vel,x,zeros(size(x)),w,tw,2);

figure
imagesc(x,z,vel);
h=colorbar;
set(get(h,'ylabel'),'string','m/s')
title('velocity model')
plotimage(seisthrust,t,x)

save thrust_model

%%
%pspi depth migration
if(~exist('seisthrust','var'))
    if(exist('thrust_model.mat','file'))
        load thrust_model
    else
        disp('Please run the first cell of this script')
    end
end

%establish extrapolation checkpoints (see help for pspi_stack)
zcheck=[100 200 500 1000];

%velocity model is sample every 5 m, the next line allows a 10m depth step.
%ideally, we showld average evergy two depths into one (i.e. resample the
%model) but that is a detail.
zmig=z(1:2:end);
[zosmig,exzos]=pspi_stack(seisthrust,t,x,vel(1:2:end,:),x,zmig,[0 inf],zcheck);
tzos=dt*(0:size(exzos{1},1)-1);
xzos=dx*(0:size(exzos{1},2)-1);
plotimage(zosmig,zmig,x)
title('Depth migration')
for k=length(zcheck):-1:1
    plotimage(exzos{k},tzos,xzos)
    title(['Extrapolated to ' num2str(zcheck(k)) ' meters'])
end
plotimage(seisthrust,t,x);
title('Input zos from Thrust model')
figure
imagesc(x,z,vel);colorbar
title('Thrust velocity model')

%%
%kirchhoff time migration
if(~exist('seisthrust','var'))
    if(exist('thrust_model.mat','file'))
        load thrust_model
    else
        disp('Please run the first cell of this script')
    end
end
%make an rms velcity model
tmax=max(t);
[velrms,tv]=vzmod2vrmsmod(vel,z,dt,tmax,2);

figure
imagesc(x,tv,velrms);colorbar
title('RMS velocity model')
[zos_tmig,tmig,xmig]=kirk(seisthrust,velrms,t,x);

plotimage(zos_tmig,tmig,xmig);
title('Kirkhhoff time migration')


%%
% Demo time and depth migration on a flat section.
% Here we make a section with flat events and migrate it with the thrust
% velocity model. The results are "pleasing" with time migration but not
% with depth migration. This demonstrates the built-in bias of time
% migration to preserve flat (horizontal) events. In actuality, a migration
% such as this is a serious mistake and depth migration, by getting a bad
% result, lets us know that we are wrong. Time migration give the false
% impression that all is well.
if(~exist('seisthrust','var'))
    if(exist('thrust_model.mat','file'))
        load thrust_model
    else
        disp('Please run the first cell of this script')
    end
end
% make a flat section
r=reflec(max(t),dt);
[w,tw]=ricker(dt,40,.2);
s=convz(r,w);
seisflat=s*ones(size(x));
plotimage(seisflat,t,x)
title('flat section')
%time migration 
[flat_tmig,tmig,xmig]=kirk(seisflat,velrms,t,x);

plotimage(flat_tmig,tmig,xmig);
title('Kirkhhoff time migration of flat section')

%depth migration
zmig=z(1:2:end);
flat_dmig=pspi_stack(seisflat,t,x,vel(1:2:end,:),x,zmig);
plotimage(flat_dmig,zmig,x)
title('PSPI depth migration of flat section')


