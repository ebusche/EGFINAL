function [trainSet, testSet, trainCode, testCode] = generateMDSHMatrices(dataFile)
ndim = 1296; % number of features in an item
[list, label] = extractFeatures(dataFile, ndim);
[row col] = size(TotalSet);
index = round(row * 9/10);
trainSet = list(1:index,:); % training set = 9/10 total items
testSet = list(index + 1:row,:); % test set = 1/10 total items

% MDSH approach
Sigma=5;
SHparamNew.nbits = 32; % number of bits to code each sample
SHparamNew.sigma=Sigma; % Sigma for the affinity. Different codes for different sigmas!

SHparamNew = trainMDSH(trainSet, SHparamNew);
[B1,U1] = compressMDSH(trainSet, SHparamNew);
[B2,U2] = compressMDSH(testSet, SHparamNew);

trainCode = sign(U1);
testCode = sign(U2);
end