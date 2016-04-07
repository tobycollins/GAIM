function [LRDists,procTime,imMatches,imLRC] = LRConstCheck(F1, F2,F2WithSynth,img1,img2,matchedF1Inds,K,methodDescript,pairMethod,graphParams,gOptMethods)
%close all;
% figure(1);
% clf;
% imshow(img1);
% hold on;
% r4= roipoly();
% save r4 r4;


%load r4; r = r4;
 fpos1 = F1.ps(matchedF1Inds,:);
% ins = interp2(double(templateMask),fpos1(:,1),fpos1(:,2))>0.5;

ins = logical(ones(size(fpos1,1),1));


imMatches = plot2_to_1Matches(F1, F2,img1,img2,matchedF1Inds,ins);

uniqueTol = 20;
psF1 = F1.ps(matchedF1Inds,:);
[vecsSel,indx,clusters] = uniquifyvecs_greedy(psF1',uniqueTol);
psF2_uniqued = F2.ps(indx,:);

matchedF1Inds_sub = matchedF1Inds(indx);
F1_sub.ps = F1.ps(matchedF1Inds_sub,:);
F1_sub.ds = F1.ds(matchedF1Inds_sub,:);
F1_sub.AAnpd = F1.AAnpds_origImg(:,:,matchedF1Inds_sub);



% F2_.ps = F2.ps;
% F2_.ds = F2.ds;
% F2_.AAnpds_origImg = F2.AAnpd;
% dataset = single(F2_.ds)';
% index = flann_build_index(dataset,struct('algorithm','kdtree','trees',8));
% F2_.flanIndex = index;
            
F2_ = F2WithSynth.F1;


tic;
LSelect = doGraphMatch(F2_,F1_sub,K,methodDescript,pairMethod,graphParams,gOptMethods);
procTime = toc;
psF2_check = F2_.ps(LSelect,:);

numPtsF2 = size(F2.ps,1);
LRDists = zeros(numPtsF2,1);
for i=1:numPtsF2
   p =  F2.ps(i,:);
   dd = distance_vec(psF2_uniqued',p');
   [mm,mn] = min(dd);
   p2 = psF2_check(mn,:);
   LRDists(i) = norm(p2-p);
    
end

imLRC = plot2_to_1Matches(F1, F2,img1,img2,matchedF1Inds,ins&LRDists<20);








function im = plot2_to_1Matches(F1, F2,img1,img2,matchedF1Inds,plotSubset)
fpos1 = F1.ps(matchedF1Inds,:);
fpos2 = F2.ps;

if isempty(plotSubset)
    
else
   fpos1 = fpos1(plotSubset,:);
   fpos2 = fpos2(plotSubset,:);
end
   

imtW = size(img1,2);
imbComb = cat(2,img1,imresize(img2,[size(img1,1),size(img1,2)]));

    figure(10);
    clf;
    imshow(imbComb);
    hold on;
    %     fposImgiNew(i,1) = (fposImgi(i,1)*size(templageImgG,1))/size(InputImg_g,1);
    %     fposImgiNew(i,2) = (fposImgi(i,2)*size(templageImgG,2))/size(InputImg_g,2);
    for i=1:size(fpos1,1)
        pp = [ fpos1(i,:);[fpos2(i,1)*size(img1,2)/size(img2,2)+imtW,fpos2(i,2)*size(img1,1)/size(img2,1)]];
        plot(pp(:,1),pp(:,2),'b-','LineWidth',2);
    end
    im = img_saveModified(gcf,size(imbComb,2),size(imbComb,1));
    
%     allPts = [];
%     for i=1:size(fposTemplatei,1)
%         allPts = [allPts;fposImgi(i,1)*size(templageImgG,2)/size(InputImg_g,2)+imtW,fposImgi(i,2)*size(templageImgG,1)/size(InputImg_g,1)];
%     end
%     
%     x = double(allPts(:,1));
%     y = double(allPts(:,2));
%     TRI = delaunay(x,y);
%     
%     hold on
%     triplot(TRI,x,y,'-r', 'LineWidth', 2);
