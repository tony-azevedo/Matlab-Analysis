% Phototransduction sandbox
% full kefalov model

vre =  307; %s-1
krmax = 11.4; %s-1
krmin = krmax/3.3;
ke = 6.5; % s-1
FB = 59.4;

Vcyto = 1.4e-14;
kcar = 5e-7; % M
ncar = 2.6;

G_0 = 2.9313e-06; % M
amin = 34.8e-8; % M/s
amax = 34.8e-6; % M/s
Kcyc = 4.8e-7; %M
ncyc = 3.5;
bdark = 7e-5;
kcat = 2200;
Km = 1e-5; % M

jcg_0 = 15e-12; %pA
jmax = 4.45e-9;
ncg = 3;
KcG = 2e-5; %M

Nav = 6.022e23; %Avagadro
Fara = 96485; %/cm

Ca_0 = 5.0805e-07; %M
fca = 0.16;
jexsat = 4.8e-12; %pA
Kex = 1.5e-6; %M
Bmax = 0;
kplu1 = 0;
kmin1 = 0;

tstep = .0001;
t = -.5:tstep:3;
I = zeros(size(t));
R = I;
E = I;
G = ones(size(t)); G = G*G_0;
Ca = ones(size(t)); Ca = Ca*Ca_0;
a = ones(size(t));
b = ones(size(t));
jcg = ones(size(t));
jex = ones(size(t));
CaBslow = zeros(size(t));

I(t>=0&t<=.001) = 1/tstep/10 * 10000;

Caclamp = 0;

% %%
for i = 1:length(t)-1;
    % set
    
    a(i) = amin+(amax-amin)/(1+(Ca(i)/Kcyc)^ncyc);
    b(i) = (bdark + kcat/Vcyto/Nav*E(i))*(G(i)/(G(i)+Km));
    jex(i) = jexsat* (Ca(i)/(Ca(i)+Kex));
    jcg(i) = jmax*(G(i)^ncg/(G(i)^ncg+KcG^ncg))+jex(i);
    
    % update
    dRdt = I(i) - (krmin + (krmax - krmin)/(1+(Ca(i)/kcar)^ncar)) * R(i);
    R(i+1) = R(i)+ dRdt*tstep;
    
    dEdt = vre*R(i)-ke*E(i);
    E(i+1) = E(i)+ dEdt*tstep;
    
    dGdt = a(i)-b(i);
    G(i+1) = G(i)+ dGdt*tstep;
    if G(i+1)<0 G(i+1) = 0; end
    
    dCadt = 1/(FB+1) *((1/2*fca*jcg(i) - jex(i))/Fara/Vcyto); %- kplu1*Ca(i)*(Bmax - CaBslow(i)) + kmin1*CaBslow(i));
    Ca(i+1) = Ca(i)+ dCadt*tstep;
    if Ca(i+1)<0 Ca(i+1) = 0; end
    if Caclamp; Ca(i+1) = Ca(i); end
    
    dCaBslowdt = kplu1*Ca(i)*(Bmax - CaBslow(i)) - kmin1*CaBslow(i);
    CaBslow(i+1) = CaBslow(i)+ dCaBslowdt*tstep;
    
end
i = i+1;
a(i) = amin+(amax-amin)/(1+(Ca(i)/Kcyc)^ncyc);
b(i) = (bdark + kcat/Vcyto/Nav*E(i))*(G(i)/(G(i)+Km));
jex(i) = jexsat* (Ca(i)/(Ca(i)+Kex));
jcg(i) = jmax*(G(i)^ncg/(G(i)^ncg+KcG^ncg))+jex(i);

% %%
figure(1)

subplot(6,2,1);
plot(t,R), axis tight;
ylabel('R');

subplot(6,2,3);
plot(t,E), axis tight;
ylabel('E');

subplot(6,2,5);
plot(t,a), axis tight;
ylabel('cyclase');

subplot(6,2,7);
plot(t,b), axis tight;
ylabel('hydrolysis');

subplot(6,2,9);
plot(t,G), axis tight;
hold on
ylabel('G');

subplot(6,2,11);
plot(t,Ca), axis tight;
ylabel('Ca');

subplot(3,2,2);
plot(t,I), axis tight;
ylabel('I');

subplot(3,2,4);
plot(t,jcg), hold on, axis tight;
ylabel('pA');

subplot(3,2,6);
plot(t,jex), axis tight;
ylabel('exchange');

