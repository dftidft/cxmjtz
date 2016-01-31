SEQ_NAME = 'helicopter';
IMG_DIR = sprintf('D:/Dataset/tracking/vot2015/%s', SEQ_NAME);
GT_FILE_NAME = 'groundtruth.txt';

gt_file_path = sprintf('%s/%s', IMG_DIR, GT_FILE_NAME);
gt_rects = importdata(gt_file_path);

for iframe = 1 : 400
    
    % Read input
    img_file_path = sprintf('%s/%08d.jpg', IMG_DIR, iframe);
    
    if ~exist(img_file_path, 'file');
        break;
    end
    
    img = imread(img_file_path);
    imshow(img);
    hold on;
    pts_x = [gt_rects(iframe, 1), gt_rects(iframe, 3), gt_rects(iframe, 5), gt_rects(iframe, 7), gt_rects(iframe, 1)];
    pts_y = [gt_rects(iframe, 2), gt_rects(iframe, 4), gt_rects(iframe, 6), gt_rects(iframe, 8), gt_rects(iframe, 2)];
    plot(pts_x, pts_y, '-');
    hold off;
    
    if double(get(gcf,'CurrentCharacter')) == 27
        break;
    end
    
    pause(0.03);
    
end