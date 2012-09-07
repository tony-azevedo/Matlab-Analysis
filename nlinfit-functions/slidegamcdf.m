function y = slidegamcdf(x,a,b,c)

x = x-min(x)+eps+abs(a);
y = gamcdf(x,b,c);
