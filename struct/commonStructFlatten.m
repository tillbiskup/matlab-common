function flatStructure = commonStructFlatten(structure,varargin)
% COMMONSTRUCTFLATTEN Flatten hierarchical structure to having only leafs.
%
% Usage:
%   flatStructure = commonStructFlatten(structure)
%   flatStructure = commonStructFlatten(structure,<parameter>,<value>)
%
%   structure     - struct
%                   Hierarchical structure that may contain structures
%
%   flatStructure - struct
%                   Flat structure containing only leafs
%
%
% You can specify optional parameters as key-value pairs. Valid parameters
% and their values are:
%
%   overwrite - boolean
%               Overwrite leafs with same name
%               Default: true

% Copyright (c) 2015, Till Biskup
% 2015-06-03

% Assign default output
flatStructure = structure;

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('structure', @(x)isstruct(x));
    p.addParameter('overwrite',true,@(x)islogical(x));
    p.parse(structure,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

flatStructure = flattenStructure(structure,flatStructure,p.Results);

end


function flatStructure = flattenStructure(structure,flatStructure,options)

fields = fieldnames(structure);
for field = 1:length(fields)
    if isstruct(structure.(fields{field}))
        flatStructure = flattenStructure(structure.(fields{field}),...
            flatStructure,options);
        flatStructure = rmfield(flatStructure,fields{field});
    else
        if ~options.overwrite
            if commonStructureHasField(flatStructure,fields{field})
                return;
            end
        end
        flatStructure.(fields{field}) = structure.(fields{field});
    end
end

end
