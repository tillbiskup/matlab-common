function [status,message] = commonTest(functionCall,varargin)
% COMMONTEST Perform test on function call and return warnings and errors.
%
% Usage:
%   [status,message] = commonTest(functionCall)
%   [status,message] = commonTest(functionCall,parameters)
%
%   functionCall - string
%
%   status       - scalar
%                  One of the following: 0, 1, 2
%                  0 - OK - Test went well without warnings or errors.
%                  1 - WARNINGS - Test produced warnings, but passed.
%                  2 - FAILED - Test failed with errors/exceptions.
%
%   message      - string/MException object
%                  Warning string in case the test issed a warning.
%                  MException object in case the test threw an exception.
%                  Empty otherwise.
%
%   Optional parameters
%
%   something    - xxx
%
% The results of commonTest can be summarised and visualised using
% commonTestStatistics. Therefore, it is useful to save the results from
% successive tests into arrays (vector for status, cell array for messages)
% and pass this afterwards to commonTestStatistics:
%
%   % Test results
%   status = [];
%   messages = cell(0);
%
%   [status(end+1),messages{end+1}] = commonTest(<functionCall>);
%   % ...
%
%   commonTestStatistics(status,messages);
%
% SEE ALSO: commonTestStatistics

% Copyright (c) 2015, Till Biskup
% 2015-04-05

% Set default output
status = 0;
message = [];

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('functionCall', @ischar);
    %p.addParamValue('dims',321,@isvector);
    p.parse(functionCall,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Save current and afterwards reset lastwarn state
previousLastWarning = lastwarn;
lastwarn('');

fprintf('Testing... ');

try
    evalin('caller',functionCall);
catch exception
    message = exception;
    status = 2;
end

if ~isempty(lastwarn)
    message = lastwarn;
    status = 1;
end

% Restore lastwarn state
lastwarn(previousLastWarning);

switch status
    case 2
        fprintf(2,'[FAILED]\n');
    case 1
        fprintf(1,'[WARNINGS]\n');
    otherwise
        fprintf('[OK]\n');
end

end
