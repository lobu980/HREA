function results = demo_MMOEADC_HREA_mode(suite, name, num_of_runs)
%DEMO_MMOEADC_HREA_MODE HREA-style demo entry for MMOEA-DC.
%   RESULTS = DEMO_MMOEADC_HREA_MODE(SUITE, NAME, NUM_OF_RUNS) demonstrates
%   how to run MMOEA-DC directly on benchmark suites such as CEC2020, IDMP,
%   and IDMP_e using the same workflow style as HREA.
%
%   Examples:
%       demo_MMOEADC_HREA_mode('IDMP_e', 'IDMPM2T4_e', 1);
%       demo_MMOEADC_HREA_mode('IDMP',   'IDMPM2T4',   1);
%       demo_MMOEADC_HREA_mode('CEC2020','CEC2020_F01',1);

    if nargin < 1 || isempty(suite)
        suite = 'IDMP_e';
    end
    if nargin < 2 || isempty(name)
        switch lower(suite)
            case 'idmp_e'
                name = 'IDMPM2T4_e';
            case 'idmp'
                name = 'IDMPM2T4';
            otherwise
                name = 'CEC2020_F01';
        end
    end
    if nargin < 3 || isempty(num_of_runs)
        num_of_runs = 1;
    end

    results = run_HREA_experiment(name, num_of_runs, suite);
end
