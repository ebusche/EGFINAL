function [ U ] = trainCBMF( X, SHparam)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%%%% Defaults  
if ~isfield(SHparam,'sigma')
  SHparam.sigma = 0.1;
end

if ~isfield(SHparam,'epsilon')
  SHparam.epsilon = 0.1;
end

if ~isfield(SHparam,'outlier')
  SHparam.outlier = 2.5;
end

if ~isfield(SHparam,'min_weight')
  SHparam.min_weight = 0.1;
end

if ~isfield(SHparam,'nbuckets')
    SHparam.nbuckets=SHparam.nbits;
end

if ~isfield(SHparam,'doPCA')
    SHparam.doPCA=0;
end

%%%% Algorithm
[Nsamples Ndim] = size(X);
nbits = SHparam.nbits;

%%%%%%%%
%keyboard
% 1) PCA

npca=Ndim;

if (SHparam.doPCA==1)
    mu = mean(X,1);
    Xc = X - ones(Nsamples,1)*mu;
    %npca = min(nbits, Ndim);
    %[pc, l] = eigs(cov(Xc), npca);
    [pc,ss,vv]=svd(cov(Xc));
    X = Xc * pc; % overwrite original data

%% save PCA parameters
    SHparam.data_mean = mu;
    SHparam.data_pc   = pc;
else
    SHparam.data_pc=eye(Ndim);
      SHparam.data_mean = 0*mean(X,1);
end

% 1.5) Remove outliers
clip_lower = prctile(X,SHparam.outlier);
clip_upper = prctile(X,100-SHparam.outlier);
 %%% do clipping of data distribution per dimension
for a=1:npca
  q = find(X(:,a)<clip_lower(a));
  X(q,a) = clip_lower(a);
  q2 = find(X(:,a)>clip_upper(a));
  X(q2,a) = clip_upper(a);
end

%% save clipping thresholds 
SHparam.clip_lower = clip_lower;
SHparam.clip_upper = clip_upper;

W = affinity(X, SHparam.sigma);

W = round(W);
[U, V]= CBMF(W,nbits);

end

