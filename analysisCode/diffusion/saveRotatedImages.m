function rotImages = saveRotatedImages(acqfolders, cropImages, degs, parentdir, rotImages)
    numfiles = length(acqfolders);
    for i = 1:numfiles
        savedROIFolder = fullfile(parentdir, 'RotatedImagesOnly', datestr(datetime('today')), acqfolders(i).name);
        if ~exist(savedROIFolder, 'dir') 
            mkdir(savedROIFolder); 
        end
        for j = 1:numel(degs)
            % Rotate the image
            rotImages(:,:,i,j) = imrotate(cropImages(:,:,i), degs(j), 'nearest', 'crop');
           
            figure;
            imagesc(rotImages(:,:,i,j)); 
            axis image; axis off; 
            colormap gray; 
            title(sprintf('Image Rotation %d°, 60 min', degs(j)));
            
            % Save the figure in the displayed format
            filename = fullfile(savedROIFolder, sprintf('Image_Rotation_%d.png', degs(j)));
            saveas(gcf, filename);
            close(gcf);
        end
    end
end 