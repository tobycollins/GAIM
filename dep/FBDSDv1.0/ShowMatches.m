function ShowMatches(I1,I2,x1,y1,x2,y2)
imshow([I1,I2]);
hold on;
plot(x1,y1,'o','LineWidth',3,'Color',[0.9,0.9,0.9]);
plot(x2+size(I1,2),y2,'o','LineWidth',3,'Color',[0.9,0.9,0.9]);
%h=line([x1';x2'+size(I1,2)],[y1';y2']);
%set(h,'Color',[0.9,0.9,0.9]);
hold off;

for i=[1:length(x1)]
hl=line([x1,x2]',[y1,y2]');
set(hl,'LineWidth',3,'Color',[0.9,0.9,0.9])
end

end


