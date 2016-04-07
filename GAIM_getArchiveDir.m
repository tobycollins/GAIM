function archiveDir = GAIM_getArchiveDir(dr,archiveFiles)
% This file is part of the GAIM package for graph-based keypoint matching
% from the paper "An Analysis of Errors in Graph-based Keypoint Matching
% and Proposed Solutions", Collins, Mesejo and Bartoli, ECCV 2014. GAIM
% tackles the general keypoint-based graph matching problem for two images. It does not require prior knowledge about
% the number of objects in the scene, the amount of occlusion, the amount of background clutter, and object topology (which changes
% between the images if e.g. an object tears). Please cite this paper if you are using any part of this code in your work.
% This is free software covered by the GPLv3 License.
%
% Copyright (c) 2014 Toby Collins and Pablo Mesejo
%  This is a helper function used by setGAIMDependencies to get the root
%  directory of a downloaded source code archive
hs = [];
archiveDirs = {};
for i=1:length(archiveFiles)
    df = archiveFiles{i}(length(dr)+1:end);
    ff = strfind(df,'\');
    df(ff) = '/';
    ff = strfind(df,'/');
    if length(ff)<2
        continue;
    end
    p = df(ff(1)+1:ff(2)-1);
    h = string2hash(p);
    if isempty(hs)
        hs(1) = h;
        archiveDirs{1} = p;
    else
        if sum(hs==h)==0
            hs(end+1) = h;
            archiveDirs(end+1) = p;
        end
    end
    
end
if length(archiveDirs)==0
    error('Archive file did not have a root directory');
    
end
if length(archiveDirs)>1
    error('Archive file had more than one root directory');
    
end
archiveDir = archiveDirs{1};
