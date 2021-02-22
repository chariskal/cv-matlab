function [table] = BlobDetect2(I,s0,N,theta_corn)   

I=im2double(I);
%I=rgb2gray(I);

Det=zeros(size(I,1),size(I,2),N);
s=1.5;

sigma=zeros(N,1);
sigma(1)=s0;

img_height  = size(I,1);
img_width   = size(I,2);
laplacian = zeros(img_height,img_width,N);

for i=1:N;
    sigma(i)=s^(i-1)*s0;
    Det(:,:,i)= BlobDetect(I,sigma(i),theta_corn);  
    n=ceil(3*sigma(i))*2+1;
laplacian(:,:,i) = abs(sigma(i)*sigma(i).*imfilter(I,fspecial('log',[n n],sigma(i)),'symmetric'));

end
    table=zeros(sum(Det(:)),3);
    l=1;
    
    if N==1
        for i=1:size(I,1);
    for j=1:size(I,2);
        if Det(i,j)==1 
            table(l,1)=j;           
            table(l,2)=i;
            table(l,3)=sigma(1);
            l=l+1;
        end
    end
        end
        
        return
    end
    

for m=1:N;
    for i=1:size(I,1);
        for j=1:size(I,2);
            
         if (Det(i,j,m)==1) && laplacian(i,j,m)>=laplacian(i,j,max(m-1,1)) && laplacian(i,j,m)>=laplacian(i,j,min(m+1,N))
                table(l,1)=j;           
                table(l,2)=i;
                table(l,3)=sigma(m);
                l=l+1;
         end
            
        end
    end
end

