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
%   tight              - logical
%                        Whether to set axes tight to data
%                        NOTE: For 1D data, in vertical direction a
%                        fraction of the total amplitude is added on both
%                        ends to prevent data from directly hitting the
%                        axes/ticks.
%                        Default: true
%
%   title              - string
%                        Either one of the keywords "auto" or "none" or a
%                        string that is used as title.
%                        Default: auto
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
% SEE ALSO: plot

% Copyright (c) 2015, Till Biskup
% 2015-04-05

% Set default line properties
% NOTE: Every property is allowed that is understood by the "line" command
lineProperties = struct(...
    'Color',[0 0 0],...
    'LineStyle','-' ...
    );
zeroLineProperties = struct(...
    'Color',[0.5 0.5 0.5],...
    'LineStyle',':' ...
    );

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('dataset', @(x)isstruct(x));
    p.addParamValue('tight',true,@islogical);
    p.addParamValue('title','auto',@ischar);
    p.addParamValue('lineProperties',lineProperties,@isstruct);
    p.addParamValue('zeroLine',true,@islogical);
    p.addParamValue('zeroLineProperties',zeroLineProperties,@isstruct);
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

% Handle title
switch lower(p.Results.title)
    case 'none'
        title('');
    case 'auto'
        title(commonStringEscape(dataset.label,'TeX'));
    otherwise
        title(commonStringEscape(p.Results.title,'TeX'));
end

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

function addZeroLines(lineProperties)

xLimits = get(gca,'XLim');
yLimits = get(gca,'YLim');

if diff([xLimits(2) xLimits(1)]) < 0
    hold on
    hLine(1) = line([0 0],yLimits);
    hold off
end

if diff([xLimits(2) xLimits(1)]) < 0
    hold on
    hLine(2) = line(xLimits,[0 0]);
    hold off
end

% Set line properties
for lHandle = 1:length(hLine)
    set(hLine(lHandle),lineProperties);
end

end