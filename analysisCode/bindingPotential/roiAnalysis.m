% Load data
close all; clear; clc;
parentdir = fullfile(pwd, "$ENTERDIRECTORYPATH");
roi_data = load(fullfile(parentdir, "$FILENAME.mat"));
roi_pixels_values = roi_data.roi_pixels_values;

[channels, runs, wells] = size(roi_pixels_values);
time_vec = readmatrix(fullfile(parentdir, "imaging_time.xlsx")); % excel file with times images were taken
time_seconds = time_vec(:, end);

% Plot each well in its own figure
for w = 1:wells
    targeted = roi_pixels_values(2, 2:17, w);
    untargeted = roi_pixels_values(1,  2:17, w);
    
    mean_targeted = cellfun(@mean, targeted)';
    mean_untargeted = cellfun(@mean, untargeted)';
    
    [rpam_bp, fit_curve, fit_time] = RPAM_BP(mean_targeted, mean_untargeted, time_seconds, 2);
    fprintf("w: %d, rpam_bp: %f\n", w, rpam_bp)


    figure;
    plot(fit_time, fit_curve, 'k-', 'LineWidth', 1.5); hold on;
    plot(fit_time, mean_targeted, 'ro', 'MarkerSize', 6, 'DisplayName', 'Targeted');
    plot(fit_time, mean_untargeted, 'bo', 'MarkerSize', 6, 'DisplayName', 'Untargeted');
    
    xlabel('Time (s)');
    ylabel('Signal (au)');
    title(sprintf('Well %d - RPAM Fit (BP = %.3f)', w, rpam_bp));
    legend({'Model Fit', 'Targeted', 'Untargeted'}, 'Location', 'best');
    grid on;
    box off;
end

% RPAM_BP function
function [rpam_bp, fit_curve, fit_time] = RPAM_BP(CT, CR, t, normpt)
    function output = RPAM_Clover(params, input, Ref)
        a = params(1); b = params(2);
        output = a * (Ref + 1e-6).^(1 / (1 + b));
    end

    Starting = [1 1];
    options = optimset('display', 'off', 'TolFun', 1e-18, 'TolX', 1e-18);
    [newParams, ~] = lsqcurvefit(@RPAM_Clover, Starting, t, CT / CT(normpt), [0 0], [100 100], options, CR / CR(normpt));

    rpam_bp = newParams(2);
    fit_curve = CT(normpt) * RPAM_Clover(newParams, t, CR / CR(normpt));
    fit_time = t;
end
