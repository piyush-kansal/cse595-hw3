function [siftVector, imageVector, imageID] = computeSift(dataSet, imageID)
% Computes SIFT vector

k = 1;
for i=1:length(dataSet)
    img = im2double(imread(dataSet{i}));
    info = imfinfo(dataSet{i});
    if(strcmp(info.ColorType, 'truecolor'))
        grayImg = rgb2gray(img);
    end

    [~, d] = vl_sift(im2single(grayImg));
    for j = 1:size(d, 2)
        siftVector(k, :) = d(:, j);
        imageVector(k, :) = imageID;
        k = k + 1;
    end
    
	imageID = imageID + 1;
end

end