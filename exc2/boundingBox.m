function [box]=boundingBox(I,mu,sigma,i)
%Change color space
im=rgb2ycbcr(I);
im=im2double(im);

Cb = im(:,:,2);
Cr = im(:,:,3);

height = size(Cb,1);
width = size(Cb,2);

%% Alternatively Find 2D gaussian distribution manually

%     c1=Cb-mu(1);
%     c2=Cr-mu(2);
% 
%     sigma2=inv(sigma);
% 
% Q=c1.*c1.*sigma2(1,1)+2.*c1.*c2.*sigma2(2,1)+c2.*c2.*sigma2(2,2);
% Q=-0.5.*Q;
% Q=exp(Q);
% Q=Q./sqrt(det(sigma)*4*pi*pi);
%%
Q=mvnpdf([Cb(:) Cr(:)],mu,sigma);
Q=reshape(Q,height,width);
Q=Q/max(max(Q));
%%
binIm=Q>0.54;  %thresholding


filename = strcat('./ChalearnDepth/D',int2str(i),'.png');
mask=imread(filename);
mask=im2double(mask);       %mask with the image from kinect's depth channel
 mask=mask<mean(mean(mask))-0.083 & mask>0.4;

binIm=mask & binIm;         %detection of skin



    B=strel('disk',18);
    binIm=imclose(binIm,B);
    
    B=strel('disk',4);        %morphological opening and closing to remove small regions
    binIm=imopen(binIm,B);


    [binIm,num]=bwlabel(binIm);     %find the blob that is on the most left region of the image 
stats=regionprops(binIm,'BoundingBox');

%%find the biggest blob that is always the head and ignore it
biggest_blob=0;
for i=1:num
    if (stats(i).BoundingBox(3)*stats(i).BoundingBox(4)>biggest_blob)
        biggest_blob=stats(i).BoundingBox(3)*stats(i).BoundingBox(4);
        position=i;
    end
    
end

min=[height width 0 0];
for i=1:num;
    if (position==i)    %if its the head then ignore it
        continue;
    end
    
    if (stats(i).BoundingBox(1)<min(1))     %else see if it is on the left
        min=stats(i).BoundingBox;
    end
end
box=int32(min);    %return the dimensions and position of the bounding box of right hand

end