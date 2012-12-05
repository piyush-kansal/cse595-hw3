HW3 Naive Bayes
---------------

In this homework you will train a Naive Bayes classifier on word and picture features.

Data
We will again use shopping images with associated text descriptions, this time for 4 bag related categories (hobo, shoulder, clutch, totes). Download the data here.

Your training data for this assignment will be for each bag category, those images numbered 500 and below. Your testing data for this assignment will be for each bag category, those images numbered above 500.

Part 0 - Background Reading
    Read and understand Visual categorization with bags of keypoints by Csurka et al. We will be implementing something similar, but using both image and word features in our classifier. Also read descripion of Naive Bayes classifiers here and lecture notes for Oct 11 here.

Part 1 - Image Representation

    We will model images as a histogram of visual word counts. Our visual word code book will be found by clustering shape based image features.

    For each image, extract its SIFT features (code for SIFT descriptor extraction is included in the vlfeat package).
    For some large random subset of these SIFT features cluster the features into a visual word code book using kmeans (code for kmeans is also included in vlfeat and works somewhat better than the kmeans included with matlab).
    For each image, and each SIFT feature in that image, label the feature as the closest visual word. For each image, compute your image representation as a histogram of visual word counts. 

Part 2 - Text Representation

    We will model text descriptions as a histogram of word counts.

    Compute your lexicon as all words in the shopping descriptions that appear relatively frequently. As usual remember to convert to lower case and strip punctuation using something like this function.
    For each text document, compute your text representation as a histogram of word counts. 

Part 3 - Training Classifiers

In this part of the homework you will train your Naive Bayes classifier. This means calculating P(F_i|C_j) for each feature_i and each category_j. You can assume that P(C_j) is uniform over the 4 categories.

    Each visual and textual word will be a feature in your Naive Bayes classifier. Using the training data for each bag category, calculate the probability of features given categories using counts with Laplace smoothing (see Csurka paper, eqn 2 for this calculation). 

Part 4 - Image Classification and Confusion

Here we will classify test images using our trained classifier.

    For each test image calculate the probability of each category using your classifier (see Csurka paper, eqn 1 for this calculation). Label the image as the highest probability category.
    Compute a confusion matrix showing for each category what percentage of images from that category were confused with the other categories (see the Csurka paper for an example). The diagonal of this matrix is your per category accuracy. 

What to turn in

Hand in via email to cse595@gmail.com:

    Everything (except code and readme) should be handed in as a single PDF write-up. This write-up should include: a description of what you implemented and observed, some figures illustrating what you observed, and your confusion matrix.
    Commented code and readme