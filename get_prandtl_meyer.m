function nu = get_prandtl_meyer(m)
    gamma = 1.4;
    aa = (gamma+1)/(gamma-1);
    bb = m^2-1;
    nu = sqrt(aa)*atan(sqrt(bb/aa))-atan(sqrt(bb));
end