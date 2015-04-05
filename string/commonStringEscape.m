function string = commonStringEscape(string,varargin)
% COMMONSTRINGESCAPE Escape parts of strings that are control characters in
% certain context. 
%
% Usage:
%   string = commonStringEscape(string)
%   string = commonStringEscape(string,interpreter)
%
%   string      - string
%                 String that should be escaped
%
%   Optional parameters
%
%   interpreter - string
%                 "Interpreter" the string should be escaped for.
%                 Currently allowed values are: "LaTeX", "TeX"
%                 Default: TeX
%
% SEE ALSO: strrep, regexprep

% Copyright (c) 2015, Till Biskup
% 2015-04-05

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('string', @ischar);
    p.addOptional('interpreter','TeX',@ischar);
    p.parse(string,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

switch lower(p.Results.interpreter)
    case {'tex','latex'}
        string = strrep(string,'_','\_');
    otherwise
end

end