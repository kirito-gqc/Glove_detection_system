function [defect_name, newBox] = finger_not_enough_detection(img,orientation)
% Load image
% img = imread('D:/Degree 3 - Image Processing/dataset/finger not enough/palm/palm_finger_not_enough(2).jpeg');
% figure('Name','Original'),imshow(img),title('Original Image'); 
% Transform image to HSV
img_hsv = rgb2hsv(img);
%Extract saturation channel
img_hsv = img_hsv(:,:,2);

%Thresh away low saturation pixel
%if palm 0,3, fingertip 0.4, side 0.41
if(orientation=="Palm")
    threshold_value = 0.3;
elseif(orientation == "Fingertip")
     threshold_value = 0.4;
else
    threshold_value = 0.41;
end
bw_img = im2bw(img_hsv,threshold_value); %Threshold to isolate glove + finger region
bw_img = bwareaopen(bw_img,300);  % remove too small pixels
% orientation = "palm";
%use for side orientation
if(orientation=="Side")
    dilate = strel('disk',3);
    bw_img = imdilate(bw_img,dilate);
end
%remove noise
bw_img = medfilt2(bw_img,[5 5]);
%Otsu threshold method for glove region
BW = graythresh(img_hsv);
binarized = imbinarize(img_hsv,BW);
%Remove noise of glove region
binarized = imfill(binarized,'hole');
binarized = bwareaopen(binarized,300);

%Obtaining defect regions 
%defect_in is defect within glove region
%defect_out is defect out of glove region
defect_in = bw_img-binarized;
defect_out = binarized-bw_img;
defect = defect_in|defect_out;
defect = imfill(defect,'hole');
%filter away noises and small white regions
defect = medfilt2(defect,[7 7]);
defect = bwareaopen(defect,1000);
%smoothen defect region
se = strel('disk',5);
defect = imclose(defect,se);

%Label defect region
[Ilabel, num] = bwlabel(defect);
disp("Number of possible finger defect=" +num);
Iprops = regionprops(Ilabel,'BoundingBox','Area');
Ibox = [Iprops.BoundingBox];
IArea = [Iprops.Area];
Ibox = reshape(Ibox, [4 num]);
newBox = [];
%remove too small or too big region (for finger not enough)
for i = 1: length(IArea)
    disp("i="+i);
    disp("Area="+IArea(i));
    if ((IArea(i)>2000)&&(IArea(i)<100000))
        newBox(:,end+1) = Ibox(:,i);
    end
end
[rows,columns] = size(newBox);
% figure('Name','Pre-processing'),
% subplot(2,2,1),imshow(img_hsv),title('HSV Saturation Image');
% subplot(2,2,2),imshow(bw_img),title('Saturation Thresholded Image');
% subplot(2,2,3),imshow(binarized), title('Glove region mask');
% subplot(2,2,4),imshow(defect), title('Possible defect');

%Check the skin coverage of all defects detected
not_defect=[];
defect_name = [];
for cnt = 1:columns
    x = newBox(1,cnt);
    y = newBox(2,cnt);
    w = newBox(3,cnt);
    h = newBox(4,cnt);
    size(img);
    defect_region = imcrop(img,[x, y, w, h]); % Img Cutted or extrated from bounding box
    defect_mask = imcrop(defect,[x, y, w, h]);
%     figure('Name',sprintf('Defect %d',cnt)), subplot(1,3,1),imshow(defect_mask), title('Defect mask');
    %     Resize the mask image to have the same size as the input image
    defect_mask = imresize(defect_mask, [size(defect_region,1) size(defect_region,2)]);
    defect_mask = cast(defect_mask,'uint8');

%     Replicate the mask image across the additional channels of the input image, if necessary
    defect_mask = repmat(defect_mask, [1,1,3]);
%     defect = bsxfun(@times, defect_region, cast(defect_mask, 'like', defect_region));
    defect_region(~defect_mask)=255;
    
%     subplot(1,3,2),imshow(defect_region), title('Defect region');
    % Convert the image to the HSV color space
    ycbcrImg = rgb2ycbcr(defect_region);
    
    % Define the lower and upper bounds of the skin color cluster
    lower = [0, 110, 129];
    upper = [142, 131, 165];
    
    % Threshold the HSV image to create a binary mask
    mask = ycbcrImg(:,:,1) >= lower(1) & ycbcrImg(:,:,1) <= upper(1) & ...
           ycbcrImg(:,:,2) >= lower(2) & ycbcrImg(:,:,2) <= upper(2) & ...
           ycbcrImg(:,:,3) >= lower(3) & ycbcrImg(:,:,3) <= upper(3);
%     subplot(1,3,3), imshow(mask),title ('Skin region in defect region');
    % Use the mask to segment the image into regions
    regions = regionprops(mask, 'Area');
    % Compute the total area of the image
    totalArea = size(defect_region, 1) * size(defect_region, 2);
    % Compute the percentage of skin-colored regions in the image
    skinCoverage = 100 * sum([regions.Area]) / totalArea;
    
    % Print the percentage of skin-colored regions
    fprintf('Skin coverage in finger not enough defect: %.2f%%\n', skinCoverage);
    %Condition
    if (skinCoverage <20)
        not_defect = cat(2, not_defect,cnt);
        not_defect = sort(not_defect, 'descend');
    end

end
%Remove fail defect
for i = 1: length(not_defect)
    newBox(:,not_defect(i)) = [];
end
for cnt = 1:size(newBox,2)
    defect_name = cat(2, defect_name,{'Finger Not Enough'});
end
% figure, imshow(img), title('Image with defect');
%Draw bounding box
% Set the font size and color for the label
% fontSize = 8;
% fontColor = 'red';
% hold on;
% for cnt = 1:size(newBox,2)
%     rectangle('position', newBox(:,cnt),'EdgeColor','r');
%     text(newBox(1,cnt), newBox(2,cnt)-25, 'Finger not enough', ...
%      'FontSize', fontSize, 'Color', fontColor);
% end
% hold off;
end





