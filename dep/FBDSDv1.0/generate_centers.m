function [C,linelist]=generate_centers(ls,input_points)
%%%Obtain four corners in a reference plane x in [0,1] y in [0 1]
base_points=[0,0;1,0;1,1;0,1];
%%% Obtain homograpy between clicked points and the ref plane
T=cp2tform(input_points,base_points,'projective');
H=T.tdata.Tinv;
l=ls*ls;
delta=1/(ls-1);
C=[];   
linelist=zeros(ls*ls,2);
for i=[1:ls]
    for j=[1:ls]
        C=[C;[delta*(i-1),delta*(j-1),1]];
        if(i<ls)
        linelist((i-1)*(ls)+j,1)=(i)*ls+j;
        end
        if(j<ls)
        linelist((i-1)*(ls)+j,2)=(i-1)*ls+j+1;
        end
    end
end
%%% Obtain centers of the spline in vector C
C=C*H;
C=[C(:,1)./C(:,3),C(:,2)./C(:,3)];

