%Hodgkin/Huxley Equations (translated V -> -V-65) current definition
%of membrane potential (V=Vin-Vout)

vna=50;
vk=-77;
vl=-54.4;
gna=120;
gk=36;
gl=.3;
c=1;
I=-6.5;

v_init=-65;
m_init=.052;
h_init=.596;
n_init=.317;

npoints=50000;
dt=0.01; 

m=zeros(npoints,1);
n=zeros(npoints,1);
h=zeros(npoints,1);
v=zeros(npoints,1);
time=zeros(npoints,1);

peaktime1 = zeros(npoints,1);

m(1)=m_init;
n(1)=n_init;
h(1)=h_init;
v(1)=v_init;
time(1)=0.0;

numpeak = 0;

for step=1:npoints-1,
    v(step+1)=v(step)+((I - gna*h(step)*(v(step)-vna)*m(step)^3-gk*(v(step)-vk)*n(step)^4-gl*(v(step)-vl))/c)*dt;
    
    m(step+1)=m(step)+ (am(v(step))*(1-m(step))-bm(v(step))*m(step))*dt;
    h(step+1)=h(step)+ (ah(v(step))*(1-h(step))-bh(v(step))*h(step))*dt;
    n(step+1)=n(step)+ (an(v(step))*(1-n(step))-bn(v(step))*n(step))*dt;
    time(step+1)=time(step)+dt;

   if ((v(step+1)<v(step)) & (v(step)>v(step-1)))
     numpeak = numpeak + 1;
     peaktime1(numpeak) = time(step);
   end

end

figure(1);
hold on;
subplot(3,1,1);
plot(time,v);
subplot(3,1,2);
plot(time,v);
subplot(3,1,3);
plot(time,v);

npoints=10000;
dt=0.06; 

m=zeros(npoints,1);
n=zeros(npoints,1);
h=zeros(npoints,1);
v=zeros(npoints,1);
time=zeros(npoints,1);

peaktime2 = zeros(npoints,1);

m(1)=m_init;
n(1)=n_init;
h(1)=h_init;
v(1)=v_init;
time(1)=0.0;

numpeak = 0;

for step=1:npoints-1,
    v(step+1)=v(step)+((I - gna*h(step)*(v(step)-vna)*m(step)^3-gk*(v(step)-vk)*n(step)^4-gl*(v(step)-vl))/c)*dt;
    
    m(step+1)=m(step)+ (am(v(step))*(1-m(step))-bm(v(step))*m(step))*dt;
    h(step+1)=h(step)+ (ah(v(step))*(1-h(step))-bh(v(step))*h(step))*dt;
    n(step+1)=n(step)+ (an(v(step))*(1-n(step))-bn(v(step))*n(step))*dt;
    time(step+1)=time(step)+dt;

   if ((v(step+1)<v(step)) & (v(step)>v(step-1)))
     numpeak = numpeak+1;
     peaktime2(numpeak) = time(step);
   end


end

subplot(3,1,1);
hold on;
plot(time,v,'r--');
axis([0 200 -80 60]);
xlabel('t');
ylabel('V');

subplot(3,1,2);
hold on;
plot(time,v,'r--');
axis([0 10 -80 60]);
xlabel('t');
ylabel('V');

subplot(3,1,3);
hold on;
plot(time,v,'r--');
axis([160 170 -80 60]);
xlabel('t');
ylabel('V');