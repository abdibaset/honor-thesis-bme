 %% CROP IMAGES
 function [degs, rotImages, cropImages] = cropImagesUtil(allImages)
    %CROPIMAGESUTIL Crop ROI from allImages and preallocate rotImages
    %   [degs, rotImages, cropImages] = cropImagesUtil(allImages)
    clear cropImages;
    roi = allImages(:,:,2);
    figure;imagesc(roi);axis image;axis off
    [~,rect] = imcrop();
    for i = 1:size(allImages,3)
        cropImages(:,:,i) = imcrop(allImages(:,:,i),rect);
    end
    
    %% ROTATE IMAGES
    degs = [0 -45 -90 -135];
    rotImages = zeros([size(cropImages) numel(degs)]); % Preallocate for all rotations
end 