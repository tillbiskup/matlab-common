function prefix = commonGetPrefix(callerFunctionName)
% COMMONGETPREFIX Return toolbox prefix of calling function. Needed for
% inheriting functionality from common toolbox, such as "install".
%
% Usage
%   prefix = commonGetPrefix(callerFunctionName)
%
%   callerFunctionName - string
%                        Name of the function that calls commonGetPrefix
%                        Use "mfilename" when calling commonGetPrefix
%
%   prefix             - string
%                        Toolbox prefix of the calling function
%
% IMPORTANT NOTE: May only be called from functions whose name starts with
% "common", as most of the common toolbox routines do. Otherwise it most
% probably doesn't work as expected.

% Copyright (c) 2015, Till Biskup
% 2015-05-28

% Assign default output
prefix = '';

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('callerFunctionName', @(x)ischar(x));
    p.parse(callerFunctionName);
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

[stack,~] = dbstack;

stackIndex = length(stack);

if stackIndex == 1
    return;
elseif stackIndex > 2
    stackIndex = 3;
end

prefix = stack(stackIndex).name(...
    1:end-(length(callerFunctionName)-length('common')));


end