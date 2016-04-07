function [Cinds,Cvals] = sparseMat2Cell(A,dim)
%converts a sparse matrix to a cell array along dimension dim
%e.g. if size(A) = [m,n] then length(C) = m;
%returns index/value pairs

switch dim
    case 1
        A = A';
        [Cinds,Cvals] = sparseMat2Cell(A,2);
    case 2
        Cinds = cell(size(A,2),1);
        Cvals = cell(size(A,2),1);
        
        for ii=1:size(A,2)
            %g1 = nonzeros(A(:,ii));
            
            [g,tmp,vals] = find(A(:,ii));
            Cinds{ii} = g';
            Cvals{ii} = vals';  
            
            
        end
    
end