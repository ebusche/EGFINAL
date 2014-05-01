function [classifiers] = LRClassifiers(TotalSet, TotalResult, dimensions)
% generate training & testing sets
[row col] = size(TotalSet);
index = round(row * 9/10);
TrainSet = TotalSet(1:index,:);
TrainResult = TotalResult(1:index,:);
TestSet = TotalSet(index+1:row,:);
TestResult = TotalResult(index+1:row,:);
% create LR classifiers
classifiers = cell(1,dimensions);
for i=1:dimensions
   classifiers{i} = glmfit(TrainSet, TrainResult(:,i), 'binomial');
end
end