function [ Wnew] = new_affinity( N, sig, W )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[row col] = size(N);
% last item is new item
newItem = N(row,:);

Dnew = zeros(row-1, 1);

for i=1:row-1 
   Dnew(i,1) = distMat(newItem, N(i,:));
end

Dnew=exp(-0.5*Dnew.^2/sig^2);
DnewT = Dnew';
Wnew = [W Dnew];
DnewT = [DnewT 1];
Wnew = [Wnew; DnewT];
end

