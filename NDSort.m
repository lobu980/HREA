function [FrontNo, MaxFNo] = NDSort(PopObj, nSort)
%NDSORT Fast non-dominated sorting.
%   [FRONTNO, MAXFNO] = NDSORT(POPOBJ, NSORT) assigns each solution a Pareto
%   front number. The full sorting result is returned; NSORT is accepted for
%   interface compatibility with PlatEMO-style calls.

    [N, ~] = size(PopObj);
    if nargin < 2 %#ok<NASGU>
        nSort = N;
    end

    Dominate = cell(N, 1);
    DominateMe = zeros(N, 1);
    FrontNo = inf(N, 1);

    for p = 1:N-1
        for q = p+1:N
            pDominatesq = Dominates(PopObj(p, :), PopObj(q, :));
            qDominatesp = Dominates(PopObj(q, :), PopObj(p, :));
            if pDominatesq
                Dominate{p}(end + 1) = q; %#ok<AGROW>
                DominateMe(q) = DominateMe(q) + 1;
            elseif qDominatesp
                Dominate{q}(end + 1) = p; %#ok<AGROW>
                DominateMe(p) = DominateMe(p) + 1;
            end
        end
    end

    currentFront = find(DominateMe == 0).';
    FrontNo(currentFront) = 1;
    MaxFNo = 1;

    while ~isempty(currentFront)
        nextFront = [];
        for i = 1:numel(currentFront)
            p = currentFront(i);
            dominatedSet = Dominate{p};
            for j = 1:numel(dominatedSet)
                q = dominatedSet(j);
                DominateMe(q) = DominateMe(q) - 1;
                if DominateMe(q) == 0 && isinf(FrontNo(q))
                    FrontNo(q) = MaxFNo + 1;
                    nextFront(end + 1) = q; %#ok<AGROW>
                end
            end
        end
        currentFront = nextFront;
        if ~isempty(currentFront)
            MaxFNo = MaxFNo + 1;
        end
    end

    if any(isinf(FrontNo))
        error('NDSort:SortingFailed', 'Non-dominated sorting did not assign all individuals to a front.');
    end
end
