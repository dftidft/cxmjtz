% Foward-backward optical flow tracking
function next_pts = fbof_track(prev_gray, gray, keypoints, thr)

if nargin < 4
    thr = 20;
end

next_pts = cv.calcOpticalFlowPyrLK(prev_gray, gray, keypoints);
back_prev_pts = cv.calcOpticalFlowPyrLK(gray, prev_gray, next_pts);
back_prev_pts = cat(1, back_prev_pts{:});
dist = back_prev_pts - keypoints;
dist = sqrt(sum(dist .* dist, 2));

next_pts = next_pts(dist < thr);
next_pts = cat(1, next_pts{:});

end