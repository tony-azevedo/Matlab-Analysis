%Implement the Hodgkin-Huxley equations.
%See Gerstner and Kistler, Spiking Neuron Models, 2002, Section 2.2.
%You'll see I've scaled the voltage by 65 in the equation that updates V
%and the auxillary functions.  Hodgkin and Huxley set the resting voltage
%of the neuron to 0 mV and we've set it here to -65 mV (the value accepted
%today).

%INPUTS
%    I0 = input current.
%    T0 = total time to simulate (in [ms]).
%
%OUTPUTS
%    V = the voltage of neuron.
%    m = activation variable for Na-current.
%    h = inactivation variable for Na-current.
%    n = activation variable for K-current.
%    t = the time axis of the simulation (useful for plotting).

function [I_na,I_k,I_l,m,h,n,T,V] = HH_IClamp(I,T,varargin)

dt = 0.01; % ms (dt = 0.01ms)
if length(T) == 1
    T = ceil(T/dt); %T  = ceil(T0/dt);
    T = (1:T-1)';
    T = T*dt;
else
    T = T(:);
    dt = T(2)-T(1);
end
if length(I) == 1
    I = ones(size(T)) * I; %T  = ceil(T0/dt);
end

V = zeros(size(T));
I_na = zeros(size(T));
I_k = zeros(size(T));
I_l = zeros(size(T));
m = zeros(size(T));
h = zeros(size(T));
n = zeros(size(T));

p = inputParser;
p.addParamValue('V0',-70,@isnumeric);
p.addParamValue('m0',0.05,@isnumeric);
p.addParamValue('h0',0.54,@isnumeric);
p.addParamValue('n0',0.34,@isnumeric);
p.addParamValue('gNa',120,@isnumeric);
p.addParamValue('gKratio',0.3,@isnumeric);
p.addParamValue('gLratio',0.0025,@isnumeric);

parse(p,varargin{:});

V(1)= p.Results.V0; % V(1)=-70.0;
m(1)= p.Results.m0;
h(1)= p.Results.h0;
n(1)= p.Results.n0;

gNa = p.Results.gNa;  ENa=115; % gNa = 120;  ENa=115;
gK = gNa*p.Results.gKratio;  EK=-12; % gK = 36;  EK=-12;
gL = gNa*p.Results.gLratio;  ERest=100; % gL=0.3;  ERest=10.6;


for i=1:length(T)-1
    V(i+1) = V(i) + dt*(gNa*m(i)^3*h(i)*(ENa-(V(i)+65)) + gK*n(i)^4*(EK-(V(i)+65)) + gL*(ERest-(V(i)+65)) + I(i));
    I_na(i) = gNa*m(i)^3*h(i)*(ENa-(V(i)+65));
    I_k(i) = gK*n(i)^4*(EK-(V(i)+65));
    I_l(i) = gL*(ERest-(V(i)+65));
    
    m(i+1) = m(i) + dt*(alphaM(V(i))*(1-m(i)) - betaM(V(i))*m(i));
    h(i+1) = h(i) + dt*(alphaH(V(i))*(1-h(i)) - betaH(V(i))*h(i));
    n(i+1) = n(i) + dt*(alphaN(V(i))*(1-n(i)) - betaN(V(i))*n(i));
end

I_na(i+1) = gNa*m(i+1)^3*h(i+1)*(ENa-(V(i+1)+65));
I_k(i+1) = gK*n(i+1)^4*(EK-(V(i+1)+65));
I_l(i+1) = gL*(ERest-(V(i+1)+65));


end

%Below, define the AUXILIARY FUNCTIONS alpha & beta for each gating variable.

function aM = alphaM(V)
aM = (2.5-0.1*(V+65)) ./ (exp(2.5-0.1*(V+65)) -1);
end

function bM = betaM(V)
bM = 4*exp(-(V+65)/18);
end

function aH = alphaH(V)
aH = 0.07*exp(-(V+65)/20);
end

function bH = betaH(V)
bH = 1./(exp(3.0-0.1*(V+65))+1);
end

function aN = alphaN(V)
aN = (0.1-0.01*(V+65)) ./ (exp(1-0.1*(V+65)) -1);
end

function bN = betaN(V)
bN = 0.125*exp(-(V+65)/80);
end
