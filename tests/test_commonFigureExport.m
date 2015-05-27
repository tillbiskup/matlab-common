% TESTCOMMONFIGUREEXPORT Test routine for commonFigureExport.

% Copyright (c) 2015, Till Biskup
% 2015-05-13

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
commonPlot(dataset1D);

commonFigureExport(figHandles(end),'test','setFontSize',false);
%[status(end+1),messages{end+1}] = commonTest('');

%% Test with 2D data and 3D display
figHandles(end+1) = figure();
mesh(dataset2D.data(1:5:end,1:5:end));
xlabel('{\it something} / bla');
ylabel('{\it something else} / blub');
zlabel('{\it intensity} / a.u.');
title('Fancy super-duper 2D plot with title')

commonFigureExport(figHandles(end),'test3D','setFontSize',false);
%[status(end+1),messages{end+1}] = commonTest('');

