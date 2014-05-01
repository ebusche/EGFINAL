function [ precision ] = test( dataFile)

[trainSet, testSet, trainCode, testCode] = generateCBMFMatrices(dataFile);
[dd,W]=averageDistance(trainSet);

threshold = dd; %you can try different values (like dd/2) but this one seems reasonable

precision = evaluationAffinityEfficient2(trainSet, testSet, trainCode, testCode, [], threshold);

end

