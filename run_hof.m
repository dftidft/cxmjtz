addpath 'D:\Project\Matlab\mexopencv'

% Parameters

% Input
SEQ_NAME = 'singer1';
IMG_DIR = sprintf('D:/Dataset/tracking/seq_bench/%s', SEQ_NAME);
%GT_FILE_NAME = 'groundtruth_rect.txt';

%gt_file_path = sprintf('%s/%s', IMG_DIR, GT_FILE_NAME);
%gt_rects = importdata(gt_file_path);


for iframe = 1 : 200
    
    % Read input
    img_file_path = sprintf('%s/img/%04d.jpg', IMG_DIR, iframe);
    
    if (~exist(img_file_path, 'file'))
        break;
    end
    
    img = imread(img_file_path);
    if ndims(img) == 3
        gray = rgb2gray(img);
    else
        gray = img;
    end
         
    % Initialization
    if iframe == 1
        hsv = ones(size(gray, 1), size(gray, 2), 3);
    end
    
    % Tracking
    if iframe > 1
        % flow = cv.calcOpticalFlowFarneback(prevGray, gray);
        flow = cv.calcOpticalFlowFarneback(prevGray, gray, 'PyrScale', 0.5, 'Levels', 3, 'WinSize', 15, ...
            'Iterations', 3,'PolyN',  5, 'PolySigma', 1.2, 'Gaussian', 0); 
        % get optical flow angle from 0 ~ 2pi
        angle = atan2(flow(:, :, 2), flow(:, :, 1)) + pi;
        % get optical flow  magnitude
        mag = sqrt(flow(:, :, 1) .^2 + flow(:, :, 2) .^2);
        feat = hof(mag, angle);
        hofV = hogDraw(feat);
    end
        

    % Display result
    if iframe > 1
        imshow(hofV);
    end
        
    if double(get(gcf,'CurrentCharacter')) == 27
        break;
    end
    
    % Save previous data and postprocessing
    if iframe > 1
    end
    
    prevGray = gray;
    
    pause(0.001);
end

