function [vecsSel,indx,clusters] = uniquifyvecs_greedy(vecs,tol)
if nargin<2
tol = 0.01;
end



vecsRem = vecs;
vecsSel = [];
term = 0;
cc=0;
rmInds = [1:size(vecs,2)];
while (term ==0)
r = randperm(size(vecsRem,2));
r = r(1);
cc=cc+1;
vecsSel(:,cc) = vecsRem(:,r);
indx(cc) = rmInds(r);
ss = setdiff([1:size(vecsRem,2)],r);
vecsRem = vecsRem(:,ss);
rmInds = rmInds(ss);
dd = distance_vec(vecsRem,vecsSel(:,cc));
ff = dd>tol;
vecsRem = vecsRem(:,ff);
rmInds = rmInds(ff);
if isempty(vecsRem)
    term = true;
end
end
%indx=[];
clusters = [];
return;



numVecs = size(vecs,2);
numVecsrem = numVecs;
vecsrem = vecs;
term = false;
indx= zeros(numVecs,1);
cc=0;
clusters = cell(1,numVecs);
remInds=[1:numVecs];
while (term ==0)
   cc = cc+1;
   r = randperm( numVecsrem);
   r = r(1);
   indx(cc) = remInds(r);
   v_i = vecsrem(:,r);
   dd = distance_vec(v_i,vecsrem);
   fg = ((dd<=tol));
   clusters{cc} = find(fg);
   frem = find(fg==0);
   vecsrem = vecsrem(:,frem);
   remInds = remInds(frem);
   numVecsrem = size(vecsrem,2);
   if numVecsrem==0
       term = true;
   end
end
indx = indx(1:cc);
vecsSel = vecs(:,indx);