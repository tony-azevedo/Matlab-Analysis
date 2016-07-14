vna=50;  %set the constants
vk=-77;
vl=-54.4;
gna=120;
gk=36;
gl=.3;
c=1;
I=6.5;

v_init=-65;  %the initial conditions
m_init=.052;
h_init=.596;
n_init=.317;

npoints=10000;  %number of timesteps to integrate
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

gnamin = 60;  %minimum value of gna
gnamax = 160; %maximum value of gna
num_na = 11;   %number of gna values to be considered
%gnamin = 0;
%gnamax = 1200;
%num_na = 21;
gnastep = (gnamax-gnamin)/(num_na-1); %stepsize in gna
ggna = gnamin:gnastep:gnamax; %vector of gna values, used for image

gkmin = 16;   %minimum value of gk
gkmax = 56;   %maximum value of gk
num_k = 11;    %number of gk values to be considered
%gkmin = 0;
%gkmax = 180;
%num_k = 21;
gkstep = (gkmax-gkmin)/(num_k-1); %stepsize in gk
ggk = gkmin:gkstep:gkmax; %vector of gk values, used for image

numplot = 0;

for k=1:num_k
   for j=1:num_na
      gna = gnamin + (j-1)*gnastep
      gk = gkmin + (k-1)*gkstep
      nummax = 0;
      nummin = 0;

      for step=1:npoints-1,
         v(step+1)=v(step)+((I - gna*h(step)*(v(step)-vna)*m(step)^3 ...
               -gk*(v(step)-vk)*n(step)^4-gl*(v(step)-vl))/c)*dt;
         m(step+1)=m(step)+ (am(v(step))*(1-m(step))-bm(v(step))*m(step))*dt;
         h(step+1)=h(step)+ (ah(v(step))*(1-h(step))-bh(v(step))*h(step))*dt;
         n(step+1)=n(step)+ (an(v(step))*(1-n(step))-bn(v(step))*n(step))*dt;
         time(step+1)=time(step)+dt;

         if ((step>1) & (v(step+1)<v(step)) & (v(step)>v(step-1)))
            nummax = nummax + 1;
            peakmax(nummax) = v(step);
         end

         if ((step>1) & (v(step+1)>v(step)) & (v(step)<v(step-1)))
            nummin = nummin + 1;
            peakmin(nummin) = v(step);
         end
      end

      if ((nummax>0) & (nummin>0) ...  %at least one max and min
       & (peakmax(nummax)-peakmin(nummin)>10) ...  %diff of max, min >10
       & (peakmax(nummax)<1000) & (peakmin(nummin)>-1000)) %doesn't blow up
         ppeak(k,j) = 31;  %there are periodic peaks, 31 = green
      else
         ppeak(k,j) = 58;  %there are not periodic peaks, 58 = red
      end

      numplot=numplot+1;

      figure(1);  %figure showing voltage vs. time
      hold on;
      subplot(num_na,num_k,numplot);
      plot(time,v);
      axis off;
   end
end

figure(2);  %figure showing 
image(ggna,ggk,ppeak);
xlabel('max g_{Na}');
ylabel('max g_K');