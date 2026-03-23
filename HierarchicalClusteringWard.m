function labels = HierarchicalClusteringWard(X, k)
%HIERARCHICALCLUSTERINGWARD Ward-linkage agglomerative clustering.
%   LABELS = HIERARCHICALCLUSTERINGWARD(X, K) clusters the rows of X into K
%   groups using Ward's minimum variance criterion. This function is a pure
%   MATLAB fallback so that the algorithm does not depend on the Statistics
%   and Machine Learning Toolbox.

    n = size(X, 1);
    if k <= 0 || k > n
        error('HierarchicalClusteringWard:InvalidK', 'k must satisfy 1 <= k <= size(X,1).');
    end
    if k == n
        labels = (1:n).';
        return;
    end

    clusters = cell(n, 1);
    centroids = cell(n, 1);
    sizes = ones(n, 1);
    active = true(n, 1);
    for i = 1:n
        clusters{i} = i;
        centroids{i} = X(i, :);
    end

    nActive = n;
    while nActive > k
        activeIdx = find(active);
        bestI = activeIdx(1);
        bestJ = activeIdx(2);
        bestCost = inf;

        for ii = 1:numel(activeIdx)-1
            i = activeIdx(ii);
            for jj = ii+1:numel(activeIdx)
                j = activeIdx(jj);
                cost = WardMergeCost(centroids{i}, sizes(i), centroids{j}, sizes(j));
                if cost < bestCost
                    bestCost = cost;
                    bestI = i;
                    bestJ = j;
                end
            end
        end

        mergedMembers = [clusters{bestI}, clusters{bestJ}];
        mergedSize = sizes(bestI) + sizes(bestJ);
        mergedCentroid = (sizes(bestI) * centroids{bestI} + sizes(bestJ) * centroids{bestJ}) / mergedSize;

        clusters{bestI} = mergedMembers;
        centroids{bestI} = mergedCentroid;
        sizes(bestI) = mergedSize;

        active(bestJ) = false;
        clusters{bestJ} = [];
        centroids{bestJ} = [];
        sizes(bestJ) = 0;
        nActive = nActive - 1;
    end

    labels = zeros(n, 1);
    activeIdx = find(active);
    for i = 1:numel(activeIdx)
        labels(clusters{activeIdx(i)}) = i;
    end
end

function cost = WardMergeCost(c1, n1, c2, n2)
    diff = c1 - c2;
    cost = (n1 * n2) / (n1 + n2) * sum(diff .^ 2);
end
