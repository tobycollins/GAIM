function [L0_new,en] = fuseQPBO(L0,L1,unaryCosts,numNodes,edgeCosts,PI)
% This file is part of the GAIM package for graph-based keypoint matching
% from the paper "An Analysis of Errors in Graph-based Keypoint Matching
% and Proposed Solutions", Collins, Mesejo and Bartoli, ECCV 2014. GAIM
% tackles the general keypoint-based graph matching problem for two images. It does not require prior knowledge about 
% the number of objects in the scene, the amount of occlusion, the amount of background clutter, and object topology (which changes 
% between the images if e.g. an object tears). Please cite this paper if you are using any part of this code in your work. 
% This is free software covered by the GPLv3 License.
%
%fuseQPBO: Performs label fusion for an MRF with energies defined in
%nodecost and edgeCosts. The MRF's graph is defined by PI. The labels to be fused are L0 and L1. 
%
%Inputs:
%L0: numLabels x 1 vector for the first label set.
%L1: numLabels x 1 vector for the second label set.
%unaryCosts: numNodes x numLabels matrix holding the unary unaryCosts, where numNodes is the number of graph nodes.
%edgeCosts:  This is a (numLabels x numLabels x e) matrix holding the edge costs, where e is the number of edges in the graph.
%PI: A 2 x e matrix holding the graph's edges

%Outputs:
%L0_new: numLabels x 1 vector for the fused label set.
%en. Energy of MRF using labels in L0_new.

is1 = sub2ind(size(unaryCosts),[1:numNodes]',L0);
Ue1 = unaryCosts(is1);

is2 = sub2ind(size(unaryCosts),[1:numNodes]',L1);
Ue2 = unaryCosts(is2);
UE = [Ue1,Ue2]';

v1=  edgeCosts(sub2ind(size(edgeCosts),L0(PI(1,1:size(edgeCosts,3))),L0(PI(2,1:size(edgeCosts,3))),[1:size(edgeCosts,3)]'));
v2=  edgeCosts(sub2ind(size(edgeCosts),L0(PI(1,1:size(edgeCosts,3))),L1(PI(2,1:size(edgeCosts,3))),[1:size(edgeCosts,3)]'));
v3=  edgeCosts(sub2ind(size(edgeCosts),L1(PI(1,1:size(edgeCosts,3))),L0(PI(2,1:size(edgeCosts,3))),[1:size(edgeCosts,3)]'));
v4=  edgeCosts(sub2ind(size(edgeCosts),L1(PI(1,1:size(edgeCosts,3))),L1(PI(2,1:size(edgeCosts,3))),[1:size(edgeCosts,3)]'));

q1=  edgeCosts(sub2ind(size(edgeCosts),L0(PI(2,1:size(edgeCosts,3))),L0(PI(1,1:size(edgeCosts,3))),[1:size(edgeCosts,3)]'));
q2=  edgeCosts(sub2ind(size(edgeCosts),L0(PI(2,1:size(edgeCosts,3))),L1(PI(1,1:size(edgeCosts,3))),[1:size(edgeCosts,3)]'));
q3=  edgeCosts(sub2ind(size(edgeCosts),L1(PI(2,1:size(edgeCosts,3))),L0(PI(1,1:size(edgeCosts,3))),[1:size(edgeCosts,3)]'));
q4=  edgeCosts(sub2ind(size(edgeCosts),L1(PI(2,1:size(edgeCosts,3))),L1(PI(1,1:size(edgeCosts,3))),[1:size(edgeCosts,3)]'));

en = sum(v1)+sum(q1)+sum(Ue1);

PE = [[v1';v2';v3';v4'],[q1';q2';q3';q4']];
[L stats] = vgg_qpbo(UE, PI, PE);

L0_new = L0;

L0_new(L==1) = L1(L==1);
