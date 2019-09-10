function f=modexp_nn(p,x,y)
% MODEXP(p) : modele exponentiel du type y=a(1-exp(-k*x))
est=p(1).*(1-exp(-p(2).*x));
f=norm(est-y);

