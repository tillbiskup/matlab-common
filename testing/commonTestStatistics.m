function commonTestStatistics(status,messages,varargin)
% COMMONTESTSTATISTICS Analyse test results from commonTest calls and
% display some statistics.
%
% Usage:
%   commonTestStatistics(status,messages);
%
%   status   - vector
%              Numeric status of the tests performed.
%              For the meaning of the numbers see documentation of
%              "commonTest"
%
%   messages - cell array
%              Warning strings or MException objects, respectively, if the
%              test issued a warning or threw an exception, empty
%              otherwise.
%              Needs to be of same size as "status".
%
% SEE ALSO: commonTest

% Copyright (c) 2015, Till Biskup
% 2015-04-05

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('status', @isvector);
    p.addRequired('messages', @(x)iscell(x) && length(x)==length(status));
    %p.addParamValue('dims',321,@isvector);
    p.parse(status,messages,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Some statistics
fprintf('Tests passed:        %i\n',length(status(status==0)));
fprintf('Tests with warnings: %i\n',length(status(status==1)));
fprintf('Tests with errors:   %i\n',length(status(status==2)));

end