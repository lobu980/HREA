function dist = pairwiseDistance(A, B)
%PAIRWISEDISTANCE Euclidean distance matrix between two sets of vectors.

    if isempty(A) || isempty(B)
        dist = zeros(size(A, 1), size(B, 1));
        return;
    end
    AA = sum(A.^2, 2);
    BB = sum(B.^2, 2)';
    dist = sqrt(max(AA + BB - 2 * (A * B'), 0));
end
