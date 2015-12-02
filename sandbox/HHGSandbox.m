% Playing with HH model

%% Standard time vector

t = -100:.01:200;
V = -65*ones(size(t));
V(t>=0&t<100) = 30;

plot(t,V)

%% Play with conductance ratios, where does the neuron come to rest?

% Cool! this is very sensitive to these parameters
close all

gNa0 = 120; % 120;
gKratio = .10; % 0.3;
gLratio0 = .008; % 0.0025;

m0 = 0.0529;
h0 = 0.5961;
n0 = 0.3177;

[I_na,I_k,I_l,m,h,n,t,V] = HH_IClamp(0,t,'V0',-70,'m0',m0,'h0',h0,'n0',n0,'gNa',gNa0,'gKratio',gKratio,'gLratio',gLratio0);
HHPlot(t,V,I_na,I_k,I_l,[],m,h,n);



%% allow neuron to settle
V = -65*ones(size(t));

[I_na,I_k,I_l,m,h,n,t,V] = HH_VClamp(V,t,'m0',0.05,'h0',0.54,'n0',0.34,'gNa',120,'gKratio',0.1,'gLratio',0.01);
HHPlot(t,V,I_na,I_k,I_l,[],m,h,n);

m0 = m(end);
h0 = h(end);
n0 = n(end);

%% settled
V = -65*ones(size(t));

[I_na,I_k,I_l,m,h,n,t] = HH_VClamp(V,t,'m0',m0,'h0',h0,'n0',n0,'gNa',120,'gKratio',0.3,'gLratio',0.0025);
HHPlot(t,V,I_na,I_k,I_l,[],m,h,n);

m0 = m(end);
h0 = h(end);
n0 = n(end);

%% Vclamp
V = -65*ones(size(t));
V(t>=0&t<100) = -30;
[I_na,I_k,I_l,m,h,n,t] = HH_VClamp(V,t,'m0',m0,'h0',h0,'n0',n0,'gNa',120,'gKratio',0.3,'gLratio',0.0025);
HHPlot(t,V,-I_na,-I_k,-I_l,[],m,h,n);


%% allow neuron to settle
V = -65*ones(size(t));

[I_na,I_k,I_l,m,h,n,t] = HH_VClamp(V,t,'m0',0.05,'h0',0.54,'n0',0.34,'gNa',120,'gKratio',0.3,'gLratio',0.0025);
HHPlot(t,V,I_na,I_k,I_l,[],m,h,n);


%% Start with settled
[V,~,~,~,~] = HH0(0,t,'V0',V0,'m0',m0(end),'h0',h0(end),'n0',n0(end));
figure(1);
plot(t,V);

%% Inject steady
I = zeros(size(t));
I(t>100) = 1;
[V,~,~,~,t] = HH0(I,t,'V0',V0,'m0',m0(end),'h0',h0(end),'n0',n0(end));
figure(1);
plot(t,V);

%% Inject steady
I = zeros(size(t));
I(t>100) = 30;
[V,~,~,~,t] = HH0(I,t,'V0',V0,'m0',m0(end),'h0',h0(end),'n0',n0(end));
figure(1);
plot(t,V);
xlabel('ms')
ylabel('mV')


%% Inject steady
I = zeros(size(t));
I(t>100) = 100;
[V,~,~,~,t] = HH0(I,t,'V0',V0,'m0',m0(end),'h0',h0(end),'n0',n0(end));
figure(1);
plot(t,V);

%% Inject steady
I = zeros(size(t));
I(t>100) = 20;
[V,m,h,n,t] = HH0(I,t,'V0',V0,'m0',m0(end),'h0',h0(end),'n0',n0(end));
figure(1);
plot(t,V);
xlabel('ms')
ylabel('mV')

VD = V(end);
nD = n(end);
mD = m(end);
hD = h(end);

%% Inject oscillating
I_off = 20;
ramp = ones(size(t));
dt = t(2)-t(1);
ramp(t<100) = t(t<100)/100;
ramp(t>t(end)-100) = flipud(t(t<=100)/100);

f = [25, 50, 100, 200, 400]; %Hz
a = [1 2 4 8];

figure(2)
ylims = [Inf,-Inf];
for ii = 1:length(a)
    for jj = 1:length(f)
        f_ = f(jj)/1000; % cyc/ms
        I = a(ii)*sin(2*pi*f_ * t).*ramp + I_off;
        %I(:) = 170;
        
        [V,n,m,h,t] = HH0(I,t,'V0',VD,'m0',mD,'h0',hD,'n0',nD);
        
        ax = subplot(length(a),length(f),(ii-1)*length(f)+jj);
        plot(t,V);
        yl = get(ax,'ylim');
        ylims = [min(ylims(1),yl(1)),max(ylims(2),yl(2))];
        if ii==1
            title(ax,[num2str(f(jj)) ' Hz']);
        end
    end
end
set(get(2,'children'),'ylim',ylims)
xlabel('ms')


