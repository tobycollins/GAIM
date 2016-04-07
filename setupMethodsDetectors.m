function methodDescript = setupMethodsDetectors()

methodDescript(1).fExtractMethod = 'simulation';
methodDescript(1).descriptMethod = 'SIFT';
methodDescript(1).PeakThresholdTemplate = 0.01;
methodDescript(1).PeakThresholdInput = 0.01;
methodDescript(1).detectorMethod = 'DOG';
methodDescript(1).simOptsViewStepSize = 5;
%methodDescript(1).candadeSelectMethod = 'KBest';
methodDescript(1).ID = createID(methodDescript(1));
methodDescript(1).col = 'r.-';


methodDescript(2).fExtractMethod = 'simulation';
methodDescript(2).descriptMethod = 'SIFT';
methodDescript(2).PeakThresholdTemplate = 0.01;
methodDescript(2).PeakThresholdInput = 0.01;
methodDescript(2).detectorMethod = 'DOG';
methodDescript(2).simOptsViewStepSize = 8;
%methodDescript(1).candadeSelectMethod = 'KBest';
methodDescript(2).ID = createID(methodDescript(2));
methodDescript(2).col = 'kx-';

methodDescript(3).fExtractMethod = 'simulation';
methodDescript(3).descriptMethod = 'SIFT';
methodDescript(3).PeakThresholdTemplate = 0.01;
methodDescript(3).PeakThresholdInput = 0.01;
methodDescript(3).detectorMethod = 'DOG';
methodDescript(3).simOptsViewStepSize = 3;
%methodDescript(1).candadeSelectMethod = 'KBest';
methodDescript(3).ID = createID(methodDescript(3));
methodDescript(3).col = 'go-';


methodDescript(4).fExtractMethod = 'normal';
methodDescript(4).descriptMethod = 'SIFT';
methodDescript(4).PeakThresholdTemplate = 0.01;
methodDescript(4).PeakThresholdInput = 0.01;
methodDescript(4).detectorMethod = 'DOG';
%methodDescript(3).candadeSelectMethod = 'KBest';
methodDescript(4).ID = createID(methodDescript(4));
methodDescript(4).col = 'b-';

methodDescript(5).fExtractMethod = 'normal';
methodDescript(5).descriptMethod = 'ACSIFT';
methodDescript(5).PeakThresholdTemplate = 0.01;
methodDescript(5).PeakThresholdInput = 0.01;
methodDescript(5).detectorMethod = 'DOG';
%methodDescript(4).candadeSelectMethod = 'KBest';
methodDescript(5).ID = createID(methodDescript(5));
methodDescript(5).col = 'm-';

methodDescript(6).fExtractMethod = 'normal';
methodDescript(6).descriptMethod = 'SIFT';
methodDescript(6).PeakThresholdTemplate = 0;
methodDescript(6).PeakThresholdInput = 0.01;
methodDescript(6).detectorMethod = 'DOG';
%methodDescript(3).candadeSelectMethod = 'KBest';
methodDescript(6).ID = createID(methodDescript(6));
methodDescript(6).col = 'b:';

methodDescript(7).fExtractMethod = 'normal';
methodDescript(7).descriptMethod = 'ACSIFT';
methodDescript(7).PeakThresholdTemplate =0;
methodDescript(7).PeakThresholdInput = 0.01;
methodDescript(7).detectorMethod = 'DOG';
%methodDescript(4).candadeSelectMethod = 'KBest';
methodDescript(7).ID = createID(methodDescript(7));
methodDescript(7).col = 'm:';


% 
% methodDescript(8).fExtractMethod = 'normal';
% methodDescript(8).descriptMethod = 'SIFT';
% methodDescript(8).PeakThresholdTemplate = 0.00000;
% methodDescript(8).PeakThresholdInput = 0.01;
% methodDescript(8).detectorMethod = 'DOG';
% %methodDescript(3).candadeSelectMethod = 'KBest';
% methodDescript(8).ID = '008';
% methodDescript(8).col = 'b:';
% 
% 
% methodDescript(9).fExtractMethod = 'normal';
% methodDescript(9).descriptMethod = 'ACSIFT';
% methodDescript(9).PeakThresholdTemplate = 0.00000;
% methodDescript(9).PeakThresholdInput = 0.01;
% methodDescript(9).detectorMethod = 'DOG';
% %methodDescript(4).candadeSelectMethod = 'KBest';
% methodDescript(9).ID = '009';
% methodDescript(9).col = 'm:';
% 


function ID = createID(method)
f = fields(method);
str = [];
for i=1:length(f)
   vl = getfield(method,f{i});
   if ischar(vl)
       
   else
       vl = num2str(vl);
   end    
   str = [str '_' vl];
end
ID = str;
