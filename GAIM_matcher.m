function [psImg1,psImg2,ds1,ds2] = GAIM_matcher(img1f,img2f,workDir,detectorOpts,matchOpts,deleteTemFiles,verb)
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
%GAIM_matcher: Inputs:
%lImgf: file path for first image
%rImgf: file path for second image
%
%
%workDir: directory used for storing intermediate files. If workDir=[] then
%the current directory will be used. 
%
%detectorOpts: Options for keypoint detector. See parseDetectOpts for
%details of this. If detectorOpts=[] then default options are used. 
%
%matchOpts: Options for graph-based matching. See parseGAIMOpts for
%details of this. If matchOpts=[] then default options are used. 
%
%deleteTemFiles is a boolean where deleteTemFiles=1 means that after
%matching all intermediate results are deleted after matching (otherwise they are kept). Set
%deleteTemFiles=0 if you want to match one or both of the images again in
%the future, because we will not need to recompute the keypoints/descriptors again. DEFAULT: deleteTemFiles = 0
%
%verb: Binary verbose tag. If Verbose=1 then information about timing etc.
%will be displayed in the console, otherwise it won't be. DEFAULT: verb = 1
%
%GAIM_matcher: Outputs:
%psImg1: 2xN matrics where each column is a matched keypoint in img1f (N is
%the number of matched keypoints)
%psImg2: 2xN matrics where each column is a matched keypoint in img2f
%ds1: MxN matrics where each column is the descriptor of the matched keypoint in img1f
%ds2: MxN matrics where each column is the descriptor of the matched keypoint in img2f
%
%See GAIM_example for an example call to GAIM_matcher.

global GAIM_LARGE; %a large constant used for applying hard constraints in the graph.
global GAIM_verbose;
GAIM_LARGE = 1e8; 

if isempty(workDir)
    disp('no working directory specified. I am going to use the current directory');
    workDir = './';
end

%setGAIMPaths();

%parse options:
if isempty(detectorOpts)
    detectorOpts = struct;
end
if isempty(matchOpts)
    matchOpts = struct;
end
detectorOpts = parseDetectOpts(detectorOpts);
matchOpts = parseMatchOpts(matchOpts,detectorOpts);

if isempty(deleteTemFiles)
    deleteTemFiles = 0;
else
    assert(ismember(deleteTemFiles,[0,1]));
end
if isempty(verb)
    verb = 0;
else
    assert(ismember(verb,[0,1]));
end

GAIM_verbose = verb;

%load the images and normalise them to default resolution:
img1_ = imread(img1f);
img2_ = imread(img2f);
if detectorOpts.rescaleImgs
[s1,img1] = GAIM_normaliseImg(img1_);
[s2,img2] = GAIM_normaliseImg(img2_);
else
    img1 = img1_;
    img2 = img2_;
    s1 = 1;
    s2 = 1;
end
%get greyscale images:
if size(img1,3)==1
    img1_g = img1;
else
    img1_g = rgb2gray(img1);
end
if size(img2,3)==1
    img2_g = img2;
else
    img2_g = rgb2gray(img2);
end
[~,img1Name,~] = fileparts(img1f);
[~,img2Name,~] = fileparts(img2f);

%define working directors for both images:
detectWorkDir1 = [workDir img1Name '_' num2str(detectorOpts.IDImg1)];
detectWorkDir2 = [workDir img2Name '_' num2str(detectorOpts.IDImg2)];

if exist([detectWorkDir1 '/' img1Name '_mask.bmp'],'file')
    if GAIM_verbose
        disp(['A mask for image: ' img1Name 'was detected. Features will only be computed within the mask.']);
    end
    msk1 = imread(msk1);msk1 = msk1(:,:,1)>0;
else
    msk1=[];
end
if exist([detectWorkDir1 '/' img2Name '_mask.bmp'],'file')
    if GAIM_verbose
        disp(['A mask for image: ' img2Name 'was detected. Features will only be computed within the mask.']);
    end
    msk2 = imread(msk2);msk2 = msk2(:,:,1)>0;
    
