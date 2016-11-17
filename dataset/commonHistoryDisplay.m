function commonHistoryDisplay(dataset)
% COMMONHISTORYDISPLAY Show overview of history records for dataset on
% command line.
%
% Usage:
%   commonHistoryDisplay(dataset)
%
%   dataset - struct
%             dataset structure with history

% Copyright (c) 2016, Till Biskup
% 2016-11-17

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('dataset',@(x)isstruct(x));
    p.parse(dataset);
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

fprintf('\n');

for record = 1:length(dataset.history)
    fprintf('%s\n',dataset.history{record}.kind);
    fprintf('  Why?  %s\n',dataset.history{record}.purpose);
    fprintf('  How?  %s\n',dataset.history{record}.functionName);
    fprintf('  When? %s\n',dataset.history{record}.date);
    fprintf('  Who?  %s\n',dataset.history{record}.system.username);
    fprintf('\n');
end
