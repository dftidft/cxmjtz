addpath 'D:\Project\Matlab\mexopencv'

% Parameters

% Input
SEQ_NAME = 'View_001';
IMG_DIR = sprintf('D:/Dataset/tracking/pets09/S2_L1/Crowd_PETS09/S2/L1/Time_12-34/%s', SEQ_NAME);
%GT_FILE_NAME = 'groundtruth_rect.txt';

%gt_file_path = sprintf('%s/%s', IMG_DIR, GT_FILE_NAME);
%gt_rects = importdata(gt_file_path);


for iframe = 1 : 200
    
    % Read input
    img_file_path = sprintf('%s/frame_%04d.jpg', IMG_DIR, iframe);
    
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
        angle = atan2(flow(:, :, 2), flow(:, :, 1)) + pi;
        mag = sqrt(flow(:, :, 1) .^2 + flow(:, :, 2) .^2);
        hsv_h = angle / pi  / 2;
        hsv_v = min(mag / 50, 1);
        hsv(:, :, 1) = hsv_h;
        hsv(:, :, 3) = hsv_v;
        hsv(hsv < eps) = 0;
        rgb_flow = hsv2rgb(hsv);
    end
        

    % Display result
    if iframe == 1
        subplot(1, 2, 1);
        img_h = imshow(img, 'Border','tight', 'InitialMag', 100);
        subplot(1, 2, 2);
        img_h2 = imshow(img, 'Border','tight', 'InitialMag', 100);
    else
        set(img_h, 'CData', img);
        set(img_h2, 'CData', rgb_flow);
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