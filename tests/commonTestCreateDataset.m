function dataset = commonTestCreateDataset(varargin)
% COMMONTESTCREATEDATASET Create dummy dataset containing some data.
%
% Usage:
%   dataset = commonTestCreateDataset()
%   dataset = commonTestCreateDataset(<parameter>,<value>)
%
%   dataset - struct
%             Dataset complying with specification of toolbox dataset
%             structure
%
%   Optional parameters
%
%   dim           - scalar
%                   Dimension of the data of the dataset.
%                   Currently only 1 or 2 are supported.
%                   Default: 1
%
%   origData      - logical
%                   Whether to include "origData" in dataset
%                   Default: false
%
%   calculated    - logical
%                   Whether to include "calculated" in dataset
%                   Default: false
%
%   calculatedDim - scalar
%                   Dimension of the "calculated" data of the dataset.
%                   Currently only 1 or 2 are supported.
%                   Default: 1
%
% SEE ALSO: commonDatasetCreate

% Copyright (c) 2015, Till Biskup
% 2015-04-04

% Assign default output
dataset = struct();

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addParamValue('dim',1,@isscalar);
    p.addParamValue('origData',false,@islogical);
    p.addParamValue('calculated',false,@islogical);
    p.addParamValue('calculatedDim',1,@isscalar);
    p.parse(varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% x,y values for creating data
x = -16:0.1:16;
y = x;

% Strings for "measure" field in axes
measureStrings = {'x','y'};

dataset = commonDatasetCreate();

dataset.data = createData(x,y,p.Results.dim);

dataset = addAxes(dataset,'data',x,measureStrings,p.Results.dim);

if p.Results.origData
    dataset.origData = createData(x,y,p.Results.dim);
    dataset = addAxes(dataset,'origData',x,measureStrings,p.Results.dim);
end

if p.Results.calculated
    dataset.calculated = createData(x,y,p.Results.calculatedDim);
    dataset = addAxes(dataset,'calculated',x,measureStrings,...
        p.Results.calculatedDim);
end

end

function data = createData(x,y,dim)
    
sombrero = @(x,y) sin (sqrt (x.^2 + y.^2)) ./ (sqrt (x.^2 + y.^2));

if dim == 1
    data = sombrero(x,y);
elseif dim ==2
    xx = repmat(x,length(x),1);
    yy = xx';
    data = sombrero(xx,yy);
end

end

function dataset = addAxes(dataset,kind,values,measure,dim)

% Add axes
for axis = 1:dim
    dataset.axes.(kind)(axis).values = values;
    dataset.axes.(kind)(axis).measure = measure{axis};
    dataset.axes.(kind)(axis).unit = 'nm';
end
dataset.axes.(kind)(dim+1).measure = 'intensity';
dataset.axes.(kind)(dim+1).unit = '';

end