function commonInfofileMappingTableHelper(infofile)
% COMMONINFOFILEMAPPINGTABLEHELPER Helper for creating datasetMappingTable
% functions mapping infofile contents to datasets.
%
% Usage
%   commonInfofileMappingTableHelper(infofile)
%
%   infofile - string
%              Name of a valid info file
%
% SEE ALSO: commonDatasetMappingTable, commonInfofileLoad

% (c) 2014, Till Biskup
% 2014-04-11

info = commonInfofileLoad(infofile);

firstLevelFields = fieldnames(info);
for firstLevelField = 1:length(firstLevelFields)
    if isstruct(info.(firstLevelFields{firstLevelField}))
        secondLevelFields = fieldnames(...
            info.(firstLevelFields{firstLevelField}));
        for secondLevelField = 1:length(secondLevelFields)
            fprintf('    ''%s.%s'','''',''''; ...\n',...
                firstLevelFields{firstLevelField},...
                secondLevelFields{secondLevelField});
        end
    else
        fprintf('    ''%s'','''','''' ...\n',...
            firstLevelFields{firstLevelField});
    end
end

end