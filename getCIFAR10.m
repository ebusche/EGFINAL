function [trainSet, testSet] = getCIFAR10(ndim)
    length = ndim^(1/4);
    % generate trainset
    trainSet = zeros(10000, ndim); % 50000
    for f=0:0 % all will be 4
        load(['./cifar10/data_batch_', num2str(f + 1), '.mat']);
        for i=1:10000
            R = data(i, 1:1024);
            G = data(i, 1025:2048);
            B = data(i, 2049:3072);
            A = zeros(32, 32, 3, 'uint8');
            A(:, :, 1) = reshape(R, 32, 32);
            A(:, :, 2) = reshape(G, 32, 32);
            A(:, :, 3) = reshape(B, 32, 32);
            grayImg = rgb2gray(A);
            trainSet(10000*f + i,:) = HOG(grayImg, length, length, length*length);
        end
    end
    % generate testset    
    testSet = zeros(2000, ndim); % 10000
    load('./cifar10/test_batch.mat');
    for i=1:2000
        R = data(i, 1:1024);
        G = data(i, 1025:2048);
        B = data(i, 2049:3072);
        A = zeros(32, 32, 3, 'uint8');
        A(:, :, 1) = reshape(R, 32, 32);
        A(:, :, 2) = reshape(G, 32, 32);
        A(:, :, 3) = reshape(B, 32, 32);
        grayImg = rgb2gray(A);
        testSet(i,:) = HOG(grayImg, length, length, length*length);
    end
end