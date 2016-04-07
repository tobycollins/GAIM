function [edgePot,edgeCosts] = calculateEdgePotential6(edgeStruct,numLabels,L,F1,F2,pairwisePotential,threshold,featureMethod)
edgePot=[];
withUniticity = 1;

maxState = max(edgeStruct.nStates);
edgeCosts =  zeros(maxState,maxState,edgeStruct.nEdges,'double');

F1.AAnpds_origImg;
AAnpds_origImgT =F1.AAnpds_origImg;
AAnpds_origImgT(3,3,:) = 1;
for ii=1:size(AAnpds_origImgT,3)
   A =  AAnpds_origImgT(:,:,ii);
   AAnpds_origImgT(:,:,ii) = A';    
end
if pairwisePotential == 1 % Collins-Mesejo potential
    for e = 1:edgeStruct.nEdges
        % Pick the nodes in the edge
        [edgePoints] = edgeStruct.edgeEnds(e,:);
        p_i = F2.ps(edgePoints(1,1),:);
        p_j = F2.ps(edgePoints(1,2),:);
        
        d0 = p_i-p_j;
        d0 = sqrt(d0*d0');
        
        
        Aimg1 = F2.AAnpd(:,:,edgePoints(1,1));
        Aimg1(3,3) = 1;
        Aimg1Inv = inv(Aimg1);
                
        Aimg2 = F2.AAnpd(:,:,edgePoints(1,2));
        Aimg2(3,3) = 1;
        Aimg2Inv = inv(Aimg2);      
        % For such nodes, try all combinations of labels and calculate the cost
        
        index1_F1s = L(edgePoints(1,1),:);
        index2_F1s = L(edgePoints(1,2),:);
        
        AS1 = AAnpds_origImgT(:,:,index1_F1s);
        AS1(3,3,:) = 1;        
        AS1 = reshape(AS1,3,3*size(AS1,3))';
        
        AS2 = AAnpds_origImgT(:,:,index2_F1s);
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
        %costValue = mean(cat(3,d1,d2),3);
        if withUniticity
         da = distance_vec(q_is,q_js);
        same = da<1;
            costValue(same) = 1e6;
        end
        edgeCosts(:,:,e) = costValue;    

    end
    edgeCosts(edgeCosts>threshold) = threshold;
    
elseif pairwisePotential == 2 %Torresani potential
    %threshold2 = 0.5;
    for e = 1:edgeStruct.nEdges
        % Pick the nodes in the edge
        [edgePoints] = edgeStruct.edgeEnds(e,:);
        p_i = F2.ps(edgePoints(1,1),:);
        p_j = F2.ps(edgePoints(1,2),:);
        
        d0 = p_i-p_j;
        d0 = sqrt(d0*d0');
        index1_F1s = L(edgePoints(1,1),:);
        index2_F1s = L(edgePoints(1,2),:);
        
        
        qs_i = F1.ps(index1_F1s,:);
        qs_j = F1.ps(index2_F1s,:);
        dd = distance_vec(qs_i',qs_j');
        C = abs(dd-d0);
        C=C./d0;
        
        
        
        
        C(C>threshold) = threshold;
        if withUniticity
        same = dd<1;
        C(same) = 1e6;
        end
        edgeCosts(:,:,e) = C;
    end
    
    
end