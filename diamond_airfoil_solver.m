function diamond_airfoil_solver()
    % Initial Parameters
    close all
    Minf = 2.0;     % upstream mach
    Pinf = 1;       % upstream pressure, atm
    Tinf = 288;     % upstream temperature, K
    alfa = 5;       % angle of attack, deg
    wedge_u = 10;   % half wedge angle for upper surface, deg
    wedge_l = 10;   % half wedge angle for lower surface, deg
    chord = 1.0;    % chord length, fixed
    c1 = 0.3;       % leading wedge length ratio
    t = c1*chord*(atan(wedge_u*pi/180)+atan(wedge_l*pi/180));  % thickness, chordlength
    
    % Interactive window set up
    f = figure('Position', [100 100 1200 600], 'Name', 'Diamond Airfoil Interactive Viewer');
    ax = axes('Parent', f, 'Position', [0.35 0.15 0.6 0.9]);
    xlabel(ax, 'x'); 
    ylabel(ax, 'y');
    axis(ax, 'equal');
    xlim(ax, [-0.5 1.5]);
    ylim(ax, [-0.5 0.5]);
    set(gca,'FontSize',16,'LineWidth',2.0,'FontWeight','demi')
    update();

    % Controls
    xint = 0.03; yint = 0.87; gap = 0.10;
    cbx = uicontrol(f, 'Style', 'checkbox', 'String', 'Lock Wedge Angles', ...
        'Units', 'normalized', 'Position', [xint 0.05 0.25 0.05], ...
        'FontSize', 14, 'Value', 0);

    create_control(           'Mach',  1.5,    5,    Minf, xint, yint-0*gap, @(v) update_param('mach', v));
    create_control( 'Pressure (atm)', 0.01,   10,    Pinf, xint, yint-1*gap, @(v) update_param('pressure', v));
    create_control(        'AoA (°)',  -20,   20,    alfa, xint, yint-2*gap, @(v) update_param('alpha', v));
    [uSlider, uBox] = create_control('Upper Wedge (°)',    0,   30, wedge_u, xint, yint-3*gap, @(v) update_dep('wedge_u', v, cbx.Value));
    [lSlider, lBox] = create_control('Lower Wedge (°)',    0,   30, wedge_l, xint, yint-4*gap, @(v) update_dep('wedge_l', v, cbx.Value));
    create_control(     'c1 (ratio)', 0.05, 0.95,      c1, xint, yint-5*gap, @(v) update_dep('c1', v, cbx.Value));
    [tSlider, tBox] = create_control('  Thickness (c)',    0, 0.30,       t, xint, yint-6*gap, @(v) update_dep('thickness', v, cbx.Value));

    % Solution printout
    liftText = uicontrol(f, 'Style', 'text', 'String', 'Lift: ', ...
        'Units', 'normalized', 'Position', [xint 0.20 0.30 0.05], ...
        'HorizontalAlignment', 'left', 'FontSize', 14, 'FontWeight','bold');

    dragText = uicontrol(f, 'Style', 'text', 'String', 'Drag: ', ...
        'Units', 'normalized', 'Position', [xint 0.15 0.30 0.05], ...
        'HorizontalAlignment', 'left', 'FontSize', 14, 'FontWeight','bold');

    ldText = uicontrol(f, 'Style', 'text', 'String', 'L/D: ', ...
        'Units', 'normalized', 'Position', [xint 0.10 0.30 0.05], ...
        'HorizontalAlignment', 'left', 'FontSize', 14, 'FontWeight','bold');

    P2Text = uicontrol(f, 'Style', 'text', 'String', 'P2/P0: ', ...
        'Units', 'normalized', 'Position', [0.35 0.15 0.25 0.05], ...
        'HorizontalAlignment', 'left', 'FontSize', 14, 'FontWeight','bold');
    P3Text = uicontrol(f, 'Style', 'text', 'String', 'P3/P0: ', ...
        'Units', 'normalized', 'Position', [0.45 0.15 0.25 0.05], ...
        'HorizontalAlignment', 'left', 'FontSize', 14, 'FontWeight','bold');
    P4Text = uicontrol(f, 'Style', 'text', 'String', 'P4/P0: ', ...
        'Units', 'normalized', 'Position', [0.35 0.10 0.25 0.05], ...
        'HorizontalAlignment', 'left', 'FontSize', 14, 'FontWeight','bold');
    P5Text = uicontrol(f, 'Style', 'text', 'String', 'P5/P0: ', ...
        'Units', 'normalized', 'Position', [0.45 0.10 0.25 0.05], ...
        'HorizontalAlignment', 'left', 'FontSize', 14, 'FontWeight','bold');

    % Create slider and textbox for changing parameter
    function [slider, editbox] = create_control(name, minv, maxv, init, xpos, ypos, callback)
        uicontrol(f, 'Style', 'text', 'String', name, ...
            'Units', 'normalized', 'Position', [xpos ypos+0.05 0.2 0.04], ...
            'HorizontalAlignment', 'left', 'FontSize', 14, 'FontWeight','bold');

        slider = uicontrol(f, 'Style', 'slider', ...
            'Min', minv, 'Max', maxv, 'Value', init, ...
            'Units', 'normalized', 'Position', [xpos ypos 0.2 0.04], ...
            'Callback', @(src, ~) sync_inputs(src.Value), ...
            'FontSize', 12, 'FontWeight','bold');

        editbox = uicontrol(f, 'Style', 'edit', 'String', num2str(init), ...
            'Units', 'normalized', 'Position', [xpos+0.205 ypos 0.05 0.04], ...
            'Callback', @(src, ~) sync_inputs(str2double(src.String)), ...
            'FontSize', 12, 'FontWeight','bold');

        % Sync function
        function sync_inputs(val)
            % restrict parameters within determined range
            val = max(min(val, maxv), minv);
            slider.Value = val;
            editbox.String = num2str(val);
            callback(val);
            update();
        end
    end

    % Update dependent parameters
    function update_dep(paramname, value, link)
        switch paramname
            case 'wedge_u' 
                update_param('wedge_u', value)
                if link 
                    lSlider.Value = value;
                    lBox.String = num2str(value);
                    update_param('wedge_l', value)
                end
                t = c1*chord*(atan(wedge_u*pi/180)+atan(wedge_l*pi/180));
                tSlider.Value = t;
                tBox.String = num2str(t);
                update_param('thickness', t)

            case 'wedge_l' 
                update_param('wedge_l', value)
                if link 
                    uSlider.Value = value;
                    uBox.String = num2str(value);
                    update_param('wedge_u', value)
                end
                t = c1*chord*(atan(wedge_u*pi/180)+atan(wedge_l*pi/180));
                tSlider.Value = t;
                tBox.String = num2str(t);
                update_param('thickness', t)

            case 'c1'
                update_param('c1', value)

                t = c1*chord*(atan(wedge_u*pi/180)+atan(wedge_l*pi/180));
                tSlider.Value = t;
                tBox.String = num2str(t);
                update_param('thickness', t)

            case 'thickness'
                if ~link
                    cbx.Value = 1;
                end
                update_param('thickness', value)
                wedge_angle = atan2(value,2*c1*chord)*180/pi;

                lSlider.Value = wedge_angle;
                lBox.String = num2str(wedge_angle);
                update_param('wedge_l', wedge_angle)

                uSlider.Value = wedge_angle;
                uBox.String = num2str(wedge_angle);
                update_param('wedge_u', wedge_angle)
        end
    end

    % Update parameters
    function update_param(paramname, value)
        switch paramname
            case 'mach' 
                Minf = value;
            case 'pressure'
                Pinf = value;
            case 'alpha' 
                alfa = value;
            case 'wedge_u' 
                wedge_u = value;
            case 'wedge_l' 
                wedge_l = value;
            case 'c1' 
                c1 = value;
            case 'thickness'
                t = value;
        end
    end

    % Draw airfoil
    function update()
        cla(ax);
        hold(ax, 'on');

        % Define diamond airfoil parameters
        a = alfa*pi/180;            % angle of attack, rad
        wu = wedge_u*pi/180;        % upper leading half wedge angle, rad
        wl = wedge_l*pi/180;        % lower leading half wedge angle, rad
        c = chord;                  % chord
        tu = tan(wu)*c1*c;          % upper thickness
        tl = tan(wl)*c1*c;          % lower thickness
        t = tu+tl;                  % total thickness
        wu2 = atan2(tu, chord-c1);  % upper trailing half wedge angle, rad
        wl2 = atan2(tl, chord-c1);  % lower trailing half wedge angle, rad

        % Define diamond airfoil points
        pts = [0,  0;
               c1, tu;
               c,  0;
               c1, -tl;
               0,  0];

        % Rotate about point (c1, 0)
        pivot = [c1, 0];
        R = [cos(a), sin(a); 
            -sin(a), cos(a)];
        pts_shifted = pts - pivot;
        pts_rot = (R * pts_shifted')' + pivot;

        % Flow direction vector
        scale = Minf/10;
        quiver(ax, -0.5, 0, 1, 0, scale, 'r', 'LineWidth', scale*10, 'MaxHeadSize', .5);
        text(ax, -0.4, 0.4, sprintf('Mach %.2f', Minf), 'Color', 'r', 'FontSize',16,'FontWeight','bold');
        
        % =============== CALCULATE UPPER SURFACE STATIONS ===============
        % State 1 -> 2
        pt = 1;  % at the pt where the change ocurrs for shock/expansion
        theta1 = wu-a;
        [M2, P2, T2] = calculate_panel(pt, theta1, Minf, Pinf, Tinf, ax, pts_rot, 1);

        % State 2 -> 3
        pt = 2;
        theta2 = -2*wu2;
        [M3, P3, T3] = calculate_panel(pt, theta2, M2, P2, T2, ax, pts_rot, 1);

        % State 3 -> 3e (upper)
        pt = 3;
        theta3 = wu2+a;
        [Meu, Peu, Teu] = calculate_panel(pt, theta3, M3, P3, T3, ax, pts_rot, 1);
        
        % =============== CALCULATE LOWER SURFACE STATIONS ===============
        % State 1 -> 4
        pt = 5;
        theta3 = wl+a;
        [M4, P4, T4] = calculate_panel(pt, theta3, Minf, Pinf, Tinf, ax, pts_rot, 0);

        % State 4 -> 5
        pt = 4;
        theta4 = -2*wl2;
        [M5, P5, T5] = calculate_panel(pt, theta4, M4, P4, T4, ax, pts_rot, 0);

        % State 5 -> 5e (lower)
        pt = 3;
        theta5 = wl2-a;
        [Mel, Pel, Tel] = calculate_panel(pt, theta5, M5, P5, T5, ax, pts_rot, 0);

        % ================== Find qualities of interest ==================
        ds2 = get_panel_length(1, 2, pts);
        ds3 = get_panel_length(2, 3, pts);
        ds4 = get_panel_length(5, 4, pts);
        ds5 = get_panel_length(4, 3, pts);

        % Find pressure ratios
        prop_inf = get_isentropic(Minf);
        P0 = Pinf*prop_inf.p0p1;
        P2Text.String = sprintf('P2/P0: %.3f', P2/P0);
        P3Text.String = sprintf('P3/P0: %.3f', P3/P0);
        P4Text.String = sprintf('P4/P0: %.3f', P4/P0);
        P5Text.String = sprintf('P5/P0: %.3f', P5/P0);
        
        % Find forces
        Fn = -P2*ds2*cos(wu) - P3*ds3*cos(wu2) + P4*ds4*cos(wl) + P5*ds5*cos(wl2);
        Fp = P2*ds2*sin(wu) - P3*ds3*sin(wu2) + P4*ds4*sin(wl) - P5*ds5*sin(wl2);

        Lift = Fn*cos(a) - Fp*sin(a);
        Drag = Fn*sin(a) + Fp*cos(a);
        
        % Update solution printouts
        liftText.String = sprintf('Lift: %.1f N/m | %.1f lb/m', Lift*101325, Lift*22778.766);
        dragText.String = sprintf('Drag: %.1f N/m | %.1f lb/m', Drag*101325, Drag*22778.766);
        ldText.String = sprintf('L/D: %.3f', Lift/Drag); 

        % Plot airfoil
        fill(ax, pts_rot(:,1), pts_rot(:,2), 'b', 'FaceAlpha', 0.3, 'EdgeColor', 'k', 'LineWidth', 2);

        % Axes styling
        title_name = sprintf('Diamond Airfoil (α = %.1f°, t = %.3fc, M = %.2f, c1 = %.2f)', alfa, t, Minf, c1);
        title(ax, title_name);
        hold(ax, 'off');
    end

    function ds = get_panel_length(pt1, pt2, pts)
        dy = pts(pt2,2)-pts(pt1,2);
        dx = pts(pt2,1)-pts(pt1,1);
        ds = sqrt(dy^2 + dx^2);
    end
end
