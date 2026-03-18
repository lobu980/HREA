function crowdDis = crowding(pop)
%CROWDING Harmonic-average distance crowding measure in decision space.

    [N, D] = size(pop);
    if N == 0
        crowdDis = [];
        return;
    elseif N == 1
        crowdDis = inf;
        return;
    end

    K = N - 1;
    Z = min(pop, [], 1);
    Zmax = max(pop, [], 1);
    range = Zmax - Z;
    range(range == 0) = 1;

    normalized = (pop - repmat(Z, N, 1)) ./ repmat(range, N, 1);
    distance = pairwiseDistance(normalized, normalized);
    [value, ~] = sort(distance, 2, 'ascend');
    harmonicTerms = 1 ./ max(value(:, 2:N), eps);
    crowdDis = K ./ sum(harmonicTerms, 2);

    if D == 0
        crowdDis = zeros(N, 1);
    end
end
