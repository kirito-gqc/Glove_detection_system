function percentblue = gloveidentifier(img)
    % Load the image and convert it to the HSV color space
%     input = imread('D:/Degree 3 - Image Processing/dataset/finger not enough/fingertip/fingertip_finger_not_enough(10).jpeg');
%     subplot(1,3,1), imshow(I), title('Original Image')
    Ihsv = rgb2hsv(img);
%     subplot(1,3,2), imshow(Ihsv), title('HSV Image')
    
    % Extract the hue channel
    hue = Ihsv(:,:,1);
    saturation = Ihsv(:,:,2);
    value = Ihsv(:,:,3);
    % Threshold the hue channel to identify pixels with a hue value in the range of blue colors
    bluemask = hue >= 0.55 & hue <= 0.67 & saturation >=0.2 & value >=0.2;
%     subplot(1,3,3), imshow(bluemask),title ('Blue region in image')
    % Count the number of blue pixels
    numblue = nnz(bluemask);
    
    % Calculate the percentage of the image that is blue
    percentblue = numblue / numel(bluemask) * 100;
    
    % Display the result
    disp(['Percentage of blue in glove image: ' num2str(percentblue) '%'])
    
    %Condition
%     if (percentblue>= 5)
%         disp('This is a latex glove')
%     else
%         disp('This is not a latex glove')
%     end
end