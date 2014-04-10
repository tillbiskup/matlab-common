function [missing,wrong] = commonCompareModelWithStructure(model,structure)
% commonCompareModelWithStructure Compare a model structure to a given
% structure and check for missing fields or wrong field types.
%
% Usage
%   [missing,wrong] = commonCompareModelWithStructure(model,structure)
%
%   model
%
%   structure
%
%   missing
%
%   wrong
%
% SEE ALSO: commonDatasetCheck

% (c) 2014, Till Biskup
% 2014-04-10

missing = cell(0);
wrong = cell(0);
    function traverse(model,structure,parent)
        modelFieldNames = fieldnames(model);
        for fieldName=1:length(modelFieldNames)
            if ~isfield(structure,modelFieldNames{fieldName})
                missing{end+1} = ...
                    sprintf('%s.%s',parent,modelFieldNames{fieldName}); %#ok<AGROW>
            elseif isempty(model.(modelFieldNames{fieldName}))
                if isstruct(model.(modelFieldNames{fieldName}))
                    if ~isstruct(structure.(modelFieldNames{fieldName}))
                        wrong{end+1} = ...
                            sprintf('%s.%s',parent,modelFieldNames{fieldName}); %#ok<AGROW>
                    end
                    traverse(...
                        model.(modelFieldNames{fieldName}),...
                        structure.(modelFieldNames{fieldName}),...
                        [parent '.' modelFieldNames{fieldName}]...
                        );
                else
                    modelClass = class(model.(modelFieldNames{fieldName}));
                    structureClass = class(structure.(modelFieldNames{fieldName}));
                    if ~strcmpi(modelClass,structureClass)
                        wrong{end+1} = ...
                            sprintf('%s.%s',parent,modelFieldNames{fieldName}); %#ok<AGROW>
                    end
                end
            else
                for arrayIndex=1:length(model.(modelFieldNames{fieldName}))
                    if isstruct(model.(modelFieldNames{fieldName})(arrayIndex))
                        if ~isstruct(structure.(modelFieldNames{fieldName})(arrayIndex))
                            wrong{end+1} = ...
                                sprintf('%s.%s',parent,modelFieldNames{fieldName}); %#ok<AGROW>
                        end
                        traverse(...
                            model.(modelFieldNames{fieldName})(arrayIndex),...
                            structure.(modelFieldNames{fieldName})(arrayIndex),...
                            [parent '.' modelFieldNames{fieldName}]...
                            );
                    else
                        modelClass = class(model.(modelFieldNames{fieldName})(arrayIndex));
                        structureClass = class(structure.(modelFieldNames{fieldName})(arrayIndex));
                        if ~strcmpi(modelClass,structureClass)
                            wrong{end+1} = ...
                                sprintf('%s.%s',parent,modelFieldNames{fieldName}); %#ok<AGROW>
                        end
                    end
                end
            end
        end
    end
traverse(model,structure,inputname(2));
end