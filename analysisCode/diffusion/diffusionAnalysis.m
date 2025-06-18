
close all; clear; clc;
parentdir = fullfile(pwd, "$ENTERDIRECTORYNAME");
acqfolders = dir(fullfile(parentdir, "00*"));
acqfolders = sortedFoldersByNumber(acqfolders); % sort folders 

numfiles = length(acqfolders);
allImages = zeros(482, 650, numfiles);

% loop over all folders to read the files 
for i = 1: numfiles
    % open folder
    imagedir = fullfile(parentdir, acqfolders(i).name);
    imFiles = dir(fullfile(imagedir, "*700*"));           %specify the channel to analyze
    image = bfopen(convertStringsToChars(fullfile(imagedir, imFiles(1).name)));
    allImages(:,:,i) = image{1}{1};
 end 

% crop images to the defined roi
[degs, rotImages, cropImages] = cropImagesUtil(allImages);
rotImages = saveRotatedImages(acqfolders, cropImages, degs, parentdir, rotImages);
analyzeAndPlotSingleRotation(rotImages, degs, numfiles, parentdir)



