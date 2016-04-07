function im = img_saveModified(fig,imw,imh)

%close all; clear; clc;

%r = 240 ; c = 320;

c=imw;
r=imh;

%fig = figure('Visible', 'off');
%fig = figure();

%imshow( zeros(r,c) );
%hold on;
%plot([c-fix(c/2),c-fix(c/2)],[r-fix(r/2),r-fix(r/2)],'r*', 'MarkerSize', 10 );

% Sets position and size of figure on the screen
set(fig, 'Units', 'pixels', 'position', [100 100 c r] ); 

% Sets axes to fill the figure space
set(gca, 'Units', 'pixels', 'position', [0 0 c+1 r+1 ]);

% Sets print properties; Looks like 1 pixel = (3/4)th of a point
set(fig, 'paperunits', 'points', 'papersize', [fix((c-1)*(3/4))+1 fix((r-1)*(3/4))+1]);
set(fig, 'paperunits', 'normalized', 'paperposition', [0 0 1 1]);

print( fig, sprintf('-r%d', ceil(72*(4/3))), '-dpng', 'image.png' ); 


im = imread( 'image.png');
%figure; imshow(im);