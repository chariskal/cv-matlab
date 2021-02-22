function [Det] = BlobDetect(I,sigma,theta_corn)   

%Blob detection using determinant of Hessian matrix

n=ceil(3*sigma)*2+1;
h = fspecial('gaussian',[n n],sigma);

Isigma=imfilter(I,h);

[fx,fy]=imgradientxy(Isigma);

[fxx,]=imgradientxy(fx);
[fxy,fyy]=imgradientxy(fy);

Det=fxx.*fyy-fxy.^2;

ns=ceil(3*sigma)*2+1;
B_sq=strel('disk',ns);          %reject some values

Det=(Det>theta_corn*max(max(Det))&(Det==imdilate(Det,B_sq)));