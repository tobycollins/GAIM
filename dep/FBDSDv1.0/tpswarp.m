%% TPS-WARP interpolation

function q=tpswarp(p,L,C,lambda,Epsilon_lambda)

if (nargin<5) %%Then compute Epsilon_lambda here
    Epsilon_lambda=EpsilonLambda(C,lambda);
    
end

% q=L*v(p);--> v(p)=epsilon_lambda*lp;
l=size(C,1);
Ct=[C,ones(l,1)];
% Obtaining p_vec
pvec=zeros(l,2);
pvec(:,1)=p(1);
pvec(:,2)=p(2);
distances=sum((pvec'-C').^2)';
rhos=rho(distances);
lp=[rhos;p;1];
vp=Epsilon_lambda'*lp;
q=L'*vp;
