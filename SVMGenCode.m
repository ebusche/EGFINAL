function [newCode] = SVMGenCode(classifiers, newItem, dimensions)
newCode = zeros(1, dimensions);
for i=1:dimensions
   classifier = classifiers{i};
   newCode(i) = svmclassify(classifier, newItem);
end