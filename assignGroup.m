function [ groupNumber ] = assignGroup( v, N)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
[r, c] = size(N);
matrix = zeros(r, c);
for i = 1 : c
        matrix(:, i) = v;    
end

%matrix
%N
Q = abs(matrix - N);
%Q
x = sum(Q);
%x
group = find(x==min(x));
%group

%if there is more than one group it could belong to randomly pick one
[gr, gc] = size(group);

groupNumber = group(1,randi(gc));


end

