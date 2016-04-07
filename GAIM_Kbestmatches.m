function [idx, idx_dist] = GAIM_Kbestmatches(F1, F2, matchOpts)
% This file is part of the GAIM package for graph-based keypoint matching
% from the paper "An Analysis of Errors in Graph-based Keypoint Matching
% and Proposed Solutions", Collins, Mesejo and Bartoli, ECCV 2014. GAIM
% tackles the general keypoint-based graph matching problem for two images. It does not require prior knowledge about
% the number of objects in the scene, the amount of occlusion, the amount of background clutter, and object topology (which changes
% between the images if e.g. an object tears). Please cite this paper if you are using any part of this code in your work.
% This is free software covered by the GPLv3 License.
%
%GAIM_Kbestmatches: Computes the approximate k nearest neighbours in F1 for each
%keypoint in F2 (with respect to descriptor similarity). Because keypoints in F1 may be duplicates or near-duplicates, this computes
%the approximate k nearest neighbours such that the returned keypoints are
%not near-duplicates. To do this we greedily compute nearest neighbours and
%remove other keypoints in F1 which are 'too close' to the
%nearest neighbour, using a default tolerance of 5 pixels.
% 
% Copyright (c) 2014 Toby Collins and Pablo Mesejo
%
%Inputs:
%F1: Structure holding keypoint and descriptor data for image 1
%
%F2: Structure holding keypoint and descriptor data for image 2
%
%matchOpts: Structure holding the matching options. See parseMatchOpts.m
%for details. 
%
%Outputs:
%idx: The index of the nearest K matches in F1 for each keypoint in F2
%(size NxK where N is the number of keypoints in F2).
%
%idx_dist: The descriptor distance for the the nearest K matches (size NxK where N is the number of keypoints in F2).

tol =5;
numChecks = 15; %parameter used by FLANN for deciding when to terminate each query.
testset = single(F2.ds)';
numF2 = size(F2.ps,1);
maxK = min(matchOpts.K*10,size(F1.ds,1));
switch matchOpts.ANNMethod
    case 'FLANN'
        if maxK==size(F1.ds,1)
            [L_1, idx_dist] = knnsearch(F1.ds,F2.ds,'K',matchOpts.K*10);
        else
            [L_1, idx_dist] = flann_search(F1.flanIndex,testset,maxK,struct('checks',numChecks));
            L_1=L_1';
            idx_dist=idx_dist';
        end
end
L_ini = zeros(numF2,matchOpts.K);
for i=1:numF2
    lsRem = L_1(i,:);
    dsRem = idx_dist(i,:);
    pSelect = [1;1]*-inf;
    trm = false;
    cnt = 0;
    while trm==false
        dd2_ = ((pSelect(1)-F1.ps(lsRem,1)).^2 + (pSelect(2)-F1.ps(lsRem,2)).^2)';
        vld = (dd2_>tol^2);
        lsRem = lsRem(vld);
        dsRem= dsRem(vld);
        if isempty(lsRem)
            L_ini(i,cnt+1:end) = 1;
            trm = true;
        else
            [~,mn] = min(dsRem);
            cnt = cnt+1;
            L_ini(i,cnt) = lsRem(mn);
            pSelect =F1.ps(L_ini(i,cnt),:)';
            if cnt==matchOpts.K
                trm = true;
            end
        end
    end
end
idx = L_ini;
idx_dist = zeros(numF2,matchOpts.K);
for i=1:numF2
    ls = idx(i,:);
    dd = distance_vec(F2.ds(i,:)',F1.ds(ls,:)');
    idx_dist(i,:) = dd;
end

dd = abs(diff(idx,2));
dd_ = sum(dd,1);
ff = find(dd_==0);
if isempty(ff)==0
    if ff(1)+1<=size(idx,2)
        idx = idx(:,1: ff(1)+1);
        idx_dist= idx_dist(:,1: ff(1)+1);
        
    end
end

