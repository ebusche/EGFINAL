function [dd,W]=averageDistance(Xtraining)
ntrain=size(Xtraining,1);
I=randperm(ntrain);
if (length(I)>1000)
    I=I(1:1000);
end
W=distMat(Xtraining(I,:),Xtraining(I,:));
dd=mean(W(:));
