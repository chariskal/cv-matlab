function [d_x,d_y] = lk_multi(I1, I2, rho, rho_low, epsilon, nscales)

    if nscales == 1
        d_x0 = zeros(size(I1,1),size(I1,2));
        d_y0 = zeros(size(I1,1),size(I1,2));
        [d_x,d_y] = lk(I1, I2, rho, epsilon, d_x0, d_y0);
    else 
        G_rho = fspecial('gaussian',ceil(3*rho_low)*2+1,rho_low);
        I1_smoothed = imfilter(I1,G_rho,'symmetric');
        I2_smoothed = imfilter(I2,G_rho,'symmetric');
        I1_resized = imresize(I1_smoothed,0.5);
        I2_resized = imresize(I2_smoothed,0.5);
        [d_x0, d_y0] = lk_multi(I1_resized, I2_resized, rho, rho_low, epsilon, nscales-1);
        d_x0 = 2 * imresize(d_x0,[size(d_x0,1)/size(I1,1) size(d_x0,2)/size(I1,2)]);
        d_y0 = 2 * imresize(d_y0,[size(d_x0,1)/size(I1,1) size(d_x0,2)/size(I1,2)]);
        [d_x,d_y]=lk(I1, I2, rho, epsilon, d_x0, d_y0);
    end

end
