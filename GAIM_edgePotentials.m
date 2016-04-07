function edgeCosts = GAIM_edgePotentials(edgeStruct,L,F1,F2,pairTrunc)
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
%GAIM_edgePotentials: Computes the eges potentials.
%
%Inputs:
%edgeStruct: Structure holding the graph's connectivity information.
%
%L: NxnumLabels matrix holding the candidate label sets, where N is the number of
%keypoint in F2 and numLabels is the candidate-set size.
%
%F1: Structure holding keypoint and descriptor data for image 1.
%
%F2: Structure holding keypoint and descriptor data for image 2.
%
%pairTrunc: Pairwise truncation term. See parseMatchOpts.m for details. 
%
%Outputs:
%
%edgeCosts: This is a (numLabels x numLabels x e) matrix holding the edge costs,
%where e is the number of edges in the graph. This is dense matrix, but
%because we use a pairwise truncation term, it may be better to store it as a sparse matrix (watch out for a future release;-). 

global GAIM_LARGE;
withUniticity = 1; %this is set to 1 to give a high cost for matching two keypoints to the same point in the other image. 
maxState = max(edgeStruct.nStates);
edgeCosts =  zeros(maxState,maxState,edgeStruct.nEdges,'double');
for e = 1:edgeStruct.nEdges
    [edgePoints] = edgeStruct.edgeEnds(e,:);
    p_i = F2.ps(edgePoints(1,1),:);
    p_j = F2.ps(edgePoints(1,2),:);
    
    d0 = p_i-p_j;
    d0 = sqrt(d0*d0');
    d0(d0==0) = 1; %this ensures that keypoint neighbours that there is no divide-by-zero for keypoint neighbours that are at the same position.
 
    Aimg1 = F2.AAnpds_origImg(:,:,edgePoints(1,1));
    Aimg1(3,3) = 1;
    Aimg1Inv = inv(Aimg1);
    
    Aimg2 = F2.AAnpds_origImg(:,:,edgePoints(1,2));
    Aimg2(3,3) = 1;
    Aimg2Inv = inv(Aimg2);
    
    index1_F1s = L(edgePoints(1,1),:);
    index2_F1s = L(edgePoints(1,2),:);
        
    AS1 = F1.AAnpds_origImgT(:,:,index1_F1s);
    AS1(3,3,:) = 1;
    AS1 = reshape(AS1,3,3*size(AS1,3))';
    
    AS2 = F1.AAnpds_origImgT(:,:,index2_F1s);
    AS2(3,3,:) = 1;
    AS2 = reshape(AS2,3,3*size(AS2,3))';
    
    Aimg2Templatei = AS1*Aimg1Inv;
    Aimg2Templatej = AS2*Aimg2Inv;
    
    q_is = F1.ps(index1_F1s,:)';
    q_js = F1.ps(index2_F1s,:)';
    
    q_jPred = Aimg2Templatei*[p_j';1];
    q_iPred = Aimg2Templatej*[p_i';1];
    
    q_jPred = reshape(q_jPred,3,length(q_jPred)/3);
    q_iPred = reshape(q_iPred,3,length(q_iPred)/3);
    
    d1 = distance_vec(q_is,q_iPred(1:2,:));
    d2 = distance_vec(q_js,q_jPred(1:2,:))';
    costValue = min(d1,d2);
    costValue=costValue./d0;
    
    if withUniticity
        da = distance_vec(q_is,q_js);
        same = da<1;
        costValue(same) = GAIM_LARGE;
    end
    edgeCosts(:,:,e) = costValue;
    
end
edgeCosts(edgeCosts>pairTrunc & edgeCosts<GAIM_LARGE) = pairTrunc;

