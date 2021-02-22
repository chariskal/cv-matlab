function [R] = CornerDetect(I,sigma,p,theta_corn,k)   


n=ceil(3*sigma)*2+1;
h = fspecial('gaussian',[n n],sigma);
Gp = fspecial('gaussian',[n n],p);

Isigma=imfilter(I,h);

[fx,fy]=imgradientxy(Isigma);

fxx=fx.^2;
fxy=fx.*fy;     %Image derivatives
fyy=fy.^2;

J1=imfilter(fxx,Gp,'symmetric');
J2=imfilter(fxy,Gp,'symmetric');
J3=imfilter(fyy,Gp,'symmetric');


lambda_plus=(J1+J3+sqrt((J1-J3).^2+4*J2.^2))/2;
lambda_minus=(J1+J3-sqrt((J1-J3).^2+4*J2.^2))/2;

%imshow(lambda_plus);
%figure
%imshow(lambda_minus);

%corner criterion
R=lambda_plus.*lambda_minus-k*(lambda_plus+lambda_minus).^2;

ns=ceil(3*sigma)*2+1;
B_sq=strel('disk',ns);          %reject some values
R=(R>theta_corn*max(max(R))&(R==imdilate(R,B_sq)));