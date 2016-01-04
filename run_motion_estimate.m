% Add mexopencv lib
addpath 'D:\Project\Matlab\mexopencv'

% Parameters
padding = 10;  %extra area surrounding the target

% Input
SEQ_NAME = 'david2';
IMG_DIR = sprintf('D:/Dataset/tracking/seq_bench/%s', SEQ_NAME);
GT_FILE_NAME = 'groundtruth_rect.txt';
detector = cv.BRISK();

gt_file_path = sprintf('%s/%s', IMG_DIR, GT_FILE_NAME);
gt_rects = importdata(gt_file_path);
scale = 1;

target_sz = [gt_rects(1, 4), gt_rects(1, 3)];
pos = floor([gt_rects(1, 2), gt_rects(1, 1)] + target_sz / 2);
window_sz = floor(target_sz * (1 + padding));

solid_pos_rate = 0.05;
solid_neg_rate = 0.1;

for iframe = 1 : 200
    
    % Read input
    img_file_path = sprintf('%s/img/%04d.jpg', IMG_DIR, iframe);
    img = imread(img_file_path);
    if ndims(img) == 3
        gray = rgb2gray(img);
    else
        gray = img;
    end
         
    % Initialization
    if iframe == 1
        col_filter_gray = gray;
        img_sz = size(gray);
    end
    
    % Groundtruth as tracking result     
    target_sz = [gt_rects(iframe, 4), gt_rects(iframe, 3)];
    pos = floor([gt_rects(iframe, 2), gt_rects(iframe, 1)] + target_sz / 2);
    window_sz = floor(target_sz * (1 + padding));
    
    % Detect keypoints 
    keypoints_cv = detector.detect(gray);
    keypoints = cat(1, keypoints_cv.pt);
    keypoints = in_rect(keypoints, pos, window_sz, img_sz);
    % [target_keypoints, ind_target_keypoints] = in_rect(keypoints, pos, target_sz, img_sz);
    % background_keypoints = keypoints(~ind_target_keypoints, :);


    % Tracking
    if iframe > 1
        
        % Only foward-backward stable tracking points are used
        ind_prev_keypoints = (1 : size(prev_keypoints))';
        [of_tracked_keypoints, ind_tracked_keypoints] = fbof_track(prev_gray, gray, prev_keypoints, ind_prev_keypoints);
        motion = of_tracked_keypoints - prev_keypoints(ind_tracked_keypoints, :);
        
        [motion, ind_motion] = sort(motion);
        [ind_cluster, c] = kmeans(motion, 2);
        pos_keypoints = of_tracked_keypoints(ind_motion(ind_cluster == 1), :);
        neg_keypoints = of_tracked_keypoints(ind_motion(ind_cluster == 2), :);
        disp(c);
        
        %num_tracked_keypoints = size(of_tracked_keypoints, 1);
        %pos_keypoints = of_tracked_keypoints(ind_motion(1 : floor(solid_pos_rate * num_tracked_keypoints)), :);
        %neg_keypoints = of_tracked_keypoints(ind_motion(end - floor(solid_neg_rate * num_tracked_keypoints) : end), :);
        
        %disp( mean(motion(ind_motion(1 : floor(solid_pos_rate * num_tracked_keypoints)), :)) );
        %disp( mean(motion(ind_motion(end - floor(solid_neg_rate * num_tracked_keypoints) : end), :)) );
    end
    
    

    % Display result
    hold on;
    if iframe == 1
        img_h = imshow(img, 'Border','tight', 'InitialMag', 100);
    else
        set(img_h, 'CData', img);
    end
    
    if iframe > 1
        delete(rect_h);
    end
    if iframe > 2
        delete(pts_pos);
        delete(pts_neg);
    end
    
    if iframe > 1
        pts_pos = plot(pos_keypoints(:, 1), pos_keypoints(:, 2), '.', 'Color', [1, 1, 0]);
        pts_neg = plot(neg_keypoints(:, 1), neg_keypoints(:, 2), '.', 'Color', [0, 1, 1]);
    end
    rect_h = rectangle('Position', [pos(2) - target_sz(2) * scale/ 2, pos(1) - target_sz(1) * scale/ 2, ...
        target_sz(2) * scale, target_sz(1) * scale], 'EdgeColor', 'g');
    
    if double(get(gcf,'CurrentCharacter')) == 27
        break;
    end
    
    % Save previous data and postprocessing
    if iframe > 1
    end
    
    prev_keypoints = keypoints;
    prev_gray = gray;
    
    pause(0.001);
end







