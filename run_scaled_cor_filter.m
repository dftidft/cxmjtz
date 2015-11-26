% Add mexopencv lib
addpath 'D:\Project\Matlab\mexopencv'

% Parameters
padding = 1.5;  %extra area surrounding the target
lambda = 1e-4;  %regularization
output_sigma_factor = 0.1;  %spatial bandwidth (proportional to target)
interp_factor = 0.02;
kernel.sigma = 0.5;
features.hog = true;
features.gray = false;
features.hog_orientations = 9;
cell_size = 4;

% Input
SEQ_NAME = 'singer1';
IMG_DIR = sprintf('D:/Dataset/tracking/seq_bench/%s', SEQ_NAME);
GT_FILE_NAME = 'groundtruth_rect.txt';
detector = cv.BRISK();

gt_file_path = sprintf('%s/%s', IMG_DIR, GT_FILE_NAME);
gt_rects = importdata(gt_file_path);
scale = 1;

target_sz = [gt_rects(1, 4), gt_rects(1, 3)];
pos = floor([gt_rects(1, 2), gt_rects(1, 1)] + target_sz / 2);
window_sz = floor(target_sz * (1 + padding));
output_sigma = sqrt(prod(target_sz)) * output_sigma_factor / cell_size;
yf = fft2(gaussian_shaped_labels(output_sigma, floor(window_sz / cell_size)));
cos_window = hann(size(yf,1)) * hann(size(yf,2))';	

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
    
    % Detect keypoints 
    keypoints_cv = detector.detect(gray);
    keypoints = cat(1, keypoints_cv.pt);
%     % Detect keypoints in groundtruth target area
%     keypoints = keypoints(keypoints(:, 1) >= gt_rects(iframe, 1) ...
%         & keypoints(:, 2) >= gt_rects(iframe, 2) ...
%         & keypoints(:, 1) <= gt_rects(iframe, 1) + gt_rects(iframe, 3) ...
%         & keypoints(:, 2) <= gt_rects(iframe, 2) + gt_rects(iframe, 4), :);
    % Detect keypoints in estimated target area
    keypoints = in_rect(keypoints, pos, target_sz * scale, img_sz);
    ind_keypoints = 1 : size(keypoints, 1);

    % Tracking
    if iframe > 1
        
        % Estimate target's affine transform
        ind_prev_keypoints = (1 : size(prev_keypoints))';
        [of_tracked_keypoints, ind_tracked_keypoints] = fbof_track(prev_gray, gray, prev_keypoints, ind_prev_keypoints);
        [center, scale_change, rotation] = affine_estimate(of_tracked_keypoints, prev_keypoints, ind_tracked_keypoints);
        scale = scale * scale_change;
        
        % Change gray image size
        col_filter_gray = imresize(gray, 1 / scale);
        pos = pos / scale;
        
        %obtain a subwindow for detection at the position from last
		%frame, and convert to Fourier domain (its size is unchanged)
        patch = get_subwindow(col_filter_gray, pos, window_sz);
        zf = fft2(get_features(patch, features, cell_size, cos_window));
        kzf = linear_correlation(zf, model_xf);
        
        %calculate response of the classifier at all shifts
        response = real(ifft2(model_alphaf .* kzf));
        
        %target location is at the maximum response. we must take into
        %account the fact that, if the target doesn't move, the peak
        %will appear at the top-left corner, not at the center (this is
        %discussed in the paper). the responses wrap around cyclically.
        [vert_delta, horiz_delta] = find(response == max(response(:)), 1);
        if vert_delta > size(zf,1) / 2,  %wrap around to negative half-space of vertical axis
            vert_delta = vert_delta - size(zf,1);
        end
        if horiz_delta > size(zf,2) / 2,  %same for horizontal axis
            horiz_delta = horiz_delta - size(zf,2);
        end
        pos = pos + cell_size * [vert_delta - 1, horiz_delta - 1];
    end
    
    %obtain a subwindow for training at newly estimated target position
    patch = get_subwindow(col_filter_gray, pos, window_sz);
	xf = fft2(get_features(patch, features, cell_size, cos_window));
    
    %Kernel Ridge Regression, calculate alphas (in Fourier domain)
    kf = linear_correlation(xf, xf);
    alphaf = yf ./ (kf + lambda);   %equation for fast training
    
    %Postprocessing
    if iframe == 1  %first frame, train with a single image
        model_alphaf = alphaf;
        model_xf = xf;
    else
        %subsequent frames, interpolate model
        model_alphaf = (1 - interp_factor) * model_alphaf + interp_factor * alphaf;
        model_xf = (1 - interp_factor) * model_xf + interp_factor * xf;
    end
    
    pos = pos * scale;

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
    % Display groundtruth
    % rect_h = rectangle('Position', gt_rects(iframe, :), 'EdgeColor', 'g');
    rect_h = rectangle('Position', [pos(2) - target_sz(2) * scale/ 2, pos(1) - target_sz(1) * scale/ 2, target_sz(2) * scale, target_sz(1) * scale], 'EdgeColor', 'g');
    
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







