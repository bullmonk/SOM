clear;clc;close all;
load('/Users/xunliu/Documents/MATLAB/Package_XunLiu/pollentraining.mat');
%the first day and last day set up
ts = datenum('1987-1-1');
tf = datenum('2014-12-31');
%tline stores the everyday
tline = [ts:tf];
tline = datevec(tline);
tline(:,4:6) = [];
PoD = [tline In Out];
[row,col] = find(isnan(PoD));
In(row,:) = [];
Out(row,:) = [];
tline(row,:) = [];
%save it
save('tline.mat','tline');