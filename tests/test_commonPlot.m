function test_commonPlot
% TEST_COMMONPLOT Test routine testing commonPlot.
%
% Usage:
%   test_commonPlot
%
% SEE ALSO: commonTestCreateDataset

% Copyright (c) 2015, Till Biskup
% 2015-04-05

% Array of figure handles;
figHandles = [];

% Test results
status = [];
messages = cell(0);

%% Create datasets
dataset1D = commonTestCreateDataset('noise',true);
dataset1D.label = 'Dataset 1D for testing';
dataset2D = commonTestCreateDataset('ndims',2,'noise',true);
dataset2D.label = 'Dataset 2D for testing';

%% First simple test
figHandles(end+1) = figure();
[status(end+1),messages{end+1}] = commonTest('commonPlot(dataset1D)');

figHandles(end+1) = figure();
[status(end+1),messages{end+1}] = commonTest('commonPlot(dataset2D)');

%% User interaction: Close figures?
answer = input('Close figures? [y/N] ','s');
if strcmpi(answer,'y')
    close(figHandles);
end

commonTestStatistics(status,messages);

end