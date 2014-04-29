function [classifier] = ANNClassifier(TotalSet, TotalResult, dimensions)
% generate training & testing sets
[row col] = size(TotalSet);
index = round(row * 9/10);
TrainSet = TotalSet(1:index,:)';
TrainResult = TotalResult(1:index,:)';
TestSet = TotalSet(index+1:row,:);
TestResult = TotalResult(index+1:row,:);
% create ANN classifier
hiddenNeurons = 20;
net = newfit(TrainSet, TrainResult, hiddenNeurons);
net = train(net, TrainSet, TrainResult);
classifier = net;
