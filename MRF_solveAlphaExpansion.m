function  Solution = MRF_solveAlphaExpansion(initL,nodecost,edgeCosts,PI)
numL = size(nodecost,2);
numNodes = size(nodecost,1);
if isempty(initL)
L0 = round(rand(numNodes,1)*(numL-1))+1;
L0(:) = 1;
else
    L0 = initL;
end
errBest = inf;
for i=1:1
     Lord = [1:numL];
%     if i==1
%         Lord = [1:numL];
% 
%     else
%         Lord = randperm(numL);
%     end
[S,err] = genSolution(PI,L0,nodecost,edgeCosts,numL,numNodes,Lord);
if err<errBest
   Solution = S;
   errBest = err;
end
end

function [S,err] = genSolution(PI,L0,nodecost,edgeCosts,numL,numNodes,Lord)
term = false;
itc = 0;

numSweeps = 0;
err = inf;
maxIter = 50;
while term==false
     Lord = randperm(numL);
    numSweeps = numSweeps+1;
    if numSweeps>maxIter
        break;
    end
    sweepCost = err;
    for i=Lord
        itc = itc+1;
        L1 = L0*0+i;
        is1 = sub2ind(size(nodecost),[1:numNodes]',L0);
        Ue1 = nodecost(is1);
        
        is2 = sub2ind(size(nodecost),[1:numNodes]',L0*0+i);
        Ue2 = nodecost(is2);
        UE = [Ue1,Ue2]';
        
        v1=  edgeCosts(sub2ind(size(edgeCosts),L0(PI(1,1:size(edgeCosts,3))),L0(PI(2,1:size(edgeCosts,3))),[1:size(edgeCosts,3)]'));
        v2=  edgeCosts(sub2ind(size(edgeCosts),L0(PI(1,1:size(edgeCosts,3))),L1(PI(2,1:size(edgeCosts,3))),[1:size(edgeCosts,3)]'));
        v3=  edgeCosts(sub2ind(size(edgeCosts),L1(PI(1,1:size(edgeCosts,3))),L0(PI(2,1:size(edgeCosts,3))),[1:size(edgeCosts,3)]'));
        v4=  edgeCosts(sub2ind(size(edgeCosts),L1(PI(1,1:size(edgeCosts,3))),L1(PI(2,1:size(edgeCosts,3))),[1:size(edgeCosts,3)]'));
        
        q1=  edgeCosts(sub2ind(size(edgeCosts),L0(PI(2,1:size(edgeCosts,3))),L0(PI(1,1:size(edgeCosts,3))),[1:size(edgeCosts,3)]'));
        q2=  edgeCosts(sub2ind(size(edgeCosts),L0(PI(2,1:size(edgeCosts,3))),L1(PI(1,1:size(edgeCosts,3))),[1:size(edgeCosts,3)]'));
        q3=  edgeCosts(sub2ind(size(edgeCosts),L1(PI(2,1:size(edgeCosts,3))),L0(PI(1,1:size(edgeCosts,3))),[1:size(edgeCosts,3)]'));
        q4=  edgeCosts(sub2ind(size(edgeCosts),L1(PI(2,1:size(edgeCosts,3))),L1(PI(1,1:size(edgeCosts,3))),[1:size(edgeCosts,3)]'));
        
        err = sum(v1)+sum(q1)+sum(Ue1);
        
        PE = [[v1';v2';v3';v4'],[q1';q2';q3';q4']];
        [L stats] = vgg_qpbo(UE, PI, PE);
        
        L0_new = L0;
        
        L0_new(L==1) = i;
        %df = norm(L0_new-L0);
        %if norm(L0_new-L0)==0
        %    term = true;
        %    break;
        %end
        L0 = L0_new;
    end
    if sweepCost==err
        term = true;
    end
end
S = L0;