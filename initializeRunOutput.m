function out = initializeRunOutput(name, FE, population, archive, refs)
%INITIALIZERUNOUTPUT Create the output/history structure for one run.

    out.name = name;
    out.FE_hist = FE;
    out.gen_hist = 0;
    out.populationSize = numel(population);
    out.archiveSize = numel(archive);
    out.populationSnapshots = {populationToResult(population)};
    out.archiveSnapshots = {populationToResult(archive)};
    out.IGD_hist = [];
    out.IGDX_hist = [];

    if refs.hasIGD
        archiveResult = populationToResult(archive);
        out.IGD_hist = IGD_calculation(archiveResult.F, refs.truePF);
    end
    if refs.hasIGDX
        archiveResult = populationToResult(archive);
        out.IGDX_hist = IGDX_calculation(archiveResult.X, refs.truePS);
    end
end
