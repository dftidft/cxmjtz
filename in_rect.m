% Get points in the specific rectangle in the image
% pts - points set
% pos - [y, x] center of rectangle
% target_sz - [height, width] size of rectangle
% img_sz - [height, width] size of image

<<<<<<< HEAD
function [in_pts, ind_in_pts] = in_rect(pts, pos, target_sz, img_sz)
=======
function is_in_rect = in_rect(pts, pos, target_sz, img_sz)
>>>>>>> origin/master

top = max(1, pos(1) - target_sz(1) / 2);
left = max(1, pos(2) - target_sz(2) / 2);
bottom = min(img_sz(1), pos(1) + target_sz(1) / 2);
right = min(img_sz(2), pos(2) + target_sz(2) / 2);

<<<<<<< HEAD
ind_in_pts = pts(:, 1) >=  left ...
    & pts(:, 2) >= top ...
    & pts(:, 1) <= right ...
    & pts(:, 2) <= bottom;

in_pts = pts(ind_in_pts, :);

=======
is_in_rect = pts(:, 1) >=  left ...
    & pts(:, 2) >= top ...
    & pts(:, 1) <= right ...
    & pts(:, 2) <= bottom;
>>>>>>> origin/master
end