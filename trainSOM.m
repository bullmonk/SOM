function [SOMPackage] = trainSOM(DataPackage,iverb)
%--------------------------------------------------------------------------
% Find machine specs
[ngpus,ncores,ncpus,archstr,maxsize,endian] = findcapabilitiescomputer();

if ngpus>0
    useGPU='yes';
else
    useGPU='no';
end
if ncpus>1
    useParallel='yes';
else
    useParallel='no';
end

%--------------------------------------------------------------------------
% Make sure DataPackage.PlotsDir directory exists
if ~exist(DataPackage.PlotsDir,'dir')
    if isunix
        command=['mkdir -pv ' DataPackage.PlotsDir];
        system(command);
    else
        mkdir(DataPackage.PlotsDir)
    end
end

HistPlotDir=[DataPackage.PlotsDir '2DHistograms/'];
if ~exist(HistPlotDir,'dir')
    if isunix
        command=['mkdir -pv ' HistPlotDir];
        disp(command);
        system(command);
    else
        mkdir(HistPlotDir)
    end
end

ScatterPlotDir=[DataPackage.PlotsDir 'Scatter/'];
if ~exist(ScatterPlotDir,'dir')
    if isunix
        command=['mkdir -pv ' ScatterPlotDir];
        disp(command);
        system(command);
    else
        mkdir(ScatterPlotDir)
    end
end

TextDir=[DataPackage.TextDir 'Scatter/'];
if ~exist(TextDir,'dir')
    if isunix
        command=['mkdir -pv ' TextDir];
        disp(command);
        system(command);
    else
        mkdir(TextDir)
    end
end

%--------------------------------------------------------------------------
% We will be creating some plots, set up the plot size and the screen 
% location for the first plot
scrsz = get(groot,'ScreenSize');
width=scrsz(3)/5;
height=scrsz(4)/5;
left=10;
bottom=10;

%--------------------------------------------------------------------------
% Partition data into training and validation datasets
if DataPackage.ivalid
    tic
    disp('Partitioning data into training and validation datasets.')
    [In,Out,InTest,OutTest] = partitiondataforML(DataPackage.InAll,DataPackage.OutAll,DataPackage.validation_fraction);
    whos In Out InTest OutTest
    toc
else
    disp('Use all the data for a training dataset.')    
    In=DataPackage.InAll;
    Out=DataPackage.OutAll;
    whos In Out
end

%--------------------------------------------------------------------------
% Set up the size of the parallel pool
npool=ncores;

%--------------------------------------------------------------------------
% Opening parallel pool
if ncpus>1
    tic
    disp('Opening parallel pool')
    
    % first check if there is a current pool
    poolobj=gcp('nocreate');
    
    % If there is no pool create one
    if isempty(poolobj)
        command=['parpool(' num2str(npool) ');'];
        disp(command);
        eval(command);
    else
        poolsize=poolobj.NumWorkers;
        disp(['A pool of ' poolsize ' workers already exists.'])
    end
    
    % Set parallel options
    paroptions = statset('UseParallel',true);
    toc
    
end

%--------------------------------------------------------------------------
%Self Organization Map
%--------------------------------------------------------------------------
%normalizing the columns
In = normc(In);

%--------------------------------------------------------------------------


%create a self-organizing map
dimension1 = 30;
dimension2 = 1;
net = selforgmap([dimension1 dimension2]);

x = In';

%train the network
[net,tr] = train(net, x);

%test the network
y = net(x);

%view the network
%view(net);

%--------------------------------------------------------------------------
%get class distribution
classes = vec2ind(y);

%--------------------------------------------------------------------------
%obatin the dates; and add to corresponding dates
load('/Users/xunliu/Documents/MATLAB/SOM/tline.mat');
allocation = classes';
classAllo = [allocation tline];

%--------------------------------------------------------------------------
%set up figures
% location for the first plot
scrsz = get(groot,'ScreenSize');
width=scrsz(3)/5;
height=scrsz(4)/5;
left=10;
bottom=10;

%--------------------------------------------------------------------------
% figure counter
jfigure=0;


%--------------------------------------------------------------------------
%allocate 2180 days into 60 classes

Dates = cell(dimension1,1);
coord = cell(dimension1,1);
[l,sz] = size(DataPackage.InputNames);
clm = zeros(dimension1,sz); 

for i = 1:dimension1
    loc = find(~(allocation-i));
    Dates{i} = classAllo(loc,2:end);%Dates{i} 3 columns, date information of each day in this class
    tempcrd = In(loc,:);%temp coordinate information, stores the daily variables
    coord{i} = tempcrd;% a copy of temp coordinate, to build array of cell
    
%     figure('Position',[left, bottom, width, height],'Renderer','painters')%plot each class%
%     left=left+width;
%     if left>4*width
%         left=10;
%         bottom=bottom+height;
%         if bottom>4*height
%             bottom=10;
%         end
%     end
    
    clm(i,:) = median(tempcrd);

    
    
%     l = length(squeeze(tempcrd(:,1)));
%     centers = ones(l,2);
%     glyphplot(tempcrd,'centers',centers,'radius',0.8);
end


figure('Position',[left, bottom, width, height],'Renderer','painters')
glyphplot(clm,'standardize','column','radius',0.8);

%--------------------------------------------------------------------------
%Store results
SOMPackage.net = net;
SOMPackage.classAllo = classAllo;
SOMPackage.y = y;
SOMPackage.x = x;
SOMPackage.Dates =  Dates;
SOMPackage.coord = coord;
SOMPackage.clm = clm;
%--------------------------------------------------------------------------
