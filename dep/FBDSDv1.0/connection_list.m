function N=connection_list(TRI,m)
N=[];
TRI1=TRI(:,1);
TRI2=TRI(:,2);
TRI3=TRI(:,3);
for i=1:m
    N{i}=[find(TRI1==i);find(TRI2==i);find(TRI3==i)]';
end
