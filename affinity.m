function [ W] = affinity( N, sig )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
D=distMat(N);
W=exp(-0.5*D.^2/sig^2);
end

