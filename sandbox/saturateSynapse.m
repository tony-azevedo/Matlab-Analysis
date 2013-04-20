function dydt = saturateSynapse(t,y)
dy = zeros(2,1);    % a column vector
dy(1) = y(2);
dy(2) = 1000*(1 - y(1)^2)*y(2) - y(1);

b(i) = (bdark + r_on*A(i))*(N_a(i)/(N_a(i)+Km));

% update
dRdt = firing_rate(i) - kr * R(i);
R(i+1) = R(i)+ dRdt*tstep;

dAdt = Ach_per_ves*R(i)-ke*A(i);
A(i+1) = A(i)+ dAdt*tstep;

dN_adt = r_off-b(i); % available channels increases with unbinding, decreases with binding
N_a(i+1) = N_a(i)+ dN_adt*tstep;
if N_a(i+1)<0 N_a(i+1) = 0; end


dy = zeros(3,1);    % a column vector
dy(1) = y(2) * y(3);
dy(2) = -y(1) * y(3);
dy(3) = -0.51 * y(1) * y(2);