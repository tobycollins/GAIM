function [Solution] = GAIM_solveGraph(L,LCosts,A,F1,F2,matchOpts)
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
% GAIM_solveGraph: Solves the GAIM MRF by discrete optimisation.
%
%Inputs:
%L: NxnumLabels matrix holding the candidate label sets, where N is the number of
%keypoint in F2 and numLabels is the candidate-set size.
%
%LCosts: NxnumLabels matrix holding the unary costs associated with each label.
%
%A: A sparse NxN connectivity matrix (where N is the number of keypoints in F).
%
%F1: Structure holding keypoint and descriptor data for image 1.
%
%F2: Structure holding keypoint and descriptor data for image 2.
%
%matchOpts: Structure holding the matching options. See parseMatchOpts.m
%for details. 
%
%Outputs:
%
%Solution: A Nx1 vector storing the graph's solution

global GAIM_verbose;
global GAIM_LARGE;

numLabels = size(L,2);

edgeStruct = UGM_makeEdgeStruct(A,numLabels);

nodecost = double(LCosts*matchOpts.wUnary);
tic;
edgeCosts = GAIM_edgePotentials(edgeStruct,L,F1,F2,matchOpts.pairTrunc);
timeEdgePots = toc;
if GAIM_verbose
    disp(['Time to compute edge potentials: ' num2str(timeEdgePots) 's.'])
end

e1s= edgeStruct.edgeEnds(:,1);
e2s= edgeStruct.edgeEnds(:,2);
PI = uint32([e1s,e2s;e2s,e1s]');

switch matchOpts.MRF_solve_method
    case 'LBP'
        edgePot = exp(-edgeCosts);
        nodePot = exp(-nodecost);
        tic;
        Solution = UGM_Decode_LBP(nodePot,edgePot,edgeStruct);
        tm = toc;
        if GAIM_verbose
            disp(['Time to solve MRF: ' num2str(tm) 's.'])
        end
        clear edgePot nodePot;
    case 'AE'
        L0 = ones(size(nodecost,1),1);
        tic;
        [Solution] = MRF_solveAlphaExpansion(L0,nodecost,edgeCosts,PI);
        tm = toc;
        if GAIM_verbose
            disp(['Time to solve MRF: ' num2str(tm) 's.'])
        end
        
   case 'AE_LBP_fuse' %this first solves the graph with LBP and AE, then does a fusion move to combine the solutions. Finally, AE is run a final time on the fused solution. 
        edgePot = exp(-edgeCosts);
        nodePot = exp(-nodecost);
        tic;
        L0 = UGM_Decode_LBP(nodePot,edgePot,edgeStruct);
        L1 = MRF_solveAlphaExpansion(ones(size(nodecost,1),1),nodecost,edgeCosts,PI);
        L = fuseQPBO(L0,L1,nodecost, size(nodecost,1),edgeCosts,PI);
        Solution = MRF_solveAlphaExpansion(L,nodecost,edgeCosts,PI,0);
        tm = toc;
        if GAIM_verbose
            disp(['Time to solve MRF: ' num2str(tm) 's.'])
        end    
        clear edgePot nodePot;
end