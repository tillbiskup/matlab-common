function commonTooltipPrecision(varargin)
% COMMONTOOLTIPPRECISION Set precision of data tooltip in current figure.
%
% Usage:
%   commonTooltipPrecision
%   commonTooltipPrecision(precision)
%
% precision - integer
%   (maximum) number of decimals to display
%
%   Default: 8

% Copyright (c) 2020, Till Biskup
% 2020-09-25

if ~commonFigureWindowExists()
    return;
end

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addOptional('precision', 8, @isscalar);
    p.parse(varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

dcm_obj = datacursormode(gcf);
set(dcm_obj,'Updatefcn',{@myfunction_datacursor, p.Results.precision});

end

function output_txt = myfunction_datacursor(~, event_obj, precision)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% precision    Number of decimals to display
% output_txt   Data cursor text string (string or cell array of strings).

pos = get(event_obj,'Position');
output_txt = {...
    ['X: ', num2str(pos(1), precision)],...
    ['Y: ', num2str(pos(2), precision)] ...
    };

% If there is a Z-coordinate in the position, display it as well
if length(pos) > 2
    output_txt{end+1} = ['Z: ', num2str(pos(3), precision)];
end

end
