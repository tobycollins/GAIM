function GAIM_example()
% This file is part of the GAIM package for graph-based keypoint matching
% from the paper "An Analysis of Errors in Graph-based Keypoint Matching
% and Proposed Solutions", Collins, Mesejo and Bartoli, ECCV 2014. GAIM
% tackles the general keypoint-based graph matching problem for two images. It does not require prior knowledge about 
% the number of objects in the scene, the amount of occlusion, the amount of background clutter, and object topology (which changes 
% between the images if e.g. an object tears). Please cite this paper if you are using any part of this code in your work. 
% This is free software covered by the GPLv3 License.
% 
% Copyright (c) 2014 Toby Collins and Pablo Mesejo
%
%GAIM_example: An example of graph-based keypoint matching with GAIM on
%three image pairs. If all runs correctly you should see results that are
%very similar to cardboard_results.tif, tear_results.tif and
%desktop_results.tif.

close all;

gaimDir = fileparts(which('GAIM_example'));

pairs{1,1} = [gaimDir '/examples/cardboard/Movie47.png'];%
pairs{2,1}=  [gaimDir '/examples/cardboard/Movie80.png'];

pairs{1,2} = [gaimDir '/examples/desktop/d01.jpg'];
pairs{2,2} = [gaimDir '/examples/desktop/d02.jpg'];

pairs{1,3} = [gaimDir '/examples/tear/tear01.jpg'];
pairs{2,3}  = [gaimDir '/examples/tear/tear02.jpg'];

workDir = [gaimDir '/workDir/']; %current directory is used as the working directory (for saving intermediate results).
if ~exist(workDir,'dir')
   mkdir(workDir); 
end
setGAIMDependencies();

detectorOpts = parseDetectOpts(struct);
matchOpts = parseMatchOpts(struct,detectorOpts);
deleteTemFiles = 0;
verb = 1;
[psImg1_1,psImg2_1] = GAIM_matcher(pairs{1,1},pairs{2,1},workDir,detectorOpts,matchOpts,deleteTemFiles,verb);
close(figure(1));
GAIM_plotMatches(figure(10),psImg1_1,psImg2_1,rgb2gray(imread(pairs{1,1})),rgb2gray(imread(pairs{2,1})));
disp('Press any key to process second example.')
pause();
disp('OK!');

[psImg1_2,psImg2_2] = GAIM_matcher(pairs{1,2},pairs{2,2},workDir,detectorOpts,matchOpts,deleteTemFiles,verb);
close(figure(1));
GAIM_plotMatches(figure(11),psImg1_2,psImg2_2,rgb2gray(imread(pairs{1,2})),rgb2gray(imread(pairs{2,2})));
disp('Press any key to process third example.')
pause();
disp('OK!');

[psImg1_3,psImg2_3] = GAIM_matcher(pairs{1,3},pairs{2,3},workDir,detectorOpts,matchOpts,deleteTemFiles,verb);
close(figure(1));
GAIM_plotMatches(figure(12),psImg1_3,psImg2_3,rgb2gray(imread(pairs{1,3})),rgb2gray(imread(pairs{2,3})));
