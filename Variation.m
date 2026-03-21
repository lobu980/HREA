function Offspring = Variation(Problem, ParentDecs, Options)
%VARIATION Generate offspring using SBX crossover and polynomial mutation.
%   OFFSPRING = VARIATION(PROBLEM, PARENTDECS, OPTIONS) returns a population
%   structure containing the offspring decision and objective matrices.

    [originalN, D] = size(ParentDecs);
    N = originalN;
    if mod(N, 2) ~= 0
        ParentDecs = [ParentDecs; ParentDecs(randi(N), :)];
        N = N + 1;
    end

    lower = reshape(Problem.lower, 1, D);
    upper = reshape(Problem.upper, 1, D);

    OffDec = zeros(N, D);
    for i = 1 : 2 : N
        p1 = ParentDecs(i, :);
        p2 = ParentDecs(i + 1, :);
        [c1, c2] = SimulatedBinaryCrossover(p1, p2, lower, upper, Options.proC, Options.disC);
        OffDec(i, :)     = c1;
        OffDec(i + 1, :) = c2;
    end

    OffDec = PolynomialMutation(OffDec, lower, upper, Options.proM, Options.disM);
    OffDec = min(max(OffDec, repmat(lower, size(OffDec, 1), 1)), repmat(upper, size(OffDec, 1), 1));
    OffDec = OffDec(1:originalN, :);
    OffObj = Problem.evaluate(OffDec);

    Offspring = struct('decs', OffDec, 'objs', OffObj);
end

function [Child1, Child2] = SimulatedBinaryCrossover(Parent1, Parent2, Lower, Upper, ProC, DisC)
    D = numel(Parent1);
    Child1 = Parent1;
    Child2 = Parent2;

    if rand <= ProC
        for j = 1:D
            if rand <= 0.5
                if abs(Parent1(j) - Parent2(j)) > eps
                    x1 = min(Parent1(j), Parent2(j));
                    x2 = max(Parent1(j), Parent2(j));
                    lb = Lower(j);
                    ub = Upper(j);
                    randq = rand;

                    beta = 1 + 2 * (x1 - lb) / (x2 - x1);
                    alpha = 2 - beta^(-(DisC + 1));
                    if randq <= 1 / alpha
                        betaq = (randq * alpha)^(1 / (DisC + 1));
                    else
                        betaq = (1 / (2 - randq * alpha))^(1 / (DisC + 1));
                    end
                    c1 = 0.5 * ((x1 + x2) - betaq * (x2 - x1));

                    beta = 1 + 2 * (ub - x2) / (x2 - x1);
                    alpha = 2 - beta^(-(DisC + 1));
                    if randq <= 1 / alpha
                        betaq = (randq * alpha)^(1 / (DisC + 1));
                    else
                        betaq = (1 / (2 - randq * alpha))^(1 / (DisC + 1));
                    end
                    c2 = 0.5 * ((x1 + x2) + betaq * (x2 - x1));

                    c1 = min(max(c1, lb), ub);
                    c2 = min(max(c2, lb), ub);
                    if rand < 0.5
                        Child1(j) = c2;
                        Child2(j) = c1;
                    else
                        Child1(j) = c1;
                        Child2(j) = c2;
                    end
                else
                    Child1(j) = Parent1(j);
                    Child2(j) = Parent2(j);
                end
            else
                Child1(j) = Parent1(j);
                Child2(j) = Parent2(j);
            end
        end
    end
end

function Mutant = PolynomialMutation(Decs, Lower, Upper, ProM, DisM)
    [N, D] = size(Decs);
    Mutant = Decs;
    site = rand(N, D) < ProM / D;
    mu   = rand(N, D);

    LowerMat = repmat(Lower, N, 1);
    UpperMat = repmat(Upper, N, 1);
    span     = UpperMat - LowerMat;
    span(span == 0) = 1;

    delta1 = (Mutant - LowerMat) ./ span;
    delta2 = (UpperMat - Mutant) ./ span;

    mask1 = site & (mu <= 0.5);
    xy = 1 - delta1;
    val = 2 .* mu + (1 - 2 .* mu) .* (xy .^ (DisM + 1));
    deltaq = val .^ (1 / (DisM + 1)) - 1;
    Mutant(mask1) = Mutant(mask1) + deltaq(mask1) .* span(mask1);

    mask2 = site & (mu > 0.5);
    xy = 1 - delta2;
    val = 2 .* (1 - mu) + 2 .* (mu - 0.5) .* (xy .^ (DisM + 1));
    deltaq = 1 - val .^ (1 / (DisM + 1));
    Mutant(mask2) = Mutant(mask2) + deltaq(mask2) .* span(mask2);
end
