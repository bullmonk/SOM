function timeline=ObtainDates()
load('Users/xunliu/Documents/MATLAB/SOM/pollentraining.mat');
%the first day and last day set up
ts = datenum('1987-1-1');
tf = datenum('2014-12-31');
%tline stores the date series
tline = ts:tf;
tline = datevec(tline);
tline(:,4:6) = [];

%find those unusable day
PoD = [In Out];
[row,col] = find(isnan(PoD));
tline(row,:) = [];

timeline = tline;