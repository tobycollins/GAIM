function lpm=lpmatrix(P,C)

l=size(C,1);
m=size(P,1);
Ct=[C,ones(l,1)];
lpm=zeros(l+3,m);
for i=[1:m]
% Obtaining p_vec
pvec=zeros(l,2);
pvec(:,1)=P(i,1);
pvec(:,2)=P(i,2);
distances=sum((pvec'-C').^2)';
rhos=rho(distances);
lpm(:,i)=[rhos;P(i,:)';1];
end
