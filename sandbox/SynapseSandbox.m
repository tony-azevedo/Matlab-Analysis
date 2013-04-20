%% Rework in terms of Fre AchC
% Synapse model? Simplified. for Kathy

ex = 0;

% Ach concentration at receptors
Ach_per_ves =  10000;

% vesicle release dynamics
kr = 7.5e-3; % s^-1
tau_kr = 1/kr

% diffusion|clearance rate 
ke = 6.5e-3; % s^-1
tau_ke = 1/ke

% rate of binding
r_on = 0.25e-3; % s^-1
tau_r_on = 1/r_on

% unbinding rate - channels become available
r_off = 160;%e-3; % s^-1
tau_r_off = 1/r_off

% Available channels
N_0 = 20;

% binding Michaelis constant (binding depends on how many channels are
% available
Km = 10; % M

% no Ach initially
A_0 = 0; 

% binding has a dark value (inherent Ach or channel opening) - set so that
% dN_a dt = 0 initially
bdark = r_off/(N_0/(N_0+Km))

%
tstep = .01; %100us
t = -2000:tstep:4000;

firing_rate = zeros(size(t));
R = zeros(size(t)); % release
A = zeros(size(t)); % [Ach]
N_a = ones(size(t)); N_a = N_a*N_0; % channels available

% binding (Ach+N_o - )
b = ones(size(t));

bolus = 500;  % spikes
start = 0;
finit = 500; % duration
amp = bolus/(finit-start); % spikes/ms
firing_rate(t>=start & t<=finit) = amp;

totalspikes = trapz(t,firing_rate)

% %%
for i = 1:length(t)-1;
    % set
    
    % binding has a dark value (inherent Ach or channel opening)
    b(i) = (bdark + r_on*A(i))*(N_a(i)/(N_a(i)+Km));
    
    % update
    dRdt = firing_rate(i) - kr * R(i);
    R(i+1) = R(i)+ dRdt*tstep;
    
    dAdt = Ach_per_ves*R(i)-ke*A(i);
    A(i+1) = A(i)+ dAdt*tstep;
    
    dN_adt = r_off-b(i); % available channels increases with unbinding, decreases with binding
    N_a(i+1) = N_a(i)+ dN_adt*tstep;
    if N_a(i+1)<0 N_a(i+1) = 0; end
    
end
i = i+1;
b(i) = (bdark + r_on*A(i))*(N_a(i)/(N_a(i)+Km));

j = max(N_a)-N_a;

% %%
figure(2)
bluelines = findobj(2,'Color',[0, 0, 1]);
set(bluelines,'color',[.8 .8 1]);

subplot(3,2,1);
plot(t,firing_rate), axis tight;
ylabel('firing_rate');
hold on

subplot(3,2,3);
plot(t,R), axis tight;
hold on
ylabel('R - Release');

subplot(3,2,2);
plot(t,A), axis tight;
hold on
ylabel('A - Ach at channel');

% subplot(6,2,5);
% plot(t,r_off), axis tight;
% ylabel('cyclase');

subplot(3,2,4);
plot(t,b), axis tight;
hold on
ylabel('b - binding');

subplot(3,2,6);
plot(t,N_a), axis tight;
hold on
% plot(t,j);
ylabel('N_a - Channels free');


% subplot(3,2,2);
% plot(t,cumsum(I)*tstep), axis tight;
% ylabel('I');