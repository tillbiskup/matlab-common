function dataset = commonDatasetMapInfo(dataset,info)
% COMMONDATASETMAPINFO Map info from info file to dataset structure.
%
% Usage
%   dataset = commonDatasetMapInfo(dataset,info)
%
%   dataset - stucture
%             Dataset complying with specification of toolbox dataset
%             structure
%
%   info    - struct
%             Info structure as returned by commonInfofileLoad
%
% SEE ALSO: commonDatasetCreate, commonInfofileLoad

% (c) 2014, Till Biskup
% 2014-04-11

mapping = getMappingTable;

for entry = 1:size(mapping,1)
     if commonStructureHasField(info,mapping{entry,1}) && ...
             commonStructureHasField(dataset,mapping{entry,2})
        dataset = commonSetCascadedField(dataset,mapping{entry,2},...
            commonGetCascadedField(info,mapping{entry,1}));
     end
end

end

function mapping = getMappingTable
    mapping = cell(1,2);
%     mapping = {...
%         'general.label','label'
%         };
end
