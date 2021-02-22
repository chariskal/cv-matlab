function [M,int_points] = Harris_Stephens_Detector_3D(vid, sigma, ti, s_sigma, s_ti,k, theta_corn) 

% Input: (Greyscale Video, space scale, time scale,integral space scale
%         integral time scale, k, cut-off threshold)
% Output: Binary Video, indicating interest points

% 2D Gaussian Space Filter
window_size_s = 2 * ceil(3 * sigma) + 1 ;
g_s = fspecial('gaussian', [window_size_s, window_size_s], sigma);

% 1D Gaussian Time Filter
window_size_t = 2 * ceil(3 * ti) + 1 ;
g_t(1,1,:) = gausswin(window_size_t, ti);

% 3D Gaussian Filter
g = convn(g_s, g_t, 'same');

% Apply Scale to video
vid_scaled = imfilter(vid, g, 'symmetric');
vid_scaled = im2double(vid_scaled);

% Calculating Gradients
fx = imfilter(vid_scaled, [-1 0 1]', 'symmetric') ;
fy = imfilter(vid_scaled, [-1 0 1], 'symmetric') ;
div_kernel_t(1,1,:) = [-1,0,1];
ft = imfilter(vid_scaled,div_kernel_t, 'symmetric');

% Integral Scaling Filters
window_size_s = 2 * ceil(3 * s_sigma) + 1 ;
g_s = fspecial('gaussian', [window_size_s, window_size_s], s_sigma);

window_size_t = 2 * ceil(3 * s_ti) + 1 ;
clear g_t
g_t(1,1,:) = gausswin(window_size_t, s_ti);

g = convn(g_s, g_t, 'same');

J_x_x = imfilter(fx.^2, g, 'symmetric');
J_y_y = imfilter(fy.^2, g, 'symmetric');
J_t_t = imfilter(ft.^2, g, 'symmetric');

J_x_y = imfilter(fx.*fy, g, 'symmetric');
J_y_t = imfilter(fy.*ft, g, 'symmetric');
J_t_x = imfilter(ft.*fx, g, 'symmetric');

det = 0;
det = det + J_x_x .* ( J_y_y .* J_t_t - J_y_t .^ 2 ) ;
det = det - J_x_y .* ( J_x_y .* J_t_t - J_y_t .* J_t_x ) ;
det = det + J_t_x .* ( J_x_y .* J_y_t - J_t_x .* J_y_y ) ;

M = det - k * (J_x_x + J_y_y + J_t_t) .^ 3 ;

cond_1 = imregionalmax(M);
cond_2 = (M > theta_corn * max(max(max(M))));

int_points = cond_1 & cond_2 ;
[x,y,~]=size(int_points);

int_points(1,:,:)=0;
int_points(x,:,:)=0;
int_points(:,1,:)=0;
int_points(:,y,:)=0;
int_points(:,:,200)=0;      %remove STIP from last frame so that  LK doesn't fail