function [In,Out,InTest,OutTest] = partitiondataforML(InAll,OutAll,validation_fraction)
% Split up the data to provide a training dataset and independent validation dataset 
% of size specified by the validation fraction, validation_fraction

%--------------------------------------------------------------------------
disp(['Validation Fraction is: ' num2str(validation_fraction)])
ipointer=1:length(OutAll);
cvpart=cvpartition(ipointer,'holdout',validation_fraction);

% Training Data
In=InAll(training(cvpart),:);
Out=OutAll(training(cvpart),:);

% Independent Validation Data
InTest=InAll(test(cvpart),:);
OutTest=OutAll(test(cvpart),:);