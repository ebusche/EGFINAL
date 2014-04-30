function [ distance] = D( col, N, U , s )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%create a matrix entirely of column col except in the colth column
[r, c] = size(U);
matrix = zeros(r, c);
for i = 1 : s
        matrix(:, i) = N(:, col);    
end


Q = abs(matrix - U);

v = sum(Q);
x = v(1, 1:s);

distance = min(x);
end

