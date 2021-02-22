%% exc3 - Computer Vision
% part 1
clear;
clc;

%add all paths
addpath('./samples/boxing');
addpath('./samples/running');
addpath('./samples/walking');

boxing = dir('./samples/boxing/*.avi');
running = dir('./samples/running/*.avi');
walking = dir('./samples/walking/*.avi');
src=[boxing; running; walking];

folder=dir('./samples/');

%parameters
sigma = 1.5;
tau=3;
theta_corn=0.004;       %for harris
k=0.0005;
nbins=9;        % # of bins
n=3; m=3;       % Dimensions of the grid
box=4*sigma;    % cut square boxes from the frames
nwords=60;
No = 600;       %No of interest points

% NOTE:to run for single HOG or HOF change "2*nbins*n*m" to "nbins*n*m" on
% visual_words AND featuresHOG_HOF

visual_words=zeros(nwords*size(src,1),2*nbins*n*m);
featuresHOG_HOF=zeros(No,2*nbins*n*m,size(src,1));
l=0;

for i=1:size(src,1)

filename = strcat('./samples/',folder(2+ceil(i/3)).name,'/',src(i).name);  %read video
I= readVideo(filename,200,0);
I=im2double(I);

%Choose one of the following detectors

%%Harris Detector in 3D
%     [M,R]=Harris_Stephens_Detector_3D(I,sigma,tau,sigma,tau,k,0);
%%end Harris Detector

%%Gabor Detector
theta_corn=0.01;
[M,R]= Gabor_Detector_3D(I, sigma, tau, theta_corn);
%%end gabor filter

 M=im2double(M);
 M = min(R, M);
        ma = reshape(M,120*160*200,1,1);
        [sortedX,sortingIndices] = sort(ma,'descend');
        keep = sortingIndices(1:No);
        [r,c,v] = ind2sub(size(M),keep);
        N = [c,r,sigma*ones(size(r,1),1),v];
  
%    showDetection(I,N);    %uncomment if you want to see STIP on video
%%part 2
[~,d] = sort(N(:,4));   % sort table N according to 4th column (frame #)
N=N(d,:);

histogramsHOF=HOF(I,N,box,nbins,n,m);
histogramsHOG=HOG(I,N,box,nbins,n,m);

histogramsHOG_HOF=horzcat(histogramsHOG,histogramsHOF);

featuresHOG_HOF(:,:,i)=histogramsHOG_HOF;   %save features fro all videos

[~, clusters] = kmeans(histogramsHOG_HOF, nwords);
visual_words(1+l:nwords+l,:)=clusters;
l=l+nwords;
end

%% 
frequencies=zeros(size(src,1),No);                  %preallocating matrices
bovw_hist=zeros(size(src,1),nwords*size(src,1));

for j=1:size(src,1)
   temp2=zeros(1,No);
    for i = 1:No 
        temp = min_eucl_distance(featuresHOG_HOF(i,:,j), visual_words) ;
        temp2(1,i) = temp;
    end
    frequencies(j,:) = temp2;
    temp3 = histc(frequencies(j,:), 1 : nwords*9) ;
    temp3 = temp3 / norm(temp3,1) ;
    bovw_hist(j,:) = temp3 ;
end

D = pdist(bovw_hist,@distChiSq);
a = linkage(bovw_hist,'average',{@distChiSq});

dendrogram(a);



