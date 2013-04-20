%% Rework in terms of Fre AchC
% Synapse model? Simplified. for Kathy

% reslease per spike
v_per_sp = 10;

% Ach concentration at receptors
Ach_per_ves =  10000;

% vesicle release dynamics - essentially a low pass filtering of spiking
kr = 20; % s^-1

% diffusion|clearance rate - controls the decay of ach in absence of firing
kach = 20; % s^-1

% rate of binding - 
r_on = 1; % s^-1

% unbinding rate - channels become available
r_off = 256*r_on; % s^-1, just define in terms of r_on

% Available channels
N_0 = 20;

% binding Michaelis constant (binding depends on how many channels are
% available (half saturating)
Km = 10; %

% no Ach initially
A_0 = 0; 

% binding rate has a "dark" value (inherent Ach or channel opening) - set
% so that dN_a dt = 0 initially
bdark = r_off/(N_0/(N_0+Km))

% Set up vectors
tstep = .0001; %100us
t = -.5:tstep:1;

firing_rate = zeros(size(t));
R = zeros(size(t)); % release
A = zeros(size(t)); % [Ach]
N_a = ones(size(t)); N_a = N_a*N_0; % channels available

% binding (Ach+N_a -> Ach*N_a, channel no longer available)
b = ones(size(t));

bolus = 1;  % spikes, example trace is 1 or 10
start = 0;
finit = .01; % duration, example trace is .01 or .1
amp = bolus/(finit-start); % spikes/s
firing_rate(t>=start & t<=finit) = amp;

totalspikes = trapz(t,firing_rate)

% %%
for i = 1:length(t)-1;
    % set
    
    % binding has a dark value (inherent Ach or channel opening)
    b(i) = (bdark + r_on*A(i))*(N_a(i)/(N_a(i)+Km));
    
    % update
    dRdt = v_per_sp*firing_rate(i) - kr * R(i);
    R(i+1) = R(i)+ dRdt*tstep;
    
    dAdt = Ach_per_ves*R(i)-kach*A(i);
    A(i+1) = A(i)+ dAdt*tstep;
    
    dN_adt = r_off-b(i); % available channels increases with unbinding, decreases with binding
    N_a(i+1) = N_a(i)+ dN_adt*tstep;
    if N_a(i+1)<0 N_a(i+1) = 0; end
    
    
end
i = i+1;
b(i) = (bdark + r_on*A(i))*(N_a(i)/(N_a(i)+Km));

% %%
figure(1)
bluelines = findobj(1,'Color',[0, 0, 1]);
set(bluelines,'color',[.8 .8 1]);

subplot(3,2,1);
plot(t,firing_rate), axis tight;
ylabel('firing rate');
xlabel('s');
hold on

subplot(3,2,3);
plot(t,R), axis tight;
hold on
ylabel('R - Release');
xlabel('s');

subplot(3,2,2);
plot(t,A), axis tight;
hold on
ylabel('E - Ach at channel');
xlabel('s');

subplot(3,2,4);
plot(t,b), axis tight;
hold on
ylabel('b - binding rate');
xlabel('s');

subplot(3,2,6);
plot(t,N_a), axis tight;
hold on
% plot(t,j);
ylabel('N_a - Channels free');
xlabel('s');

% subplot(3,2,5);
% plot(t,j);
% axis tight;
% hold on
% ylabel('Channels bound');
% xlabel('s');
