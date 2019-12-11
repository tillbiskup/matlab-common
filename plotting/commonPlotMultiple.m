function commonPlotMultiple(datasets,varargin)
% COMMONPLOTMULTIPLE Display multiple data contained in dataset as 1D plot.
% Useful for a quick overview of the data. Axes labels are set properly,
% given that the dataset contains proper values in the respective axes
% fields.
%
% Usage:
%   commonPlotMultiple(datasets)
%   commonPlotMultiple(datasets,<parameter>,<value>)
%
%   datasets - cell array of datasets
%              Datasets complying with specification of toolbox dataset
%              structure
%
%   Optional parameters
%
%   tight              - logical
%                        Whether to set axes tight to data
%                        NOTE: For 1D data, in vertical direction a
%                        fraction of the total amplitude is added on both
%                        ends to prevent data from directly hitting the
%                        axes/ticks.
%                        Default: true
%
%   title              - string
%                        Either the keyword "none" or a string that is used
%                        as title.
%                        Default: auto
%
%   legend             - struct
%                        Properties of the legend
%                        The cell array containing the label strings
%                        is auto-generated from the labels of the datasets
%                        if not provided explicitly.
%                        Default:
%                        struct('Labels',{<auto>},'Location','northeast')
%
%   lineProperties     - struct
%                        Properties of the line of a 1D plot
%                        NOTE: Every property is allowed that is understood
%                        by the "line" command.
%                        Default: 
%                        struct('color',[0 0 0],'LineStyle','-');
%
%   zeroLine           - logical
%                        Whether to plot zero line(s)
%                        Default: true
%
%   zeroLineProperties - struct
%                        Properties of the zero line(s)
%                        NOTE: Every property is allowed that is understood
%                        by the "line" command.
%                        Default: 
%                        struct('color',[0.5 0.5 0.5],'LineStyle','-');
%
% A note to developers of derived toolboxes: In order to load the proper
% configuration of your own toolbox and be independent of the configuration
% distributed with the common toolbox, you can pass the contents of your
% own configuration with the call of commonPlot:
%
%   config = PREFIXconfigGet('<yourFileName>');
%   commonPlot(dataset,'config',config);
%
% SEE ALSO: plot

% Copyright (c) 2018-19, Till Biskup
% 2019-12-11

% Set default line properties
% NOTE: Every property is allowed that is understood by the "line" command
lineProperties = struct(...
    'Color',[0 0 0],...
    'LineStyle','-' ...
    );
legendProperties = struct(...
    'Location','northeast' ...
    );
legendProperties.Labels = cell(0);
zeroLineProperties = struct(...
    'Color',[0.5 0.5 0.5],...
    'LineStyle',':' ...
    );
lineColors = [ ...
    0.0, 0.0, 0.0; ...
    1.0, 0.0, 0.0; ...
    0.0, 0.0, 1.0; ...
    0.8, 0.8, 0.0; ...
    ];

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('datasets', @(x)iscell(x));
    p.addParameter('tight',true,@islogical);
    p.addParameter('title','none',@ischar);
    p.addParameter('legendProperties',legendProperties,@isstruct);
    p.addParameter('lineProperties',lineProperties,@isstruct);
    p.addParameter('zeroLine',true,@islogical);
    p.addParameter('zeroLineProperties',zeroLineProperties,@isstruct);
    p.addParameter('config',struct(),@isstruct);
    p.parse(datasets,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

commonAssignParsedVariables(p.Results);
parameters = p.Results;

% Read configuration - handle different configuration files for
% different derived toolboxes in an appropriate way.
if isempty(fieldnames(config)) %#ok<NODEF>
    config = commonConfigGet('plot');
end


for dataset = 1:length(datasets)
    % In case we have 1D data
    if isscalar(datasets{dataset}.data) || isvector(datasets{dataset}.data)
        parameters.lineProperties.Color = lineColors(mod(dataset,length(lineColors))+1,:);
        plot1Ddata(datasets{dataset},parameters);
        hold on;
        % In case we have >1D data
    else
        disp('Multidimensional arrays with dim > 2 not supported yet...');
        return;
    end
end
hold off;

% Handle title
switch lower(p.Results.title)
    case 'none'
        title('');
    otherwise
        title(commonStringEscape(p.Results.title,'TeX'));
end

% Handle legend
addLegend(datasets,legendProperties)

% Handle zero line
if p.Results.zeroLine
    addZeroLines(zeroLineProperties);
end

end


function plot1Ddata(dataset,options)

hLine = plot(dataset.axes.data(1).values,dataset.data);
xlabel(createAxisLabelString(dataset.axes.data(1)));
ylabel(createAxisLabelString(dataset.axes.data(2)));

% Set line properties
for lHandle = 1:length(hLine)
    set(hLine(lHandle),options.lineProperties);
end

% Axes tight
if options.tight
    set(gca,'XLim',dataset.axes.data(1).values([1 end]));
    limits = [min(dataset.data) max(dataset.data)];
    set(gca,'YLim',...
        [limits(1)-0.05*diff(limits) limits(2)+0.05*diff(limits)]);
end

end


function str = createAxisLabelString(axis)

str = sprintf('{\\it %s}',axis.measure);
if isempty(axis.unit) || all(isspace(axis.unit))
    return;
end
str = [ str ' / ' axis.unit ];

end


function addLegend(datasets,legendProperties)

if isfield(legendProperties,'Labels') 
    if isempty(legendProperties.Labels)
        labels = {};
        for dataset = 1:length(datasets)
            labels{dataset} = datasets{dataset}.label;
        end
    else
        labels = legendProperties.Labels;
    end
    legendProperties = rmfield(legendProperties,'Labels');
else
    labels = {};
end


hl = legend(labels);

propertyNames = fieldnames(legendProperties);
for field = 1:length(propertyNames)
    set(hl,propertyNames{field},legendProperties.(propertyNames{field}))
end

end


function addZeroLines(lineProperties)

xLimits = get(gca,'XLim');
yLimits = get(gca,'YLim');

hLine = [];

if prod(xLimits) <= 0
    hold on
    hLine(end+1) = line([0 0],yLimits);
    hold off
end

if prod(yLimits) <= 0
    hold on
    hLine(end+1) = line(xLimits,[0 0]);
    hold off
end

% Set line properties
for lHandle = 1:length(hLine)
    set(hLine(lHandle),lineProperties);
    set(hLine(lHandle),'HandleVisibility','off');
end

end
