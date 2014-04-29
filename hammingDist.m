function list = hammingDist(M, X)

[row col] = size(M);
list = zeros(1, row);

for i = 1:row
    list(i) = sum(X ~= M(i,:));
end