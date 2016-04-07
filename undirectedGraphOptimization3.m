function [Solution,timeEdgePots,timeInference,edgePot,edgeCosts,edgeStruct] = undirectedGraphOptimization3(L,LCosts,numLabels,adjacency_matrix,F1,F2,pairwiseMethod,params,optMethods,featureMethod)
% Using the Matlab code for undirected graphical models (http://www.di.ens.fr/~mschmidt/Software/UGM/small.html)

w = params.wUnary;

nStates = numLabels;
edgeStruct = UGM_makeEdgeStruct(adjacency_matrix,nStates);
numNodes = size(adjacency_matrix,1);

nodecost = double(LCosts*w);
nodePot = exp(-nodecost);




% nodecost = LCosts/10;
% nodePot = exp(-LCosts/700);
% nodePot = nodePot*1000;

if strcmp(pairwiseMethod,'Torresani')
    pind = 2;
else
    pind = 1;
end
%switch pairwiseMethod
tic;
[tmp,edgeCosts] = calculateEdgePotential6(edgeStruct,numLabels,L,F1,F2,pind,params.threshold,featureMethod);
timeEdgePots = toc;

%case 'Torresani'
%    [edgePot,edgeCosts] = calculateEdgePotential6(edgeStruct,numLabels,L,featDataTrain,F2,2,featureMethod);
%case 'GAIM-G'
%tic;
%[edgePot,edgeCosts] = calculateEdgePotential5(edgeStruct,numLabels,L,featDataTrain,F2,1,featureMethod);
%t1 = toc;

%''
%end
%
% % We use the potentials to:
% % - Select bad edges
% indexesBadEdges = detectBadEdgesPot(edgePot);
% % - Remove the nodes connected only by bad edges
% indexesNodesToRemove = detectNodesBadConnected(indexesBadEdges,edgeStruct);
if iscell(optMethods)
    
else
    o{1} = optMethods;
    optMethods =o;
end
timeInference = zeros(length(optMethods),1);
for ii=1:length(optMethods)
    optMethod = optMethods{ii};
    switch optMethod
        case 'BP'
            % In UGM Graph Cuts is only implemented for sub-modular potentials, and the
            % Integer and Linear Programming methods for large matrices give 'Out of
            % memory' errors. Iterated Conditional Modes and Greedy Local Search work but obtain very poor results.
            % Tree-Reweighted Belief Propagation didn't converge.
            % % Loopy Belief Propagation
            edgePot = exp(-edgeCosts);
            
            tic;
            decodeLBP = UGM_Decode_LBP(nodePot,edgePot,edgeStruct);
            timeInference(ii) = toc;
            
            if nargout<4
                clear edgePot
            end
            Solution(:,ii) = decodeLBP;
        case 'alpha'
            tic;
            Solution(:,ii) = MRF_solveAlphaExpansion([],double(nodecost),edgeCosts,edgeStruct);
            %             try
            %             Solution(:,ii) = MRF_solveAlphaExpansion(Solution(:,ii-1),double(nodecost),edgeCosts,edgeStruct);
            %             catch
            %                decodeLBP = UGM_Decode_LBP(nodePot,edgePot,edgeStruct);
            %                Solution(:,ii) = MRF_solveAlphaExpansion(decodeLBP,double(nodecost),edgeCosts,edgeStruct);
            %             end
            %
            timeInference(ii) = toc;
    end
end
if nargout<4
    clear edgePot edgeCosts
end

% % S is the solution to the matching we have obtained. It contains the
% % indexes of the label Set L. it goes from 1 to numLabels.
% % L is the label set obtained using K-best matches
% Solution = ones(size(L,1),1);
