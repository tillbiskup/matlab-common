function commonAssignParsedVariables(structure)
% COMMONASSIGNPARSEDVARIABLES Assign parsed variables in caller.
%
% Usage
%   commonAssignParsedVariables(structure)
%
%   structure - struct
%               Structure with results of InputParser, normally
%               p.Results if p is an object of class InputParser
%
% Useful especially for optional parameters with default values. Normally,
% one would need to call them via "p.Results.<parametername>", leading to
% long variable names. On the other hand, having to manually assign each of
% the parameters in "p.Results" by hand is often error-prone.

% Copyright (c) 2015, Till Biskup
% 2015-06-02

parsedVariables = fieldnames(structure);
for variable = 1:length(parsedVariables)
    assignin('caller',parsedVariables{variable},structure.(parsedVariables{variable}));
end

end