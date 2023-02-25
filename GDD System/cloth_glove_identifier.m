function clothcover = cloth_glove_identifier(im)
% im = imread('D:/Degree 3 - Image Processing/dataset/Tai Yi Yong/open seam/resize_IMG20221220153811.jpg');
E = entropyfilt(im);
% S = stdfilt(im,ones(9));
% R = rangefilt(im,ones(9));
Eim = rescale(E);
% Sim = rescale(S);
% montage({Eim,Sim,R},'Size',[1 3],'BackgroundColor','w',"BorderSize",20)
% title('Texture Images Showing Local Entropy, Local Standard Deviation, and Local Range');

binary = im2bw(Eim,0.5);
% figure,imshow(binary),title('Thresholded Texture Image');
BWao = bwareaopen(binary,2000);
% imshow(BWao)
% title('Area-Opened Texture Image')

nhood = ones(9);
closeBWao = imclose(BWao,nhood);
% imshow(closeBWao)
% title('Closed Texture Image')

mask = imfill(closeBWao,'holes');
% figure,imshow(mask);
% title('Mask of Bottom Texture');

numcloth = nnz(~mask);
    
    % Calculate the percentage of the image that is blue
    clothcover = numcloth / numel(mask) * 100;
    
    % Display the result
    disp(['Percentage of cloth in glove image: ' num2str(clothcover) '%'])

%         Condition
%     if (clothcover>= 50)
%         disp('This is a cloth glove')
%     else
%         disp('This is not a cloth glove')
%     end
end