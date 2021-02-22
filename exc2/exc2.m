%% part 1 // find mu and sigma from the samples
addpath('./Chalearn');
addpath('./ChalearnDepth');

load ('skinSamplesRGB.mat');

img_ycbcr = rgb2ycbcr(skinSamplesRGB);  %change color space
Cb = img_ycbcr(:,:,2);
Cr = img_ycbcr(:,:,3);
Cb=im2double(Cb);
Cr=im2double(Cr);

mu=[mean(mean(Cb)) mean(mean(Cr))];     %find mean and covariance
sigma=cov(Cb,Cr);


%find the bounding box's position containing the right hand in the first
%frame
srcFiles = dir('./Chalearn/*.png');  
filename = strcat('./Chalearn/',srcFiles(1).name);
I= imread(filename);
box=boundingBox(I,mu,sigma,1);

% //  box=boundingBox(frame,mu,sigma,No of frame)
% //  box=[uper left corner x, upper left corner y, height, width];

%Use the same method for all the frames. Normally this would not be
%accurate since the blob of the right hand can easily be missed because of
%a different object(i.e. elbow, head,or just noise) appearing on the left.
%In this case for this image the boundingBox function finds the right hand
%accurately for all the frames (it can be tested below) because of the
%right thresholding in the function.

%% Find Bounding Boxes for all frames ( not exactly required )as a different
%%method for tracking the position of the hand.
figure;
for i = 1 : length(srcFiles)
    
    filename = strcat('./Chalearn/',srcFiles(i).name);
    [I,map]= imread(filename);
    box1=boundingBox(I,mu,sigma,i);
    
    green = uint8([0 255 0]); 
    shapeInserter = vision.ShapeInserter('Shape','Rectangles','LineWidth',2,'BorderColor','Custom','CustomBorderColor',green) ;
    J = step(shapeInserter, I, [box1(1),box1(2),box(3)+5,box(4)+5] );
    
    %Use the dimensions of the first detected box for better optical
    %result, but I could have used the dimensions of each box as detected
    %from the algorithm.
   
  imshow(J); 
  pause(.3)
   
%     subplot('Position',[(mod(i-1,8))/8 1-(ceil(i/8))/8 1/8 1/8])
%     imshow(J);

end

%%%%%%%%%%%%%%%%%%  Create caption   %%%%%%%%%%%%%%%%

% p = get(gcf,'Position');
% k = [size(I,2) size(I,1)]/(size(I,2)+size(I,1));
% set(gcf,'Position',[p(1) p(2) (p(3)+p(4)).*k]) %// adjust figure x and y size


%% part 2. Use Lucas-Kanade method to find optical flow 
 pad=max(box(3),box(4));        %cut square boxes from the frames
 x=box(1)-(pad-box(3))/2;
 y=box(2)-(pad-box(4))/2;
 
srcFiles = dir('./Chalearn/*.png');  % the folder in which the images exist
for i = 1 : length(srcFiles)-1
    filename = strcat('./Chalearn/',srcFiles(i).name);  %read i-th frame
    I10= imread(filename);

    filename = strcat('./Chalearn/',srcFiles(i+1).name);    % read (i+1)-th frame
    I20= imread(filename);

    I1=im2double(rgb2gray(I10));
    I2=im2double(rgb2gray(I20));
    

filename = strcat('./ChalearnDepth/D',int2str(i),'.png');       %create mask
mask=imread(filename);
mask=im2double(mask);       %mask with the image from kinect's depth channel
mask=mask<(mean(mean(mask))-0.05) & mask>0.4;
 
I1(:)=min(I1,mask);

filename = strcat('./ChalearnDepth/D',int2str(i+1),'.png');
mask=imread(filename);
mask=im2double(mask);       %mask with the image from kinect's depth channel
mask=mask<(mean(mean(mask))-0.05) & mask>0.4;

I2(:)=min(I2,mask);

    I1=imcrop(I1,[x-5,y-5, pad+5,pad+5]);       %crop images I1,I2
    I2=imcrop(I2,[x-5,y-5, pad+5,pad+5]);
     
    dx=zeros(size(I1));
    dy=zeros(size(I1));

  [dx,dy,k]=lk(I1,I2,5,0.03,dx,dy,1);       %find optical flow
 
