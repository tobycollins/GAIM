function Featdata = GAIM_extractImgFeatures(Img_g,detectOpts)
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
%GAIM_extractImgFeatures: Wrapper for computing keypoints and descriptors.
%Inputs:
%Img_g: greyscale input image
%
%detectOpts: Structure holding the keypoint detection options. See parseDetectOpts.m
%for details. 
%
%Outputs:
%Featdata: A structure holding the detected keypoints, descriptors and the
%local similarity transform of their coordinate frame.
if isa(class(Img_g),'uint8')
    error('image input should be a grey uint8 image');
end
detectOpts.dI = (detectOpts.dI==1);
switch detectOpts.descriptMethod
    case 'SURF' % MATLAB
        if detectOpts.dI
            s = 1.5;
            Img_g_ = imresize(Img_g,s);
            POINTS = detectSURFFeatures(Img_g_,'MetricThreshold',detectOpts.MetricThreshold);
            [FEATURES,VALID_POINTS] = extractFeatures((Img_g_), POINTS);
            scales = double(VALID_POINTS.Scale)/s;
            Featdata.LocationImage =double(VALID_POINTS.Location)/s;
        else
            POINTS = detectSURFFeatures(Img_g,'MetricThreshold',detectOpts.MetricThreshold);
            [FEATURES,VALID_POINTS] = extractFeatures((Img_g), POINTS);
            scales = double(VALID_POINTS.Scale);
            Featdata.LocationImage =double(VALID_POINTS.Location);
        end
        Featdata.ds = double(FEATURES);
        orients = double(VALID_POINTS.Orientation);
   
        %store the rotation, scale and translation for each keypoint:
        Anpd = zeros(3,3,size(Featdata.ds,1));
        Anpd(3,3,:) = 1;
        Anpd(1,1,:) = scales.*cos(orients);
        Anpd(1,2,:) = scales.*sin(orients);
        Anpd(2,1,:) = -scales.*sin(orients);
        Anpd(2,2,:) = scales.*cos(orients);
        Anpd(1,3,:) = Featdata.LocationImage(:,1);
        Anpd(2,3,:) = Featdata.LocationImage(:,2);
        Featdata.AAnpd = Anpd;   
        
        
        
    case 'SIFT' % VLFEAT
        
        im_g_s = im2single(Img_g) ;
        [f,d,info] = vl_covdet(im_g_s, 'verbose','method',detectOpts.detectorMethod,'EstimateOrientation', true,'EstimateAffineShape', false,'PeakThreshold',detectOpts.PeakThreshold,'DoubleImage', detectOpts.dI) ;
        vlds = isnan(sum(d,1))==0;
        f = f(:,vlds);
        d = d(:,vlds);        
        
        %store the rotation, scale and translation for each keypoint:
        Anpd = zeros(3,3,size(f,2));
        Anpd(3,3,:) = 1;
        Anpd(1,1,:) = f(3,:);
        Anpd(2,1,:) = f(4,:);
        Anpd(1,2,:) = f(5,:);
        Anpd(2,2,:) = f(6,:);
        Anpd(1,3,:) = f(1,:);
        Anpd(2,3,:) = f(2,:);
  
        Featdata.AAnpd = Anpd;      
        Featdata.LocationImage =double(f(1:2,:)');
        Featdata.ds = double(d');
        %orScores = info.orientationScore(vlds);        
end
