function flag = Dominates(a, b)
%DOMINATES Return true if objective vector a Pareto-dominates b.
    flag = all(a <= b) && any(a < b);
end
