function stopwords_map = initStopWords(fileName)

% Make a hash table of all the stop words
% We got this stop word file from:
% https://github.com/faridani/MatlabNLP/tree/master/nlp%20lib/funcs

fid = fopen(fileName);
stopwords = textscan(fid, '%s');
fclose(fid);

stopwords = stopwords{1,:};
stopwords_map = containers.Map('KeyType', 'char', 'ValueType', 'uint64');

for i = 1:length(stopwords)
    stopwords{i,:} = strip_punctuation(stopwords{i,:});
    stopwords_map(stopwords{i,:}) = i;
end

end