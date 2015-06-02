function sanitisedName = commonSanitiseVariableName(name,varargin)
% COMMONSANITISEVARIABLENAME Convert name into valid name for variables or
% fieldnames in structs.
%
% Usage:
%   sanitisedName = commonSanitiseVariableName(name)
%
%   name          - string
%                   string to convert into proper variable name/field name
%                   for Matlab(r) struct
%
%   sanitisedName - string
%                   Sanitised string
%
% Spaces are removed and the string camelCased accordingly, All characters
% not allowed in Matlab(r) variable names are silently removed, leading
% numerical characters are prepended by the letter "a". The first character
% is converted to lower-case. Finally, if the length of the variable name
% exceeds the return value of namelengthmax, the name gets truncated
% accordingly. 

% Copyright (c) 2015, Till Biskup
% 2015-06-02

% Assign default output
sanitisedName = '';

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('name', @(x)ischar(x));
    p.parse(name,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

sanitisedName = name;

% If name is already a valid varname, return immediately
if isvarname(name)
    return;
end

% If there is a percent sign (aka comment), cut comment
commentSignPosition = strfind(sanitisedName,'%');
if ~isempty(commentSignPosition)
    sanitisedName = strtrim(...
        sanitisedName(1:commentSignPosition-1));
end

% Remove all characters that are not allowed and remove leading and
% trailing whitespace
sanitisedName = strtrim(regexprep(sanitisedName,'[^a-zA-Z_0-9 ]*',''));

% If there are spaces in the field name, camelCase and remove spaces
if find(isspace(sanitisedName))
    sanitisedName(find(isspace(sanitisedName))+1) = ...
        upper(sanitisedName(find(isspace(sanitisedName))+1));
    sanitisedName(isspace(sanitisedName)) = [];
end

% If field name doesn't start with a letter, prepend a letter
if regexp(sanitisedName,'[a-zA-Z]','once') ~= 1
    sanitisedName = ['a' sanitisedName];
end

% Convert first character to lower case
sanitisedName = [lower(sanitisedName(1)) sanitisedName(2:end)];

% If variable name exceeds allowed length, truncate
if length(sanitisedName) > namelengthmax
    sanitisedName = sanitisedName(1:namelengthmax);
end

end
