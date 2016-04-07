function [x,y,indexes]=filter_matches(x,y,bw)
radius=5;
indexes=[];
for i=[1:length(x)]
if(bw(round(y(i)),round(x(i)))>0)
indexes=[indexes,i];
end
end

x=x(indexes);
y=y(indexes);