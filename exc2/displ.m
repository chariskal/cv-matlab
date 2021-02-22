function [disp_x, disp_y,E0]= displ(dx,dy)

    E0=dx.^2+dy.^2;             %find Energy
    E=E0>=0.95*max(max(E0));    %thresholding
    
    dx=dx(E==1);                %keep only eligible values
    dy=dy(E==1);
   
    
    disp_x=mean(dx);            
    disp_y=mean(dy);            %find mean


end