function out = appendRunOutput(out, FE, generation, population, archive, refs)
%APPENDRUNOUTPUT Append one generation snapshot and optional indicators.

    archiveResult = populationToResult(archive);
    out.FE_hist(end + 1, 1) = FE; %#ok<AGROW>
    out.gen_hist(end + 1, 1) = generation; %#ok<AGROW>
    out.populationSize(end + 1, 1) = numel(population); %#ok<AGROW>
    out.archiveSize(end + 1, 1) = numel(archive); %#ok<AGROW>
    out.populationSnapshots{end + 1, 1} = populationToResult(population); %#ok<AGROW>
    out.archiveSnapshots{end + 1, 1} = archiveResult; %#ok<AGROW>

    if refs.hasIGD
        out.IGD_hist(end + 1, 1) = IGD_calculation(archiveResult.F, refs.truePF); %#ok<AGROW>
    end
    if refs.hasIGDX
        out.IGDX_hist(end + 1, 1) = IGDX_calculation(archiveResult.X, refs.truePS); %#ok<AGROW>
    end
end
