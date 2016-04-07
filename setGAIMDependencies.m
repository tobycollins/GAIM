function setGAIMDependencies()
% This file is part of the GAIM package for graph-based keypoint matching
% from the paper "An Analysis of Errors in Graph-based Keypoint Matching
% and Proposed Solutions", Collins, Mesejo and Bartoli, ECCV 2014. GAIM
% tackles the general keypoint-based graph matching problem for two images. It does not require prior knowledge about
% the number of objects in the scene, the amount of occlusion, the amount of background clutter, and object topology (which changes
% between the images if e.g. an object tears). Please cite this paper if you are using any part of this code in your work.
% This is free software covered by the GPLv3 License.
% Copyright (c) 2014 Toby Collins and Pablo Mesejo
%
% setGAIMDependencies: sets up the necessary dependencies for GAIM. The dependencies are as follows:
%
%
% FLANN: http://www.cs.ubc.ca/research/flann/#download
%           Tested with version 1.8.0.
%           Requires compiling
% UGM: http://www.cs.ubc.ca/~schmidtm/Software/UGM.html
%           Tested with 2011 version.
%           Does not require compiling
%
% FBDSD by Daniel Pizarro (http://isit.u-clermont1.fr/en/content/Daniel-Pizarro): Library included in ./dep.
%           Tested with version FBDSDv1.0. If you use QPBO please refer to Daniel's webpage and
%           software section to correctly cite his work and for licence terms.
%           Does not require compiling
% QPBO by Vladimir Kolmogorov (http://pub.ist.ac.at/~vnk/). Library included in ./dep. Using mex
%           wrapper by Oxford university's VGG libraries (http://www.robots.ox.ac.uk/~vgg/software/).
%           If you use QPBO please refer to Vladimir's webpage and software section to correctly cite his
%           work and for licence terms.


%please modify the following according to your system: If you do not have one of the libraries then you can set the path to the source code archive url.
%This will automatically download and extract the arcive as a subdirectory
%in ./dep
%
%%%%%%%%%%%%%%%
flann_path = 'http://www.cs.ubc.ca/research/flann/uploads/FLANN/flann-1.8.4-src.zip';
%or if you already have a local copy something like: flann_path = './dep/flann-1.8.4-src';

flann_mexDir = './dep/flann-1.8.4-src/build/src/matlab'; %directory where FLANN mex files are. You only need to set this if FLANN has already been installed on your system and you do not want to install a local copy in ./dep. Note that there is sometimes difficulty with compiling FLANN on windows (this is a FLANN issue).
%If you have difficulty you can try the pre-built binaries in ./dep/flannWindowsBins.

UGM_path = 'http://www.cs.ubc.ca/~schmidtm/Software/UGM_2011.zip'; %directory where UMG is
%or if you have a local copy something like UGM_path = './dep/UGM';

VL_path = 'http://www.vlfeat.org/download/vlfeat-0.9.20-bin.tar.gz';
%or if you have a local copy something like VL_path = './vlfeat-0.9.20';
%%%%%%%%%%%%%%

%%%%%%%%%%%%%% no need to modify this because it is included in GAIM
PIZ_dir = './dep/FBDSDv1.0'; %directory where FBDSD is
QPBO_dir = './dep/vgg';      %directory where vgg wrapper to qpbo is
%%%%%%%%%%%%%%


disp('setting up GAIM dependencies.');

gaimDir = fileparts(which('GAIM_example'));

addpath(genpath('./dep'));

%%%%%%%%VLFEAT:
disp('VLFEAT...');
T =  which('vl_SIFT');
if isempty(T)
    T =  which('vl_setup');
    if isempty(T)
        if checkIfurl(VL_path)
            vlURL = VL_path;
            archiveDirName = GAIM_downloadCodeSource(vlURL,[gaimDir '/dep'],'vlfeat');
            VL_path = [gaimDir '/dep/' archiveDirName];
        end
        addpath([VL_path '/toolbox']);
        T =  which('vl_setup');
        if isempty(T)
            error('I could not find VLFeats vl_setup function. Are you sure you set VL_dir correctly? vl_setup should be in $(VL_dir)/toolbox');
        end
    end
    vl_setup();
end


%%%%%%%%UMG:
disp('UMG...');
T =  which('UGM_makeEdgeStruct');
if isempty(T)
    if checkIfurl(UGM_path)
        umgURL = UGM_path;
        archiveDirName = GAIM_downloadCodeSource(umgURL,[gaimDir '/dep'],'UMG');
        UGM_path = [gaimDir '/dep/' archiveDirName];
    end
    addpath(UGM_path)
    addpath([UGM_path '/sub']);
    addpath([UGM_path '/compiled']);
    addpath([UGM_path '/decode']);
    addpath([UGM_path '/misc']);
    T =  which('UGM_makeEdgeStruct');
    if isempty(T)
        error('I could not find UMG. Are you sure you set UGM_path correctly?');
    end
end



%%%%%%%%FLANN:
disp('FLANN...');
T =  which('flann_build_index');
if isempty(T)
    if checkIfurl(flann_path)
        flannURL = flann_path;
        archiveDirName = GAIM_downloadCodeSource(flannURL,[gaimDir '/dep'],'FLANN');
        flann_path = [gaimDir '/dep/' archiveDirName];
    end
    addpath([flann_path '/src/matlab']);
    T =  which('flann_build_index');
    if isempty(T)
        error('I could not find FLANN. Are you sure you set flann_path correctly?');
    end
end
T =  which('nearest_neighbors');
if isempty(T)
    addpath(flann_mexDir);
    T =  which('nearest_neighbors');
    if isempty(T)
        flann_dir = fileparts(fileparts(fileparts( which('flann_build_index'))));
        disp('I cannot find the FLANN mex files.');
        v = (input(['Shall I try to automatically compile FLANN mex files from the source code (1 = yes, 0 = no)? This has been tested for linux only and requires (i) cmake and (ii) the matlab bin directory to be in system path. If using windows please compile it yourself through cmake. The root source directory is ' flann_dir]));       
        if v
            flann_dir_build = [flann_dir '/build'];
            buildFlann(gaimDir,flann_dir,flann_dir_build);
        else
            error('You need to obtain the FLANN mex files and set the directory variable (flann_mexDir) manually');            
        end
    end
end





%%%%%%%%MIRT 2D
addpath([gaimDir '/dep/mirt2D']);
T =  which('mirt2D_mexinterp');
if strcmp(T(end-1:end),'.m')
    disp('mirt2D found but it requires compiling');
    cd([gaimDir '/dep/mirt2D']);
    mex mirt2D_mexinterp.cpp;
    cd(gaimDir);
end
T =  which('mirt2D_mexinterp');
if strcmp(T(end-1:end),'.m')
    error('Could not compile mirt2D');
end


%%%%%%%%QPBO:
disp('QPBO...');
T =  which('vgg_qpbo');
if isempty(T)
    addpath(QPBO_dir)
    T =  which('vgg_qpbo');
    if isempty(T)
        error('The path to QPBO has not been set or is not correct (see setGAIMPaths)');
    end
end
if strcmp(T(end-1:end),'.m')
    disp('qpbo found but it requires compiling');
    cd(QPBO_dir);
    %%%unsure why there is a comiplation error, but it does not affect
    %%%compiling vgg_qpbo
    try
        vgg_qpbo
    catch
        
    end
    cd(gaimDir);
    
    
    T =  which('vgg_qpbo');
    if strcmp(T(end-1:end),'.m')
        error('could not compile vgg_qpbo');
    else        
        disp('qpboMex successfully compiled');
    end
    
end

%%%%%%%%FBDSD:
disp('FBDSD...');
T =  which('DetectOutliers');
if isempty(T)
    addpath(PIZ_dir)
    T =  which('DetectOutliers');
    if isempty(T)
        error('The path to FBDSD has not been set or is not correct (see setGAIMPaths)');
    end
end

function buildFlann(gaimDir,flann_dir_src,flann_dir_build)
if ~exist(flann_dir_build,'dir')
mkdir(flann_dir_build);
end
cd(flann_dir_build);
system(['cmake ' flann_dir_src]);
system('make');
addpath([flann_dir_build '/src/matlab'])
cd(gaimDir);
T =  which('nearest_neighbors');
if isempty(T)
    error(['I could not automatically build FLANN. You need to build FLANN. The source directory is ' flann_dir_src '. If you are using wincows and a microsoft compiler there is a known issue (https://github.com/chambbj/osgeo-superbuild/issues/3). IIf you have difficulty you can try the pre-built binaries in ./dep/flannWindowsBins.']);
else
    disp(['FLANN successfully built. Compiled matlab functions are at ' flann_dir_build '/src/matlab']);
end



function isurl = checkIfurl(str)
%naive url checker:
isurl = strfind(str,'www.');











