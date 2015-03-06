function table = commonDatasetMappingTable
% COMMONDATASETMAPPINGTABLE Mapping table for mapping info file contents to
% dataset.
%
% Usage
%   table = commonDatasetMappingTable
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

% Copyright (c) 2014-15, Till Biskup
% 2015-03-06

table = {...
    'general.dateStart','parameters.date.start',''; ...
    'general.timeStart','parameters.date.start','joinWithSpace'; ...
    'general.dateEnd','parameters.date.end',''; ...
    'general.timeEnd','parameters.date.end','joinWithSpace'; ...
    'general.operator','parameters.operator',''; ...
    'general.label','label',''; ...
    'general.purpose','parameters.purpose',''; ...
    'sample.name','sample.name',''; ...
    'sample.description','sample.description',''; ...
    'sample.solvent','sample.solvent',''; ...
    'sample.preparation','sample.preparation',''; ...
    'temperature.temperature','parameters.temperature','splitValueUnit'; ...
    'comment','comment','' ...
    };

end