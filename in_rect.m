% Get points in the specific rectangle in the image
% pts - points set
% pos - [y, x] center of rectangle
% target_sz - [height, width] size of rectangle
% img_sz - [height, width] size of image

function [in_pts, ind_in_pts] = in_rect(pts, pos, target_sz, img_sz)

top = max(1, pos(1) - target_sz(1) / 2);
left = max(1, pos(2) - target_sz(2) / 2);
bottom = min(img_sz(1), pos(1) + target_sz(1) / 2);
right = min(img_sz(2), pos(2) + target_sz(2) / 2);

ind_in_pts = pts(:, 1) >=  left ...
    & pts(:, 2) >= top ...
    & pts(:, 1) <= right ...
    & pts(:, 2) <= bottom;

in_pts = pts(ind_in_pts, :);

end