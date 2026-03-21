function demo_MMOEADC_ZDT1()
%DEMO_MMOEADC_ZDT1 Demonstrate the standalone MMOEA-DC implementation.

    problem = ZDT1_Problem(30);
    options = struct(...
        'N', 100, ...
        'MaxGen', 100, ...
        'delta', 5, ...
        'seed', 1, ...
        'saveHistory', false);

    result = MMOEADC(problem, options);

    figure;
    scatter(result.population.objs(:, 1), result.population.objs(:, 2), 28, 'filled');
    xlabel('f_1');
    ylabel('f_2');
    title('MMOEA-DC Result on ZDT1');
    grid on;
end
