function tr=tav(teta,n)
% TAV(teta,n) : calcul de la transmittivite d'une interface pour un
% angle d'ouverture teta donne (en radians).
% n est l'indice de refraction relatif du milieu 2 et peut etre un vecteur.
% fred, le 27/11/91
%     STERN F., 1964, Transmission of isotropic radiation across an
%     interface between two dielectrics, Appl.Opt., Vol.3, 1:111-113
%     ALLEN W.A., 1973, Transmission of isotropic light across a
%     dielectric surface in two and three dimensions, J.Opt.Soc.Am.,
%     Vol.63, 6:664-666
 
      if (teta==0)
        tav=4*n./(n+1).^2;
      else
        a=(n+1).^2/2;
        k=-(n.^2-1).^2./4;
 
          if teta==pi/2
          b1=0;
          else
          b1=sqrt((sin(teta)*sin(teta)-(n.^2+1)/2).^2+k);
          end
 
        b2=sin(teta)*sin(teta)-(n.^2+1)/2;
        b=b1-b2;
        ts=(k.^2../(6*b.^3)+k./b-b/2)-(k.^2../(6*a.^3)+k./a-a/2);
        tp1=-2.*n.^2..*(b-a)./(n.^2+1).^2;
        tp2=-2.*n.^2..*(n.^2+1).*log(b./a)./(n.^2-1).^2;
        tp3=n.^2..*(1../b-1../a)/2;
        tp4=16*n.^4..*(n.^4+1).*log((2..*(n.^2+1).*b-(n.^2-1).^2) ...
        ./(2..*(n.^2+1).*a-(n.^2-1).^2))./((n.^2+1).^3..*(n.^2-1).^2);
        tp5=16*n.^6..*(1../(2*(n.^2+1).*b-(n.^2-1).^2)-1../(2*(n.^  ...
        2+1).*a-(n.^2-1).^2))./(n.^2+1).^3;
        tp=tp1+tp2+tp3+tp4+tp5;
        tr=(ts+tp)./(2*sin(teta)*sin(teta));
      end

