function mapped = commonStructMap(mapped,tomap,mapping)
% COMMONSTRUCTMAP Map one structure onto another.
%
% Usage:
%   mapped = commonStructMap(mapped,tomap,mappingTable)
%
%   mapped       - stuct
%                  (hierarchical) structure with fields the contents of the
%                  structure "tomap" should be mapped on
%
%   tomap        - struct
%                  Info structure as returned by commonInfofileLoad
%
%   mappingTable - cell (nx3)
%                  Mapping table
%
%                  1st column: field of structure in "tomap"
%
%                  2nd column: corresponding field in "mapped"
%
%                  3rd column: modifier telling commonStructMap how to
%                  modify the field from "tomap" to fit into "mapping".
%
%                  Currently allowed (case insensitive) modifiers contain:
%                  join, joinWithSpace, splitValueUnit, str2double
%
%                  Furthermore, you can add arbitrary anonymous functions
%                  that start with "@" - and you're entirely responsible
%                  for the result... (although there is a try-catch around
%                  and catch will make a plain copy of the field).
%
%                  See the source code for more info
%
% NOTE: You can add as many fields as you like in the first two columns, as
% the function will check for the existence of the respective fields in the
% corresponding structure. 
%
% SEE ALSO: commonDatasetMapInfo

% Copyright (c) 2015, Till Biskup
% 2015-11-23

for entry = 1:size(mapping,1)
    if ~isempty(mapping{entry,1}) && ~isempty(mapping{entry,2}) && ...
            commonStructureHasField(tomap,mapping{entry,1}) && ...
            commonStructureHasField(mapped,mapping{entry,2})
        switch lower(mapping{entry,3})
            case 'join'
                mapped = commonSetCascadedField(...
                    mapped,mapping{entry,2},...
                    [commonGetCascadedField(mapped,mapping{entry,2}) ...
                    commonGetCascadedField(tomap,mapping{entry,1})]);
            case 'joinwithspace'
                mapped = commonSetCascadedField(...
                    mapped,mapping{entry,2},...
                    [commonGetCascadedField(mapped,mapping{entry,2}) ...
                    ' ' commonGetCascadedField(tomap,mapping{entry,1})]);
            case 'splitvalueunit'
                valueUnit = regexp(...
                    commonGetCascadedField(tomap,mapping{entry,1}),...
                    ' ','split');
                % In case splitting didn't work (e.g., "N/A" as value)
                if length(valueUnit)<2
                    valueUnit = {'',''};
                end
                mapped = commonSetCascadedField(...
                    mapped,[mapping{entry,2} '.value'],...
                    str2num(valueUnit{1})); %#ok<ST2NM>
                mapped = commonSetCascadedField(...
                    mapped,[mapping{entry,2} '.unit'],valueUnit{2});
            case 'str2double'
                mapped = commonSetCascadedField(...
                    mapped,mapping{entry,2},...
                    str2double(...
                    commonGetCascadedField(tomap,mapping{entry,1})));
            otherwise
                % Handle special case of anonymous function
                if strncmp('@',mapping{entry,3},1)
                    try
                        anonFun = str2func(mapping{entry,3});
                        mapped = commonSetCascadedField(...
                            mapped,mapping{entry,2},...
                            anonFun(...
                            commonGetCascadedField(tomap,mapping{entry,1})));
                    catch %#ok<CTCH>
                        mapped = commonSetCascadedField(...
                            mapped,mapping{entry,2},...
                            commonGetCascadedField(tomap,mapping{entry,1}));
                    end
                else
                    mapped = commonSetCascadedField(...
                        mapped,mapping{entry,2},...
                        commonGetCascadedField(tomap,mapping{entry,1}));
                end
        end
    end
end

end

