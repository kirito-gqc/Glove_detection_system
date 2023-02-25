function fingernum = finger_counter(img)
% read the image
% img = imread('D:/Degree 3 - Image Processing/dataset/finger not enough/palm/palm_finger_not_enough(18).jpeg');
% subplot(2,2,1), imshow(img),title('Original image');
%convert to hsv
img_hsv = rgb2hsv(img);
%Extract saturation channel
img_hsv = img_hsv(:,:,2);

%Glove region extraction
bw_img = im2bw(img_hsv,0.45);
%smoothen boundaries and remove noises
se= strel('disk',5);
bw_img = imclose(bw_img,se);
bw_img = bwareaopen(bw_img,100000);
bw_img = imfill(bw_img,'holes');
% subplot(2,2,2), imshow(bw_img),title('Glove region');

%Palm region extraction
open = strel('disk',50);
palm_img = imopen(bw_img, open);
% subplot(2,2,3), imshow(palm_img),title('Palm region');

%Reduction of palm area in glove region
finger = bw_img-palm_img;
finger = im2bw(finger);
%Accept size with greater or equal to 5000 pixels (finger size)
sizeThreshold = 5000;
finger = bwpropfilt(finger, 'Area', [sizeThreshold Inf]);
% subplot(2,2,4),imshow(finger), title('Fingers extracted');

%Record number of fingers
[label,fingernum]  = bwlabel(finger);
% fprintf('Number of fingers: %d',fingernum);
% if (num ~= 5)
%     disp('-> Finger not enough');
% else
%     disp('-> Not finger not enough');
% end
end