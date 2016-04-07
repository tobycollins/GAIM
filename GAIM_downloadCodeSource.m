function archiveDirName = GAIM_downloadCodeSource(url,targetPath,libName)
% This file is part of the GAIM package for graph-based keypoint matching
% from the paper "An Analysis of Errors in Graph-based Keypoint Matching
% and Proposed Solutions", Collins, Mesejo and Bartoli, ECCV 2014. GAIM
% tackles the general keypoint-based graph matching problem for two images. It does not require prior knowledge about
% the number of objects in the scene, the amount of occlusion, the amount of background clutter, and object topology (which changes
% between the images if e.g. an object tears). Please cite this paper if you are using any part of this code in your work.
% This is free software covered by the GPLv3 License.
%
% Copyright (c) 2014 Toby Collins and Pablo Mesejo
%  This is a helper function used by setGAIMDependencies to download a
%  local copy of a source archive file.

[~,t,y] = fileparts(url);
filename = [t y];

disp([libName ' will now be downloaded form ' url ' and placed in ' targetPath]);
if ~exist(targetPath,'dir')
    mkdir(targetPath);
end
if ~exist(targetPath,'dir')
    error(['I could not make the directory ' targetPath]);
    
end
disp('downloading...');
try
    urlwrite(url,[targetPath '/' filename]);
catch
    error(['could not download ' libName ' from ' url '. Is the web accessible? If so the library server maybe down. Please check the url and manually download the library and add it to your matlab path.']);
end
disp('downloaded!');

disp('unpacking...');
[~,~,archiveType] = fileparts(filename);
switch archiveType
    case '.gz'
        gunzip([targetPath '/' filename],targetPath);
        [~,t,ex] = fileparts(filename);
        if ~strcmp(ex,'.gz')
            error(['the url ' url ' has an unsupported filetype. Supported files are .tar.gz and .zip']);
        end
        F = untar([targetPath '/' t],targetPath);
        delete([targetPath '/' filename]);
        delete([targetPath '/' t]);
        
        
    case '.zip'
        F = unzip(filename,targetPath);
        delete([targetPath '/' filename]);
    otherwise
        error(['the url ' url ' has an unsupported filetype. Supported files are .tar.gz and .zip']);
        
        
        
end
disp('unpacked!');

archiveDirName = GAIM_getArchiveDir(targetPath,F);

