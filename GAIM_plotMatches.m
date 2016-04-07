function GAIM_plotMatches(h,fpos1, fpos2,img1,img2)
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
% GAIM_plotMatches: Plots the keypoint matches fpos1 and fpos2 found in images img1 and
% img2. A random colour is given to each match to help visualise the results.
%
%Inputs:
%h: A figure handle
%
%fpos1: A 2 x P matrix, where P is the number of matched points. This holds
%the matched points in img1.
%
%fpos2: A 2 x P matrix, where P is the number of matched points. This holds
%the matched points in img2.
%
%img1: First image (of class uint8, which can have 1 or 3 channels). 
%
%img2: Second image (of class uint8, which can have 1 or 3 channels). 
if size(img1,3)==1
    img1 = repmat(img1,[1,1,3]);
end
if size(img2,3)==1
    img2 = repmat(img2,[1,1,3]);
end

imtW = size(img1,2);
imbComb = cat(2,img1,imresize(img2,[size(img1,1),size(img1,2)]));

figure(h);
clf;
imshow(imbComb);
hold on;

for i=1:size(fpos1,2)
    cl = rand(1,3);
    pp = [ fpos1(:,i)';[fpos2(1,i)*size(img1,2)/size(img2,2)+imtW,fpos2(2,i)*size(img1,1)/size(img2,1)]];
    plot(pp(:,1),pp(:,2),'LineWidth',2,'color',cl);
end
