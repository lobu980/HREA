function referenceData = loadReferenceData(name)
%LOADREFERENCEDATA Load benchmark PF/PS reference data from MAT files.
%   REFERENCEDATA = LOADREFERENCEDATA(NAME) searches common local folders for
%   a MAT file named after NAME and extracts standard PF/PS fields when they
%   exist. Missing fields are returned as empty arrays.

    candidateDirs = { ...
        fullfile(pwd, 'reference_data'), ...
        fullfile(pwd, 'ReferenceData'), ...
        fullfile(pwd, 'compare_results'), ...
        fullfile(pwd, 'MM_testfunctions'), ...
        fullfile(pwd, 'IDMP_testfunctions')};

    candidateFiles = {};
    for i = 1:numel(candidateDirs)
        candidateFiles{end + 1} = fullfile(candidateDirs{i}, [name, '.mat']); %#ok<AGROW>
        candidateFiles{end + 1} = fullfile(candidateDirs{i}, 'PF_PS', [name, '.mat']); %#ok<AGROW>
        candidateFiles{end + 1} = fullfile(candidateDirs{i}, 'truePF', [name, '.mat']); %#ok<AGROW>
    end

    loaded = [];
    for i = 1:numel(candidateFiles)
        if exist(candidateFiles{i}, 'file') == 2
            loaded = load(candidateFiles{i});
            break;
        end
    end

    referenceData = struct(...
        'PF_global', [], ...
        'PF_local', [], ...
        'PS_global1', [], ...
        'PS_global2', [], ...
        'PS_local', []);

    if isempty(loaded)
        return;
    end

    standardFields = fieldnames(referenceData);
    for i = 1:numel(standardFields)
        if isfield(loaded, standardFields{i})
            referenceData.(standardFields{i}) = loaded.(standardFields{i});
        end
    end

    if isfield(loaded, 'referenceData') && isstruct(loaded.referenceData)
        nestedFields = fieldnames(referenceData);
        for i = 1:numel(nestedFields)
            if isfield(loaded.referenceData, nestedFields{i})
                referenceData.(nestedFields{i}) = loaded.referenceData.(nestedFields{i});
            end
        end
    end
end
