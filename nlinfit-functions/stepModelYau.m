function model = stepModelYau(coef,ib)
% stepModelYau
%      stepResponseAmplitude = I_0*S_0*ln(1+ib/I_0)
%     Nakatani, Tamura, Yau 1991  
% see 
% TA 03/06/11

model = coef(1)*log(1+ib./coef(2));

