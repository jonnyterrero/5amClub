function a=alphah(v)
%filename: alphah.m
theta = (v+70)/20;
a=0.07*exp(-theta);

function a=alpham(v)
%filename: alpham.m
theta=(v+45)/10;
if(theta==0)   %check for case that gives 0/0
  a=1.0;  %in that case use L'Hospital's rule
else
  a=1.0*theta/(1-exp(-theta));
end

function a=alphan(v)
%filename: alphan.m
theta=(v+60)/10;
if(theta==0)   %check for case that gives 0/0
  a=0.1;  %in that case use L'Hospital's rule
else
  a=0.1*theta/(1-exp(-theta));
end

