function distances = calDistance(M, X)

[row col] = size(M);
distances = zeros(1, row);
for i=1:row
   curItem = M(i, :);
   distances(i) = norm(X - curItem);
end