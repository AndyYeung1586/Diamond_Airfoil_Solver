function m2 = normal_shock(m1)
    gamma = 1.4;
    aa = 1+((gamma-1)/2)*m1^2;
    bb = gamma*m1^2-(gamma-1)/2;
    m2 = sqrt(aa/bb);
end