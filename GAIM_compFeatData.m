function GAIM_compFeatData(dr,img_g,msk,detectorOpts,x)
% This file is part of the GAIM package for graph-based keypoint matching
% from the paper "An Analysis of Errors in Graph-based Keypoint Matching
% and Proposed Solutions", Collins, Mesejo and Bartoli, ECCV 2014. GAIM
% tackles the general keypoint-based graph matching problem for two images. It does not require prior knowledge about 
% the number of objects in the scene, the amount of occlusion, the amount of background clutter, and object topology (which changes 
% between the images if e.g. an object tears). Please cite this paper if you are using any part of this code in your work. 
% This is free software covered by the GPLv3 License.
% 
% Copyright (c) 2014 Toby Collins and Pablo Mesejo
%
%GAIM_compFeatData: Compute keypoints and descriptors using simulated
%views.
%
%Inputs:
%
%dr: Working directory (used for saving the keypoint information). 
%
%img_g: greyscale input image
%
%msk: A mask matrix of the same size as img_g. If msk is non-empty, only
%features within the mask will be computed. 
%
%detectorOpts: Structure holding the detection options. See
%parseDetectOpts.m for details. 
%
%x: A positive integer specifying the number of steps for quantising shear and
%anisotropic scale. 

outf = [dr '/GxFeats.mat']; %the output file

if isempty(msk)
    msk = true(size(img_g));
end
assert(size(msk,1)==size(img_g,1));
assert(size(msk,2)==size(img_g,2));

%%create the ranges for shear and anisotropic scale:
detectorOpts.s2Range = linspace(detectorOpts.shearRng(1),detectorOpts.shearRng(2),x); %define the shear quantisations
detectorOpts.s2Range(end+1) = 0;

su = 1;
sb = 1;
for ii=2:x/2
    su(ii) = su(ii-1)*detectorOpts.anisoStp;
    sb(ii) = sb(ii-1)/detectorOpts.anisoStp;   
end
detectorOpts.s3Range = [sb(end:-1:2),1,su(2:end)];

%do the simulation:
tic;
F_= GAIM_doSimulation(img_g,dr,detectorOpts); %generate the feature data
vlds = interp2(double(msk),F_.ps(:,1),F_.ps(:,2))>0.5;
F.ps = F_.ps(vlds,:);
F.ds= F_.ds(vlds,:);
F.indexes= F_.indexes(vlds,:);
F.AAnpds_origImg= F_.AAnpds_origImg(:,:,vlds);
F.AAnpds_origImgT= F_.AAnpds_origImgT(:,:,vlds);
tm = toc;
save(outf,'F');%save(fout,'AsSim','featsdata');


%now compute the keypoints in the original image:
detectorOpts_ = detectorOpts;
detectorOpts_.dI = 0; %don't double the image size:

Featdata = GAIM_extractImgFeatures(img_g,detectorOpts_);
vlds = interp2(double(msk),Featdata.LocationImage(:,1),Featdata.LocationImage(:,2))>0.5;
p = Featdata.LocationImage(vlds,:);

%eliminate duplicated keypoints:
[~,indx] = uniquifyvecs_greedy(p',1);
s = setdiff([1:size(p,1)],indx);
vlds(s) = 0;

%save the keypoint data to the structure F:
F.ps =double(Featdata.LocationImage(vlds,:)); % x,y coordiantes of the center of the Oriented ellipse
F.ds = double(Featdata.ds(vlds,:)); % descriptors

F.AAnpds_origImg = Featdata.AAnpd(:,:,vlds);
F.AAnpds_origImgT = F.AAnpds_origImg*0;
F.AAnpds_origImgT(1,1,:) = F.AAnpds_origImg(1,1,:);
F.AAnpds_origImgT(1,2,:) = F.AAnpds_origImg(2,1,:);
F.AAnpds_origImgT(1,3,:) = F.AAnpds_origImg(3,1,:);

F.AAnpds_origImgT(2,1,:) = F.AAnpds_origImg(1,2,:);
F.AAnpds_origImgT(2,2,:) = F.AAnpds_origImg(2,2,:);
F.AAnpds_origImgT(2,3,:) = F.AAnpds_origImg(3,2,:);

F.AAnpds_origImgT(3,1,:) = F.AAnpds_origImg(1,3,:);
F.AAnpds_origImgT(3,2,:) = F.AAnpds_origImg(2,3,:);
F.AAnpds_origImgT(3,3,:) = F.AAnpds_origImg(3,3,:);

F.timeToComputeFeats = tm;
outf = [dr '/G1Feats.mat']; 
save(outf,'F');