function [classifiers] = SVMClassifiers(TotalSet, TotalResult, dimensions)
% generate training & testing sets
[row col] = size(TotalSet);
index = round(row * 9/10);
TrainSet = TotalSet(1:index,:);
TrainResult = TotalResult(1:index,:);
TestSet = TotalSet(index+1:row,:);
TestResult = TotalResult(index+1:row,:);
options.MaxIter = 1000000;
% create SVM classifiers
classifiers = cell(1,dimensions);
for i=1:dimensions
   classifiers{i} = svmtrain(TrainSet, TrainResult(:,i), 'Options', options);
end
