function dataset = commonDatasetCreate(varargin)
% COMMONDATASETCREATE Create and return data structure of most general
% dataset.
%
% Usage
%   dataset = commonDatasetCreate
%   dataset = commonDatasetCreate(<parameters>)
%
%   dataset    - struct
%                Structure complying with the data structure of the dataset
%                of the common toolbox
%
%   parameters - key-value pairs (OPTIONAL)
%
%                Optional parameters may include:
%
%                numberOfAxes  - scalar
%                                Number of axes the dataset should have
%                                Default: 2
%
%                hasCalculated - logical
%                                Should  the dataset have a field
%                                "calculated" for storing calculated data?
%                                Default: false
%
% Hint: Parameters can be provided as a structure with the fieldnames
% corresponding to the parameter names specified above.
%
% SEE ALSO: commonHistoryCreate

% (c) 2014, Till Biskup
% 2014-04-10

% Assign output parameter
dataset = struct();

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure
% Add optional parameters, with default values
p.addParamValue('numberOfAxes',2,@isscalar);
p.addParamValue('hasCalculated',false,@islogical);
% Parse input arguments
p.parse(varargin{:});

% Define version of dataset structure
structureVersion = '0.1';

dataset.data = [];
dataset.origdata = [];

if p.Results.hasCalculated
    dataset.calculated = [];
end

for axis = 1:p.Results.numberOfAxes
    dataset.axes(axis) = axisStructureCreate;
end

dataset.parameters = struct(...
    'operator','',...
    'date',struct(...
        'start','',...
        'end',''...
        ),...
    'temperature',struct(...
        'value',[],...
        'unit','' ...
        ) ...
    );
% NOTE: Matlab doesn't handle cells defined in structs together with other
%       parameters. Therefore, you have to add them explicitly afterwards.
dataset.parameters.purpose = cell(0);

dataset.sample = struct(...
    'name','' ...
    );
dataset.sample.description = cell(0);
dataset.sample.buffer = cell(0);
dataset.sample.preparation = cell(0);

dataset.comment = cell(0);
dataset.history = cell(0);
dataset.file = struct(...
    'name','', ...
    'format','' ...
    );
dataset.format = struct(...
    'type','common dataset',...
    'version',structureVersion ...
    );
dataset.label = '';

end

function axis = axisStructureCreate

axis = struct(...
    'values',[],...
    'measure','',...
    'unit','' ...
    );

end
