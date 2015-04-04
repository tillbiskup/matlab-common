function commonPlot(dataset,varargin)
% COMMONPLOT Display data contained in dataset as either 1D or 2D plot.
% Useful for a quick overview of the data. Axes labels are set properly,
% given that the dataset contains proper values in the respective axes
% fields.
%
% Usage:
%   commonPlot(dataset)
%   commonPlot(dataset,<parameter>,<value>)
%
%   dataset - struct
%             Dataset complying with specification of toolbox dataset
%             structure
%
%   Optional parameters
%
%   tight   - logical (true/false)
%             Whether to set axes tight to data
%             Default: true
%
% SEE ALSO: plot

% Copyright (c) 2015, Till Biskup
% 2015-04-04

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('dataset', @(x)isstruct(x));
    p.addParamValue('tight',true,@islogical);
    p.parse(dataset,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% In case we have 1D data
if isscalar(dataset.data) || isvector(dataset.data)
    plot1Ddata(dataset,p.Results);
% In case we have 2D data
elseif ismatrix(dataset.data)
    plot2Ddata(dataset,p.Results)
% In case we have >2D data
else
    disp('Multidimensional arrays with dim > 2 not supported yet...');
    return;
end

end


function plot1Ddata(dataset,options)

plot(dataset.axes.data(1).values,dataset.data);
xlabel(createAxisLabelString(dataset.axes.data(1)));
ylabel(createAxisLabelString(dataset.axes.data(2)));

% Axes tight
if options.tight
    set(gca,'XLim',dataset.axes.data(1).values([1 end]));
    limits = [min(dataset.data) max(dataset.data)];
    set(gca,'YLim',...
        [limits(1)-0.05*diff(limits) limits(2)+0.05*diff(limits)]);
end

end


function plot2Ddata(dataset,options)

imagesc(dataset.axes.data(2).values,dataset.axes.data(1).values,dataset.data);
set(gca,'YDir','normal')
xlabel(createAxisLabelString(dataset.axes.data(1)));
ylabel(createAxisLabelString(dataset.axes.data(2)));

% Axes tight
if options.tight
    set(gca,'XLim',dataset.axes.data(1).values([1 end]));
    set(gca,'YLim',dataset.axes.data(2).values([1 end]));
end

end

function str = createAxisLabelString(axis)

str = sprintf('{\\it %s}',axis.measure);
if isempty(axis.unit) || all(isspace(axis.unit))
    return;
end
str = [ str ' / ' axis.unit ];

end