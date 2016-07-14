% Hodgkin/Huxley Equations (V_HH = -V-65), with current definition 
% of membrane potential (V=Vin-Vout)

vna=50;  %set the constants
vk=-77;
vl=-54.4;
%gna=120;
%gk=36;
gna = 720;
gk = 144;
%gk = 117;
gl=.3;
c=1;
I=6.23;

v_init=-65;  %the initial conditions
m_init=0.052;
h_init=0.596;
n_init=0.317;

npoints=100000;  %number of timesteps to integrate
dt=0.001;        %timestep

m=zeros(npoints,1); %initialize everything to zero
n=zeros(npoints,1);
h=zeros(npoints,1);
v=zeros(npoints,1);
time=zeros(npoints,1);

m(1)=m_init; %set the initial conditions to be the first entry in the vectors
n(1)=n_init;
h(1)=h_init;
v(1)=v_init;
time(1)=0.0;

for step=1:npoints-1,
    v(step+1)=v(step)+((I - gna*h(step)*(v(step)-vna)*m(step)^3 ...
               -gk*(v(step)-vk)*n(step)^4-gl*(v(step)-vl))/c)*dt;
    m(step+1)=m(step)+ (am(v(step))*(1-m(step))-bm(v(step))*m(step))*dt;
    h(step+1)=h(step)+ (ah(v(step))*(1-h(step))-bh(v(step))*h(step))*dt;
    n(step+1)=n(step)+ (an(v(step))*(1-n(step))-bn(v(step))*n(step))*dt;
    time(step+1)=time(step)+dt;
end

figure(1)
subplot(2,1,2);
hold on;
plot(time,v);
xlabel('t');
ylabel('V');

%subplot(2,1,2);
%hold on;
%plot(time,n);
%plot(time,m,'--');
%plot(time,h,':');
