vna=50;  %set the constants
vk=-77;
vl=-54.4;
gna=120;
gk=36;
gl=.3;
c=1;

v_init=-65;  %the initial conditions
m_init=.052;
h_init=.596;
n_init=.317;

npoints=10000;  %number of timesteps to integrate for each value of I
dt=0.01;        %timestep

m=zeros(npoints,1); %initialize everything to zero
n=zeros(npoints,1);
h=zeros(npoints,1);
v=zeros(npoints,1);
time=zeros(npoints,1);
peaktime = zeros(npoints,1);

m(1)=m_init; %set the initial conditions to be the first entry in the vectors
n(1)=n_init;
h(1)=h_init;
v(1)=v_init;
time(1)=0.0;

numI = 0;
numpeak = 0;

for j=1:3

   if j == 1
      Imax = 20;  
      Istep = 1;   %low resolution
      Imin = 7;
   elseif j==2
      Imax = 6.9;
      Istep = 0.1; %middle resolution
      Imin = 6.3;
   else
      Imax=6.299;
      Istep=0.001; %high resolution
      Imin=6.24;
   end

   for I=Imax:-Istep:Imin
      for step=1:npoints-1,
          v(step+1)=v(step)+((I - gna*h(step)*(v(step)-vna)*m(step)^3 ...
                     -gk*(v(step)-vk)*n(step)^4-gl*(v(step)-vl))/c)*dt;
          m(step+1)=m(step)+ (am(v(step))*(1-m(step))-bm(v(step))*m(step))*dt;
          h(step+1)=h(step)+ (ah(v(step))*(1-h(step))-bh(v(step))*h(step))*dt;
          n(step+1)=n(step)+ (an(v(step))*(1-n(step))-bn(v(step))*n(step))*dt;
          time(step+1)=time(step)+dt;

          if ((step>1) & (v(step+1)<v(step)) & (v(step)>v(step-1)))
            numpeak = numpeak + 1;
            peaktime(numpeak) = time(step+1);
          end
      end

      numI = numI + 1;
      Iarray(numI) = I;
      freq(numI) = 1000/(peaktime(numpeak) - peaktime(numpeak-1));
       %frequency in Hertz

      m(1) = m(npoints); %use final condition from previous I as
      n(1) = n(npoints); % initial condition for new I
      h(1) = h(npoints);
      v(1) = v(npoints);
   end
end

plot(Iarray,freq);
xlabel('I (\muA/cm^2)');
ylabel('f (Hz)');