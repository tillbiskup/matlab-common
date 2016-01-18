function table = commonDatasetMappingTableV0_2_0
% COMMONDATASETMAPPINGTABLEV0_2_0 Mapping table for mapping common info
% file (v. 0.2.0) contents to dataset.
%
% Usage
%   table = commonDatasetMappingTableV0_2_0
%
%   table - cell (nx3)
%           1st column: field of info structure returned by
%           commonInfofileLoad
%
%           2nd column: corresponding field in dataset structure as
%           returned by commonDatasetCreate
%
%           3rd column: modifier telling dataasetMapInfo how to modify the
%           field from the info file to fit into the dataset
%
%           Currently allowed (case insensitive) modifiers contain:
%           join, joinWithSpace, splitValueUnit, str2double
%
%           See the source code of commonDatasetMapInfo for more info
%
% NOTE FOR TOOLBOX DEVELOPERS:
% Use commonInfofileMappingTableHelper to create the basic structure of the
% cell array "table" and create your own PREFIXdatasetMappingTable function
% as a copy of this function.
%
% SEE ALSO: commonDatasetMapInfo, commonDatasetCreate, commonInfofileLoad,
% commonInfofileMappingTableHelper

% Copyright (c) 2016, Till Biskup
% 2016-01-18

oldTable = commonDatasetMappingTableV0_1_0;
table = { ...
    'sample.id','sample.id','' ...
    };

% Join mapping tables from previous version and this version
table = [oldTable; table];

end