function [ s ] = center( k, v, N )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
[r n] = size(N);

s = zeros(n,1);
count = 0;

for i = 1:n
    if(v(i, 1) == 0)
        count = count +1;
        s = s + N(:,i);
    end

end

s = round(s./count);


end

