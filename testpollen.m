clear;clc;close all;

%--------------------------------------------------------------------------
% Save directory
SaveDir=['Save/'];
if ~exist(SaveDir,'dir')
    if isunix
        command=['mkdir -pv ' SaveDir];
        disp(command);
        system(command);
    else
        mkdir(SaveDir);
    end
end

%--------------------------------------------------------------------------
% Plots directory
PlotsDir=['Plots/'];
if ~exist(PlotsDir,'dir')
    if isunix
        command=['mkdir -pv ' PlotsDir];
        disp(command);
        system(command);
    else
        mkdir(PlotsDir);
    end
end    

TextDir=['Text/'];
if ~exist(TextDir,'dir')
    if isunix
        command=['mkdir -pv ' TextDir];
        disp(command);
        system(command);
    else
        mkdir(TextDir);
    end
end

%--------------------------------------------------------------------------
% Set up variables

iverb=0;

% perform validation switch
ivalid=0;

% drop missing variables switch
imissing=1;

% drop missing output variables switch
imissingoutput=0;

% drop columns with constant values switch
icolumns=1;

idropsatellite=1;

% Fraction to use for validation dataset
validation_fraction=0.05;

% Preselected using Mutual Information
ipreselected=1;

itop=3;
itop=20;
itop=0;

%--------------------------------------------------------------------------
% Load data
tic
if ipreselected
    fn_mat='pollentraining.mat';
    disp(fn_mat);
    load(fn_mat);
    
    % Input variables to use
    % Expect each input to be a vector
    if itop>0
        iuse=1:itop;
    else
        iuse=1:length(usednames);
    end
    %InputNames=usednames;
    %DataNames=usednames;
    for i=1:length(iuse)
        DataNames{i}=usednames{i};
    end        
    OutputNames={'pollen'}; 
    DataNames{end+1}='pollen';
    
    InAll=In(:,iuse);
    OutAll=Out;
    
    Data=[InAll OutAll];
    
    clear In Out usednames
    
else
    fn_mat='AllPollenData.mat';
    disp(fn_mat);
    load(fn_mat);
    
    for i=1:length(DataNames)-1
        InputNames{i}=DataNames{i};
    end
    OutputNames={'pollen'};

    InAll=Data(:,1:end-1);
    OutAll=Data(:,end);
        
end
toc

%--------------------------------------------------------------------------
% Specify which input variable columns are categorical predictors
% % Fasting
% icat(1)=1;
% % InsulinPumpWorking
% icat(2)=2;
icat=[];

%--------------------------------------------------------------------------
% Prepare Machine Learning data arrays
tic
disp('Preparing Machine Learning data arrays')

% % Output Data
% command=['OutAll=['];
% for i=1:length(OutputNames)
%     command=[command 'makecolumnvectorforML(' OutputNames{i} ') '];
% end
% command=[command '];'];
% disp(command);
% eval(command);
% 
% % Input Data
% command=['InAll=['];
% for i=1:length(InputNames)
%     command=[command 'makecolumnvectorforML(' InputNames{i} ') '];
% end
% command=[command '];'];
% disp(command);
% eval(command);

% InAll=In;
% OutAll=Out;
% toc

%--------------------------------------------------------------------------
% Drop columns which are constant
if idropsatellite
    disp('Droping columns which are satellite data')
    whos Data    
    nd=size(Data);
    ikeep=[];
    for i=1:nd(2)
        clear x iwant
        x=squeeze(Data(:,i));
        iwant=find(~isnan(x));
        if idropsatellite
            k_albedo=strfind(DataNames{i},'Albedo');
            k_pm25=strfind(DataNames{i},'PM25');
            if length(k_albedo)>0 | length(k_pm25)>0
                if iverb
                    disp(DataNames{i})
                end
                continue
            else
                ikeep=[ikeep i];
            end
        end
    end
    % just keep rows that have valid non-constant data
    data=Data(:,ikeep);
    clear keptnames
    for i=1:length(ikeep)
        keptnames{i}=DataNames{ikeep(i)};
    end
    whos Data data
    Data=data;
    clear data
    DataNames=keptnames;
    clear keptnames
    
    for i=1:length(DataNames)-1
        InputNames{i}=DataNames{i};
    end
    OutputNames={'Pollen'};    
    whos Data    
end



%--------------------------------------------------------------------------
% Drop columns which are constant
if icolumns
    disp('Droping columns which are constant')
    whos Data    
    nd=size(Data);
    ikeep=[];
    for i=1:nd(2)
        clear x iwant
        x=squeeze(Data(:,i));
        iwant=find(~isnan(x));
        if length(iwant)>1 & min(x) ~=max(x)
            ikeep=[ikeep i];
        end
    end
    % just keep rows that have valid non-constant data
    data=Data(:,ikeep);
    clear keptnames
    for i=1:length(ikeep)
        keptnames{i}=DataNames{ikeep(i)};
    end
    whos Data data
    Data=data;
    clear data
    DataNames=keptnames;
    clear keptnames
    
    for i=1:length(DataNames)-1
        InputNames{i}=DataNames{i};
    end
    OutputNames={'Pollen'};    
    whos Data    
