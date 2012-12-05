function wordCountHistogram = initLexiconVector(textFiles, allLexicon, stopwords_map)
% Inits the lexicon vector

wordCountHistogram = zeros(length(textFiles), length(allLexicon));

for fileId = 1:length(textFiles)
	fileId
	fileNameList = {textFiles{fileId}};
	wordsInCurFile = removeStopWords(fileNameList, stopwords_map);
	wordCountInCurFile = cellfun(@(word)sum(ismember(word, wordsInCurFile)), allLexicon, 'UniformOutput', false);
	wordCountHistogram(fileId,:) = cell2mat(wordCountInCurFile);
end

end