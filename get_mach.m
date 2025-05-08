function m = get_mach(nu)
    syms m
    gamma = 1.4;
    aa = (gamma+1)/(gamma-1);
    bb = m^2-1;

    eqn = nu == sqrt(aa)*atan(sqrt(bb/aa))-atan(sqrt(bb));
    m = vpa(vpasolve(eqn, m, pi/2));
end