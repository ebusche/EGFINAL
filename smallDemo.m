
% create random data in 32D
 ndim=1000;
Ntrain=3000;
Ntest=100;
dd=(1:ndim).^(2);
aspectMat=diag(1./dd); % create diagional matrix 32x32
Xtraining=randn(Ntrain,ndim)*aspectMat; % matrix[1000x32] * matrix[32x32] = [1000x32]
% Xtest=randn(Ntest,ndim)*aspectMat; % matrix[300x32] * matrix[32x32] = [300x32]

% list = extractFeatures('data_batch_1.mat', 1296);
% Xtraining = list(1:1000,:);
% Xtest = list(1001:1030,:);
tStart = tic;
Sigma=0.4;
SHparamNew.nbits = 32; % number of bits to code each sample
SHparamNew.sigma=Sigma; % Sigma for the affinity. Different codes for different sigmas!

SHparamNew = trainMDSH(Xtraining, SHparamNew);
[B1,U1] = compressMDSH(Xtraining, SHparamNew);
[B2,U2] = compressMDSH(Xtest, SHparamNew);

Utraining_mdsh = sign(U1);
Utest_mdsh = sign(U2);
executingTime = toc(tStart);
disp(['running time - MDSH - training: ', num2str(executingTime)]);
% 
% % calculate the affinity between the first test point and all training
% % points. Large affinities mean high similarities
%
for x = 1:Ntest
    Whamm = hammingDistEfficientNew(Utest_mdsh(x,:),Utraining_mdsh,SHparamNew);
    [~,iisort]=sort(Whamm,'descend');
end
% 
% 'affinities to 10 most similar points in original space'
% trueAffinity=exp(-0.5*distMat(Xtest(1,:),Xtraining)/Sigma^2);
% trueSorted=sort(trueAffinity,'descend');
% trueSorted(1:10)
% 
% % find 10 nearest neighbors in Hamming space
 
executingTime = toc(tStart);
disp(['running time - MDSH - testing: ', num2str(executingTime)]);
% 'true affinities of retrieved 10 points by sorting Hamming affinity'
% sort(exp(-0.5*distMat(Xtest(1,:),Xtraining(iisort(1:10),:))/Sigma^2),'descend')
% 
% % alternatively use hashing to retrieve all test points in the same bucket
% % and 32 best buckets
% 
% [~,IImdsh1]=retrieveNeighboringCodes(Utest_mdsh(1,:),Utraining_mdsh,SHparamNew.deltas(1,:));
% 'top 10 true affinities of retrieved points in exact same bucket'
% yysort=sort(exp(-0.5*distMat(Xtest(1,:),Xtraining(IImdsh1,:))/Sigma^2),'descend');
% yysort(1:10)
% 'top 10 true affinities of retrieved points in top 32 buckets'
% [~,IImdsh]=retrieveNeighboringCodes(Utest_mdsh(1,:),Utraining_mdsh,SHparamNew.deltas);
% yysort32=sort(exp(-0.5*distMat(Xtest(1,:),Xtraining(IImdsh,:))/Sigma^2),'descend');
% yysort32(1:10)