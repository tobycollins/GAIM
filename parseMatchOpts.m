function opts = parseMatchOpts(opts,detectOpts)
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
%parseMatchOpts: Parse the matching options for GAIM. opts is a structure
%containing the following fields:

%MRF_solveMethods: in {'AE','LBP'}; AE = alpha expansion, LBP = loopy
%belief propagation.

%graphNeighSize: positive integer

%pairTrunc: positive double, specifying the truncation term for pairwise
%potentials.

%wUnary: positive double, specifying the weight for the unary term (i.e. the keypoint descriptor similarity)

%K: number of approximate nearest neighbours for matching each keypoint. K
%gives the state size of the nodes in the graph. 

%ANN_methods: in {'FLANN'}. Currently only FLANN is supported. 

MRF_solveMethods = {'AE','LBP'}; 
ANN_methods = {'FLANN'}; 

if isfield(opts,'MRF_solveMethod')   
    assert(sum(cell2mat(cellfun(@(x) strcmp(x,opts.MRF_solveMethod),MRF_solveMethods, 'UniformOutput',false)))==1);
else
    opts.MRF_solve_method = MRF_solveMethods{1};
end

if isfield(opts,'graphNeighSize')   
    assert(isa(opts.graphNeighSize,'double'));
    assert(opts.graphNeighSize>=0);
    assert(round(opts.graphNeighSize)==opts.graphNeighSize);         
else
    opts.graphNeighSize =35;
end

if isfield(opts,'pairTrunc')   
    assert(isa(opts.pairTrunc,'double'));
    assert(opts.pairTrunc>=0);
else
    opts.pairTrunc =0.4;   
end

if isfield(opts,'wUnary')   
    assert(isa(opts.wUnary,'double'));
    assert(opts.wUnary>=0);
else
    switch detectOpts.descriptMethod
        case 'SURF'
            opts.wUnary = 5;
    
        case 'SIFT'
            opts.wUnary = 5;
        otherwise
            error('unrecognised descriptor type');         
    end    
end

if isfield(opts,'K')   
    assert(isa(opts.K,'double'));
    assert(opts.K>=0);
    assert(round(opts.K)==opts.K);    
else
    opts.K = 50;   
end


if isfield(opts,'ANNMethod')   
    assert(sum(cell2mat(cellfun(@(x) strcmp(x,opts.ANNMethod),ANN_methods, 'UniformOutput',false)))==1);
else
    opts.ANNMethod = 'FLANN';
end

if isfield(opts,'ANNMethod')   
    assert(sum(cell2mat(cellfun(@(x) strcmp(x,opts.ANNMethod),ANN_methods, 'UniformOutput',false)))==1);
else
    opts.ANNMethod = 'FLANN';
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
opts.ID=string2hash(str,'djb2');




