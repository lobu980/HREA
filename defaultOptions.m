function opts = defaultOptions(problem, opts)
%DEFAULTOPTIONS Fill in default HREA parameters.

    if nargin < 2 || isempty(opts)
        opts = struct();
    end

    if isfield(opts, 'FEmax') && ~isfield(opts, 'maxFE')
        opts.maxFE = opts.FEmax;
    end
    if isfield(opts, 'maxFE') && ~isfield(opts, 'FEmax')
        opts.FEmax = opts.maxFE;
    end

    opts = setDefaultOption(opts, 'N', 100);
    opts = setDefaultOption(opts, 'maxFE', 10000);
    opts = setDefaultOption(opts, 'FEmax', opts.maxFE);
    opts = setDefaultOption(opts, 'eps', 0.3);
    opts = setDefaultOption(opts, 'p', 0.5);
    opts = setDefaultOption(opts, 'proC', 1.0);
    opts = setDefaultOption(opts, 'disC', 20);
    opts = setDefaultOption(opts, 'proM', 1.0);
    opts = setDefaultOption(opts, 'disM', 20);
    opts = setDefaultOption(opts, 'seed', []);
    opts = setDefaultOption(opts, 'verbose', true);
    opts.D = numel(problem.lower);

    validateattributes(opts.N, {'numeric'}, {'scalar', 'integer', '>=', 2}, mfilename, 'opts.N');
    validateattributes(opts.maxFE, {'numeric'}, {'scalar', 'integer', '>=', opts.N}, mfilename, 'opts.maxFE');
    validateattributes(opts.eps, {'numeric'}, {'scalar', '>=', 0, '<=', 1}, mfilename, 'opts.eps');
    validateattributes(opts.p, {'numeric'}, {'scalar', '>=', 0, '<=', 1}, mfilename, 'opts.p');
end