%     dx_r=imresize(dx,0.3); 
%     dy_r=imresize(dy,0.3);         %plot the optical flow space using quiver
%     quiver(-1*dx_r,-1*dy_r);
%      pause;

    [disp_x, disp_y,E]= displ(-dx,-dy);       %find mean of vector 
    
    x=x+round(disp_x);
    y=y+round(disp_y);
    
    % Plot the bounding box containing the right hand in each frame
    figure(2)
    green = uint8([0 255 0]); 
    shapeInserter = vision.ShapeInserter('Shape','Rectangles','LineWidth',2,'BorderColor','Custom','CustomBorderColor',green) ;
    J = step(shapeInserter, I20, [x,y,pad+5,pad+5] );
    imshow(J);
    pause(0.2);
    
      
%     subplot('Position',[(mod(i-1,8))/8 1-(ceil(i/8))/8 1/8 1/8])
%      imshow(J);
%      quiver(-1*dx_r,-1*dy_r);

end

%%%%%%%%%%%%%%%%%%  Create caption   %%%%%%%%%%%%%%%%
% 
% p = get(gcf,'Position');
% k = [size(I,2) size(I,1)]/(size(I,2)+size(I,1));
% set(gcf,'Position',[p(1) p(2) (p(3)+p(4)).*k]) %// adjust figure x and y size


%% multi scale LK method
scales=3;
rho=5;
epsilon=0.03;

pad=max(box(3),box(4));        %cut square boxes from the frames
 x=box(1)-(pad-box(3))/2;
 y=box(2)-(pad-box(4))/2;
 
srcFiles = dir('./Chalearn/*.png');  % the folder in which ur images exists
for i = 1 : length(srcFiles)-1
    filename = strcat('./Chalearn/',srcFiles(i).name);  %read i-th frame
    I10= imread(filename);

    filename = strcat('./Chalearn/',srcFiles(i+1).name);    % read (i+1)-th frame
    I20= imread(filename);

    I1=im2double(rgb2gray(I10));
    I2=im2double(rgb2gray(I20));
    

filename = strcat('./ChalearnDepth/D',int2str(i),'.png');       %create mask
mask=imread(filename);
mask=im2double(mask);       %mask with the image from kinect's depth channel
mask=mask<(mean(mean(mask))-0.04) & mask>0.4;
 
I1(:)=min(I1,mask);

filename = strcat('./ChalearnDepth/D',int2str(i+1),'.png');
mask=imread(filename);
mask=im2double(mask);       %mask with the image from kinect's depth channel
mask=mask<(mean(mean(mask))-0.04) & mask>0.4;

I2(:)=min(I2,mask);

    I1=imcrop(I1,[x-5,y-5, pad+5,pad+5]);
    I2=imcrop(I2,[x-5,y-5, pad+5,pad+5]);
        
  [dx,dy]=multi_scale_lk(I1,I2,rho,epsilon,scales);

  [dx,dy]=lk(I1,I2,rho,epsilon,dx,dy,1);
%     dx_r=imresize(dx,0.3); 
%     dy_r=imresize(dy,0.3); 
%     figure(1);
%     quiver(-dx_r,-dy_r);
%     
    [disp_x, disp_y,E]= displ(-dx,-dy);
    
    x=x+floor(disp_x);
    y=y+floor(disp_y);
    
    figure(2)
    green = uint8([0 255 0]); 
    shapeInserter = vision.ShapeInserter('Shape','Rectangles','LineWidth',2,'BorderColor','Custom','CustomBorderColor',green) ;
    J = step(shapeInserter, I20, [x,y,pad+5,pad+5] );
    pause(0.3);
%      subplot('Position',[(mod(i-1,8))/8 1-(ceil(i/8))/8 1/8 1/8])
     imshow(J);
%      quiver(-1*dx_r,-1*dy_r);

end

%%%%%%%%%%%%%%%%%%  Create caption   %%%%%%%%%%%%%%%%

% p = get(gcf,'Position');
% k = [size(I,2) size(I,1)]/(size(I,2)+size(I,1));
% set(gcf,'Position',[p(1) p(2) (p(3)+p(4)).*k]) %// adjust figure x and y size


