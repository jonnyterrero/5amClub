function s=snew(s_old,alpha,beta,dt)
%filename: snew.m
global check;
s=(s_old+dt*alpha)/(1+dt*(alpha+beta));
if(check)
  chsnew=(s-s_old)/dt-(alpha*(1-s)-beta*s);
end
