function CrowdDis = Crowding(Decs)
%CROWDING Decision-space crowding distance.
%   CROWDIS = CROWDING(DECS) computes an NSGA-II style crowding distance in
%   the decision space for each individual.

    [N, D] = size(Decs);
    CrowdDis = zeros(N, 1);
    if N == 0
        return;
    elseif N == 1
        CrowdDis(:) = inf;
        return;
    elseif N == 2
        CrowdDis(:) = inf;
        return;
    end

    for i = 1:D
        [sortedValues, rank] = sort(Decs(:, i));
        CrowdDis(rank(1))   = inf;
        CrowdDis(rank(end)) = inf;
        span = sortedValues(end) - sortedValues(1);
        if span == 0
            continue;
        end
        for j = 2:N-1
            if ~isinf(CrowdDis(rank(j)))
                CrowdDis(rank(j)) = CrowdDis(rank(j)) + ...
                    (sortedValues(j + 1) - sortedValues(j - 1)) / span;
            end
        end
    end
end
