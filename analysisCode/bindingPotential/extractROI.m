% read time 
close all; clear; clc;
parentdir = fullfile(pwd, "$ENTERDIRECTORYPATH");

% sort files inorder of acquisition
acqfolders = dir(fullfile(parentdir, "00*"));
% sorting folders by the order images were taken
fnum = zeros(1,numel(acqfolders));
for a = 1:numel(acqfolders)
    str_fld = strsplit(acqfolders(a).name,'_');
    fnum(a) = str2double(str_fld{1});
end
[~,ind] = sort(fnum);
acqfolders = acqfolders(ind);

numfiles = length(acqfolders);
channel_names = [700, 800];
num_channels = length(channel_names);

allImages = zeros(num_channels, 482, 650, numfiles);  

for ch = 1:num_channels
    ch_label = num2str(channel_names(ch));  % '700' or '800'
    
    for i = 1:numfiles
        imagedir = fullfile(parentdir, acqfolders(i).name);
        imFiles = dir(fullfile(imagedir, ['*' ch_label '*'])); 

        if isempty(imFiles)
            error("No files found for channel %s in folder %s", ch_label, imagedir);
        end

        image = bfopen(convertStringsToChars(fullfile(imagedir, imFiles(1).name)));
        im_data = image{1}{1};  % extract image matrix

        allImages(ch, :, :, i) = im_data;
    end
end

% ROI to reuse - ensures the dimensions of the ROI are consistent 
% Step 1: Base mask and relative offsets

img = squeeze(allImages(1, :, :, 1));
figure; imagesc(img); axis image off;
radius = 80;
roi = drawcircle('Radius', radius, 'Center', [100, 100], 'Color', 'r', ...
                'LineWidth', 0.75, ...
                'FaceAlpha', 0); 
wait(roi);
base_mask = createMask(roi);
[yy, xx] = find(base_mask);
roi_center = round(roi.Center);
rel_coords = [yy, xx] - roi_center;  % relative to center
close;
num_runs = size(allImages,4);
roi_pixels_values = cell(num_channels, num_runs, 3); 
% Step 2: Reuse mask by translating coordinates
for ch = 1:num_channels
    background = cell(1, 3);
    for run = 1:num_runs
        img = squeeze(allImages(ch, :, :, run));
        figure; imagesc(img); axis image off;
        for well = 1:3
            roi = drawcircle('Radius', radius, ...
                'Center', [100, 100], ...
                'Color', 'r', ...
                'LineWidth', 0.75, ...
                'FaceAlpha', 0);
            wait(roi);
            new_center = round(roi.Center);
            coords = bsxfun(@plus, rel_coords, new_center);
            
            % Bounds check
            valid = coords(:,1) > 0 & coords(:,1) <= size(img,1) & ...
                    coords(:,2) > 0 & coords(:,2) <= size(img,2);
            coords = coords(valid, :);
            lin_idx = sub2ind(size(img), coords(:,1), coords(:,2));
            
            if run == 1
                background{well} = mean(img(lin_idx));
            else
                roi_pixels_values{ch, run, well} = mean(img(lin_idx)) -  background{well};   % same size every time
            end
            
            
        end
        close;
    end
end


save('$FILENAME.mat', 'roi_pixels_values');
