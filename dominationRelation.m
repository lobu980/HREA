function relation = dominationRelation(obj1, obj2)
%DOMINATIONRELATION Compare two objective vectors.
%   relation = 1  means obj1 dominates obj2.
%   relation = -1 means obj2 dominates obj1.
%   relation = 0  means neither dominates the other.

    less = any(obj1 < obj2);
    greater = any(obj1 > obj2);
    if ~greater && less
        relation = 1;
    elseif ~less && greater
        relation = -1;
    else
        relation = 0;
    end
end
