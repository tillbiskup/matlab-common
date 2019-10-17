function commonFigureExport(figureHandle,filename,varargin)
% COMMONFIGUREEXPORT Export Matlab(r) figures to different formats as good
% as possible making use of predefined (user-specific) formats, but at the
% same time giving access to a number of basic parameters.
%
% Usage
%   commonFigureExport(figHandle,filename)
%   commonFigureExport(figHandle,filename,<parameter>,<value>)
%
%   figHandle - handle
%               Handle of graphics (figure) window to save/export
%
%   filename  - string
%               Name of file to save/export the figure to
%               Regardless of the extension given, the file will always
%               automatically get the correct extension resembling the file
%               format.
%
%   There is a number of optional parameters to control the export:
%
%   paperUnits - string
%                One of the units understood by Matlab(r)
%                Default: 'centimeters'
%
%   paperSize  - 2x1 vector
%                Size of the paper (in paperUnits, see above)
%
%   paperSizeCorrection - 4x1 vector
%                Corrections for the paper size to account for Matlab(r)'s
%                incapabilities.
%                Hint: Use with care and test with different types of plots
%
%   fontSize   - scalar
%                Font size in pt
%                If "setFontSize" is true, font size will be set for all
%                children of the figure that shall be exported.
%                Note: In contrast to the figure properties, these font
%                sizes will _not_ be reset after exporting.
%
%   setFontSize - boolean
%                Whether to set font size for all children of figure.
%                Default: true
%   
%
% A note to developers: In order to work in most common cases, the routine
% will only change parameters of the figure, not the underlying axis or
% other graphics handles, with the one exception being the font size of all
% child objects of the figure handle provided as first input argument.
%
% So far, the function has not been checked with newer versions of
% Matlab(r), particularly 2014b and newer, making use of a completely new
% graphics stack.
%
% A note to developers of derived toolboxes: In order to load the proper
% configuration of your own toolbox and be independent of the configuration
% distributed with the common toolbox, you can pass the contents of your
% own configuration with the call of commonFigureExport:
%
%   config = PREFIXconfigGet('<yourFileName>');
%   commonFigureExport(figureHandle,filename,'config',config);
%
% SEE ALSO: print, saveas

% Copyright (c) 2015-19, Till Biskup
% Copyright (c) 2015, Deborah Meyer
% 2019-08-29

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('figureHandle',@ishandle);
    p.addRequired('filename',@ischar);
    p.addParameter('paperUnits','centimeters',@ischar);
    p.addParameter('paperSize',[16 11],@(x)isvector(x) && numel(x)==2);
    p.addParameter('paperSizeCorrection',...
        [-0.5 -0.1 1.25 0.25],@(x)isvector(x) && numel(x)==4);
    p.addParameter('fontSize',10,@isscalar);
    p.addParameter('setFontSize',true,@islogical);
    p.addParameter('config',struct(),@isstruct);
    p.parse(figureHandle,filename,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

commonAssignParsedVariables(p.Results);

% TODO: Read configuration - handle different configuration files for
% different derived toolboxes in an appropriate way.
if isempty(fieldnames(config)) %#ok<NODEF>
    config = commonConfigGet('figureExport');
end

% Save figure properties - will get restored later on.
figureProperties = get(figureHandle);

% Set figure properties according to input parameters and defaults
set(figureHandle,'PaperOrientation','Landscape');
set(figureHandle,'PaperUnits',paperUnits);
% Note: PaperSize needs to be reversed for landscape to work properly
set(figureHandle,'PaperSize',paperSize);
% Note: paperSizeCorrection is empirically determined and applied to
% compensate for buggy Matlab(r) figure export
set(figureHandle,'PaperPosition',...
    [0 0 paperSize]+paperSizeCorrection);

if setFontSize
    % Set font size recursively for ALL children of figure graphics handle
    settingFontSize(figureHandle,fontSize);
end

% Actual export of figure
print(figureHandle,'-dpdf',filename);

% Restore figure properties
% Note: try-catch is used to handle read-only properties that throw errors.
properties = fieldnames(figureProperties);
for property = 1:length(properties)
    try
        set(figureHandle,properties{property},...
            figureProperties.(properties{property}));
    catch %#ok<CTCH>
        continue
    end
end

end


function settingFontSize(graphicsHandle,fontSize)

if isprop(graphicsHandle,'FontSize')
    set(graphicsHandle,'FontSize',fontSize);
end
children = allchild(graphicsHandle);
if ~isempty(children)
    for child = 1:length(children)
        settingFontSize(children(child),fontSize);
    end
end

end
