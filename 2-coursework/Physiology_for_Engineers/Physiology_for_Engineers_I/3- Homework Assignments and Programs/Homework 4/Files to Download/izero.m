function i=izero(t)
%filename: izero.m
global t1p t2p ip;
if((t1p<t)&(t<t2p))
  i=ip;
else
  i=0;
end
