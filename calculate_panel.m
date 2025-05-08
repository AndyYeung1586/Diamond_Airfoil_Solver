function [M2, P2, T2]=calculate_panel(pt, theta1, M1, P1, T1, ax, pts_rot, dir)
    if theta1 == 0.00 || M1 < 1.00
        % infinitely weak mach wave or subsonic speed, no properties change
        M2 = M1;
        P2 = P1;
        T2 = T1;

    elseif theta1 > 0.00
        % calculate effects of shock 
        beta = find_beta(M1, theta1);
        M1n = M1*sin(beta);
        M2n = normal_shock(M1n);
        M2 = M2n/sin(beta-theta1);
        P2 = P1*pressure_ratio_across_shock(M1n);
        T2 = T1*temperature_ratio_across_shock(M1n);
    
        % calculate the shock line
        x_shock = [pts_rot(pt,1), pts_rot(pt,1) + 1.5 * cos(beta)];
        if dir
            y_shock = [pts_rot(pt,2), pts_rot(pt,2) + 1.5 * sin(beta)];
        else
            y_shock = [pts_rot(pt,2), pts_rot(pt,2) - 1.5 * sin(beta)];
        end
        
        % plot the shock line
        plot(ax, x_shock, y_shock, 'r', 'LineWidth', min(5, double(P2/P1)));

    elseif theta1 < -0.00
        % using Prandtl Meyer function to find new Mach
        nu1 = get_prandtl_meyer(M1);
        nu2 = nu1 - theta1;
        M2 = get_mach(nu2);
        mu1 = asin(1/M1);
        mu2 = asin(1/M2);
        
        % find properties in new state using isentropic relations
        properties_1 = get_isentropic(M1);
        properties_2 = get_isentropic(M2);
    
        P2 = properties_1.p0p1 / properties_2.p0p1 * P1; 
        T2 = properties_1.T0T1 / properties_2.T0T1 * T1;
        P2 = vpa(P2);
        T2 = vpa(T2);

        % calculate the expansion fan lines
        x_mach1 = [pts_rot(pt,1), pts_rot(pt,1) + 1.5 * cos(mu1-theta1)];
        x_mach2 = [pts_rot(pt,1), pts_rot(pt,1) + 1.5 * cos(mu2)];
        
        if dir
            y_mach1 = [pts_rot(pt,2), pts_rot(pt,2) + 1.5 * sin(mu1-theta1)];
            y_mach2 = [pts_rot(pt,2), pts_rot(pt,2) + 1.5 * sin(mu2)];
        else
            y_mach1 = [pts_rot(pt,2), pts_rot(pt,2) - 1.5 * sin(mu1-theta1)];
            y_mach2 = [pts_rot(pt,2), pts_rot(pt,2) - 1.5 * sin(mu2)];
        end
        
        % plot the expansion fan lines
        plot(ax, x_mach1, y_mach1, 'b--', 'LineWidth', 1);
        plot(ax, x_mach2, y_mach2, 'b--', 'LineWidth', 1);
    end
end