function [ u, w ] = CBMF(N, k)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% N data matrix
% k desired output size
% u is a n x k matrix
% w is a k x n matrix

% make initial u
[n c] = size(N);
u = zeros(n, k+1);

for i = 1:k
    p = zeros(1, n);
   
    for j = 1:n
        p(1, j)= D(j, N, u, i+1);
    end
    

    
    total = sum(p);
    
    %probabilities for selecting each column
    p = p ./total;
  
    %randomly pick a column
    x = find(rand<cumsum(p),1,'first');
    
    %add column to u
    u(:,i) = N(:,x);
end

usmall1 = u(:, 1:k);

while(true) 
nearest = zeros(1, n);
w = zeros(k, n);
for i = 1:n
%     %assign each column in N to its nearest column in u
v = N(:, i);
nearest(1, i)= assignGroup( v, u);

if(nearest(1, i) < k+1)
    w(nearest(1, i),i) = 1;
end
end

%determine l1 center for every cluster

usmall2 = u(:, 1:k);

if(isequal(usmall1,usmall2))
    %make matrices the right size;
    u = usmall1;
  
    break;
    
end

unew = zeros(n, k+1);
for  i = 1 : k +1
  unew(:, i) = center(  i, v, N);

end
    
u = unew;
usmall1 = u(:, 1:k);
end

end


