% Add mexopencv lib
addpath 'D:\Project\Matlab\mexopencv'

% Parameters
padding = 1.5;  %extra area surrounding the target

% Input
SEQ_NAME = 'coke';
IMG_DIR = sprintf('D:/Dataset/tracking/seq_bench/%s', SEQ_NAME);
GT_FILE_NAME = 'groundtruth_rect.txt';
detector = cv.BRISK();

gt_file_path = sprintf('%s/%s', IMG_DIR, GT_FILE_NAME);
gt_rects = importdata(gt_file_path);
scale = 1;

target_sz = [gt_rects(1, 4), gt_rects(1, 3)];
pos = floor([gt_rects(1, 2), gt_rects(1, 1)] + target_sz / 2);
window_sz = floor(target_sz * (1 + padding));

DESC_LEN = 512;
THR_CONF = 0.75;
THR_RATIO = 0.7;
matcher = cv.DescriptorMatcher('BruteForce-Hamming');
labels = [];

for iframe = 1 : 200
    
    % Read input
    img_file_path = sprintf('%s/img/%04d.jpg', IMG_DIR, iframe);
    img = imread(img_file_path);
    gray = rgb2gray(img);
         
    % Initialization
    if iframe == 1
        col_filter_gray = gray;
        img_sz = size(gray);
    end
    
    % Use groundtruth rectangle
    target_sz = [gt_rects(iframe, 4), gt_rects(iframe, 3)];
    pos = floor([gt_rects(iframe, 2), gt_rects(iframe, 1)] + target_sz / 2);
    window_sz = floor(target_sz * (1 + padding));
    
    % Detect keypoints 
    keypoints_cv = detector.detect(gray);
    keypoints = cat(1, keypoints_cv.pt);
    is_in_window = in_rect(keypoints, pos, window_sz, img_sz);
    is_in_rect = in_rect(keypoints, pos, target_sz, img_sz);
    target_keypoints = keypoints(is_in_rect, :);
    target_keypoints_cv = keypoints_cv(is_in_rect);
    background_keypoints_cv = keypoints_cv(~is_in_rect & is_in_window);
    
    % Add new descriptors to database
    [target_descriptors, ~] = detector.compute(gray, target_keypoints_cv);
    [background_descriptors, ~] = detector.compute(gray, background_keypoints_cv);

    % Tracking
    if iframe > 1
        
        % Estimate target's affine transform
        ind_prev_keypoints = (1 : size(prev_target_keypoints))';
        [of_tracked_keypoints, ind_tracked_keypoints] = fbof_track(prev_gray, gray, prev_target_keypoints, ind_prev_keypoints);
        % [center, scale_change, rotation] = affine_estimate(of_tracked_keypoints, prev_keypoints, ind_tracked_keypoints);
        % scale = scale * scale_change;
        
        % Remove background points from of_tracked_keypoints
        matches = matcher.knnMatch(target_descriptors, 2);
        matches = cell2mat(matches);
        best_distance = cat(1, matches(1:2:end).distance);
        % idx in OpenCV starts from 0
        best_query_idx = cat(1, matches(1:2:end).queryIdx) + 1;
        best_train_idx = cat(1, matches(1:2:end).trainIdx) + 1;
        second_distance = cat(1, matches(2:2:end).distance);
        second_query_idx = cat(1, matches(2:2:end).queryIdx) + 1;
        second_train_idx = cat(1, matches(2:2:end).trainIdx) + 1;
        ratio = best_distance ./ second_distance;
        confidence = 1 - best_distance / DESC_LEN;
        bg_match_idx = ratio < THR_RATIO & confidence > THR_CONF & labels(best_train_idx) == 0;
        disp(numel(matches));
        disp(sum(bg_match_idx == 1));
        outliers = target_keypoints(bg_match_idx, :);
    end

    % Display result
    hold on;
    if iframe == 1
        img_h = imshow(img, 'Border','tight', 'InitialMag', 100);
    else
        set(img_h, 'CData', img);
    end
    
    % Display
    if iframe > 2
        delete(pts_h2);
    end
    
    if iframe > 1
        delete(rect_h);
        delete(pts_h);
        hold off;
    end
    % Display groundtruth
    % rect_h = rectangle('Position', gt_rects(iframe, :), 'EdgeColor', 'g');
    rect_h = rectangle('Position', [pos(2) - target_sz(2) * scale/ 2, pos(1) - target_sz(1) * scale/ 2, target_sz(2) * scale, target_sz(1) * scale], 'EdgeColor', 'g');
    hold on;
    pts_h = plot(target_keypoints(:, 1), target_keypoints(:, 2), '.', 'Color', [1, 1, 0]);
    
    if iframe > 1
        pts_h2 = plot(outliers(:, 1), outliers(:, 2), '.', 'Color', [1, 0, 0]);
    end
    
    if double(get(gcf,'CurrentCharacter')) == 27
        break;
    end
    
    % Save previous data and postprocessing
    if iframe > 1
    end
    
    prev_target_keypoints = target_keypoints;
    prev_gray = gray;
    matcher.add(target_descriptors);
    matcher.add(background_descriptors);
    labels = [labels; ones(size(target_descriptors, 1), 1); zeros(size(background_descriptors, 1), 1)];
    
    pause(0.001);
end







