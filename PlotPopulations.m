function PlotPopulations(Pop1, Pop2, FE, maxFE, name, nvar)
%PLOTPOPULATIONS Plot current population/archive against benchmark PF/PS.

    if nargin < 6 || isempty(nvar)
        nvar = size(Pop1.X, 2);
    end
    if nargin < 5 || isempty(name) || exist('get_local_fun', 'file') ~= 2
        return;
    end

    addpath(genpath('MM_testfunctions/'));
    addpath(genpath('IDMP_testfunctions/'));

    [PS_global1, PS_global2, PS_local, PF_global, PF_local] = get_local_fun(name);

    if nvar == 2
        figure(1);
        subplot(1, 2, 1); cla; hold on;
        switch name
            case {'MMF1','MMF2','MMF4','MMF5','MMF7','MMF8','IDMPM2T1','IDMPM2T2','IDMPM2T3','IDMPM2T4'}
                plot(PF_global(:,1), PF_global(:,2), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Global PF');
            case {'MMF10','MMF11','MMF12','IDMPM2T1_e','IDMPM2T2_e','IDMPM2T3_e'}
                plot(PF_global(:,1), PF_global(:,2), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Global PF');
                plot(PF_local(:,1), PF_local(:,2), 'k--', 'LineWidth', 1.5, 'DisplayName', 'Local PF');
            case {'IDMPM2T4_e'}
                plot(PF_global(:,1), PF_global(:,2), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Global PF');
                plot(PF_local(:,1), PF_local(:,2), 'k--', 'LineWidth', 1.5, 'DisplayName', 'Local PF');
                plot(PF_local(:,3), PF_local(:,4), 'k:', 'LineWidth', 1.5, 'DisplayName', 'Local PF');
        end
        plot(Pop1.F(:,1), Pop1.F(:,2), 'bo', 'MarkerFaceColor', 'b', 'DisplayName', 'CA');
        plot(Pop2.F(:,1), Pop2.F(:,2), 'ro', 'MarkerFaceColor', 'r', 'DisplayName', 'DA');
        title(['Objective Space (FE: ' num2str(FE) '/' num2str(maxFE) ')']);
        xlabel('f1'); ylabel('f2'); grid on; legend('Location', 'northeast');

        subplot(1, 2, 2); cla; hold on;
        switch name
            case {'MMF1','MMF7'}
                plot(PS_global1(:,1), PS_global1(:,2), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Global PS');
            case {'MMF2','MMF4','MMF5','MMF8'}
                plot(PS_global1(:,1), PS_global1(:,2), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Global PS1');
                plot(PS_global2(:,1), PS_global2(:,2), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Global PS2');
            case {'MMF10','MMF11','MMF12','IDMPM2T1_e','IDMPM2T2_e'}
                plot(PS_global1(:,1), PS_global1(:,2), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Global PS');
                plot(PS_local(:,1), PS_local(:,2), 'k--', 'LineWidth', 1.5, 'DisplayName', 'Local PS');
            case {'IDMPM2T3_e'}
                plot(PS_global1(:,1), PS_global1(:,2), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Global PS');
                plot(PS_global2(:,1), PS_global2(:,2), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Global PS');
                plot(PS_local(:,1), PS_local(:,2), 'k--', 'LineWidth', 1.5, 'DisplayName', 'Local PS');
            case {'IDMPM2T4_e'}
                plot(PS_global1(:,1), PS_global1(:,2), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Global PS');
                plot(PS_global2(:,1), PS_global2(:,2), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Global PS');
                plot(PS_local(:,1), PS_local(:,2), 'k--', 'LineWidth', 1.5, 'DisplayName', 'Local PS');
                plot(PS_local(:,3), PS_local(:,4), 'k--', 'LineWidth', 1.5, 'DisplayName', 'Local PS');
                plot(PS_local(:,5), PS_local(:,6), 'k--', 'LineWidth', 1.5, 'DisplayName', 'Local PS');
                plot(PS_local(:,7), PS_local(:,8), 'k:', 'LineWidth', 1.5, 'DisplayName', 'Local PS');
                plot(PS_local(:,9), PS_local(:,10), 'k:', 'LineWidth', 1.5, 'DisplayName', 'Local PS');
            case {'IDMPM2T1','IDMPM2T2','IDMPM2T3','IDMPM2T4'}
                plot(PS_global1(:,1), PS_global1(:,2), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Global PS');
                plot(PS_global2(:,1), PS_global2(:,2), 'k-', 'LineWidth', 1.5, 'DisplayName', 'Global PS');
        end
        plot(Pop1.X(:,1), Pop1.X(:,2), 'bo', 'MarkerFaceColor', 'b', 'DisplayName', 'CA');
        plot(Pop2.X(:,1), Pop2.X(:,2), 'ro', 'MarkerFaceColor', 'r', 'DisplayName', 'DA');
        title('Decision Space'); xlabel('x1'); ylabel('x2'); grid on;
    end

    if nvar == 3
        figure(1);
        subplot(1, 2, 1); cla; hold on;
        switch name
            case {'MMF13'}
                scatter(PF_global(:,1), PF_global(:,2), 8, 'filled', 'DisplayName', 'Global PF');
                scatter(PF_local(:,1), PF_local(:,2), 8, 'filled', 'DisplayName', 'Local PF');
                scatter(Pop1.F(:,1), Pop1.F(:,2), 24, 'b', 'filled', 'DisplayName', 'CA');
                scatter(Pop2.F(:,1), Pop2.F(:,2), 24, 'r', 'filled', 'DisplayName', 'DA');
            case {'MMF15','IDMPM3T1_e','IDMPM3T4_e'}
                scatter3(PF_global(:,1), PF_global(:,2), PF_global(:,3), 10, 'filled', 'DisplayName', 'Global PF');
                scatter3(PF_local(:,1), PF_local(:,2), PF_local(:,3), 10, 'filled', 'DisplayName', 'Local PF');
                scatter3(Pop1.F(:,1), Pop1.F(:,2), Pop1.F(:,3), 30, 'b', 'filled', 'DisplayName', 'CA');
                scatter3(Pop2.F(:,1), Pop2.F(:,2), Pop2.F(:,3), 30, 'r', 'filled', 'DisplayName', 'DA');
                grid on; view(135, 30); rotate3d on;
            case {'IDMPM3T2_e','IDMPM3T3_e'}
                scatter3(PF_global(:,1), PF_global(:,2), PF_global(:,3), 10, 'r', 'filled', 'DisplayName', 'Global PF');
                scatter3(PF_local(:,1), PF_local(:,2), PF_local(:,3), 10, 'b', 'filled', 'DisplayName', 'Local PF1');
                scatter3(Pop1.F(:,1), Pop1.F(:,2), Pop1.F(:,3), 30, 'b', 'filled', 'DisplayName', 'CA');
                scatter3(Pop2.F(:,1), Pop2.F(:,2), Pop2.F(:,3), 30, 'r', 'filled', 'DisplayName', 'DA');
                grid on; view(135, 30); rotate3d on;
            case {'IDMPM3T1','IDMPM3T2','IDMPM3T3','IDMPM3T4'}
                scatter3(PF_global(:,1), PF_global(:,2), PF_global(:,3), 10, 'r', 'filled', 'DisplayName', 'Global PF');
                scatter3(Pop1.F(:,1), Pop1.F(:,2), Pop1.F(:,3), 30, 'b', 'filled', 'DisplayName', 'CA');
                scatter3(Pop2.F(:,1), Pop2.F(:,2), Pop2.F(:,3), 30, 'r', 'filled', 'DisplayName', 'DA');
                grid on; view(135, 30); rotate3d on;
        end
        title(['Objective Space (FE: ' num2str(FE) '/' num2str(maxFE) ')']);
        xlabel('f1'); ylabel('f2'); zlabel('f3'); grid on; legend('Location', 'northeast');

        subplot(1, 2, 2); cla; hold on;
        switch name
            case {'MMF13','MMF15','IDMPM3T1_e'}
                scatter3(PS_global1(:,1), PS_global1(:,2), PS_global1(:,3), 10, 'b', 'filled', 'DisplayName', 'Global PS');
                scatter3(PS_local(:,1), PS_local(:,2), PS_local(:,3), 10, 'r', 'filled', 'DisplayName', 'Local PS');
            case {'IDMPM3T2_e','IDMPM3T3_e'}
                scatter3(PS_global1(:,1), PS_global1(:,2), PS_global1(:,3), 10, 'r', 'filled', 'DisplayName', 'Global PS1');
                scatter3(PS_global2(:,1), PS_global2(:,2), PS_global2(:,3), 10, 'r', 'filled', 'DisplayName', 'Global PS2');
                scatter3(PS_local(:,1), PS_local(:,2), PS_local(:,3), 10, 'b', 'filled', 'DisplayName', 'Local PS1');
                scatter3(PS_local(:,4), PS_local(:,5), PS_local(:,6), 10, 'b', 'filled', 'DisplayName', 'Local PS2');
            case {'IDMPM3T4_e'}
                scatter3(PS_global1(:,1), PS_global1(:,2), PS_global1(:,3), 10, 'r', 'filled', 'DisplayName', 'Global PS1');
                scatter3(PS_local(:,1), PS_local(:,2), PS_local(:,3), 10, 'b', 'filled', 'DisplayName', 'Local PS1');
                scatter3(PS_local(:,4), PS_local(:,5), PS_local(:,6), 10, 'b', 'filled', 'DisplayName', 'Local PS2');
                scatter3(PS_local(:,7), PS_local(:,8), PS_local(:,9), 10, 'b', 'filled', 'DisplayName', 'Local PS3');
            case {'IDMPM3T1','IDMPM3T2','IDMPM3T3','IDMPM3T4'}
                scatter3(PS_global1(:,1), PS_global1(:,2), PS_global1(:,3), 10, 'r', 'filled', 'DisplayName', 'Global PS');
        end
        scatter3(Pop1.X(:,1), Pop1.X(:,2), Pop1.X(:,3), 30, 'b', 'filled', 'DisplayName', 'CA');
        scatter3(Pop2.X(:,1), Pop2.X(:,2), Pop2.X(:,3), 30, 'r', 'filled', 'DisplayName', 'DA');
        title('Decision Space');
        xlabel('x1'); ylabel('x2'); zlabel('x3'); legend('Location', 'northeast');
        grid on; view(135, 30); rotate3d on;
    end
end
