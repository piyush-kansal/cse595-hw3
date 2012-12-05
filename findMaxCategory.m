function [category, logProb] = findMaxCategory(featureVector, condProb, diffCategories)
% find most suitable category based on maximum probability

categoryProbs = [];

for i = 1 : size(diffCategories, 1)
    condProbForCategory = condProb(i,:);
    logCondProb = log(condProbForCategory);
    categoryProbs(i, :) = logCondProb .* featureVector;
end

totalProbs = sum(categoryProbs, 2);
[maxProb, probID] = max(totalProbs);
maxCategory = diffCategories(probID);
category = maxCategory(1, 1);
logProb = maxProb(1, 1);

end