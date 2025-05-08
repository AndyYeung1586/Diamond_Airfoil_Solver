function T2T1 = temperature_ratio_across_shock(m1)
    % based on eqn 3.57
    gamma = 1.4;

    P2P1 = pressure_ratio_across_shock(m1);
    r2r1 = (gamma+1)*m1^2/((gamma-1)*m1^2+2);
    T2T1 = P2P1/r2r1;
end