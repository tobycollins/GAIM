function l=rho(d)
d2=d;
d2(find(d2==0))=1;
l=d.*log(d2);