% Add mexopencv lib
addpath 'D:\Project\Matlab\mexopencv'

% Parameters

% Input
SEQ_NAME = 'singer1';
IMG_DIR = sprintf('D:/Dataset/tracking/seq_bench/%s', SEQ_NAME);
GT_FILE_NAME = 'groundtruth_rect.txt';
detector = cv.BRISK();

gt_file_path = sprintf('%s/%s', IMG_DIR, GT_FILE_NAME);
gt_rects = importdata(gt_file_path);

obj_width = gt_rects(1, 3);
obj_height = gt_rects(1, 4);
obj_angle = 0;

for iframe = 1 : 400
    
    % Read input
    img_file_path = sprintf('%s/img/%04d.jpg', IMG_DIR, iframe);
    img = imread(img_file_path);
    gray = rgb2gray(img);
    keypoints_cv = detector.detect(gray);
    keypoints = cat(1, keypoints_cv.pt);
    keypoints = keypoints(keypoints(:, 1) >= gt_rects(iframe, 1) ...
        & keypoints(:, 2) >= gt_rects(iframe, 2) ...
        & keypoints(:, 1) <= gt_rects(iframe, 1) + gt_rects(iframe, 3) ...
        & keypoints(:, 2) <= gt_rects(iframe, 2) + gt_rects(iframe, 4), :);
    ind_keypoints = 1 : size(keypoints, 1);
    
    % Initialization
    if iframe == 1
%         num_keypoints = size(keypoints, 1);
%         ind_point_pairs = nchoosek((1 : num_keypoints), 2);
%         ind1 = ind_point_pairs(:, 1);
%         ind2 = ind_point_pairs(:, 2);
%         dist = keypoints(ind1, :) - keypoints(ind2, :);
%         dist_point_pairs = sqrt(sum(dist .* dist, 2));
%         angle_point_pairs = atan2(dist(:, 2), dist(:, 1));
    end

    % Tracking
    if iframe > 1
        ind_prev_keypoints = (1 : size(prev_keypoints))';
        [of_tracked_keypoints, ind_tracked_keypoints] = fbof_track(prev_gray, gray, prev_keypoints, ind_prev_keypoints);
        
        orig_ind_point_pairs = nchoosek(ind_tracked_keypoints, 2);
        orig_ind1 = orig_ind_point_pairs(:, 1);
        orig_ind2 = orig_ind_point_pairs(:, 2);
        orig_v = prev_keypoints(orig_ind1, :) - prev_keypoints(orig_ind2, :);
        orig_dist_point_pairs = sqrt(sum(orig_v .* orig_v, 2));
        orig_angle_point_pairs = atan2(orig_v(:, 2), orig_v(:, 1));
        
        ind_point_pairs = nchoosek((1 : size(of_tracked_keypoints, 1)), 2);
        ind1 = ind_point_pairs(:, 1);
        ind2 = ind_point_pairs(:, 2);
        v = of_tracked_keypoints(ind1, :) - of_tracked_keypoints(ind2, :);
        dist_point_pairs = sqrt(sum(v .* v, 2));
        angle_point_pairs = atan2(v(:, 2), v(:, 1));
        
        diff_scale = dist_point_pairs ./ orig_dist_point_pairs;
        diff_scale = diff_scale(~isnan(diff_scale));
        % disp(dist_point_pairs(isnan(diff_scale)));
        % disp(orig_dist_point_pairs(isnan(diff_scale)));
        diff_angle = angle_point_pairs - orig_angle_point_pairs;
        scale = mean(diff_scale);
        rotation = mean(diff_angle);
        center = [mean(of_tracked_keypoints(ind1, :)), mean(of_tracked_keypoints(ind2, :))];
        fprintf('center: (%f, %f),scale: %f, angle :%f\n', center(1),  center(2), scale, rotation);
        % disp(ind_tracked_keypoints);
    end

    % Display result
    imshow(img);
    hold on;
    if iframe > 1
        % plot(prev_keypoints(:, 1), prev_keypoints(:, 2), '.', 'Color', [1, 1, 0]);
        % plot(of_tracked_keypoints(:, 1), of_tracked_keypoints(:, 2), '.', 'Color', [0, 1, 1]);
        obj_width = obj_width * scale;
        obj_height = obj_height * scale;
        obj_angle = obj_angle + rotation;
        DrawRectangle([center(1), center(2), obj_width, obj_height, - obj_angle]);
    end
    if double(get(gcf,'CurrentCharacter')) == 27
        break;
    end
    
    % Save previous data and postprocessing
    if iframe > 1
        
    end
    prev_keypoints = keypoints;
    prev_gray = gray;
    
    pause(0.01);
end







