function [idx, idx_dist,tme] = obtainKbestmatches(F1, F2, numLabels,useFlann,withNoOverlap)
%tol = 15;
tol =4;

%numChecks = 128;
numChecks = 15;

%withNoOverlap = 1;

%useFlann = 1;
% dataset = single(F1.d)';
testset = single(F2.ds)';
% build_params.target_precision = 1;
% build_params.build_weight = 0.01;
% build_params.memory_weight = 0;
%[index, parameters] = flann_build_index(dataset, build_params);
%[index, parameters] = flann_build_index(dataset, struct('algorithm','kdtree','trees',8));

%[idx idx_dist] = flann_search(index,testset,numLabels,parameters);
if withNoOverlap==0
    tic;
    if useFlann
        [idx, idx_dist] = flann_search(F1.flanIndex,testset,numLabels,struct('checks',numChecks));
        idx=idx';
        idx_dist=idx_dist';
    else
        [idx, idx_dist] = knnsearch(F1.ds,F2.ds,'K',numLabels);
    end
    tme = toc;  
else
     tic;
    numF2 = size(F2.ps,1);
    %  Select Label Set using K-Nearest Neighbors
    maxK = min(numLabels*10,size(F1.ds,1));
    if maxK==size(F1.ds,1)
        useFlann=0;
        
    end
    if useFlann
        [L_1, idx_dist] = flann_search(F1.flanIndex,testset,maxK,struct('checks',numChecks));
        L_1=L_1';
        idx_dist=idx_dist';
    else
        [L_1, idx_dist] = knnsearch(F1.ds,F2.ds,'K',numLabels*10);
    end
     tme = toc;  
    
    
    
    L_ini = zeros(numF2,numLabels);
    for i=1:numF2
        lsRem = L_1(i,:);
        dsRem = idx_dist(i,:);
        pSelect = [1;1]*-inf;
        
        %L_ini(i,1) = ls(1);
        %ls = setdiff(ls,ls(1));
        %pSelect = featDataTrain.F1.ps(L_ini(i,1),:);
        
        trm = false;
        cnt = 0;
        while trm==false
            
            %dd = distance_vec(pSelect,F1.ps(lsRem,:)');
            %vld = (dd>tol);
            
            dd2_ = ((pSelect(1)-F1.ps(lsRem,1)).^2 + (pSelect(2)-F1.ps(lsRem,2)).^2)';
            vld = (dd2_>tol^2);
            
            
            lsRem = lsRem(vld);
            dsRem= dsRem(vld);
            if isempty(lsRem)
                L_ini(i,cnt+1:end) = 1;
                trm = true;
            else
                
                
                [mm,mn] = min(dsRem);
                cnt = cnt+1;
                L_ini(i,cnt) = lsRem(mn);
                pSelect =F1.ps(L_ini(i,cnt),:)';
                if cnt==numLabels
                    trm = true;
                end
            end
            
            
            
        end
%         qs = F1.ps(L_ini(i,:),:);
%         figure(4);
%         clf;
%         imshow(imgTemplate);
%         hold on;
%         plot(qs(:,1),qs(:,2),'r.');
%         axis equal;
%         figure(5);
%         clf;
%         imshow(imgIn);
%         hold on;
%         plot(F2.ps(i,1),F2.ps(i,2),'r.');
%         axis equal;
%         ''
        
        
    end
    idx = L_ini;
    idx_dist = zeros(numF2,numLabels);
    for i=1:numF2
        ls = idx(i,:);
        dd = distance_vec(F2.ds(i,:)',F1.ds(ls,:)');
        idx_dist(i,:) = dd;
        
    end
    
end
return;



%[idx, idx_dist] = knnsearch(F1.ds,F2.ds,'K',numLabels);
%return;
%[idx_, idx_dist_] = knnsearch(F1.ds,F2.ds(1,:),'K',numLabels);

%kdtree = vl_kdtreebuild(single(F1.ds'), 'NumTrees', 4) ;
%[idx, idx_dist] = vl_kdtreequery(F1.kdtree, single(F1.ds'), single(F2.ds'),'NumNeighbors', numLabels,'MAXNUMCOMPARISONS', numLabels) ;
tic;
[idx, idx_dist] = vl_kdtreequery(F1.kdtree, single(F1.ds'), single(F2.ds'),'NumNeighbors', numLabels,'MAXNUMCOMPARISONS', 100) ;
toc;

%[idx, idx_dist] = vl_kdtreequery(F1.kdtree, single(F1.ds'), single(F2.ds'),'NumNeighbors', numLabels) ;



idx = idx';
idx_dist=idx_dist';
[ss,sb] = sort(idx_dist,2);
for ii=1:size(idx,1)
    idx(ii,:) = idx(ii,sb(ii,:));
    
end
idx_dist = ss;

return;


%
% indexStruct = struct; %struct('algorithm','kdtree','trees',8)
% searchStruct = struct('checks',1000);
%
% flann_set_distance_type('euclidean');
% index = flann_build_index(dataset,indexStruct);
%

%index = F1.flanIndex;




%
% tic;
% if nargout ==2
%     [idx idx_dist] = flann_search(index,testset,numLabels,searchStruct);
% else
%     [idx] = flann_search(index,testset,numLabels,searchStruct);
% end

toc
idx=idx';
idx_dist=idx_dist';
''

% ''
%
% build_params = struct('algorithm','kdtree','trees',8);
%     [index, params, speedup] = flann_build_index(single(featDataTrain.F1.ds)',build_params);
%
% %result = flann_search(featDataTrain.F1.flann.index,single(F2.ds'),numLabels,struct('checks',128));
% op = struct('checks',128);
% result = flann_search(index,single(F2.ds)',numLabels,op);

%% Direct KNN
%tic;
%[idx, idx_dist] = knnsearch(featDataTrain.F1.ds,F2.ds,'K',numLabels);
%toc

%     %% Using F1.kbest
%     [idx_temp, ~] = knnsearch(featDataTrain.F1.ds,F2.ds,'K',1);
%     for i=1:length(F2.LocationImage)
%         idx(i,:) = featDataTrain.F1.kbest{idx_temp}(1:numLabels);
%     end

% %% Using F1.kbest in F2
% marginRng = 5;
% treePositions = kdtree(featDataTrain.F1.ps);
% idx = zeros(length(F2.LocationImage),numLabels);
% idx_dist = zeros(length(F2.LocationImage),numLabels); % We do not care about this!
%
% for i = 1:length(F2.LocationImage) % for every point in F2
%     numLabelsTemp = 2;
%     % Select closest point from F2 in F1 in terms of descriptors
%     [idxT, ~] = knnsearch(featDataTrain.F1.ds,F2.ds(i,:),'K',numLabelsTemp);
%
%     % Get overlapping points for idx
%     rng = [featDataTrain.F1.ps(idxT(1),1)-marginRng,featDataTrain.F1.ps(idxT(1),1)+marginRng;featDataTrain.F1.ps(idxT(1),2)-marginRng,featDataTrain.F1.ps(idxT(1),2)+marginRng];
%     overlapping_pnts = kdtree_range(treePositions,rng);
%     overlapping_pnts = overlapping_pnts(overlapping_pnts~=idxT(1)); %range of overlapping points for the F1 point
%     idx(i,1) = idxT(1);
%     %idx_dist(i,1) = idx_distT(1);
%     idxT = idxT(2);
%     %idx_distT = idx_distT(2);
%     for j = 2:numLabels
%         invalidPoint = 1;
%         while invalidPoint
%             if ~ismember(idxT,overlapping_pnts)
%                 invalidPoint = 0;
%                 idx(i,j) = idxT;
%                 %idx_dist(i,j) = idx_distT;
%                 rng = [featDataTrain.F1.ps(idxT,1)-marginRng,featDataTrain.F1.ps(idxT,1)+marginRng;featDataTrain.F1.ps(idxT,2)-marginRng,featDataTrain.F1.ps(idxT,2)+marginRng];
%                 overlapping_pnts2 = kdtree_range(treePositions,rng);
%                 overlapping_pnts2 = [overlapping_pnts,overlapping_pnts2(overlapping_pnts2~=idxT)];
%                 overlapping_pnts = unique(overlapping_pnts2);
%             end
%             numLabelsTemp = numLabelsTemp + 1;
%             [idxT2, ~] = knnsearch(featDataTrain.F1.ds,F2.ds(i,:),'K',numLabelsTemp);
%             idxT = idxT2(end);
%             %idx_distT = idx_distT2(end);
%         end
%     end
% end

