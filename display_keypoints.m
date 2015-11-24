% Add mexopencv lib
addpath 'D:\Project\Matlab\mexopencv'

% Parameters

% Input
SEQ_NAME = 'motorrolling';
IMG_DIR = sprintf('D:/Dataset/tracking/seq_bench/%s', SEQ_NAME);
GT_FILE_NAME = 'groundtruth_rect.txt';
detector = cv.BRISK();


for iframe = 1 : 200
    img_file_name = sprintf('%s/img/%04d.jpg', IMG_DIR, iframe);
    img = imread(img_file_name);
    % img = imresize(img, 0.5);
    gray = rgb2gray(img);
    keypoints_cv = detector.detect(gray);
    keypoints = cat(1, keypoints_cv.pt);
    % disp(keypoints);
    imshow(img);
    hold on;
    plot(keypoints(:, 1), keypoints(:, 2), '.', 'Color', [0, 1, 1]);
    if double(get(gcf,'CurrentCharacter')) == 27
        break;
    end
    pause(0.001);
end





