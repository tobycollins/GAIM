function stackedData = stackFeatureData(featsdata)
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
%stackFeatureData: Stacks the keypoints and descriptor vectors. A bit of
%pre-allocation might speed things up ;-)
numViews = length(featsdata);
ps=[]; %feature positions in template image
ds=[]; %feature descriptors
Is=[]; %The index of the simulate view from which each feature was detected

AAnpds_origImg=[];
AAnpds_origImgT=[];
for i=1:numViews
    p = featsdata{i}.Location_TemplateImg;
    d = featsdata{i}.ds;
    I = featsdata{i}.AIndexes;
    ps = [ps;p];
    ds = [ds;d];
    Is = [Is;I];
    AAnpds_origImg = cat(3,AAnpds_origImg,featsdata{i}.AAnpd_origImg);
    AAnpds_origImgT = cat(3,AAnpds_origImgT,featsdata{i}.AAnpd_origImgT);    
end

stackedData.ps =ps;
stackedData.ds =ds;
stackedData.indexes =Is;
stackedData.AAnpds_origImg =AAnpds_origImg;
stackedData.AAnpds_origImgT =AAnpds_origImgT;


