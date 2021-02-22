function [M,int_points] = Gabor_Detector_3D (vid, s, t, theta_corn) 

% Input: (Greyscale Video, space scale, time scale, cut-off threshold)
% Output: Binary Video, indicating interest points

% Gaussian 2D Filter
window_size = 2 * ceil(3 * s) + 1 ;
g = fspecial('gaussian', [window_size, window_size], s);

% Gabor Filters
dt = linspace(-2*t, 2*t, 2*t + 1);
h_e(1,1,:) = - cos (2 * pi * dt * 4 / t) .* exp ( - dt .^ 2 / ( 2 * t ^ 2) ) ;
h_o(1,1,:) = - sin (2 * pi * dt * 4 / t) .* exp ( - dt .^ 2 / ( 2 * t ^ 2) ) ;
% Applying L1 norm
h_e(1,1,:) = h_e(1,1,:) / sum(abs(h_e(1,1,:)));
h_o(1,1,:) = h_o(1,1,:) / sum(abs(h_o(1,1,:)));

f_e = convn(g, h_e) ;
f_o = convn(g, h_o) ;

one = imfilter (vid, f_e, 'symmetric');
two = imfilter (vid, f_o, 'symmetric');

M = one.^2 + two.^2 ;

cond_1 = imregionalmax(M);
cond_2 = (M > theta_corn * max(max(max(M))));

int_points = cond_1 & cond_2 ;
[x,y,~]=size(int_points);
int_points(1:5,:,:)=0;
int_points(x-5:x,:,:)=0;
int_points(:,1:5,:)=0;
int_points(:,y-5:y,:)=0;
int_points(:,:,200)=0;