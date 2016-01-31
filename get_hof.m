function x = get_hof(prevGray, gray, features, cell_size, cos_window)
%GET_FEATURES
%   Extracts dense features from image.
%
%   X = GET_FEATURES(IM, FEATURES, CELL_SIZE)
%   Extracts features specified in struct FEATURES, from image IM. The
%   features should be densely sampled, in cells or intervals of CELL_SIZE.
%   The output has size [height in cells, width in cells, features].
%
%   To specify HOG features, set field 'hog' to true, and
%   'hog_orientations' to the number of bins.
%
%   To experiment with other features simply add them to this function
%   and include any needed parameters in the FEATURES struct. To allow
%   combinations of features, stack them with x = cat(3, x, new_feat).
%
%   Joao F. Henriques, 2014
%   http://www.isr.uc.pt/~henriques/

    %HOG features, from Piotr's Toolbox
    flow = cv.calcOpticalFlowFarneback(prevGray, gray, 'PyrScale', 0.5, 'Levels', 3, 'WinSize', 15, ...
        'Iterations', 3,'PolyN',  5, 'PolySigma', 1.2, 'Gaussian', 0); 
    % get optical flow angle from 0 ~ 2pi
    angle = atan2(flow(:, :, 2), flow(:, :, 1)) + pi;
    % get optical flow  magnitude
    mag = sqrt(flow(:, :, 1) .^2 + flow(:, :, 2) .^2);
    x = double(hof(mag, angle, cell_size, features.hog_orientations));
    x(:,:,end) = [];  %remove all-zeros channel ("truncation feature")

	%process with cosine window if needed
	if ~isempty(cos_window),
		x = bsxfun(@times, x, cos_window);
	end
	
end
