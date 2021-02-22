function [R] = BoxFilterBlobDetect(I,sigma,theta_corn)   

%Blob detection using box filters

n=2*ceil(3*sigma)+1;

x=4*floor(n/6)+1;
y=2*floor(n/6)+1;

X=floor(x/2);
Y=floor(3*y/2);
Y_1=ceil(y/2);
Y_2=floor(y/2);

integral_image = cumsum(cumsum(I, 2), 1);
integral_image = padarray(integral_image,[Y Y],'replicate');

Lxx=zeros(size(I,1),size(I,2));
Lyy=Lxx;
Lxy=Lxx;

k=1;
for i=Y+1:size(integral_image,1)-Y
    l=1;
   for j=Y+1:size(integral_image,2)-Y
       
       Lxx(k,l)=integral_image(i+X,j-Y_1)+integral_image(i-X,j-Y)-integral_image(i+X,j-Y)-integral_image(i-X,j-Y_1);
       Lxx(k,l)=Lxx(k,l)-2*(integral_image(i+X,j+Y_2)+integral_image(i-X,j-Y_2)-integral_image(i+X,j-Y_2)-integral_image(i-X,j+Y_2));
       Lxx(k,l)=Lxx(k,l)+integral_image(i+X,j+Y)+integral_image(i-X,j+Y_1)-integral_image(i+X,j+Y_1)-integral_image(i-X,j+Y);

       
       Lyy(k,l)=integral_image(i+Y,j+X)+integral_image(i+Y_1,j-X)-integral_image(i+Y,j-X)-integral_image(i+Y_1,j+X);
       Lyy(k,l)=Lyy(k,l)-2*(integral_image(i+Y_2,j+X)+integral_image(i-Y_2,j-X)-integral_image(i+Y_2,j-X)-integral_image(i-Y_2,j+X));
       Lyy(k,l)=Lyy(k,l)+integral_image(i-Y_1,j+X)+integral_image(i-Y,j-X)-integral_image(i-Y_1,j-X)-integral_image(i-Y,j+X);
       
       
       Lxy(k,l)=integral_image(i-1,j-1)+integral_image(i-y,j-y)-integral_image(i-1,j-y)-integral_image(i-y,j-1);
       Lxy(k,l)=Lxy(k,l)-(integral_image(i+y,j-1)+integral_image(i+1,j-y)-integral_image(i+y,j-y)-integral_image(i+1,j-1));
       Lxy(k,l)=Lxy(k,l)+integral_image(i+y,j+y)+integral_image(i+1,j+1)-integral_image(i+y,j+1)-integral_image(i+1,j+y);
       Lxy(k,l)=Lxy(k,l)-(integral_image(i-1,j+y)+integral_image(i-y,j+1)-integral_image(i-1,j+1)-integral_image(i-y,j+y));

       l=l+1;
   end
    k=k+1; 
end

R=Lxx.*Lyy-0.81*Lxy.^2;

ns=ceil(3*sigma)*2+1;
B_sq=strel('disk',ns);          %reject some values
R=(R>theta_corn*max(max(R))&(R==imdilate(R,B_sq)));
