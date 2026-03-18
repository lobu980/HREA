function options = defaultOptions(problem, options)
%DEFAULTOPTIONS Fill in default HREA parameters.

    if nargin < 2 || isempty(options)
        options = struct();
    end

    options = setDefaultOption(options, 'N', 100);
    options = setDefaultOption(options, 'maxFE', 10000);
    options = setDefaultOption(options, 'eps', 0.3);
    options = setDefaultOption(options, 'p', 0.5);
    options = setDefaultOption(options, 'proC', 1.0);
    options = setDefaultOption(options, 'disC', 20);
    options = setDefaultOption(options, 'proM', 1.0);
    options = setDefaultOption(options, 'disM', 20);
    options = setDefaultOption(options, 'seed', []);
    options = setDefaultOption(options, 'verbose', true);
    options.D = numel(problem.lower);

    validateattributes(options.N, {'numeric'}, {'scalar', 'integer', '>=', 2}, mfilename, 'options.N');
    validateattributes(options.maxFE, {'numeric'}, {'scalar', 'integer', '>=', options.N}, mfilename, 'options.maxFE');
    validateattributes(options.eps, {'numeric'}, {'scalar', '>=', 0, '<=', 1}, mfilename, 'options.eps');
    validateattributes(options.p, {'numeric'}, {'scalar', '>=', 0, '<=', 1}, mfilename, 'options.p');
end