end

%--------------------------------------------------------------------------
% Drop rows with missing values
if imissing
    disp('Drop rows with missing values')
    whos Data
    tic
    [row,col] = find(isnan(Data));
    Data(row,:)=[];
    toc
    whos Data
end

%--------------------------------------------------------------------------
% Drop rows with missing output values
if imissingoutput
    disp('Drop rows with missing output values')
    whos Data
    tic
    clear Out
    Out=Data(:,end);
    [row,col] = find(isnan(Out));
    Data(row,:)=[];    
    toc
    whos Data    
end

clear InAll OutAll

InAll=Data(:,1:end-1);
OutAll=Data(:,end);

%--------------------------------------------------------------------------
% Reorganize the data
%--------------------------------------------------------------------------
% WantedNames = {...
%     'Lag_15_MaxDISPH','Lag_26_MinGRN','MinZ0H','Lag_9_MeanEFLUX',...
%     'Lag_9_MaxEVPTRNS','Lag_12_MeanEVPTRNS','Lag_9_MeanEVPTRNS',...
%     'Lag_14_MeanEVPTRNS','Lag_11_MeanEVPTRNS','Lag_12_MaxEVPTRNS',...
%     'Lag_8_MaxEVPTRNS','Lag_11_MaxEVPTRNS','Lag_14_MaxEVPTRNS',...
%    'Lag_30_MinTELAND','MeanTSH','Lag_29_MinTELAND','Lag_1_MeanTSH',...
%    'MaxHLML','Lag_8_MaxEFLUX','Lag_29_MaxTELAND','MeanTUNST',...
%    'Lag_1_MeanTUNST','Lag_8_MaxEVAP','MeanTWLT'...
%     };

WantedNames = {...
   'Lag_15_MaxDISPH','MinZ0H',...
   'Lag_30_MinTELAND','Lag_29_MinTELAND',...
   'Lag_29_MaxTELAND'...
   };


[B, Index] = intersect(InputNames,WantedNames);

InAll = InAll(:,Index);
InputNames = InputNames(:,Index);
%--------------------------------------------------------------------------
% Data package
DataPackage.InAll=InAll;
DataPackage.OutAll=OutAll;
DataPackage.icat=icat;
DataPackage.InputNames=InputNames;
DataPackage.OutputNames=OutputNames;
DataPackage.ivalid=ivalid;
DataPackage.validation_fraction=validation_fraction;
DataPackage.imissing=imissing;
DataPackage.ntop=length(DataPackage.InputNames);
DataPackage.irelieff=1;
DataPackage.iInteractionInformation=1;
DataPackage.VariableName=[InputNames OutputNames];
DataPackage.Description=[InputNames OutputNames];
DataPackage.iplotScatter=0;
DataPackage.iplot2DHistograms=0;
DataPackage.PlotsDir=PlotsDir;
DataPackage.TextDir=TextDir;

%--------------------------------------------------------------------------
% For calculating mutual information, continuous variables have to be discretized. 
% The function quantize offers several options to do this. We choose the 
% case of 10 levels for each variable.
nqlevels=5;
% DataPackage.QuantInAll=quantize(DataPackage.InAll,'levels',nqlevels);
% DataPackage.QuantOutAll=quantize(DataPackage.OutAll,'levels',nqlevels);

%DataPackage.QuantInAll=quantize(DataPackage.InAll,'method','kmeans');
%DataPackage.QuantOutAll=quantize(DataPackage.OutAll,'method','kmeans');

%DataPackage.QuantInAll=quantize(DataPackage.InAll,'method','uniform');
%DataPackage.QuantOutAll=quantize(DataPackage.OutAll,'method','uniform');

% DataPackage.QuantInAll=quantize(DataPackage.InAll,'method','quantiles');
% DataPackage.QuantOutAll=quantize(DataPackage.OutAll,'method','quantiles');

DataPackage.QuantInAll=quantize(DataPackage.InAll,'levels',nqlevels);
DataPackage.QuantOutAll=quantize(DataPackage.OutAll,'levels',nqlevels);



% Then, we run the default feature selection algorithm, called 'first order utility'. 
% It is based on approximating the mutual information between the set of selected variables 
% and the target by expanding interaction information terms of up to degree 2. 
% In each step, the variable with the highest estimated incremental gain is selected greedily. 
% The output distinguishes between relevance, i.e., mutual information between a feature and the target;
% redundancy, i.e., mutual information between different variables; and conditional redundancy, 
% which measures the increase of mutual information between the previously selected variables and 
% the target, conditional on a selected variable.
%[steps,sel_flag,rel,red,cond_red] = select_features(DataPackage.QuantInAll,DataPackage.QuantOutAll,2);
%[steps,sel_flag,rel,red,cond_red] = select_features(DataPackage.InAll,DataPackage.OutAll,2);


%--------------------------------------------------------------------------
% Self Organization Map
[SOMPackage] = trainSOM(DataPackage,iverb);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%Plot the classification
plotClassDates(SOMPackage);

%--------------------------------------------------------------------------
% End