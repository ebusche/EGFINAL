function [trainSet, testSet, trainCode, testCode] = generateCBMFMatrices(dataFile)
    ndim = 1296; % number of features in an item
    [list, label] = extractFeatures(dataFile, ndim);
    [row col] = size(list); %is this right? row is the number of sample, right?
    index = round(row * 9/10);
    trainSet = list(1:index,:); % training set = 9/10 total items
    testSet = list(index + 1:row,:); % test set = 1/10 total items

    % CBMF approach
    Sigma=5;
    SHparamNew.nbits = 16; % number of bits to code each sample
    SHparamNew.sigma=Sigma; % Sigma for the affinity. Different codes for different sigmas!

    % create affinity matrix
    trainCode = trainCBMF(trainSet, SHparamNew);

    % train classifiers to generate new code
    % create LR classifiers
    classifiers = LRClassifiers(trainSet, trainCode, SHparamNew.nbits);
    testItems = row - index;
    testCode = zeros(testItems, SHparamNew.nbits);
    for x = 1:testItems
        newItem = testSet(x,:);
        newCode = LRGenCode(classifiers, newItem, SHparamNew.nbits);
        testCode(x,:) = newCode;
    end
end