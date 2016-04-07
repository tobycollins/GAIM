function test1(img1,img2)
%addpath('E:\collins\INRIA_summerSchool\1_practical_instance_level_recognition\practical-instance-search\vlfeat\toolbox\mex\mexw32');
img1 = imread('E:\collins\data\cvpr2013\selfcalib\realExperiments\deformedCap\run2\rend1.bmp');
img2 = imread('E:\collins\data\cvpr2013\selfcalib\realExperiments\deformedCap\run2\targetImage.bmp');
I1 = single(rgb2gray(img1));
I2 = single(rgb2gray(img2));

I2= imresize(I2,0.4);

H = fspecial('gaussian',5,1);

I2 = imfilter(I2,H,'replicate');


[fa, da] = vl_sift(I1) ;
[fb, db] = vl_sift(I2) ;
[matches, scores] = vl_ubcmatch(da, db) ;
''


%% example
% Be sure to have the vlfeat library installed
%run('../vlfeat-0.9.9/toolbox/vl_setup.m');

manual_annotation=0; % put 1 to mark the ROI in the template image
experiment=3; % ID of the experiment
% 
% % Two example images
% % Graffiti images
% % imagePath='images/frame%.5d.png';tframe=202;sfactor=1/2;nframe=758;
% % Escher images
% imagePath='images/CIMG%.4d.JPG';tframe=792;sfactor=1/4;nframe=795;
% %Load Template
% I1=mat2gray(imresize(imread(sprintf(imagePath,tframe)),sfactor));
% %Load Input image
% I2=mat2gray(imresize(imread(sprintf(imagePath,nframe)),sfactor));
% %Select four points in the Template to indicate the Roi. The clicking order
% %is: [upperleft,upperright,bottomright,bottomleft]
% if(manual_annotation)
% imshow(I1);
%     [x,y]=ginput(4);
%     eval(sprintf('save centers_template_exp%d x y',experiment));
% else
%     eval(sprintf('load centers_template_exp%d',experiment));
% end

% Detect and match SIFT features
%input_points=[x(1:4),y(1:4)];
F1 = vl_sift(I1);

 


[x1,y1,x2,y2]=SIFTFeatures(I1,I2,input_points);
% Show matches contaminated with outliers
figure(1);
ShowMatches(I1,I2,x1,y1,x2,y2);
% Perform delaunay triangulation of the points
TRI=delaunay(x1,y1);
m=length(x1);
% Generate neighbour list for each point
Neig=neighbour_list(TRI,m);
% Outlier Detection with 3DPVT method
% DetectOutliers(x1,y1,x2,y2,Neig,mu,lambda,ls,threshold);
% mu =>is a smoothing parameter (0.55 is a good value).
% lambda => Thin Plate Spline (TPS) internal smoothing (0.001 is a good value).
% ls => lsxls centers used in the TPS. (use 5 or 3)
% threshold => (IMPORTANT PARAMETER) threshold used to consider when a point is an inlier. I recommend to
% use a value around 5-30 pixels. if threshold is very small you discard
% many inliers.
inliers=DetectOutliers(x1,y1,x2,y2,Neig,0.55,0.001,5,25);
x1=x1(inliers);x2=x2(inliers);y1=y1(inliers);y2=y2(inliers);
% Show inliers
figure(2);
ShowMatches(I1,I2,x1,y1,x2,y2);
% Good Luck!