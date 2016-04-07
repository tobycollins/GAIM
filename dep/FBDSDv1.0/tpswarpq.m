%% TPS-WARP interpolation

function Q=tpswarpq(P,L,Epsilon_lambda,lpm)

% q=L*v(p);--> v(p)=epsilon_lambda*lp;
m=size(P,1);
Q=P;
for i=[1:m]
vp=Epsilon_lambda'*lpm(:,i);
Q(i,:)=(L'*vp)';
end
