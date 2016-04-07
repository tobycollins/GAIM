function outs = outliersDanielWithInitLabel(ps1,ps2,thresh,initInliers)
x1 = ps1(:,1);
y1 = ps1(:,2);

x2 = ps2(:,1);
y2 = ps2(:,2);

if isempty(thresh)
    thresh = 20;
end

x1 = x1+rand(length(x1),1)*1e-5;
y1 = y1+rand(length(y1),1)*1e-5;



% Perform delaunay triangulation of the points
TRI=delaunay(x1,y1);
m=length(x1);
% Generate neighbour list for each point
Neig=neighbour_list(TRI,m);
% Outlier Detection with 3DPVT method
% DetectOutliers(x1,y1,x2,y2,Neig,mu,lambda,ls,threshold);
% mu =>is a smoothing parameter (0.55 is a good value).
% lambda => Thin Plate Spline (TPS) internal smoothing (0.001 is a good value).
% ls => lsxls centers used in the TPS. (use 5 or 3)
% threshold => (IMPORTANT PARAMETER) threshold used to consider when a point is an inlier. I recommend to
% use a value around 5-30 pixels. if threshold is very small you discard
% many inliers.



inliers=DetectOutliersWithInitInliers(x1,y1,x2,y2,Neig,0.55,0.001,5,thresh,initInliers);



outs =ones(1,length(x1));
outs(inliers) = 0;
outs = outs(:);

%outs = find(outs);



