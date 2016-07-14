% Check that numerical and analytical solutions of the Hodgkin/Huxley
% equations with gna=gk=0 agree

global I gl vl c

vna=50;   %set the constants
vk=-77;
vl=-54.4;
gna=0;
gk=0;
gl=.3;
c=1;
Istep=10;  %current will be stepped up to Istep for 50<t<150

v_init=-65;  %the initial conditions
m_init=.052;
h_init=.596;
n_init=.317;

npoints=20000;  %number of timesteps to integrate
dt=0.01;        %timestep

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
    if ((time(step+1)>50) & (time(step+1)<150) ) 
      I = Istep;
    else 
      I = 0;
    end;

    time(step+1)=time(step)+dt;
    v(step+1)=v(step)+((I - gna*h(step)*(v(step)-vna)*m(step)^3 ...
               -gk*(v(step)-vk)*n(step)^4-gl*(v(step)-vl))/c)*dt;
    m(step+1)=m(step)+ (am(v(step))*(1-m(step))-bm(v(step))*m(step))*dt;
    h(step+1)=h(step)+ (ah(v(step))*(1-h(step))-bh(v(step))*h(step))*dt;
    n(step+1)=n(step)+ (an(v(step))*(1-n(step))-bn(v(step))*n(step))*dt;
end

figure(1);
hold on;
plot(time,v);
xlabel('t');
ylabel('V');

%superimpose the exact solution
t0 = 0;     %we know that at t=0, the solution starts at v_init
v0 = v_init;  
I=0;
for j=1:50
   plot(j,HH_check_exact(j,t0,v0),'o');
end

t0 = 50;    %at t=50, the solution is approximately vl
v0 = vl;
I = Istep;
for j=51:150
   plot(j,HH_check_exact(j,t0,v0),'o');
end

t0 = 150;   %at t=150, the solution is approximately vl+Istep/gl
v0 = vl+Istep/gl;
I = 0;
for j=151:200
   plot(j,HH_check_exact(j,t0,v0),'o');
end