function xdot = ss_gravity_j2( ~ , x )
Re  = 6378.137;
J2  = 1.08262668e-3;
mu  = 398600.4415;
r   = norm(x(1:3));
xdot    = [ x(4);
            x(5);
            x(6);
            -mu*x(1)/r^3*(1+1.5*J2*(Re/r)^2*(1-5*(x(3)/r)^2));
            -mu*x(2)/r^3*(1+1.5*J2*(Re/r)^2*(1-5*(x(3)/r)^2));
            -mu*x(3)/r^3*(1+1.5*J2*(Re/r)^2*(3-5*(x(3)/r)^2))];
end