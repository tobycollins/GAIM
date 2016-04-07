%% TPS-Warp from feature correspondences with smoothing

function L=TPSWfromfeatures_FBDSD(x2,x1,C,mu,lambda,Epsilon_lambda)
if(nargin<6) %% ifndef Compute Epsilon_lambda here
    Epsilon_lambda=EpsilonLambda(C,lambda);
end
l=size(C,1);
% for each p=(x y) obtain the v(p)
PSI=[];
N=[];

for i=[1:size(x1,1)]
    p=x1(i,:)';
    q=x2(i,:)';
% q=L*v(p);--> v(p)=epsilon_lambda*lp;

% Obtaining p_vec
pvec=zeros(l,2);
pvec(:,1)=p(1);
pvec(:,2)=p(2);
distances=sum((pvec'-C').^2)';
rhos=rho(distances);
lp=[rhos;p;1];
N=[N,Epsilon_lambda'*lp];
PSI=[PSI,q];
end
N=N';
PSI=PSI';   
m=size(x1,1);
Epsilon_bar=Epsilon_lambda(1:size(Epsilon_lambda,1)-3,:);%inv(Klambda)*(eye(l)-Ct*A);
ZTZ=8.*pi.*Epsilon_bar;
L=inv(N'*N+m*mu^2*ZTZ)*N'*PSI;

