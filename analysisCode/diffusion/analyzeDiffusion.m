function analyzeAndPlotSingleRotation(rotImages, degs, numfiles, parentdir)
    sr = 12;
    cmPerSampledPixel = 0.01692307692;

    for j = 1:numel(degs)
        deg = degs(j);
        targetData = squeeze(sum(rotImages(:, :, :, j), 1));
        pixels = resample(targetData, sr, 1, 2);
        fs = 1 / (1); % 1 unit per original pixel step
        t2 = (0:(length(pixels)-1)) / (sr * fs);
        distance = t2 * cmPerSampledPixel;

        baseline = pixels(:, 1);
        fullWidthHalfMaxDistance = zeros(1, numfiles);

        for i = 1:numfiles
            pdata = pixels(:, i) - baseline;
            halfMax = (min(pdata) + max(pdata)) / 2;
            idx1 = find(pdata >= halfMax, 1, 'first');
            idx2 = find(pdata >= halfMax, 1, 'last');
            fullWidthHalfMaxDistance(i) = (idx2 - idx1 + 1) * cmPerSampledPixel;
            pixels(:, i) = pdata;
        end

        time = linspace(0, 10 * 60 * (numfiles - 1), numfiles);
        radiusSquared = (fullWidthHalfMaxDistance / 2).^2;
        linefit = polyfit(time(1:end-1), radiusSquared(2:end), 1);
        D = linefit(1) / 4;
        t_diffuse = (0.106^2) / (4 * D) / 60;

        % Folder structure
        baseFolder = fullfile(parentdir, 'RotatedImagesOnly', datestr(datetime('today'), 'yyyy-mm-dd'));
        if ~exist(baseFolder, 'dir'), mkdir(baseFolder); end

        % --- Combined Figure ---
        figure('units', 'normalized', 'outerposition', [0.1 0.25 0.85 0.5]);
        sgtitle(sprintf('Rotation: %d°', deg), 'FontSize', 16, 'FontWeight', 'bold');

        % Subplot 1: Final image + FWHM line
        subplot(1, 3, 1);
        imagesc(rotImages(:, :, end, j)); axis image off; colormap gray;
        title('60 min');
        yMid = size(rotImages, 1) / 2;
        xMid = size(rotImages, 2) / 2;
        fwhm_px = fullWidthHalfMaxDistance(end) / cmPerSampledPixel;
        xStart = xMid - fwhm_px / 2;
        xEnd = xMid + fwhm_px / 2;
        hold on; plot([xStart, xEnd], [yMid, yMid], 'r-', 'LineWidth', 2); hold off;

        % Subplot 2: Pixel curves
        subplot(1, 3, 2);
        plot(distance, pixels, 'LineWidth', 2);
        xlabel('Distance (cm)'); ylabel('Pixel Intensity');
        title('All curves'); box off;

        % Subplot 3: Radius^2 vs Time
        subplot(1, 3, 3);
        scatter(time(1:end-1), radiusSquared(2:end), 60, 'filled'); hold on;
        plot(time(1:end-1), polyval(linefit, time(1:end-1)), '--k');
        xlabel('Time (s)'); ylabel('Radius^2 (cm^2)');
        title(sprintf('D = %.3g cm^2/s\nTime = %.2f min', D, t_diffuse));
        hold off;

        saveas(gcf, fullfile(baseFolder, sprintf('figure_combined_deg%d.fig', deg)));
        close(gcf);

        % --- Standalone Intensity Plot ---
        curveFolder = fullfile(baseFolder, 'allCurvePlots');
        if ~exist(curveFolder, 'dir'), mkdir(curveFolder); end

        figure;
        plot(distance, pixels, 'LineWidth', 2);
        xlabel('Distance (cm)'); ylabel('Pixel Intensity');
        title('Pixel Intensity Distribution');
        saveas(gcf, fullfile(curveFolder, sprintf('figSL_deg%d.png', deg)));
        close(gcf);
    end
end
