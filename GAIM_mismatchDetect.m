function matchedF1Inds = GAIM_mismatchDetect(F1, F2,F2_,matchedF1Inds,matchDists,matchOpts)
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
%GAIM_mismatchDetect: once matches have been computed from F2 to F1 we then
%determine which of those are correct and incorrect. To perform the LRC test we must compute a new graph using the matched keypoints in F1. 
%
%Inputs:
%F1: Structure holding keypoint and descriptor data for image 1.
%
%F2: Structure holding keypoint and descriptor data for image 2 (without
%keypoints from simulating images of image 2). 
%
%F2_: Structure holding keypoint and descriptor data for image 2 (with
%keypoints from simulating images of image 2). 
%
%matchedF1Inds: A Sx1 vector holding, for each keypoint in F2, the index of
%its match in F1. If matchedF1Inds(i)=0, then keypoint i in F2 has no match
%in F1. 
%
%matchDists: A Sx1 vector holding, for each keypoint in F2, the distance of
%its descriptor to its matched keypoint in F1. 
%
%matchOpts: Structure holding the matching options. See parseMatchOpts.m
%for details. 
%
%Outputs:
%
%matchedF1Inds: A Sx1 vector holding, for each keypoint in F2, the index of
%its match in F1. If a mismatch is detected for keypoint i in F2, then
%matchedF1Inds(i) is set to 0.

mismatchDetectThresh = 20; %a threshold (in pixels) used for deciding when a match is incorrect. A smaller value will tend to label more matches as incorrect, so there is a precision/recall trade-off for setting it.
clustThresh = 10; %a threshold (in pixels) used for clustering the matched keypoints in F1. For the LRC, the new graph is constructed with nodes corresponding to each cluster. 

psF1 = F1.ps(matchedF1Inds,:); %this holds the keypoint positions of the matched keypoints in F1. Now we cluster them:
[~,indx] = uniquifyvecs_greedy(psF1',clustThresh);
clustCells = cell(1,length(indx));
clustInds = zeros(size(psF1,1),1);


for j=1:size(psF1,1)
   d = distance_vec(psF1(j,:)',psF1(indx,:)');
   [~,mn] = min(d); 
   clustCells{mn}(end+1) = j;
   clustInds(j) = mn;
end

for i=1:length(clustCells)
   for k=1: length(clustCells{i})
      m = matchDists(clustCells{i});
      [~,sb] = min(m);
      indx(i) = clustCells{i}(sb);
   end
end

%now perform reverse matching from keypoints in F1 to keypoints in F2:
matchedF1Inds_sub = matchedF1Inds(indx);
F1_sub.ps = F1.ps(matchedF1Inds_sub,:);
F1_sub.ds = F1.ds(matchedF1Inds_sub,:);
F1_sub.AAnpds_origImg = F1.AAnpds_origImg(:,:,matchedF1Inds_sub);
F1_sub.AAnpds_origImgT = F1.AAnpds_origImgT(:,:,matchedF1Inds_sub);


[Ls_, idx_dist_] = GAIM_Kbestmatches(F2_,F1_sub,matchOpts);
A2 = GAIM_makGraph(F1_sub,matchOpts.graphNeighSize);
s_ = GAIM_solveGraph(Ls_,idx_dist_,A2,F2_,F1_sub,matchOpts);
LSelect_ = zeros(length(s_),1);
for ks=1:length(LSelect_)
    LSelect_(ks) =  Ls_(ks,s_(ks));
end
psF2_check = F2_.ps(LSelect_,:);

numPtsF2 = size(F2.ps,1);
LRDists = zeros(numPtsF2,1);
for i=1:numPtsF2
    p =  F2.ps(i,:);
    q = psF2_check(clustInds(i),:);
    LRDists(i) = norm(q-p);
end

ps1 = F1.ps(matchedF1Inds,:);
ps2 = F2.ps;
initInliers = LRDists<mismatchDetectThresh;
%now do a final stage of mismatch detection using [PB12], using the LRC
%checks as the initial solution. This step is mandatory.
outs = FBDSD_refineInliers(ps1,ps2,mismatchDetectThresh,initInliers);
matchedF1Inds(outs) = 0;


