function a=alphan(v)
%filename: alphan.m
theta=(v+60)/10;
if(theta==0)   %check for case that gives 0/0
  a=0.1;  %in that case use L'Hospital's rule
else
  a=0.1*theta/(1-exp(-theta));
end
