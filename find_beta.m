function beta=find_beta(m, theta)
    % based on eqn 4.17
    b = asin(1/m);  % inital guess at mach angle
    gamma = 1.4;
    beta = pi/2;

    for i=1:60
        aa = m^2*sin(b)^2-1;
        bb = m^2*(gamma+cos(2*b))+2;
        res = tan(theta)-2*cot(b)*aa/bb;

        b = b+res;
        if abs(res)<10e-6
            beta = b;
            break
        end
    end
end