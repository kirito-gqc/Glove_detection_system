function [defect_name, newBox] = dirty_and_hole_detection(im,orientation)
% read the image
% im = imread('D:/Degree 3 - Image Processing/dataset/dirty and stain/side(left)/side_left_dirty(18).jpeg');
% figure('Name','Original'),imshow(im),title('Original Image'); 
% Transform image to HSV
Ihsv = rgb2hsv(im);
%Extract saturation channel
I1= Ihsv(:,:,2);
%Thresh away low saturation pixel
thresholded = I1 > 0.4; %% Threshold to isolate glove
thresholded = bwareaopen(thresholded,100);  % remove too small pixels
I2=thresholded.*I1; %apply threshold
%Otsu threshold for getting glove region
BW = graythresh(I2);
I3 = imbinarize(I2,BW);
% remove noise of glove
I3 = imfill(I3,'hole');
I3=medfilt2(I3,[5,5]);
% erode the glove region
se = strel("disk",5);
I3 = imerode(I3,se);
% ensure there is only one white region in the binary image
I3 = bwareafilt(I3,1);
%mask out glove region
I4 = I2.*I3;
%Single threshold segmentation
s = size(I4); 
if(orientation=="Side")
    threshold_value = 0.69;
else
    threshold_value = 0.5;
end
segment = zeros(s(1),s(2));
for i = 1:s(1)
    for j = 1:s(2)
        %side 0.69, fingertip palm 0.5
        if(I4(i,j)>=threshold_value)
            segment(i,j) = 0;
        else
            segment(i,j)=255;
        end
    end
end
%show defects regions
I4 = I3-(~segment);
%smoothen defects using closing operation
I4 = imclose(I4,se);
% figure('Name','segment'),imshow(segment),title('Segmented Image');
%Blob up possible defect region 
[Ilabel, num] = bwlabel(I4);
disp("Total possible defect="+num);
Iprops = regionprops(Ilabel,'BoundingBox','Area');
Ibox = [Iprops.BoundingBox];
IArea = [Iprops.Area];
Ibox = reshape(Ibox, [4 num]);
newBox = [];
%Remove too big or too small defect (for dirty and stain defect + hole)
for i = 1: length(IArea)
    disp("i="+i);
    disp("Area="+IArea(i));
    if ((IArea(i)>100)&&(IArea(i)<6000))
        newBox(:,end+1) = Ibox(:,i);
    end
end
[rows,columns] = size(newBox);

% figure('Name','Pre-processing'),
% subplot(2,2,1), imshow(I1), title('HSV Saturation Image');
% subplot(2,2,2), imshow(I2), title('Saturation Thresholded Image');
% subplot(2,2,3), imshow(I3), title('Glove region mask');
% subplot(2,2,4), imshow(I4), title('Possible defects');

defect_name = [];
not_defect = [];
for cnt = 1:columns
    x = newBox(1,cnt);
    y = newBox(2,cnt);
    w = newBox(3,cnt);
    h = newBox(4,cnt);
    size(segment);
    defect_mask = imcrop(segment,[x, y, w, h]); % Img Cutted or extrated from bounding box
    defect_region = imcrop(im,[x, y, w, h]);
%     Resize the mask image to have the same size as the input image
    defect_mask = imresize(defect_mask, [size(defect_region,1) size(defect_region,2)]);
    defect_mask = cast(defect_mask,'uint8');

%     Replicate the mask image across the additional channels of the input image, if necessary
    defect_mask = repmat(defect_mask, [1,1,3]);
    defect_region(~defect_mask)=255;
%     figure('Name',sprintf('Defect %d',cnt)), subplot(2,2,1),imshow(defect_region), title('Defect detected');
%     subplot(2,2,2),imshow(defect_mask), title('Segmented mask');
    
    defect_hsv = rgb2hsv(defect_region);
    % Extract the hue channel
    hue = defect_hsv(:,:,1);
    saturation = defect_hsv(:,:,2);
    value = defect_hsv(:,:,3);
    % Threshold the hue channel to identify pixels with a hue value in the range of blue colors
    bluemask = hue >= 0.55 & hue <= 0.67 & saturation >=0.2 & value >=0.2;
%     subplot(2,2,3), imshow(bluemask),title ('Blue region in defect region');
    % Count the number of blue pixels
    numblue = nnz(bluemask);
    % Calculate the percentage of the image that is blue
    percentblue = numblue / numel(bluemask) ;
    numberwhite = nnz(defect_mask);
    percentwhite = numberwhite / numel(defect_mask);
    percent = percentblue/percentwhite * 100;
    
    % Display the result
    disp(['Percentage of blue in hole/dirty+stain defects: ' num2str(percent) '%'])
    
    %Condition
    if (percent< 50)
        % Convert the image to the YCbcr color space
        ycbcrImg = rgb2ycbcr(defect_region);
    
        % Define the lower and upper bounds of the skin color cluster
        lower = [80, 110, 129];
        upper = [210, 145, 165];
        
        % Threshold the HSV image to create a binary mask
        mask = ycbcrImg(:,:,1) >= lower(1) & ycbcrImg(:,:,1) <= upper(1) & ...
               ycbcrImg(:,:,2) >= lower(2) & ycbcrImg(:,:,2) <= upper(2) & ...
               ycbcrImg(:,:,3) >= lower(3) & ycbcrImg(:,:,3) <= upper(3);
%         subplot(2,2,4), imshow(mask),title ('Skin region in defect region');
        % Use the mask to segment the image into regions
        regions = regionprops(mask, 'Area');
        % Compute the total area of the image
        totalArea = size(defect_region, 1) * size(defect_region, 2);
        % Compute the percentage of skin-colored regions in the image
        skinCoverage = 100 * sum([regions.Area]) / totalArea;
        
        % Print the percentage of skin-colored regions
        fprintf('Skin coverage in hole/dirty+stain defects: %.2f%%\n', skinCoverage);

        if (skinCoverage > 1 )
            %Hole defect
            defect_name = cat(2, defect_name,{'Hole'});
        else
            %Dirty and stain
            defect_name = cat(2, defect_name,{'Dirty and Stain'});
        end

    else
        %fail defect
        not_defect = cat(2, not_defect,cnt);
        not_defect = sort(not_defect, 'descend');
    end
end
%Remove fail defect
for i = 1: length(not_defect)
    newBox(:,not_defect(i)) = [];
end
% figure, imshow(im), title('Image with defect');
% %Draw bounding box
% % Set the font size and color for the label
% fontSize = 8;
% fontColor = 'red';
% %Start draw with rectangle
% hold on;
% for cnt = 1:size(newBox,2)
%     rectangle('position', newBox(:,cnt),'EdgeColor','r');
%     text(newBox(1,cnt), newBox(2,cnt)-25, defect_name(cnt), ...
%      'FontSize', fontSize, 'Color', fontColor);
% end
% hold off;
end
        


