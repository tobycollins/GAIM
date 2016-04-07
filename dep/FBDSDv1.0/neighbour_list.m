function Neig=neighbour_list(TRI,m)
% Obtain the neighbours of a vertex.
% N=connection_list(TRI,m);
% 
% Neig=[];
% for i=[1:m]
% triangles=N{i};
% vec=[];
% for j=[1:length(triangles)]
%     neigs=TRI(triangles(j),:);
%     neigs(find(neigs==i))=[];
%     if(isempty(find(vec==neigs(1))))
%     vec=[vec,neigs(1)];
%     end
%     if(isempty(find(vec==neigs(2))))
%     vec=[vec,neigs(2)];
%    end
%  
% end
% 
%   Neig{i}=vec; 

%end

E1 = [TRI(:,1),TRI(:,2)];
E2 = [TRI(:,1),TRI(:,3)];
E3 = [TRI(:,2),TRI(:,3)];
S1 = sparse(E1(:,1),E1(:,2),1,m,m);
S2 = sparse(E2(:,1),E2(:,2),1,m,m);
S3 = sparse(E3(:,1),E3(:,2),1,m,m);
S = S1+S2+S3;
S = S+S';
Neig = sparseMat2Cell(S,1);
Neig = Neig';


