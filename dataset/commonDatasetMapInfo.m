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
                 dataset = commonSetCascadedField(...
                     dataset,[mapping{entry,2} '.value'],...
                     str2double(valueUnit{1}));
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

function mapping = getMappingTable
    mapping = commonDatasetMappingTable;
end
