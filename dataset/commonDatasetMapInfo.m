function dataset = commonDatasetMapInfo(dataset,info,format)
% COMMONDATASETMAPINFO Map info from info file to dataset structure.
%
% Usage:
%   dataset = commonDatasetMapInfo(dataset,info,format)
%
%   dataset - stucture
%             Dataset complying with specification of toolbox dataset
%             structure
%
%   info    - struct
%             Info structure as returned by commonInfofileLoad
%
%   format  - struct
%             Format of the info file as returned by commonInfofileLoad
%
% NOTE FOR DEVELOPERS: The corresponding <PREFIX>datasetMapInfo routine
% needs to call ALWAYS directly this commonDatasetMapinfo routine in order
% to work properly. Otherwise it will try to look for the mapping table in
% the wrong toolbox (if cascading more than one toolbox, e.g.,
% cwEPR->EPR->common). Cascading of mapping tables is EXCLUSIVELY done in
% the respective <PREFIX>datasetMappingTableVa_b_c routines.
%
% SEE ALSO: commonDatasetCreate, commonInfofileLoad

% Copyright (c) 2014-15, Till Biskup
% Copyright (c) 2015, Deborah Meyer
% 2015-11-23

mapping = getMappingTable(format.version);

dataset = commonStructMap(dataset,info,mapping);

end


%% Subfunction: getMappingTable
function mapping = getMappingTable(version)

[~,toolboxPrefix] = getToolboxPathAndPrefix;
if isempty(version)
    mappingTableCommand = str2func(...
        commonCamelCase({toolboxPrefix,'datasetMappingTable'}));
else
    mappingTableCommand = str2func(...
        [ commonCamelCase({toolboxPrefix,'datasetMappingTable'}) ...
        'V' strrep(version,'.','_')]);
end
mapping = mappingTableCommand();
end

%% Subfunction: getToolboxPathAndPrefix
function [toolboxPath,toolboxPrefix] = getToolboxPathAndPrefix

[stack,~] = dbstack('-completenames');

if length(stack)>3
    stackIndex = 4;
else
    stackIndex = 3;
end

[toolboxPath,~,~] = fileparts(stack(stackIndex).file);
toolboxPath = toolboxPath(1:end-length('/dataset'));
toolboxPrefix = stack(stackIndex).name(1:end-length('DatasetMapInfo'));

end
