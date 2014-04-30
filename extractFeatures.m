function [list, label] = extractFeatures(file, dimension)
load(file);
list = zeros(10000, dimension);
label = labels;
for i=1:10000
    R = data(i, 1:1024);
    G = data(i, 1025:2048);
    B = data(i, 2049:3072);
    A = zeros(32, 32, 3, 'uint8');
    A(:, :, 1) = reshape(R, 32, 32);
    A(:, :, 2) = reshape(G, 32, 32);
    A(:, :, 3) = reshape(B, 32, 32);
    grayImg = rgb2gray(A);
    list(i,:) = HOG(grayImg);
end
clear data;
clear labels;


