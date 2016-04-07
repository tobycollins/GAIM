function F = GAIM_doSimulation(Img_g,workDir,detectOpts)
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
%GAIM_doSimulation: Perform image simulations and compute keypoints and
%descriptors.
%
%Inputs:
%Img_g: greyscale input image
%
%workDir: working directory used to save the keypoint/descriptor data.
%
%detectOpts: Structure holding the keypoint detection options. See parseDetectOpts.m
%for details. 
%
%Outputs:
%AsSim: 
%
%F: structure holding information about the detected keypoints.



if exist([workDir '/TemplateImages'])==0
mkdir([workDir '/TemplateImages'])
end

s2 = detectOpts.s2Range; %top right element of affine transform (shear)
s3 = detectOpts.s3Range; %bottom right element of affine transform (anisotropic scale)
cc = 0;
numSamples = length(s2)*length(s3);
AsSim = zeros(3,3,length(s2)*length(s3));
featsdata = cell(numSamples,1);
disp('Simulating images and computing keypoints/descriptors...');
for j=1:length(s2)
    for k=1:length(s3)
        cc=cc+1; %simulated view counter
        %A = [s(1),s2(j);0,s3(k)]; %affine transform (without translation)
        Ash = [1,s2(j);0,1];
        %Aan = [1,0;0,s3(k)];
        Aan = [s3(k),0;0,1];
        A = Aan*Ash;
        
        A =  A/sqrt(det(A));
        A(3,3) = 1;        
        [imWarped,Awarp] = imgWarpAffine(Img_g,A);
        imWarped_b = uint8(imWarped);
        detectOpts.dI = 1; %this doubles the image size and means we will usually have more features at the smallest scale.
        Featdata = GAIM_extractImgFeatures(imWarped_b,detectOpts);
        if isempty(Featdata)
            %We could not compute features for this simulated image
            clear Featdata;
            Featdata.AAnpd =zeros(2,3,0);
            Featdata.LocationImage =zeros(0,2);
            Featdata.ds =[];
            
        end       
        %store the affine transforms:
        AwarpInv = inv(Awarp);
        Featdata.AAnpd_origImg = Featdata.AAnpd*0; %this is the affine transform from the original image to the keypoint's local coordinate frame.
        Featdata.AAnpd_origImgT = Featdata.AAnpd_origImg*0; %this is the transpose of Featdata.AAnpd_origImg
        
        for pp=1:size(Featdata.AAnpd_origImg,3)
            A = Featdata.AAnpd(:,:,pp);
            A_ = AwarpInv*A;
            Featdata.AAnpd_origImg(:,:,pp) = A_;    
            Featdata.AAnpd_origImgT(:,:,pp) = A_';
        end
        Featdata.Location_TemplateImg = homoMult(inv(Awarp),Featdata.LocationImage);
        Featdata.AIndexes = repmat([1,j,k],size(Featdata.Location_TemplateImg,1),1);
        Featdata.AIndexes(:,end+1) = cc;
        AsSim(:,:,cc) = Awarp;
        featsdata{cc} = Featdata;
        
    end  
end
disp('Done!');
%stack the feature data into one big list:
F = stackFeatureData(featsdata);