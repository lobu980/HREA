function frontNo = ndSort(objs, nSort)
%NDSORT Fast non-dominated sorting for a matrix of objective values.

    N = size(objs, 1);
    dominateMe = zeros(1, N);
    iDominate = cell(1, N);
    frontNo = inf(1, N);
    front{1} = []; %#ok<AGROW>

    for p = 1:N
        for q = p + 1:N
            relation = dominationRelation(objs(p, :), objs(q, :));
            if relation == 1
                iDominate{p}(end + 1) = q; %#ok<AGROW>
                dominateMe(q) = dominateMe(q) + 1;
            elseif relation == -1
                iDominate{q}(end + 1) = p; %#ok<AGROW>
                dominateMe(p) = dominateMe(p) + 1;
            end
        end
        if dominateMe(p) == 0
            frontNo(p) = 1;
            front{1}(end + 1) = p; %#ok<AGROW>
        end
    end

    assigned = numel(front{1});
    currentFront = 1;
    while assigned < min(nSort, N) && ~isempty(front{currentFront})
        nextFront = [];
        for p = front{currentFront}
            dominatedSet = iDominate{p};
            for q = dominatedSet
                dominateMe(q) = dominateMe(q) - 1;
                if dominateMe(q) == 0
                    frontNo(q) = currentFront + 1;
                    nextFront(end + 1) = q; %#ok<AGROW>
                    assigned = assigned + 1;
                end
            end
        end
        currentFront = currentFront + 1;
        front{currentFront} = nextFront; %#ok<AGROW>
    end
end