else
    msk2 = [];
end

clear KTestData;
clear dataset dataset_;

%test to see if features for first image have already been computed. If not, then compute
%them.
if exist( [detectWorkDir1 '/GxFeats.mat'],'file')
    disp(['Keypoints for image ' img1Name ' have already been computed.']);
else
    GAIM_compFeatData(detectWorkDir1,img1_g,msk1,detectorOpts,detectorOpts.xLandR(1))
end
GxFeats1 = load([detectWorkDir1 '/GxFeats.mat']);

%index the features with FLANN:
dataset1 = single(GxFeats1.F.ds)';
switch matchOpts.ANNMethod
    case 'FLANN'
        tic;
        index = flann_build_index(dataset1,struct('algorithm','kdtree','trees',8));
        tm = toc;
        if GAIM_verbose
        disp(['Time to index GxFeatures: ' num2str(tm) 's.'])
        end
end
GxFeats1.F.flanIndex = index;

%test to see if features for second image have already been computed. If not, then compute
%them.
if exist( [detectWorkDir2 '/GxFeats.mat'],'file')
    disp(['Keypoints for image ' img2Name ' have already been computed.']);
else
    GAIM_compFeatData(detectWorkDir2,img2_g,msk2,detectorOpts,detectorOpts.xLandR(2))
end
GxFeats2 = load([detectWorkDir2 '/GxFeats.mat']);
G1Feats2 = load([detectWorkDir2 '/G1Feats.mat']);
N = size(G1Feats2.F.ps,1);
%index the features with FLANN:
dataset2 = single(GxFeats2.F.ds)';
switch matchOpts.ANNMethod
    case 'FLANN'
        tic;
        index2 = flann_build_index(dataset2,struct('algorithm','kdtree','trees',8));
        tm = toc;
        if GAIM_verbose
        disp(['Time to index GxFeatures for Left-Right Consistency: ' num2str(tm) 's.'])
        end
end
GxFeats2.F.flanIndex = index2;

%for each feature in second image, compute approximate K-nearest neighbours
%in first image:
tic;
[Ls, D] = GAIM_Kbestmatches(GxFeats1.F, G1Feats2.F, matchOpts);
tm = toc;
if GAIM_verbose
        disp(['Time to compute ANNs: ' num2str(tm) 's.'])
end
        
%Construct the graph:
A = GAIM_makGraph(G1Feats2.F,matchOpts.graphNeighSize);

%solve the graph:
s = GAIM_solveGraph(Ls,D,A,GxFeats1.F,G1Feats2.F,matchOpts);

%obtain matches from the solution s:
LSelect = zeros(N,1);
matchDists = zeros(N,1);
for ks=1:N
    LSelect(ks) =  Ls(ks,s(ks));
    matchDists(ks) = D(ks,s(ks));
end
matchedF1Inds = LSelect;

%If verbose, then plot the matches from image 1 to image 2.
if GAIM_verbose
h = figure(1);
GAIM_plotMatches(h, GxFeats1.F.ps(matchedF1Inds,:)',G1Feats2.F.ps',img1_g,img2_g);
end

%Determine which keypoints are mismatched:
matchedInds = GAIM_mismatchDetect(GxFeats1.F, G1Feats2.F,GxFeats2.F,matchedF1Inds,matchDists,matchOpts);

%extract the points for all matches:
psImg1 = GxFeats1.F.ps(matchedInds(matchedInds>0),:)'/s1;
psImg2 = G1Feats2.F.ps(matchedInds>0,:)'/s2;
ds1 = GxFeats1.F.ds(matchedInds(matchedInds>0),:)';
ds2 = G1Feats2.F.ds(matchedInds>0,:)';

%explicitely delete the large datastructures:
clear dataset dataset_ GxFeats1 GxFeats2 G1Feats1 G1Feats2;

%Should we remove the temporary files?
if deleteTemFiles
    checkAndDelete_dir(detectWorkDir1);
    checkAndDelete_dir(detectWorkDir2);
end
