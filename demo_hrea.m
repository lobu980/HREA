function demo_hrea()
%DEMO_HREA Demonstration of the standalone HREA implementation.
%   The demo uses a two-variable multimodal bi-objective test problem.

    problem.objFcn = @demoObjective;
    problem.lower = [-1, -1];
    problem.upper = [ 1,  1];
    problem.integer = [];

    options.N = 80;
    options.maxFE = 2000;
    options.eps = 0.3;
    options.p = 0.5;
    options.seed = 1;
    options.verbose = true;

    [archive, history] = HREA(problem, options);
    archiveObjs = reshape([archive.objs], 2, [])';

    figure('Color', 'w');
    scatter(archiveObjs(:, 1), archiveObjs(:, 2), 36, 'filled');
    grid on;
    xlabel('f_1(x)');
    ylabel('f_2(x)');
    title(sprintf('HREA archive, final size = %d, FE = %d', numel(archive), history.FE(end)));
end

function f = demoObjective(x)
%DEMOOBJECTIVE A simple multimodal multi-objective test function.
%   Many different decision vectors map to similar objective values, which
%   makes it suitable for checking the archive behavior.

    g1 = x(1)^2 + (x(2) - 0.5)^2 + 0.15 * sin(6 * pi * x(1))^2;
    g2 = (x(1) + 0.4)^2 + (x(2) + 0.5)^2 + 0.15 * sin(6 * pi * x(2))^2;
    f = [g1, g2];
end
