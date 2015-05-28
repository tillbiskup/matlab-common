function config = commonConfigGet(fileName,varargin)
% COMMONCONFIGGET Return configuration read from given file.
%
% Usage
%   config = commonConfigGet(filename)
%   config = commonConfigGet(filename,<param>,<value>)
%
%   filename - string
%              Name of config file to get contents from
%              Only filename without path and extension
%
%   config   - struct
%              Configuration loaded from given config file
%              Empty struct if no configuration could be loaded.
%
% You can specify optional parameters as key-value pairs. Valid parameters
% and their values are:
%
%   prefix   - string
%              Toolbox prefix
%              Default: evaluation of 'commonGetPrefix(mfilename)'
%
% SEE ALSO: commonConfigSet, commonConfigCreate, commonConfigMerge

% Copyright (c) 2015, Till Biskup
% 2015-05-28

% Assign default output
config = struct();

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('fileName', @(x)ischar(x));
    p.addParamValue('prefix',commonGetPrefix(mfilename), @(x)ischar(x));
    p.parse(fileName,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Get config file directory
configDir = commonConfigDir(p.Results.prefix);

% Strip possible file extension for config file
[path,name,~] = fileparts(fileName);

% Load config file
config = ...
    commonConfigLoad(fullfile(configDir,path,name),'typeConversion',true);

end