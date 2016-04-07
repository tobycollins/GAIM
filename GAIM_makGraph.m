function A = GAIM_makGraph(F,neighSize)
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
% GAIM_makGraph: Computes the symmetric adjacency matrix A, with height and
% width equal to the number of keypoints.) A is computed by a knn graph of
% the points in F2. A higher connectivity tends to produce better results particularly when the number of detection or candidate
% pruning errors is large (because the graph can become fragmented). 
% By the same argument, using a KNN graph with K~ 20 -> 30 tends to do better than a Delaunay triangulation, so it should be used as the default method.  

%Inputs:
%F: Structure holding keypoint and descriptor data
%
%neighSize: The neighbourhood size (i.e. K)
%
%Outputs:
%A: A sparse NxN connectivity matrix (where N is the number of keypoints in F).

numPts = size(F.ps,1);
idx = knnsearch(F.ps,F.ps,'K',neighSize);
i1 = repmat([1:numPts]',1,neighSize);
E = [idx(:),i1(:)];
E = E(E(:,1)~=E(:,2),:);
A = sparse(E(:,1),E(:,2),1,numPts,numPts);
A = (A+A')>0;