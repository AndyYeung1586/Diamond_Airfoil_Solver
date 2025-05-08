function p2p1 = pressure_ratio_across_shock(m1)
    % based on eqn 3.57
    gamma = 1.4;
    p2p1 = 1+(2*gamma)*(m1^2-1)/(gamma+1);
end