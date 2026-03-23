function [PS_global1, PS_global2, PS_local, PF_global, PF_local] = get_local_fun(name)
%GET_LOCAL_FUN Generate reference PS/PF curves or surfaces for plotting.
%   [PS_GLOBAL1, PS_GLOBAL2, PS_LOCAL, PF_GLOBAL, PF_LOCAL] = GET_LOCAL_FUN(NAME)
%   returns benchmark-specific reference sets used by the plotting helper.

    PS_global1 = [];
    PS_global2 = [];
    PS_local   = [];
    PF_global  = [];
    PF_local   = [];

    switch name
        case 'MMF1'
            f1_range  = linspace(0, 1, 300);
            f2_global = 1 - sqrt(f1_range);
            PF_global = [f1_range(:), f2_global(:)];
            x1_range1 = linspace(1, 3, 300);
            x2_global1 = sin(6 * pi * abs(x1_range1 - 2) + pi);
            PS_global1 = [x1_range1(:), x2_global1(:)];

        case 'MMF2'
            f1_range  = linspace(0, 1, 300);
            f2_global = 1 - sqrt(f1_range);
            PF_global = [f1_range(:), f2_global(:)];
            x2_global1 = linspace(0, 1, 300);
            x1_range1  = x2_global1 .^ 2;
            x2_global2 = linspace(1, 2, 300);
            x1_range2  = (x2_global2 - 1) .^ 2;
            PS_global1 = [x1_range1(:), x2_global1(:)];
            PS_global2 = [x1_range2(:), x2_global2(:)];

        case 'MMF4'
            f1_range  = linspace(0, 1, 300);
            f2_global = 1 - f1_range .^ 2;
            PF_global = [f1_range(:), f2_global(:)];
            x1_range1  = linspace(-1, 1, 300);
            x2_global1 = sin(pi * abs(x1_range1));
            x2_global2 = sin(pi * abs(x1_range1)) + 1;
            PS_global1 = [x1_range1(:), x2_global1(:)];
            PS_global2 = [x1_range1(:), x2_global2(:)];

        case 'MMF5'
            f1_range  = linspace(0, 1, 300);
            f2_global = 1 - sqrt(f1_range);
            PF_global = [f1_range(:), f2_global(:)];
            x1_range1  = linspace(1, 3, 300);
            x2_global1 = sin(6 * pi * abs(x1_range1 - 2) + pi);
            x2_global2 = x2_global1 + 2;
            PS_global1 = [x1_range1(:), x2_global1(:)];
            PS_global2 = [x1_range1(:), x2_global2(:)];

        case 'MMF7'
            f1_range  = linspace(0, 1, 300);
            f2_global = 1 - sqrt(f1_range);
            PF_global = [f1_range(:), f2_global(:)];
            x1_range1 = linspace(1, 3, 300);
            abs_x1_minus_2 = abs(x1_range1 - 2);
            term1 = 0.3 * abs_x1_minus_2 .^ 2 .* cos(24 * pi * abs_x1_minus_2 + 4 * pi);
            term2 = 0.6 * abs_x1_minus_2;
            x2_global1 = (term1 + term2) .* sin(6 * pi * abs_x1_minus_2 + pi);
            PS_global1 = [x1_range1(:), x2_global1(:)];

        case 'MMF8'
            f1_range  = linspace(0, 1, 300);
            f2_global = 1 - f1_range .^ 2;
            PF_global = [f1_range(:), f2_global(:)];
            x1_range1  = linspace(-pi, pi, 300);
            base = sin(abs(x1_range1)) + abs(x1_range1);
            PS_global1 = [x1_range1(:), base(:)];
            PS_global2 = [x1_range1(:), (base + 4).'];

        case 'MMF10'
            f1_range = linspace(0.1, 1.1, 100);
            g_global = 1 - 0.8 * exp(-((0.2 - 0.6) / 0.4) ^ 2);
            g_local  = 2 - exp(-((0.6 - 0.2) / 0.004) ^ 2) - 0.8;
            PF_global = [f1_range(:), (g_global ./ f1_range(:))];
            PF_local  = [f1_range(:), (g_local ./ f1_range(:))];
            x1_range1 = linspace(0.1, 1.1, 100);
            PS_global1 = [x1_range1(:), 0.2 * ones(numel(x1_range1), 1)];
            PS_local   = [x1_range1(:), 0.6 * ones(numel(x1_range1), 1)];

        case 'MMF11'
            np = 2;
            f1_range = linspace(0.1, 1.1, 100);
            temp1 = (sin(2 * pi * 0.25)) ^ 6;
            temp2 = exp(-2 * log(2) * ((0.25 - 0.1) / 0.8) ^ 2);
            g = 2 - temp2 * temp1;
            PF_global = [f1_range(:), (g ./ f1_range(:))];
            PF_local = [];
            for i = 2:np
                local = 0.25 + 0.5 * (i - 1);
                temp1 = (sin(2 * pi * local)) ^ 6;
                temp2 = exp(-2 * log(2) * ((local - 0.1) / 0.8) ^ 2);
                g = 2 - temp2 * temp1;
                PF_local = [PF_local; f1_range(:), (g ./ f1_range(:))]; %#ok<AGROW>
            end
            x1_range1 = linspace(0.1, 1.1, 300);
            PS_global1 = [x1_range1(:), 0.25 * ones(numel(x1_range1), 1)];
            PS_local   = [x1_range1(:), 0.75 * ones(numel(x1_range1), 1)];

        case 'MMF12'
            np = 2;
            q  = 4;
            g_func = @(x) 2 - exp(-2 * log(2) * ((x - 0.1) / 0.8) .^ 2) .* sin(np * pi * x) .^ 6;
            h_func = @(f1, g) 1 - (f1 ./ g) .^ 2 - (f1 ./ g) .* sin(2 * pi * q * f1);
            x2_global = 1 / (2 * np);
            x2_local  = 1 / (2 * np) + 1 / np;
            g_global = g_func(x2_global);
            g_local  = g_func(x2_local);
            f1 = linspace(0, 1, 10000);
            f2_global = g_global .* h_func(f1, g_global);
            f2_local  = g_local  .* h_func(f1, g_local);
            valid_global = KeepDescendingEnvelope(f2_global);
            valid_local  = KeepDescendingEnvelope(f2_local);
            f2_global(~valid_global) = NaN;
            f2_local(~valid_local)   = NaN;
            x2g = repmat(x2_global, size(f1));
            x2l = repmat(x2_local,  size(f1));
            x2g(~valid_global) = NaN;
            x2l(~valid_local)  = NaN;
            PS_global1 = [f1(:), x2g(:)];
            PS_local   = [f1(:), x2l(:)];
            PF_global  = [f1(:), f2_global(:)];
            PF_local   = [f1(:), f2_local(:)];

        case 'MMF13'
            f1_range = linspace(0.1, 1.1, 300);
            np = 2;
            t_global = 1 / (2 * np);
            g_global = 2 - exp(-2 * log(2) * ((t_global - 0.1) / 0.8) ^ 2) * (sin(np * pi * t_global)) ^ 6;
            PF_global = [f1_range(:), (g_global ./ f1_range(:))];
            PF_local = [];
            for i = 2:np
                t_local = 1 / (2 * np) + (i - 1) / np;
                g_local = 2 - exp(-2 * log(2) * ((t_local - 0.1) / 0.8) ^ 2) * (sin(np * pi * t_local)) ^ 6;
                PF_local = [PF_local; f1_range(:), (g_local ./ f1_range(:))]; %#ok<AGROW>
            end
            x1_range = linspace(0.1, 1.1, 300);
            x3_range = linspace(0.1, 1.5, 300);
            [X1, X3] = meshgrid(x1_range, x3_range);
            X2_global = 0.25 - sqrt(X3);
            mask_global = (X2_global >= 0.1) & (X2_global <= 1.1);
            PS_global1 = [X1(mask_global), X2_global(mask_global), X3(mask_global)];
            PS_local = [];
            for i = 2:np
                t = 1 / (2 * np) + (i - 1) / np;
                X2_local = t - sqrt(X3);
                mask_local = (X2_local >= 0.1) & (X2_local <= 1.1);
                PS_local = [PS_local; X1(mask_local), X2_local(mask_local), X3(mask_local)]; %#ok<AGROW>
            end

        case 'MMF15'
            np = 2;
            [x1_grid, x2_grid] = meshgrid(linspace(0, 1, 40), linspace(0, 1, 40));
            x1 = x1_grid(:);
            x2 = x2_grid(:);
            x3_global = 1 / (2 * np);
            PS_global1 = [x1, x2, x3_global * ones(size(x1))];
            g_star = 2 - exp(-2 * log(2) * ((x3_global - 0.1) / 0.8) ^ 2) * (sin(np * pi * x3_global)) ^ 2;
            PF_global = [(1 + g_star) .* cos(pi / 2 * x1) .* cos(pi / 2 * x2), ...
                         (1 + g_star) .* cos(pi / 2 * x1) .* sin(pi / 2 * x2), ...
                         (1 + g_star) .* sin(pi / 2 * x1)];
            for i = 2:np
                x3_local = 1 / (2 * np) + (i - 1) / np;
                PS_local = [PS_local; x1, x2, x3_local * ones(size(x1))]; %#ok<AGROW>
                g_local_star = 2 - exp(-2 * log(2) * ((x3_local - 0.1) / 0.8) ^ 2) * (sin(np * pi * x3_local)) ^ 2;
                PF_local = [PF_local; ...
                    (1 + g_local_star) .* cos(pi / 2 * x1) .* cos(pi / 2 * x2), ...
                    (1 + g_local_star) .* cos(pi / 2 * x1) .* sin(pi / 2 * x2), ...
                    (1 + g_local_star) .* sin(pi / 2 * x1)]; %#ok<AGROW>
            end

        case {'IDMPM2T1_e', 'IDMPM2T2_e'}
            x1_global = linspace(-0.6, -0.4, 300);
            PS_global1 = [x1_global(:), -0.5 * ones(numel(x1_global), 1)];
            PF_global  = [abs(x1_global(:) + 0.6), abs(x1_global(:) + 0.4)];
            x1_local = linspace(0.4, 0.6, 300);
            PS_local = [x1_local(:), 0.5 * ones(numel(x1_local), 1)];
            PF_local = [abs(x1_local(:) - 0.4) + 0.01, abs(x1_local(:) - 0.6) + 0.01];

        case 'IDMPM2T3_e'
            x1_global = linspace(-0.6, -0.4, 300);
            PS_global1 = [x1_global(:), -0.5 * ones(numel(x1_global), 1)];
            PS_global2 = [x1_global(:),  0.5 * ones(numel(x1_global), 1)];
            PF_global  = [abs(x1_global(:) + 0.6), abs(x1_global(:) + 0.4)];
            x1_local = linspace(0.4, 0.6, 300);
            PS_local = [x1_local(:), 0.5 - 0.4 * (x1_local(:) - 0.5)];
            PF_local = [abs(x1_local(:) - 0.4) + 0.01, abs(x1_local(:) - 0.6) + 0.01];

        case 'IDMPM2T4_e'
            x1_global = linspace(-0.6, -0.4, 300);
            PS_global1 = [x1_global(:), -0.5 * ones(numel(x1_global), 1)];
            PS_global2 = [x1_global(:),  0.5 * ones(numel(x1_global), 1)];
            PF_global  = [abs(x1_global(:) + 0.6), abs(x1_global(:) + 0.4)];
            x1_local = linspace(0.4, 0.6, 300).';
            localLevels = [-1, -0.5, 0, 0.5, 1];
            PS_blocks = cell(1, numel(localLevels));
            for i = 1:numel(localLevels)
                PS_blocks{i} = [x1_local, localLevels(i) * ones(size(x1_local))];
            end
            PS_local = horzcat(PS_blocks{:});
            f1_local = abs(x1_local - 0.4) + 0.01;
            f2_local = abs(x1_local - 0.6) + 0.01;
            PF_local = [f1_local, f2_local, f1_local, f2_local];

        case 'IDMPM3T1_e'
            [PS_global1, PF_global] = TwoModeTrianglePS(0.1, [-0.5 -0.5 0.6; 0.5 -0.5 0.2]);
            [~, ~, V] = TrianglePF(0.1);
            PF_global = TriangleDistanceCloud(V);
            [PS_local1, ~] = TwoModeTrianglePS(0.1, [0.5 0.5 -0.2; -0.5 0.5 -0.6]);
            PS_local = PS_local1;
            PF_local = PF_global + 0.03;

        case 'IDMPM3T2_e'
            [~, ~, V] = TrianglePF(0.1);
            PF_global = TriangleDistanceCloud(V);
            PS_global1 = TriangleMode(0.1, [0.5, -0.5, -0.6]);
            PS_global2 = TriangleMode(0.1, [-0.5, 0.5, 0.6]);
            PS_local1 = TriangleMode(0.1, [0.5, 0.5, 0.2]);
            PS_local2 = TriangleMode(0.1, [-0.5, -0.5, 0.2]);
            PS_local = [PS_local1, PS_local2];
            PF_local = [PF_global + 0.03; PF_global + 0.06];

        case 'IDMPM3T3_e'
            [~, ~, V] = TrianglePF(0.1);
            PF_global = TriangleDistanceCloud(V);
            theta = [0, 2 * pi / 3, 4 * pi / 3, 0];
            r = 0.1;
            vx = r * cos(theta);
            vy = r * sin(theta);
            PS_global1 = [vx(:) - 0.5, vy(:) - 0.5, -0.6 * ones(numel(vx), 1)];
            PS_global2 = [vx(:) + 0.5, vy(:) + 0.5, (0.2 - 0.2 * (vx(:) + vy(:)))];
            PS_local1  = [vx(:) + 0.5, vy(:) - 0.5, (-0.2 - 0.1 * (vx(:) + vy(:)))];
            PS_local2  = [vx(:) - 0.5, vy(:) + 0.5, (-0.2 - 0.3 * (vx(:) + vy(:)))];
            PS_local   = [PS_local1, PS_local2];
            PF_local   = [PF_global + 0.03; PF_global + 0.06];

        case 'IDMPM3T4_e'
            [~, ~, V] = TrianglePF(0.1);
            PF_global = TriangleDistanceCloud(V);
            PS_global1 = TriangleMode(0.1, [0.5, -0.5, -0.2]);
            PS_local1  = TriangleMode(0.1, [0.5,  0.5,  0.2]);
            PS_local2  = TriangleMode(0.1, [-0.5, -0.5, -0.6]);
            PS_local3  = TriangleMode(0.1, [-0.5,  0.5,  0.6]);
            PS_local   = [PS_local1, PS_local2, PS_local3];
            PF_local   = [PF_global + 0.03; PF_global + 0.06];

        case {'IDMPM2T1', 'IDMPM2T2', 'IDMPM2T4'}
            x1_global = linspace(-0.6, -0.4, 300);
            x1_global1 = linspace(0.4, 0.6, 300);
            PS_global1 = [x1_global(:), -0.5 * ones(numel(x1_global), 1)];
            PS_global2 = [x1_global1(:), 0.5 * ones(numel(x1_global1), 1)];
            PF_global  = [abs(x1_global(:) + 0.6), abs(x1_global(:) + 0.4)];

        case 'IDMPM2T3'
            x1_global = linspace(-0.6, -0.4, 300);
            x1_global1 = linspace(0.4, 0.6, 300);
            PS_global1 = [x1_global(:), -0.5 * ones(numel(x1_global), 1)];
            PS_global2 = [x1_global1(:), 0.5 - 0.4 * (x1_global1(:) - 0.5)];
            PF_global  = [abs(x1_global(:) + 0.6), abs(x1_global(:) + 0.4)];

        case {'IDMPM3T1', 'IDMPM3T2', 'IDMPM3T4'}
            [~, ~, V] = TrianglePF(0.1);
            PF_global = TriangleDistanceCloud(V);
            PS_global1 = [TriangleMode(0.1, [-0.5, -0.5, -0.6]); ...
                          TriangleMode(0.1, [ 0.5, -0.5, -0.2]); ...
                          TriangleMode(0.1, [ 0.5,  0.5,  0.2]); ...
                          TriangleMode(0.1, [-0.5,  0.5,  0.6])];

        case 'IDMPM3T3'
            [~, ~, V] = TrianglePF(0.1);
            PF_global = TriangleDistanceCloud(V);
            theta = [0, 2 * pi / 3, 4 * pi / 3, 0];
            r = 0.1;
            vx = r * cos(theta(:));
            vy = r * sin(theta(:));
            PS1 = [vx - 0.5, vy - 0.5, -0.6 * ones(numel(vx), 1)];
            PS2 = [vx + 0.5, vy - 0.5, -0.2 - 0.1 * ((vx + 0.5) + (vy - 0.5))];
            PS3 = [vx + 0.5, vy + 0.5,  0.2 - 0.2 * (((vx + 0.5) + (vy + 0.5)) - 1)];
            PS4 = [vx - 0.5, vy + 0.5,  0.6 - 0.3 * ((vx - 0.5) + (vy + 0.5))];
            PS_global1 = [PS1; PS2; PS3; PS4];

        case {'IDMPM4T1', 'IDMPM4T2', 'IDMPM4T3', 'IDMPM4T4'}
            [PS_global1, PF_global] = FourModeReference(name);

        otherwise
            error('get_local_fun:UnsupportedCase', 'Unsupported benchmark name: %s', name);
    end
end

function valid = KeepDescendingEnvelope(f2)
    valid = false(size(f2));
    min_f2 = inf;
    for i = 1:numel(f2)
        if f2(i) < min_f2
            valid(i) = true;
            min_f2 = f2(i);
        end
    end
end

function [PS, PF] = TwoModeTrianglePS(r, centers)
    PS = [];
    for i = 1:size(centers, 1)
        PS = [PS; TriangleMode(r, centers(i, :))]; %#ok<AGROW>
    end
    [~, ~, V] = TrianglePF(r);
    PF = TriangleDistanceCloud(V);
end

function mode = TriangleMode(r, center)
    theta = [0, 2 * pi / 3, 4 * pi / 3, 0];
    vx = r * cos(theta(:));
    vy = r * sin(theta(:));
    mode = [vx + center(1), vy + center(2), center(3) * ones(numel(vx), 1)];
end

function [u, v, V] = TrianglePF(r)
    [u, v] = meshgrid(0:0.05:1, 0:0.05:1);
    mask = u + v <= 1;
    u = u(mask);
    v = v(mask);
    V = [r * cos([0, 2 * pi / 3, 4 * pi / 3]); r * sin([0, 2 * pi / 3, 4 * pi / 3])]';
end

function PF = TriangleDistanceCloud(V)
    [u, v] = meshgrid(0:0.05:1, 0:0.05:1);
    mask = u + v <= 1;
    u = u(mask);
    v = v(mask);
    w = 1 - u - v;
    P_x = u * V(1,1) + v * V(2,1) + w * V(3,1);
    P_y = u * V(1,2) + v * V(2,2) + w * V(3,2);
    f1 = sqrt((P_x - V(1,1)).^2 + (P_y - V(1,2)).^2);
    f2 = sqrt((P_x - V(2,1)).^2 + (P_y - V(2,2)).^2);
    f3 = sqrt((P_x - V(3,1)).^2 + (P_y - V(3,2)).^2);
    PF = [f1(:), f2(:), f3(:)];
end

function [PS_global1, PF_global] = FourModeReference(name)
    psize   = 0.1;
    centers = [-0.5 -0.5; 0.5 -0.5; 0.5 0.5; -0.5 0.5];
    baseV = [1 0; 0 1; -1 0; 0 -1];
    baseV_close = [baseV; baseV(1,:)];
    Ng = size(baseV_close, 1);
    V3 = baseV * psize + centers(3, :);
    step = 0.005;
    [X, Y] = ndgrid(min(V3(:,1)):step:max(V3(:,1)), min(V3(:,2)):step:max(V3(:,2)));
    inside = inpolygon(X(:), Y(:), V3(:,1), V3(:,2));
    P = [X(inside), Y(inside)];
    dx = P(:,1) - V3(:,1).';
    dy = P(:,2) - V3(:,2).';
    PF_global = sqrt(dx .^ 2 + dy .^ 2);
    PS_global1 = zeros(Ng * 4, 4);

    switch name
        case {'IDMPM4T1', 'IDMPM4T2', 'IDMPM4T4'}
            z = [-0.6; -0.2; 0.2; 0.6];
            for k = 1:4
                XY = baseV_close * psize + centers(k, :);
                rows = (k - 1) * Ng + (1:Ng);
                PS_global1(rows,:) = [XY(:,1), XY(:,2), z(k) * ones(Ng,1), z(k) * ones(Ng,1)];
            end
        case 'IDMPM4T3'
            a2 = 0.05; a3 = 0.10; a4 = 0.15;
            for k = 1:4
                XY = baseV_close * psize + centers(k, :);
                x1 = XY(:,1); x2 = XY(:,2);
                t2 = x1 + x2;
                t3 = x1 + x2 - 1;
                t4 = x1 + x2;
                switch k
                    case 1
                        x3 = -0.6 * ones(Ng,1); x4 = x3;
                    case 2
                        x3 = -0.2 - a2 * t2; x4 = x3;
                    case 3
                        x3 = 0.2 - a3 * t3;  x4 = x3;
                    otherwise
                        x3 = 0.6 - a4 * t4;  x4 = x3;
                end
                rows = (k - 1) * Ng + (1:Ng);
                PS_global1(rows,:) = [x1, x2, x3, x4];
            end
    end
end
