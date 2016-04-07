function [x1,y1,x2,y2]=SIFTFeatures(I1,I2,input_points)
if nargin<3
    minx = 0;
    maxx = inf;
    miny = 0;
    maxy = inf;
    
else
    minx=min(input_points(:,1));
    maxx=max(input_points(:,1));
    miny=min(input_points(:,2));
    maxy=max(input_points(:,2));
end

[F1,D1]=vl_sift(single(rgb2gray(I1)));
[F2,D2]=vl_sift(single(rgb2gray(I2)));
[matches]=vl_ubcmatch(D1,D2);

A=matches(1,:);
B=matches(2,:);
[Ap,I,J]=unique(A);
Bp=B(I);
[Bpp,I,J]=unique(Bp);
App=Ap(I);

matches=[App;Bpp];

x1=F1(1,matches(1,:));
y1=F1(2,matches(1,:));
x2=F2(1,matches(2,:));
y2=F2(2,matches(2,:));
indices=find(x1>minx & x1< maxx);
x1=x1(indices);y1=y1(indices);x2=x2(indices);y2=y2(indices);
indices=find(y1>miny & y1< maxy);
x1=x1(indices);y1=y1(indices);x2=x2(indices);y2=y2(indices);


P=[x1;y1]';
Q=[x2;y2]';
[Pp,I,J]=unique(P,'rows');
Qp=Q(I,:);
x1=Pp(:,1);
y1=Pp(:,2);
x2=Qp(:,1);
y2=Qp(:,2);
if nargin<3
    
else
    bw = poly2mask(input_points(:,1),input_points(:,2),size(I1,1),size(I1,2));
    %imwrite(bw,'grafitti/lowbase.roi','jpg');
    [x1,y1,indexrows]=filter_matches(x1,y1,bw);
    x2=x2(indexrows);
    y2=y2(indexrows);
end
