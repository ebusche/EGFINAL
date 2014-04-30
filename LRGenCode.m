function [newCode] = LRGenCode(classifiers, newItem, dimensions)
newCode = zeros(1, dimensions);
for i=1:dimensions
   classifier = classifiers{i};
   newCode(i) = hardlim(glmval(classifier, newItem, 'logit')-0.5);
end