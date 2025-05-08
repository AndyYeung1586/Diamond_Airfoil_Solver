function prop=get_isentropic(m1)
    gamma = 1.4;
    prop.T0T1=1+(gamma-1)*m1^2/2;
    prop.p0p1=(prop.T0T1)^(gamma/(gamma-1));
    prop.r0r1=(prop.T0T1)^(1/(gamma-1));
end