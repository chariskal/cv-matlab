function [dx,dy,k]=lk(I1,I2,rho,epsilon,dx,dy,k)
% Input: (frame No(i), frame No(i+1), LK parameter rho, LK parameter
% epsilon, optical flow x, optical flow y, No of repetition of recursive
% function lk() )

% Output: optical flow, no of repetitions

    [x0,y0]= meshgrid(1:size(I1,2),1:size(I1,1)); 
    In_1=interp2(I1,x0+dx,y0+dy,'linear',0);
   
    
   Ex=I2-In_1;
   [A1x,A2x]=gradient(I1);
   
   A1x=interp2(A1x,x0+dx,y0+dy,'linear',0);
   A2x=interp2(A2x,x0+dx,y0+dy,'linear',0);


   n=ceil(3*rho)*2+1;
   Gp=fspecial('gaussian',[n n],rho);
   
   %%find ux,uy
   a=imfilter(A1x.^2,Gp,'symmetric')+epsilon;
   b=imfilter(A1x.*A2x,Gp,'symmetric');
   c=imfilter(A2x.*A1x,Gp,'symmetric');
   d=imfilter(A2x.^2,Gp,'symmetric')+epsilon;
   
  w=imfilter(A1x.*Ex,Gp,'symmetric');
  v=imfilter(A2x.*Ex,Gp,'symmetric');
   
   det=a.*d-c.*b;
    ux=(d.*w-b.*v)./det;
    uy=(-c.*w+a.*v)./det;
    
    dx=ux+dx;
    dy=uy+dy;
      
    dx(isnan(dx))=0;
    dy(isnan(dy))=0;
    
    % k equals to number of repetitions
    
       if ((max(max(ux.^2)))+max(max(uy.^2))>0.08)
          k=k+1;
          [dx,dy,k]=lk(I1,I2,rho,epsilon,dx,dy,k);
       end

end