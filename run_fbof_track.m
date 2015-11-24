% Add mexopencv lib
addpath 'D:\Project\Matlab\mexopencv'

% Parameters

% Input
SEQ_NAME = 'motorrolling';
IMG_DIR = sprintf('D:/Dataset/tracking/seq_bench/%s', SEQ_NAME);
GT_FILE_NAME = 'groundtruth_rect.txt';
detector = cv.BRISK();

gt_file_path = sprintf('%s/%s', IMG_DIR, GT_FILE_NAME);
gt_rects = importdata(gt_file_path);

for iframe = 1 : 100
    img_file_path = sprintf('%s/img/%04d.jpg', IMG_DIR, iframe);
    img = imread(img_file_path);
    gray = rgb2gray(img);
    keypoints_cv = detector.detect(gray);
    keypoints = cat(1, keypoints_cv.pt);
    keypoints = keypoints(keypoints(:, 1) >= gt_rects(iframe, 1) ...
        & keypoints(:, 2) >= gt_rects(iframe, 2) ...
        & keypoints(:, 1) <= gt_rects(iframe, 1) + gt_rects(iframe, 3) ...
        & keypoints(:, 2) <= gt_rects(iframe, 2) + gt_rects(iframe, 4), :);

    next_pts = [];
    if iframe > 1
        of_tracked_keypoints = fbof_track(prev_gray, gray, prev_keypoints);
        % disp(keypoints);
    end

    imshow(img);
    hold on;
    if iframe > 1
        plot(prev_keypoints(:, 1), prev_keypoints(:, 2), '.', 'Color', [1, 1, 0]);
        plot(of_tracked_keypoints(:, 1), of_tracked_keypoints(:, 2), '.', 'Color', [0, 1, 1]);
    end
    if double(get(gcf,'CurrentCharacter')) == 27
        break;
    end
    
    prev_keypoints = keypoints;
    prev_gray = gray;
    pause(0.01);
end







