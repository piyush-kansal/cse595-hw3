function lexicon = removeStopWords(fileNameList, stopwords_map, databaseDirectory)

% For each description(text) file, do following:
% - read text file
% - read all the words in an array
% - for each word in this array, check if it
%   is present in the stop word hash table.
%   If yes, then do not put it into the lexicon
%   Else, put it in the lexicon
% - Finally choose unique words only

prevDir = pwd();
l = 1;
lexicon{0,:} = '';

for j = 1:length(fileNameList)
	fileName = fileNameList(j);
	fid = fopen(fileName{1}, 'r');
	words = textscan(fid, '%s');
	words = words{1,:};

	for k = 1:length(words)
		curword = lower(strip_punctuation(strtrim(words{k,:})));
		tempword = regexprep(curword, '[\d]', '');
		if(strcmp(tempword, ''))
			continue;
		end

		if(~isKey(stopwords_map, curword))
			lexicon{l, :} = curword;
			l = l + 1;
		end
	end

	fclose(fid);
end

lexicon = unique(lexicon);

end