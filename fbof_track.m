% Foward-backward optical flow tracking
function [tracked_pts, ind_tracked_pts] = fbof_track(prev_gray, gray, keypoints, ind_keypoints, thr)

if nargin < 5
    thr = 20;
end

[next_pts, status] = cv.calcOpticalFlowPyrLK(prev_gray, gray, keypoints);
% next_pts = cv.calcOpticalFlowPyrLK(prev_gray, gray, keypoints);
back_prev_pts = cv.calcOpticalFlowPyrLK(gray, prev_gray, next_pts);
back_prev_pts = cat(1, back_prev_pts{:});
dist = back_prev_pts - keypoints;
dist = sqrt(sum(dist .* dist, 2));

status = dist < thr & status;
next_pts = next_pts(status);
tracked_pts = cat(1, next_pts{:});

ind_tracked_pts = ind_keypoints(status);

end