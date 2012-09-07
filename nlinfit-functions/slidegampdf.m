function y = slidegampdf(x,a,b,c)

x = x-min(x)+eps+abs(a);
y = gampdf(x,b,c);
