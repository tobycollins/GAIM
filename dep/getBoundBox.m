function bb = getBoundBox(imSize,px,py)

if nargin==1
    bb.x = [1,size(imSize,2)];
    bb.y = [1,size(imSize,1)];
    return;
    
end
mm_min(1) =min(px);
mm_min(2) =min(py);

mm_max(1) =max(px);
mm_max(2) =max(py);

%truncation:
if ~isempty(imSize)
if mm_min(1)<1
    mm_min(1)=1;   
end
if mm_min(2)<1
    mm_min(2)=1;   
end
if mm_max(1)>imSize(2)
    mm_max(1)=imSize(2);
end
if mm_max(2)>imSize(1)
    mm_max(2)=imSize(2); 
end
end
bb.x = [mm_min(1),mm_max(1)];
bb.y = [mm_min(2),mm_max(2)];