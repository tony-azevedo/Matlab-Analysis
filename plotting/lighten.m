function lght = lighten(clr)
lght = clr;
for g =1:3
lght(g) = (1-clr(g))*.5 + clr(g);
lght(g) = min([1, lght(g)]);
end
