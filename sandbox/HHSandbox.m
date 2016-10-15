% Playing with HH model

%% allow neuron to settle
[V,m0,h0,n0,t] = HH0(0,50);
figure(1);
plot(t,V);
V0 = V(end);

%% Start with settled
[V,~,~,~,~] = HH0(0,t,'V0',V0,'m0',m0(end),'h0',h0(end),'n0',n0(end));
figure(1);
plot(t,V);


%% plot m,h and m^3*h at steady state
[V,m0,h0,n0,t] = HH0(0,50);
figure(1);
plot(t,V);
V0 = V(end);


V_hold = (-110:1:20)+.1
m = nan(size(V_hold));
h = nan(size(V_hold));
n = nan(size(V_hold));

[V,m0,h0,n0,t] = HH0(I(1),t,'V0',V0,'m0',m0(end),'h0',h0(end),'n0',n0(end));
[V,m0,h0,n0,t] = HH0(I(1),t,'V0',V0,'m0',m0(end),'h0',h0(end),'n0',n0(end));

m(1) = m0(end);
h(1) = h0(end);
n(1) = n0(end);

[V,m0,h0,n0,t] = HH_VClamp2(0,t,'V0',V_hold(1),'m0',m(1),'h0',h(1),'n0',n(1));
m(1) = m0(end);
h(1) = h0(end);
n(1) = n0(end);

for i = 2:length(V_hold);
    i
    [V,m0,h0,n0,t] = HH_VClamp2(0,t,'V0',V_hold(i),'m0',m(i-1),'h0',h(i-1),'n0',n(i-1));
    figure(1);
    plot(t,[m0,h0,n0])
    drawnow
    m(i-1)
    h(i-1)
        
    m(i) = m0(end);
    h(i) = h0(end);
    n(i) = n0(end);
end

figure(1);
% plot(V_hold,[m;h;n;m.^3.*h/max(m.^3.*h)]);
plot(V_hold,[m.^3;h;m.^3.*h/max(m.^3.*h)]);

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


