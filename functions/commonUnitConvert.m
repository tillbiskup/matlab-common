function [output,warnings] = commonUnitConvert(data,unit,varargin)
% COMMONUNITCONVERT  Helper function to convert data between different
%   units
%
% Usage
%   output = commonUnitConvert(data,unit)
%   output = commonUnitConvert(data,oldUnit,newUnit)
%   [output,warnings] = commonUnitConvert(data,unit)
%   [output,warnings] = commonUnitConvert(data,oldUnit,newUnit)
%
%   data     - double
%              value(s) that sould be converted
%
%   unit     - structure array with fields
%              'old' - current unit of data
%              'new' - unit to convert data into
%
%   oldUnit  - string
%              current unit of data
%
%   newUnit  - string
%              unit to convert data into
%
%   output   - double
%              value(s) of 'data' in new unit
%              empty vector in case something went wrong
%
%   warnings - cell array of strings
%              possible warning messages if something went wrong
%              usually this should be empty
%
% Supported units are
%   'G'     - Gauss - magnetic field
%   'Hz'    - Hertz - frequency
%   'rad'   - radians - angular frequency
%   'T'     - Tesla - magnetic field
%

% Copyright (c) 2014, Bernd Paulus
% 2014-04-15

%% Initial checking
% allocate output for error management
output = [];
warnings = {};

% check input
if ~isnumeric(data)
    warnings{end+1} = 'Input argument ''data'' must be numeric!';
    return
end
% expect structure array
if ~isstruct(unit) || ~all(isfield(unit,{'old','new'})) || ...
        ~ischar(unit.old) || ~ischar(unit.new)
    % otherwise look for 2 string
    if nargin > 2 && ischar(unit) && ischar(varargin{1})
        oldUnit = unit;
        newUnit = varargin{1};
    else
        warnings{end+1} = ['Input argument ''unit'' must be a structure ' ...
            'array with fields ''old'' and ''new''. Both fields must ' ...
            'containt units as strings.'];
        return
    end
else
    oldUnit = unit.old;
    newUnit = unit.new;
end

% make sure there is a conversion at all
if strcmp(oldUnit, newUnit)
    output = data;
    return
end


%% Try to grab units with possible prefix
% old unit
if length(oldUnit)>1 && any(strcmp(oldUnit(1), ...
        {'f','a','n','µ','u','m','k','M','G','T'}))
    [powerOld, warnings] = getPowerValue(oldUnit(1));
    if ~isempty(warnings)
        return
    end
    unitOld = oldUnit(2:end);
else
    powerOld = 0;
    unitOld = oldUnit;
end
% new unit
if length(newUnit)>1 && any(strcmp(newUnit(1), ...
        {'f','a','n','µ','u','m','k','M','G','T'}))
    [powerNew, warnings] = getPowerValue(newUnit(1));
    if ~isempty(warnings)
        return
    end
    unitNew = newUnit(2:end);
else
    powerNew = 0;
    unitNew = newUnit;
end

%% check if we only change prefix for order of magnitude

if strcmp(unitOld,unitNew)
    % convert data and exit
    output = data*10^(powerOld-powerNew);
    return
end

%% inter-unit conversions
% scaling factors are chosen to avoid calculations with very big or very 
% small numbers
G2mT = .1; % G/mT
mT2MHz = 28.024954; % MHz/mT
Hz2rad = 2*pi; % rad/Hz

switch unitOld
    case 'G'
        switch unitNew
            case 'Hz'
                output = data*mT2MHz * 10^(5+powerOld-powerNew);
            case 'rad'
                output = data*mT2MHz*Hz2rad * 10^(5+powerOld-powerNew);
            case 'T'
                output = data*G2mT * 10^(-3+powerOld-powerNew);
        end
    case 'Hz'
        switch unitNew
            case 'G'
                output = data/mT2MHz * 10^(-5+powerOld-powerNew);
            case 'rad'
                output = data*Hz2rad * 10^(powerOld-powerNew);
            case 'T'
                output = data/mT2MHz * 10^(-9+powerOld-powerNew);
        end
    case 'rad'
        switch unitNew
            case 'G'
                output = data/Hz2rad/mT2MHz * 10^(-5+powerOld-powerNew);
            case 'Hz'
                output = data/Hz2rad * 10^(powerOld-powerNew);
            case 'T'
                output = data/Hz2rad/mT2MHz * 10^(-9+powerOld-powerNew);
        end
    case 'T'
        switch unitNew
            case 'G'
                output = data/G2mT * 10^(3+powerOld-powerNew);
            case 'Hz'
                output = data*mT2MHz * 10^(9+powerOld-powerNew);
            case 'rad'
                output = data*mT2MHz*Hz2rad * 10^(9+powerOld-powerNew);
        end
end

% if output was not assigned, create warning message
if isempty(output)
    warnings{end+1} = ['Conversion of ' unitOld ' into ' unitNew ...
        ' is not supported'];
end

end

function [powerValue, warnings] = getPowerValue(prefix)
% allocate output
powerValue = [];
warnings = {};
switch prefix
    case 'f'
        powerValue = -15;
    case 'a'
        powerValue = -12;
    case 'n'
        powerValue = -9;
    case {'u', 'µ'}
        powerValue = -6;
    case 'm'
        powerValue = -3;
    case 'k'
        powerValue = 3;
    case 'M'
        powerValue = 6;
    case 'G'
        powerValue = 9;
    case 'T'
        powerValue = 12;
    otherwise
        warnings(end+1) = {['Unsupported unit prefix: ' prefix]};
        return
end

end
