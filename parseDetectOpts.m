function opts = parseDetectOpts(opts)
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
%parseDetectOpts: Parse the keypoint detection/descriptor extraction options for GAIM. opts is a structure
%containing the following fields:

%detectorMethods: in {'DOG','SURF'}; DOG is Difference of Gaussian implemented by VLFeat. 
%SURF is the SURF keypoint detector implemented by Matlab.

%rescaleImgs: in {0,1}. Set this to 1 if you want to rescale the input
%images to a default resolution (this is 1000 pixels along the image
%diagonal.

%descriptMethods: in {'SIFT','SURF'}; SIFT is the SIFT descriptor implemented by VLFeat. 
%implementation from VLFeat. SURF is the SURF keypoint descriptor implemented by Matlab.

%PeakThreshold: A positive double. If SIFT features are used, PeakThreshold
%is required, which eliminates low-response detections. 

%MetricThreshold: A positive double. If SURF features are used, MetricThreshold
%is required, which eliminates low-response detections. 

%shearRng: A vector of size two that holds the minimum and maximum shear
%component for simulating affine transformations. 

%anisoStp: A scalar used for building the anisotropic scale range. For
%example, if we had anisoRng=1.5, and the number of steps was 8, the
%anisotrpic scale factors would be  [0.2963    0.4444    0.6667    1.0000
%1.5000    2.2500    3.3750]. See GAIM_compFeatData.m to see how the
%anisotrpic scale factors are generated from anisoStp.

%xLandR: A vector of size two that holds number of simulation quantisations for shear and anisotropic scale. xLandR(1) is the number of quantisations for the first
%image, and xLandR(2) is the number of quantisations for the second image. We use xLandR(2) when we are performing the left-right consistency test, because simulation keypoints are also computed for the second image.
%Higher quantisation sizes means more simulated images. Typically, for the
%LRC we can save some time by having xLandR(2)<xLandR(1).

detectorMethods = {'DOG','SURF'}; 
descriptMethods = {'SIFT','SURF'}; 

if isfield(opts,'detectorMethod')
     assert(sum(cell2mat(cellfun(@(x) strcmp(x,opts.detectorMethod),detectorMethods, 'UniformOutput',false)))==1);
else
    opts.detectorMethod ='SURF';
end

if isfield(opts,'descriptMethod')
     assert(sum(cell2mat(cellfun(@(x) strcmp(x,opts.descriptMethod),descriptMethods, 'UniformOutput',false)))==1);
else
    opts.descriptMethod ='SURF';
end

if strcmp(opts.descriptMethod,'SIFT')
    if isfield(opts,'PeakThreshold')
    else
        opts.PeakThreshold = 0.01;
    end   
end
if strcmp(opts.descriptMethod,'SURF')
    if isfield(opts,'MetricThreshold')
    else
      opts.MetricThreshold = 400;
    end   
end

if isfield(opts,'rescaleImgs')
    assert(opts.rescaleImgs==0||opts.rescaleImgs==1)
else
   opts.rescaleImgs = 1;
end

if isfield(opts,'xLandR')
    assert(length(opts.xLandR)==2);
else
    opts.xLandR = [6,4];
end

if isfield(opts,'shearRng')
    assert(length(opts.shearRng)==2);
else
   opts.shearRng = [-2,2];
end

if isfield(opts,'anisoStp')
    assert(length(opts.anisoStp)==1);
else
   opts.anisoStp = 1.5;
end


%serialise the options and create a unique ID:
f = fields(opts);
str = [];
for i=1:length(f)
    vl = getfield(opts,f{i});
    if strcmp(f{i},'x')
        continue;
    end
    if ischar(vl)
    else
        for j=1:length(vl)
             str = [str '_' num2str(vl(j))];
        end
    end
   
end

%create a unique ID for the options:
opts.IDImg1=string2hash([str '_' num2str(opts.xLandR(1))],'djb2');
opts.IDImg2=string2hash([str '_' num2str(opts.xLandR(2))],'djb2');


