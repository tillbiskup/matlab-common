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
% 2015-04-09

mapping = getMappingTable(format.version);

for entry = 1:size(mapping,1)
    if ~isempty(mapping{entry,1}) && ~isempty(mapping{entry,2}) && ...
            commonStructureHasField(info,mapping{entry,1}) && ...
            commonStructureHasField(dataset,mapping{entry,2})
        switch lower(mapping{entry,3})
            case 'join'
                dataset = commonSetCascadedField(...
                    dataset,mapping{entry,2},...
                    [commonGetCascadedField(dataset,mapping{entry,2}) ...
                    commonGetCascadedField(info,mapping{entry,1})]);
            case 'joinwithspace'
                dataset = commonSetCascadedField(...
                    dataset,mapping{entry,2},...
                    [commonGetCascadedField(dataset,mapping{entry,2}) ...
                    ' ' commonGetCascadedField(info,mapping{entry,1})]);
            case 'splitvalueunit'
                valueUnit = regexp(...
                    commonGetCascadedField(info,mapping{entry,1}),...
                    ' ','split');
                % In case splitting didn't work (e.g., "N/A" as value)
                if length(valueUnit)<2
                    valueUnit = {'',''};
                end
                dataset = commonSetCascadedField(...
                    dataset,[mapping{entry,2} '.value'],...
                    str2num(valueUnit{1})); %#ok<ST2NM>
                dataset = commonSetCascadedField(...
                    dataset,[mapping{entry,2} '.unit'],valueUnit{2});
            case 'str2double'
                dataset = commonSetCascadedField(...
                    dataset,mapping{entry,2},...
                    str2double(...
                    commonGetCascadedField(info,mapping{entry,1})));
            otherwise
                dataset = commonSetCascadedField(...
                    dataset,mapping{entry,2},...
                    commonGetCascadedField(info,mapping{entry,1}));
        end
    end
end

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
