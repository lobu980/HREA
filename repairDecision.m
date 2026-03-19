function dec = repairDecision(dec, problem)
%REPAIRDECISION Project a decision vector back into the legal search space.

    dec = min(max(dec, problem.lower), problem.upper);
    if ~isempty(problem.integer)
        dec(problem.integer) = round(dec(problem.integer));
        dec = min(max(dec, problem.lower), problem.upper);
    end
end
