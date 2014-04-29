disp('load data');
ndim = 1296;
[list, label] = extractFeatures('data_batch_1.mat', ndim);
trainItems = 1000;
Xtraining = list(1:trainItems,:);
Xtest = list(9001:10000,:);

% MDSH approach
disp('create affinity matrix');
tStart = tic;
Sigma=5;
SHparamNew.nbits = 32; % number of bits to code each sample
SHparamNew.sigma=Sigma; % Sigma for the affinity. Different codes for different sigmas!

SHparamNew = trainMDSH(Xtraining, SHparamNew);
[B1,U1] = compressMDSH(Xtraining, SHparamNew);
[B2,U2] = compressMDSH(Xtest, SHparamNew);

Utraining_mdsh = sign(U1);
Utest_mdsh = sign(U2);

% calculate the affinity between the first test point and all training
% points. Large affinities mean high similarities
checkpoint = toc(tStart);
disp(['check point: ', num2str(checkpoint)]);
accuracy = 0;
disp('test items');
testItems = 1000;
for x = 1:testItems
    Whamm = hammingDistEfficientNew(Utest_mdsh(x,:),Utraining_mdsh,SHparamNew);
    % find 10 nearest neighbors in Hamming space
    [~,iisort]=sort(Whamm,'descend');
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

