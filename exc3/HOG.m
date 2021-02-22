function histogramsHOG=HOG(I,N,box,nbins,n,m)

% Input: (Greyscale Video, Array of sorted interest points, square box
% value,number of bins,dimensions of the grid nxm )

% Output: array of histogramms for each frame

histogramsHOG=zeros(size(N,1),n*m*nbins);
for i = 1 : size(N,1)
    
    I10=I(:,:,N(i,4));
    I1=imcrop(I10,[max(N(i,1)-box/2,1),max(N(i,2)-box/2,1), box+1,box+1]);
     
        [dx,dy]=imgradientxy(I1);                       %find gradients
        desc=OrientationHistogram(dx,dy,nbins, [n m]);
        histogramsHOG(i,:)=desc;
end




