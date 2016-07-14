function r = HH_check_exact(t,t0,v0)

% exact solution for V(t) when gna=gk=0, where V(t0) = v0

global I gl vl c

r = vl + I*(1-exp(-gl*(t-t0)/c))/gl + (v0-vl)*exp(-gl*(t-t0)/c);