function histogramsHOF=HOF(I,N,box,nbins,n,m)

% Input: (Greyscale Video, Array of sorted interest points, square box
% value,number of bins,dimensions of the grid nxm )

% Output: array of histogramms for each frame

rho=5;              %LK parameters
epsilon=0.03;

%dont take into account interest points found on last frame
histogramsHOF=zeros(size(N(N(:,4)~=size(I,3),:),1),n*m*nbins);

for i = 1 : size(N(N(:,4)~=size(I,3),:),1)
    
    I10=I(:,:,N(i,4));
    I1=imcrop(I10,[max(N(i,1)-box/2,1),max(N(i,2)-box/2,1), box+1,box+1]);
        
    I20=I(:,:,N(i,4)+1);
    I2=imcrop(I20,[max(N(i,1)-box/2,1),max(N(i,2)-box/2,1), box+1,box+1]);
          
        dx=zeros(size(I1));
        dy=zeros(size(I1));

        [dx,dy,~]=lk(I1,I2,rho,epsilon,dx,dy,1);       %find optical flow
        
        desc=OrientationHistogram(dx,dy,nbins, [n m]);
        histogramsHOF(i,:)=desc;
        
end


