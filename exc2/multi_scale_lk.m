function [dx,dy]=multi_scale_lk(I1,I2,rho,epsilon,scales)

    dx=zeros(size(I1));     %initialiaze dx0,dy0 with zeros
    dy=zeros(size(I1));
    
    scales=scales-1;        %reduce scale
    n=ceil(3*3)*2+1;

if (scales>0)
        Gp=fspecial('gaussian',[n n],3);        %low pass filter to counter aliasing
        I1=imfilter(I1,Gp,'symmetric');
        I2=imfilter(I2,Gp,'symmetric');
        
        I1_new=imresize(I1,0.5);
        I2_new=imresize(I2,0.5);
        
        [dx,dy]=multi_scale_lk(I1_new,I2_new,rho,epsilon,scales);       %function calls itself
      
end
   
    
    [dx,dy,k]=lk(I1,I2,rho,epsilon,dx,dy,1);
    dx = 2 * imresize(dx,[size(dx,1)/size(I1,1) size(dx,2)/size(I1,2)]);
    dy = 2 * imresize(dy,[size(dy,1)/size(I1,1) size(dy,2)/size(I1,2)]);
end