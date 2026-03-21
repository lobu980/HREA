function Population = Environmental_Selection_C(Union, N, delta, gen)
%ENVIRONMENTAL_SELECTION_C Environmental selection in MMOEA-DC.
%   POPULATION = ENVIRONMENTAL_SELECTION_C(UNION, N, DELTA, GEN) performs the
%   neighborhood-clustering assisted environmental selection.
%   GEN is accepted for compatibility with the original PlatEMO-style call.

    if nargin < 4
        gen = 1; %#ok<NASGU>
    end

    if isempty(Union.decs)
        error('Environmental_Selection_C:EmptyUnion', 'Union population cannot be empty.');
    end

    range = max(Union.decs, [], 1) - min(Union.decs, [], 1);
    r = range * 0.1;

    C = NCM(Union.decs, r);
    K = length(C);
    local_A = [];

    for i = 1:K
        cluster = C(i).p;
        if numel(cluster) <= delta
            continue;
        end
        FrontNo1 = NDSort(Union.objs(cluster, :), numel(cluster));
        local_A = [local_A, cluster(FrontNo1 == 1)]; %#ok<AGROW>
    end
    local_A = unique(local_A, 'stable');

    FrontNo = NDSort(Union.objs, size(Union.objs, 1));
    P = find(FrontNo == 1).';
    temp = setdiff(P, local_A, 'stable');
    P = [local_A, temp];

    i = 1;
    while numel(P) < N
        i = i + 1;
        temp1 = find(FrontNo == i).';
        temp2 = setdiff(temp1, local_A, 'stable');
        if isempty(temp2)
            if i > max(FrontNo)
                break;
            end
        else
            P = [P, temp2]; %#ok<AGROW>
        end
    end

    if numel(P) > N
        newpop.decs = Union.decs(P, :);
        newpop.objs = Union.objs(P, :);

        z = min(newpop.objs, [], 1);
        Z = max(newpop.objs, [], 1);
        scale = Z - z;
        scale(scale == 0) = 1;
        ZZZ = (newpop.objs - repmat(z, size(newpop.objs, 1), 1)) ./ repmat(scale, size(newpop.objs, 1), 1);
        H = HierarchicalClusteringWard(ZZZ, N);

        count = size(newpop.decs, 1) - N;
        for iter = 1:count
            CrowdDis = Crowding(newpop.decs);
            num = zeros(1, max(H));
            for k = 1:max(H)
                num(k) = sum(H == k);
            end
            I = find(num == max(num));
            R = [];
            for j = 1:length(I)
                R = [R; find(H == I(j))]; %#ok<AGROW>
            end
            [~, minValue] = min(CrowdDis(R));
            candidateMask = CrowdDis(R) == CrowdDis(R(minValue));
            T = find(candidateMask);
            s = randperm(length(T));
            x = R(T(s(1)));
            newpop.decs(x, :) = [];
            newpop.objs(x, :) = [];
            H(x) = [];
            H = ReLabelClusters(H);
        end
        Population = newpop;
    else
        Population.decs = Union.decs(P, :);
        Population.objs = Union.objs(P, :);
    end
end

function labels = ReLabelClusters(labels)
    uniqueLabels = unique(labels(:).');
    for i = 1:numel(uniqueLabels)
        labels(labels == uniqueLabels(i)) = i;
    end
end
