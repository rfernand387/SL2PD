function f=modexp(p,x,y)
% MODEXP(p) : modele exponentiel du type y=a(1-exp(-k*x))
est=p(1)+(p(2)-p(1)).*(exp(-p(3).*x));
f=norm(est-y);

