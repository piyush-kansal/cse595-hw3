function [] = hw3_part1(databaseDirectory)

%% Split the data into training and test data
% REF: http://code.google.com/p/cse-595/source/browse/trunk/assignment3

prevDir = pwd();
categories = {'hobo', 'shoulder', 'clutch', 'totes'};

filePrefix = 'img_';
fileSuffix = '.jpg';
dirPrefix = 'bags_';

if ~exist('training.mat', 'file')
	cd(databaseDirectory);
	curDir = pwd();

	for i = 1:length(categories)
		category = sprintf('%s%s', dirPrefix, categories{i});
		img_dir = sprintf('%s/%s/', curDir, category);
		
		for j = 1:499
			trainingSet(i).files{j} = sprintf('%s%s%s_%d%s', img_dir, filePrefix, category, j, fileSuffix);
			testSet(i).files{j} = sprintf('%s%s%s_%d%s', img_dir, filePrefix, category, j+500, fileSuffix);
		end
		
		trainingSet(i).files{500} = sprintf('%s%s%s_%d%s', img_dir, filePrefix, category, 500, fileSuffix);
		trainingSet(i).category = categories{i};
		testSet(i).category = categories{i};
	end
	
	cd(prevDir);
	save('trainingSet.mat', 'trainingSet');
	save('testSet.mat', 'testSet');
else
	load('trainingSet.mat');
end

%% Compute Sift Vectors

if ~exist('allSiftVectors.mat', 'file')
	imageID = 1;
	allSifts = [];
	allImageVec = [];
	
	for i = 1:length(categories)
		dataSet = [{trainingSet(1,i).files{:}}' ; {testSet(1,i).files{:}}'];
		[siftVector, imageVector, imageID] = computeSift(dataSet, imageID);
		allSifts = [allSifts; siftVector];
		allImageVec = [allImageVec; imageVector];
	end
	
	save('allSiftVectors.mat', 'allSifts', 'allImageVec', 'imageID');
else
	load('allSiftVectors.mat');
end

%% K-means clustering

if ~exist('imageFeatureMap.mat', 'file')
	k = 1000;

	[C, A] = vl_kmeans((double(allSifts))', k);
	imageFeatureMap = zeros(imageID-1, size(C, 2));
	
	for i = 1:size(A, 2)
		imageIDx = allImageVec(i);
		imageFeatureMap(imageIDx, A(:, i)) = imageFeatureMap(imageIDx, A(:, i)) + 1;
	end
	
	save('imageFeatureMap.mat' , 'imageFeatureMap');
else
	load('imageFeatureMap.mat');
end

%% Create lexicon - Part 2

% Create a hash table for stop words for fast searching
stopwords_map = initStopWords('Stop words.txt');

% Create a lexicon for unique words among all 4 categories
if ~exist('allLexicon.mat', 'file')
	allLexicon = {};

	for i = 1:length(categories)
		% fetch file names
		fileNameList = dir([databaseDirectory '/bags_' categories{i} '/descr_bags*.txt']);
		fileNameList = {fileNameList.name};
		fileNameList = cellfun(@(fileName) fullfile([databaseDirectory '/bags_' categories{i}], fileName), fileNameList, 'UniformOutput', false);
		lexicon = removeStopWords(fileNameList, stopwords_map, databaseDirectory);
		allLexicon = union(allLexicon, lexicon);
	end
	
	allLexicon = {allLexicon{:}};
	save('allLexicon.mat', 'allLexicon');
else
	load('allLexicon.mat');
end

% Now using the unique word lexicon, calculate the word count histogram
% for each file for both training and test data set
if ~exist('allLexiconVector.mat', 'file')
	allLexiconVector = zeros(0, length(allLexicon));

	for i = 1:length(trainingSet)
		textFiles = cellfun(@(filepath) strrep(strrep(filepath, 'img', 'descr'), 'jpg', 'txt'), trainingSet(i).files, 'UniformOutput', false);
		allLexiconVector = [allLexiconVector; initLexiconVector(textFiles, allLexicon, stopwords_map)];
	end

	for i = 1:length(testSet)
		textFiles = cellfun(@(filepath) strrep(strrep(filepath, 'img', 'descr'), 'jpg', 'txt'), testSet(i).files, 'UniformOutput', false);
		allLexiconVector = [allLexiconVector; initLexiconVector(textFiles, allLexicon, stopwords_map)];
	end
	
	save('allLexiconVector.mat', 'allLexiconVector');
else
	load('allLexiconVector.mat');
end

% Figure out most frequently used words
if ~exist('mostFrequentLexicon.mat', 'file')
    K = 1000;
	colSum = sum(allLexiconVector, 1);
	[v, index] = sort(colSum, 'descend');
	mostFrequentLexicon = zeros(size(allLexiconVector, 1), K);

	for i = 1:K
		mostFrequentLexicon(:,i) = allLexiconVector(:,index(i));
	end

	save('mostFrequentLexicon.mat', 'mostFrequentLexicon');
else
	load('mostFrequentLexicon.mat');
end

% Train the Naive Bayes classifier
for i = 1:size(imageFeatureMap, 1)
	imageFeatureMap(i, :) = 0.1*imageFeatureMap(i, :) ./ sum(imageFeatureMap(i,:),2);
end

categoryId = [];
curCategoryId = 1;
imageId = 1;
allTrainVector = [];
count = 0;

for i = 1:500*length(categories)
	allTrainVector(i,:) = [imageFeatureMap(imageId+count,:) mostFrequentLexicon(i,:)];
	categoryId(i,:) = curCategoryId;
	count = count + 1;

	if mod(count, 500) == 0
		imageId = imageId + 500;
		curCategoryId = curCategoryId + 1;
		count = 0;
	end
end

diffCategories = unique(categoryId);

for i = 1 : size(diffCategories, 1)
	catId = diffCategories(i);
	feature = allTrainVector(categoryId == catId, :);
	featureCount = sum(feature, 1);
	condProb(i,:) = (1 + featureCount) ./ (sum(featureCount) + size(feature, 2));
end

categoryId2 = [];
curCategoryId = 1;
imageId = 501;
allTestVector = [];
count = 0;

for i = 1:499*length(categories)
	allTestVector(i,:) = [imageFeatureMap(imageId+count,:) mostFrequentLexicon(i+500*length(categories),:)];
	categoryId2(i,:) = curCategoryId;
	count = count + 1;

	if mod(count, 499) == 0
		imageId = imageId + 501;
		curCategoryId = curCategoryId + 1;
		count = 0;
	end
end

% Predict from classifier
for i = 1 : size(allTestVector, 1)
	[category, logProb] = findMaxCategory(allTestVector(i,:), condProb, diffCategories);
	categories2(i) = category;
	logProbs(i) = logProb;
end

confusionmat(categoryId2, categories2')

end