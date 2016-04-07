function [imWarped,A_imin2out] = imgWarpAffine(imIn,A1to2)
%warps an input image imIn by a 2D affine transform A1to2
imIn=double(imIn);
[imH,imW,d] = size(imIn);
px1_c=[1,1;1,imH;imW,1;imW,imH];
pxI2 = homoMult(A1to2,px1_c);
bb2 = getBoundBox([],pxI2(:,1),pxI2(:,2));
ww = ceil(bb2.x(2)-(bb2.x(1)))+1;
hh =  ceil(bb2.y(2)-(bb2.y(1)))+1;

if mod(ww,2)==1
    ww = ww+1;
end

if mod(hh,2)==1
    hh = hh+1;
end
ATrans = eye(3);
ATrans(1,3)=-bb2.x(1)+1;
ATrans(2,3)=-bb2.y(1)+1;
A_imin2out=ATrans*A1to2;
[xx,yy] = meshgrid([1:ww],[1:hh]);
pix_c = [xx(:),yy(:)];

M = inv(A_imin2out);

pix_back = M(1:2,1:2)*pix_c';
pix_back(1,:) = pix_back(1,:) + M(1,3);
pix_back(2,:) = pix_back(2,:) + M(2,3);

imWarped = zeros(hh,ww,d);
for i=1:d
    imout = zeros(hh,ww);
    vs = mirt2D_mexinterp(imIn(:,:,i),pix_back(1,:),pix_back(2,:));
    imout(:)=vs;
    imWarped(:,:,i) = imout;
end

imWarped=(imWarped);