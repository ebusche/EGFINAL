disp('load data');
ndim = 1296;
[list, label] = extractFeatures('data_batch_1.mat', ndim);
trainItems = 9000;
Xtraining = list(1:trainItems,:);
Xtest = list(9001:10000,:);

% CBMF approach
tStart = tic;
Sigma=5;
SHparamNew.nbits = 64; % number of bits to code each sample
SHparamNew.sigma=Sigma; % Sigma for the affinity. Different codes for different sigmas!

disp('create affinity matrix');
U1 = trainCBMF(Xtraining, SHparamNew);
checkpoint = toc(tStart);
disp(['check point 1: ', num2str(checkpoint)]);
% train classifiers to generate new code
disp('create LR classifiers');
classifiers = LRClassifiers(Xtraining, U1, SHparamNew.nbits);

checkpoint = toc(tStart);
disp(['check point 2: ', num2str(checkpoint)]);
accuracy = 0;
disp('test items');
testItems = 1000;
testCode = zeros(testItem, SHparamNew.nbits);
for x = 1:testItems
    newItem = Xtest(x,:);
    newCode = LRGenCode(classifiers, newItem, SHparamNew.nbits);
    testCode(x,:) = newCode;
    hammingList = hammingDist(U1, newCode);
    % find 10 nearest neighbors in Hamming space
    [~,iisort]=sort(hammingList);
    nearestIndexes = iisort(1:10);
    nearestLabels = label(nearestIndexes);
    trueLabel = label(9000 + x);
    
    if (sum(nearestLabels == trueLabel) == mode(nearestLabels))
        accuracy = accuracy + 1;
    else
        if (mode(nearestLabels) == trueLabel)
            accuracy = accuracy + 1;
        end
    end
end

executingTime = toc(tStart);
disp(['accuracy: ', num2str(accuracy*100/testItems), '%']);
disp(['running time: ', num2str(executingTime)]);