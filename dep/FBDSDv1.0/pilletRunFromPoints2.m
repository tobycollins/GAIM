% Add path.
function [L,ys] = pilletRunFromPoints2(img1,img2,ps1,ps2,inlierThresh)

%addpath('E:\collins\sourceCode3\outlierRemoval_2D_registration\4_annealed_m_estimation\model_specific\model_specific');

% Parameters.
sigma_th = 250;         % Inlier threshold.
sigma_0 = 80;           % Initial value of sigma.
alpha = 0.5;            % Decay rate of sigma.
lambda_r = 3*10^-4;     % Regularization coefficient.
ransac_iter = 10;       % RANSAC iterations.
ransac_th = 0.3;        % RANSAC threshold.
x_stepsize = 15;        % Step size for triangulated mesh.
smooth_coeff = 10^-4;   % Smoothness coefficient.

if isempty(inlierThresh)
    sigma_th=250; 
else
    sigma_th = inlierThresh^2;
end


% Load data.
%load('../data/tshirt');

score = ones(size(ps1,2),1)';


ss = size(img1,2)/320;
img1 = imresize(img1,1/ss);
img2 = imresize(img2,1/ss);
ps1=ps1./ss;
ps2=ps2./ss;

data = [ps1;ps2];
data(1:2,:) = ps1;
data(3,:) = 1;
data(4:5,:) = ps2;
data(6,:) = 1;

NROWS = size(img1,1);
NCOLS = size(img1,2);

% Create the original triangulated mesh.
[ mesh_points mesh_triangles ] = create_triangulated_mesh(x_stepsize, NROWS+x_stepsize, NCOLS+x_stepsize);
mesh_points(1,:) = mesh_points(1,:)-x_stepsize/2;
mesh_points(2,:) = mesh_points(2,:)-x_stepsize/2;



% Compute the laplacian matrix for the original triangulated mesh.
[ mesh_triplets K ] = compute_laplacian_matrix(mesh_points, mesh_triangles, NROWS, NCOLS);

% Determine which triangles are the points in.
detri = DelaunayTri(mesh_points');
triangle_index = pointLocation(detri, data(1,:)', data(2,:)');

% Remove the points outside the original triangulated mesh.
outside_index = isnan(triangle_index);    
data = data(:,~outside_index);

%label = label(:,~outside_index);
score = score(:,~outside_index);
triangle_index = triangle_index(~outside_index);

% Initial matches.
m0 = data(1:2,:);
m1 = data(4:5,:);

% Compute the barycentric coordinates of points inside the original triangulated mesh.
T = compute_barycentric_coordinates(mesh_points, mesh_triangles, m0, triangle_index);                  

% Start timer.
tic;
    
% Normalise 2D points.            
[ data_img1_norm T1 ] = normalise2dpts(data(1:3,:));
[ data_img2_norm T2 ] = normalise2dpts(data(4:6,:));
data_norm = [ data_img1_norm ; data_img2_norm ];

% PROSAC initialization.
[ par res inx ] = prosac_sampling(data_norm,ransac_iter,-score);
[ ~, maxinx ] = max(sum(res<=ransac_th));    
A = reshape(par(:,maxinx),3,3);
A_denorm = inv(T2)*A*T1;    
init_mesh_points = A_denorm*[ mesh_points; ones(1,size(mesh_points,2)) ];                       
                    
% Newton optimization.     
loop = 1;
sigma = sigma_0;       
n = size(m0,2);
m = size(mesh_points,2);
X = init_mesh_points(1,:)';
Y = init_mesh_points(2,:)'; 
while (1)                    
    fprintf('Loop %d: Sigma = %.2f.\n', loop, sigma);

    % Compute the residuals of matches.             
    m0_warp = [ sum(T.*repmat(X,1,n)); sum(T.*repmat(Y,1,n)) ];
    delta2 = sum((m1-m0_warp).^2)';
    
    % Compute b and A.         
    bx = sparse(m,1);
    by = sparse(m,1);
    A = sparse(m,m);
    for i=1:n
        if (delta2(i) <= sigma^2)
            bx = bx + m1(1,i)*T(:,i);
            by = by + m1(2,i)*T(:,i);
            A = A + T(:,i)*T(:,i)';
        end
    end
    bx = bx/(sigma^4);
    by = by/(sigma^4);
    A = A/(sigma^4);    

    % Compute X and Y.
    mat = lambda_r*K + A;
    X = mat\bx;
    Y = mat\by;    

    % Lower value of sigma.
    if (sigma >= 1)
        loop = loop + 1;
        sigma = sigma*alpha;    
    else        
        ininx = delta2 <= sigma_th;
        break;
    end    
end        
L = (ininx==0);

if nargout>1
   ys; 
end
return;

% Stop timer.
tim = toc;

% Compute error.
n = size(data,2);
tp = sum(label==1&ininx'==1);
fp = sum(label-ininx'>0);
tn = sum(label==0&ininx'==0);
fn = sum(label-ininx'<0);
tpr = tp/(tp+fn);
fpr = fp/(fp+tn);
err = fp+fn;
                           
% Show result.
figure;
imshow([[ img1 ; zeros(max(0,size(img2,1)-size(img1,1)),size(img1,2)) ] [ img2 ; zeros(max(0,size(img1,1)-size(img2,1)),size(img2,2)) ] ]);
title(sprintf('Running Time = %.2fs - True Positive Rate = %.2f - False Positive Rate = %.2f - Labelling Error = %d.\n',tim,tpr,fpr,err));
hold on;
for i=1:n
    if (ininx(i)==1)
        plot(data(1,i),data(2,i),'go','LineWidth',2);
        plot(data(4,i)+size(img1,2),data(5,i),'go','LineWidth',2);
        plot([data(1,i) data(4,i)+size(img1,2)],[data(2,i) data(5,i)],'g-','LineWidth',1);
    else
        plot(data(1,i),data(2,i),'ro','LineWidth',2);
        plot(data(4,i)+size(img1,2),data(5,i),'ro','LineWidth',2);
        plot([data(1,i) data(4,i)+size(img1,2)],[data(2,i) data(5,i)],'r-','LineWidth',1);
    end
end