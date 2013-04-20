%% Rework in terms of Fre AchC
% Synapse model? Simplified. for Kathy

% Ach in vesicles
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

bolus = 5;  % spikes
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


% % Set the initial conditions 
% Xo = [b;c];
% % Define the time span over which to execute the model 
% tspan = 0:1:99;
% % Implementation of u1 and u2 within the model
% n = length (tspan);
% for a=1:n;
%      if(tspan(a))
%         u1 = U1(a);
%         u2 = U2(a);
%         [t,X] = ode45(@Store_1,tspan,Xo,[],u1,u2,T1);
%      end
% end
% % Output
% Store1 = [t X(:,1) X(:,2)];
% 
% % System of Equations
% % dx1/dt = (u1 - x1)/T
% % dx2/dt = ((u1*u2) - (x1*x2))/(T*x1)
% function [dx_dt]= Store_1(t,x,u1,u2,T1)
% % System of Differential Equations
% dx_dt(1) = (u1 - x(1))/T1;
% dx_dt(2) = ((u1*u2) -(x(1)*x(2)))/(T1*x(1));
% % Collect derivatives into a column vector
% dx_dt = dx_dt';
% return
% 
% 
% 
% 
% > I have attempted to do this by using a For loop and If statement to assign 
% > constant value to the input variables u1 and u2 at each time step selected 
% > from two vectors, U1 and U2.
% > The code executes in MATLAB and generates outputs however the results do 
% > not appear to be correct.
% > If someone could review the code to check that my for and if statements 
% > are correct it would be greatly appreciated.
% > Thank you for your time,
% > Sarah
% >
% > function [Store1] = ModelS1(Inputs, T1, b, c)
% > % Define Store input time series U1 = Inputs(:,1);
% > U2 = Inputs(:,2);
% > % Set the initial conditions Xo = [b;c];
% > % Define the time span over which to execute the model tspan = 0:1:99;
% > % Implementation of u1 and u2 within the model
% > n = length (tspan);
% 
% This looks off to me. You shouldn't care about the length of the tspan 
% vector here; you should care about how many pairs of u1 and u2 parameters 
% you have to process.
% 
% for whichparams = 1:size(Inputs, 1)
%     u1 = Inputs(whichparam, 1);
%     u2 = Inputs(whichparam, 2);
%     % I would also suggest using an anonymous function
%     [t, X] = ode45(@(t, y) Store_1(t, y, u1, u2), tspan, Xo);
%     % Do something with this parameter value's t and X output from ODE45
% end
% 
% If instead you're using u1 and u2 as time-varying parameters, so your 
% equations are:
% 
% y' = f(t, y(t), u1(t), u2(t))
% 
% then you will need to pass ALL of U1 and U2 into your ODE function so you 
% can interpolate it for time values at which you don't have an actual value. 
% Use INTERP1 for this.
