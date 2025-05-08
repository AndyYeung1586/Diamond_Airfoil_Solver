function theta=find_theta(m, beta)
    % based on eqn 4.17
    syms t
    aa = m^2*sin(beta)^2-1;
    bb = m^2*(1.4+cos(2*beta))+2;
    eqn1 = tan(t)==2*cot(beta)*aa/bb;
    % eqn2 = (0 <= b) && (b <= pi);

    theta = vpa(vpasolve(eqn1, t, 0.5));
end