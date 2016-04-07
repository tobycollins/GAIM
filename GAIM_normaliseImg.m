function [sc,img_] = GAIM_normaliseImg(img)
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
% GAIM_normaliseImg: Rescales img so that it has a default diagonal size of
% 1000 pixels.
%
% Inputs:
% img: A image matrix (can be any class and any number of channels).
%
% Outputs:
% img_: The rescaled image.
% sc: The scale factor mapping img to img_;


std = 1000; 
d = ceil(sqrt(size(img,1)^2 + size(img,2)^2));
sc = std/d;
img_ = imresize(img,sc);



