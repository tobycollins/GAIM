


function im = plot2_to_1Matches(F1, F2,img1,img2,matchedF1Inds,plotSubset,col)
fpos1 = F1.ps(matchedF1Inds,:);
fpos2 = F2.ps;
if isempty(col)
    col = 'b-';
end
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
        plot(pp(:,1),pp(:,2),col,'LineWidth',2);
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
