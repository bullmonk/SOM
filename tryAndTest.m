% A = cell(2,1);
% A{1,1} = 'adb';
% A{1,2} = 'adkjfkdj';
% 
% [m,n] = size(A);
% 
% l = size(DataPackage.InputNames);
% dimension1 = 13;
% cols = zeros(dimension1,l);


exam = SOMPackage.coord(1,1);
exam = exam{1,1};
examNames = char(InputNames);

[m,n] = size(exam);
centers = ones(m,2);
glyphplot(exam,'centers',centers,'radius',0.8);
