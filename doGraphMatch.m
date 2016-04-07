
function LSelect = doGraphMatch(F1,F2,K,methodDescript,pairMethod,graphParams,gOptMethods)



if strcmp(methodDescript.fExtractMethod,'simulation')
    withNoOverlap=1;
else
    withNoOverlap=0;
end
useFlann = 1
[Ls, idx_dist,tme] = obtainKbestmatches(F1,F2,K,useFlann,withNoOverlap);


adjacency_matrix = graphConstruction2(F2);

tic
[Solution] = undirectedGraphOptimization3(Ls,idx_dist,size(Ls,2),adjacency_matrix,F1,F2,pairMethod,graphParams,gOptMethods,methodDescript.descriptMethod);
toc
LSelect = zeros(size(Ls,1),1);
for i=1:length(LSelect)
    LSelect(i) =  Ls(i,Solution(i));
end