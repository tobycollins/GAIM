function indices=DetectOutliersProy(x1,y1,x2o,y2o,Neig,th)
if(nargin<6)
th=20;
%th=0.15;
end
% Generate spline control points in a reference frame [0,1;1,0];
BoundPoints=[0,0;1,0;1,1;0,1];
smoothlocal=LocalSmoothnessProy(x1,y1,x2o,y2o,Neig);
m=length(x1);
for iter=1:4
x1t=x1(find(smoothlocal<=th));
y1t=y1(find(smoothlocal<=th));
x2ot=x2o(find(smoothlocal<=th));
y2ot=y2o(find(smoothlocal<=th));
mt=length(x1t);
if(mt>2)
for i=[1:m]
    if(smoothlocal(i)>th)
TRIt=delaunay([x1t;x1(i)],[y1t;y1(i)]);
%TRIt=filter_triangulation(TRIt,[x1t;x1(i)],[y1t;y1(i)]);
Neigt=neighbour_list(TRIt,mt+1);        

[norma,qtemp]=LocalSmoothnessProy([x1t;x1(i)],[y1t;y1(i)],[x2ot;x2o(i)],[y2ot;y2o(i)],Neigt,mt+1);

     if(norma(mt+1)<smoothlocal(i))
         smoothlocal(i)=norma(mt+1);
     end
           
            
  end

end
end
end
indices=find(smoothlocal<=th);
