function outs = FBDSD_refineInliers(ps1,ps2,thresh,initInliers)
x1 = ps1(:,1);
y1 = ps1(:,2);
x2 = ps2(:,1);
y2 = ps2(:,2);
if isempty(thresh)
    thresh = 20;
end
%a little hack to ensure that the points are not perfect duplicates:
x1 = x1+rand(length(x1),1)*1e-5;
y1 = y1+rand(length(y1),1)*1e-5;
%inliers=FBDSDWithInitInliers(x1,y1,x2,y2,0.55,0.001,3,thresh,initInliers,5);
%inliers=FBDSDWithInitInliers(x1,y1,x2,y2,0.95,0.001,3,thresh,initInliers,5);
inliers=FBDSDWithInitInliers(x1,y1,x2,y2,2,0.001,3,thresh,initInliers,5);

outs =ones(1,length(x1));
outs(inliers) = 0;
outs = logical(outs(:));

