function [center, scale, rotation] = affine_estimate(tracked_keypoints, prev_keypoints, ind_tracked_keypoints)

orig_ind_point_pairs = nchoosek(ind_tracked_keypoints, 2);
orig_ind1 = orig_ind_point_pairs(:, 1);
orig_ind2 = orig_ind_point_pairs(:, 2);
orig_v = prev_keypoints(orig_ind1, :) - prev_keypoints(orig_ind2, :);
orig_dist_point_pairs = sqrt(sum(orig_v .* orig_v, 2));
orig_angle_point_pairs = atan2(orig_v(:, 2), orig_v(:, 1));

ind_point_pairs = nchoosek((1 : size(tracked_keypoints, 1)), 2);
ind1 = ind_point_pairs(:, 1);
ind2 = ind_point_pairs(:, 2);
v = tracked_keypoints(ind1, :) - tracked_keypoints(ind2, :);
dist_point_pairs = sqrt(sum(v .* v, 2));
angle_point_pairs = atan2(v(:, 2), v(:, 1));

diff_scale = dist_point_pairs ./ orig_dist_point_pairs;
diff_scale = diff_scale(~isnan(diff_scale));
% disp(dist_point_pairs(isnan(diff_scale)));
% disp(orig_dist_point_pairs(isnan(diff_scale)));
diff_angle = angle_point_pairs - orig_angle_point_pairs;
scale = mean(diff_scale);
rotation = mean(diff_angle);
center = [mean(tracked_keypoints(ind1, :)), mean(tracked_keypoints(ind2, :))];

end