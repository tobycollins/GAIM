function [smoothlocal,qtemp]=LocalSmoothnessLocal(x1,y1,x2o,y2o,Neig,mu,lambda,ls,C,Epsilon_Lambda,index)
m=length(x1);
if(nargin<11)
    index=[1:m];
end

smoothlocal=zeros(1,m);

for i=index
% Move the Neig coordinates to the local reference frame.
NeighLocal=Neig{i};
% if isempty(NeighLocal)
%     smoothlocal(i) = nan;
%     continue;
%     
% end


if(length(NeighLocal)<3)
 NeighLocal=[Neig{i},Neig{Neig{i}(1)}];
 NeighLocal(find(NeighLocal==(i)))=[];
end


% Neighbours in local reference frame
x1l=x1(NeighLocal);
y1l=y1(NeighLocal);
x2l=x2o(NeighLocal);
y2l=y2o(NeighLocal);
maxx=max([x1l;x1(i)]);maxy=max([y1l;y1(i)]);minx=min([x1l;x1(i)]);miny=min([y1l;y1(i)]);
%maxx=max([x2l;x2o(i)]);maxy=max([y2l;y2o(i)]);minx=min([x2l;x2o(i)]);miny=min([y2l;y2o(i)]);
x1l=(x1(NeighLocal)-minx)./(maxx-minx);
y1l=(y1(NeighLocal)-miny)./(maxy-miny);

x2l=(x2o(NeighLocal)-minx)./(maxx-minx);
y2l=(y2o(NeighLocal)-miny)./(maxy-miny);



%qxl=(x2o(i));
%qyl=(y2o(i));
%pxl=x1(i);
%pyl=y1(i);
pxl=(x1(i)-minx)./(maxx-minx);
pyl=(y1(i)-miny)./(maxy-miny);
qxl=(x2o(i)-minx)./(maxx-minx);
qyl=(y2o(i)-miny)./(maxy-miny);
%inp_points=[minx,miny;maxx,miny;maxx,maxy;minx,maxy];
%[C,linelist]=generate_centers(ls,inp_points);  
L=TPSWfromfeatures_FBDSD([x2l,y2l],[x1l,y1l],C,mu*2,lambda,Epsilon_Lambda);
qtemp=tpswarp([pxl,pyl]',L,C,lambda,Epsilon_Lambda);
smoothlocal(i)=norm([maxx-minx,0;0,maxy-miny]*(qtemp-[qxl;qyl]));    


end

end