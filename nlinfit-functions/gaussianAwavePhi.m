function response = gaussianAwavePhi(model,time)

response = time-model(2);
response = exp(-1/2 * model(3) * model(1) * response.*response);
response(time<model(2)) = 1;