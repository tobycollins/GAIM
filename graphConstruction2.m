function adjacency_matrix = graphConstruction2(F2,InputImg_g,scalingFactor,visualizeGraphs,coordinatesEmpty)

x = double(F2.ps(:,1));
y = double(F2.ps(:,2));
% TRI = delaunay(x,y);
% % Create Adjacency matrix from the connections
% adjacency_matrix = tris2AdjMat(TRI, size(F2.ps,1));

visualizeGraphs=0;
%[idx, idx_dist] = knnsearch(F2.ps,F2.ps,'K',10);
[idx, idx_dist] = knnsearch(F2.ps,F2.ps,'K',14);


%adjacency_matrix = zeros(size(F2.ps,1),size(F2.ps,1));
%adjacency_matrix(:) =0;
adjacency_matrix = sparse(1,1,0,size(F2.ps,1),size(F2.ps,1));

for i=1:size(adjacency_matrix,1)
    adjacency_matrix(i,idx(i,:))=1;  
    adjacency_matrix(i,i) = 0;
end
adjacency_matrix = (adjacency_matrix+adjacency_matrix')>0;

if visualizeGraphs
    % Visualize it
    figure,imshow(InputImg_g)
    hold on
    triplot(TRI,x,y);
    f2Ind = 1; % We represent the neighbors of keypoint f2Ind
    valuesAdjacencyMatrix = adjacency_matrix(f2Ind,:);
    [I Nf x]=find(valuesAdjacencyMatrix);
    fff= F2.ps(Nf',:);
    hold on, plot(fff(:,1),fff(:,2),'ro')
    hold on, plot(F2.ps(f2Ind,1),F2.ps(f2Ind,2),'gs','MarkerSize',7);
    % Now, I want to show the points that are scalingFactor times far from the scale and I want to
    % paint them in yellow
    closeNeighbors = zeros(size(Nf));
%    for indexNf = 1:size(Nf,2)
%        closeNeighbors(indexNf) = (F2.ps(Nf(indexNf),1) - F2.ps(f2Ind,1))^2 + (F2.ps(Nf(indexNf),2) - F2.ps(f2Ind,2))^2 < (scalingFactor*F2.scales(f2Ind))^2;
%    end
    fff= F2.ps(Nf(closeNeighbors>0)',:);
    hold on, plot(fff(:,1),fff(:,2),'yx')    
    if ~isempty(coordinatesEmpty)
        hold on,plot(F2.ps(coordinatesEmpty,1),F2.ps(coordinatesEmpty,2),'g*')
        title('Delaunay triangulation in blue; keypoint 1 with a green square; its neighbors in red; "close" neighbors in red with a white cross. In green, the removed points from F2 (their GT was empty)')
    else
        title('Delaunay triangulation in blue; keypoint 1 with a green square; its neighbors in red; "close" neighbors in red with a white cross')
    end
end;