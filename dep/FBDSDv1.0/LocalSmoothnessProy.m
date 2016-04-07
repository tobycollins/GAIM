function [smoothlocal,qtemp]=LocalSmoothnessProy(x1,y1,x2o,y2o,Neig,index)
m=length(x1);
if(nargin<6)
    index=[1:m];
end

smoothlocal=zeros(1,m);

for i=index
% Move the Neig coordinates to the local reference frame.
NeighLocal=Neig{i};
topiter=1;
while(length(NeighLocal)<3 & topiter<length(Neig{i}))
 NeighLocal=[NeighLocal,Neig{Neig{i}(topiter)}];
 NeighLocal(find(NeighLocal==(i)))=[];
 NeighLocal=unique(NeighLocal);
 topiter=topiter+1;   
end

if(length(NeighLocal)>2)
    
% Neighbours in local reference frame
x1l=x1(NeighLocal);
y1l=y1(NeighLocal);
x2l=x2o(NeighLocal);
y2l=y2o(NeighLocal);
%colinearfactor1=svd([x1l,y1l]');
%colinearfactor2=svd([x2l,y2l]');
maxx=max([x1l;x1(i)]);maxy=max([y1l;y1(i)]);minx=min([x1l;x1(i)]);miny=min([y1l;y1(i)]);


%x1l=(x1(NeighLocal)-minx)./(maxx-minx);
%y1l=(y1(NeighLocal)-miny)./(maxy-miny);%

%x2l=(x2o(NeighLocal)-minx)./(maxx-minx);
%y2l=(y2o(NeighLocal)-miny)./(maxy-miny);

qxl=(x2o(i));
qyl=(y2o(i));
pxl=x1(i);
pyl=y1(i);
%pxl=(x1(i)-minx)./(maxx-minx);
%pyl=(y1(i)-miny)./(maxy-miny);
%qxl=(x2o(i)-minx)./(maxx-minx);
%qyl=(y2o(i)-miny)./(maxy-miny);
inp_points=[minx,miny;maxx,miny;maxx,maxy;minx,maxy];
T=cp2tform([x1l,y1l],[x2l,y2l],'affine');
H=T.tdata.T;
qtemp=H'*[pxl;pyl;1]; qtemp=[qtemp(1);qtemp(2)]./qtemp(3);
smoothlocal(i)=norm(qtemp-[qxl;qyl]);%./norm([maxx-minx;maxy-miny]);    
else
smoothlocal(i)=Inf;
qtemp=[x2o(i);y2o(i)]';
end

end

end