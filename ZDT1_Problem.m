function Problem = ZDT1_Problem(D)
%ZDT1_PROBLEM Create a standard ZDT1 benchmark problem descriptor.
%   PROBLEM = ZDT1_PROBLEM(D) returns a problem structure compatible with
%   MMOEADC. Default dimensionality D is 30.

    if nargin < 1 || isempty(D)
        D = 30;
    end

    Problem = struct();
    Problem.D = D;
    Problem.M = 2;
    Problem.lower = zeros(1, D);
    Problem.upper = ones(1, D);
    Problem.evaluate = @Evaluate;

    function objs = Evaluate(decs)
        f1 = decs(:, 1);
        g  = 1 + 9 * mean(decs(:, 2:end), 2);
        h  = 1 - sqrt(f1 ./ g);
        f2 = g .* h;
        objs = [f1, f2];
    end
end
