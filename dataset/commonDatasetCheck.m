function [missingFields,wrongType] = commonDatasetCheck(dataset)
% COMMONDATASETCHECK Check data structure for compliance with
% specification. 
%
% Usage
%   [missingFields,wrongType] = commonDatasetCheck(dataset)
%
%   dataset       - struct
%                   Structure complying with common dataset
%
%   missingFields - cell array
%                   List of fields missing in dataset according to
%                   specification
%
%   wrongType     - cell array
%                   List of fields in dataset with wrong type according to
%                   specification
%
% NOTE FOR TOOLBOX DEVELOPERS:
% PREFIXdatasetCheck simply calls commonDatasetCheck. This will
% automatically check a dataset of the PREFIX toolbox type.
%
% SEE ALSO: commonDatasetCreate

% Copyright (c) 2014-15, Till Biskup
% 2015-05-30

% Get structure of dataset corresponding to current toolbox
datasetStructure = getDatasetStructure;

[missingFields,wrongType] = ...
    commonCompareModelWithStructure(datasetStructure,dataset);

end


%% Subfunction: getDatasetStructure
function datasetStructure = getDatasetStructure
    datasetCreateFunction = getDatasetCreateFunction;
    datasetStructure = datasetCreateFunction();
end

%% Subfunction: getDatasetCreateFunction
function datasetCreateFunction = getDatasetCreateFunction

[stack,~] = dbstack('-completenames');

suffix = 'DatasetCheck';

if length(stack)>2 && strcmpi(...
        stack(3).name(end-length(suffix)+1:end),suffix)
    stackIndex = 3;
else
    stackIndex = 2;
end

toolboxPrefix = stack(stackIndex).name(1:end-length(suffix));

datasetCreateFunction = ...
    str2func(commonCamelCase({toolboxPrefix, 'datasetCreate'}));

end
