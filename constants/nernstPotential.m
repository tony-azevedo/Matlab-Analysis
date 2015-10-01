function E = nernstPotential(outside,inside,z)

R = 8.314;
T = 25+273;
F = 9.6485E4;

E = R*T/z/F * log(outside/inside);
