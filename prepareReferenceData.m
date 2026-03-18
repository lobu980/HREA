function refs = prepareReferenceData(problem, name)
%PREPAREREFERENCEDATA Load optional true PF/PS data for convergence curves.

    refs.truePF = [];
    refs.truePS = [];
    refs.hasIGD = false;
    refs.hasIGDX = false;

    if isfield(problem, 'truePF') && ~isempty(problem.truePF)
        refs.truePF = problem.truePF;
    end
    if isfield(problem, 'truePS') && ~isempty(problem.truePS)
        refs.truePS = problem.truePS;
    end

    if (isempty(refs.truePF) || isempty(refs.truePS)) && ~isempty(name) && exist('get_local_fun', 'file') == 2
        try
            [PS_global, PS_local, PF_global, PF_local] = get_local_fun(name);
            refs.truePS = [PS_global; PS_local];
            refs.truePF = [PF_global; PF_local];
        catch
            refs.truePF = [];
            refs.truePS = [];
        end
    end

    refs.hasIGD = ~isempty(refs.truePF) && exist('IGD_calculation', 'file') == 2;
    refs.hasIGDX = ~isempty(refs.truePS) && exist('IGDX_calculation', 'file') == 2;
end
