function C = NCM(X, r)
%NCM Neighborhood-based clustering method.
%   C = NCM(X, r) partitions the rows of X into connected clusters where two
%   points are neighbors if the absolute difference in every dimension does
%   not exceed the corresponding radius component in r.
%
%   Output C is a structure array with field:
%       p - indices of points belonging to that cluster

    [n, dim] = size(X);
    if numel(r) ~= dim
        error('NCM:InvalidRadius', 'The radius vector r must have the same dimension as X.');
    end

    S = 1:n;
    D = zeros(n, n);
    for i = 1:dim
        Xi = X(:, i);
        D = D + (abs(Xi - repmat(Xi.', n, 1)) <= r(i));
    end

    K = 0;
    C = struct('p', {});
    while ~isempty(S)
        K = K + 1;
        Q = [];
        C(K).p = [];
        s = randperm(length(S));
        x = S(s(1));
        Q = [Q, x];
        C(K).p = [C(K).p, x];

        while ~isempty(Q)
            ss = randperm(length(Q));
            y = Q(ss(1));
            B = find(D(y, :) == dim);
            T = setdiff(B, C(K).p, 'stable');
            Q = [Q, T]; %#ok<AGROW>
            C(K).p = [C(K).p, T]; %#ok<AGROW>
            Q(ss(1)) = [];
        end
        S = setdiff(S, C(K).p, 'stable');
    end
end
