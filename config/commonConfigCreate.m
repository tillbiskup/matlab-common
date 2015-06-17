function commonConfigCreate(fileName,varargin)
% COMMONCONFIGCREATE Create user configuration from distributed
% configuration for given file.
%
% Usage
%   config = commonConfigCreate(filename)
%   config = commonConfigCreate(filename,<param>,<value>)
%
%   filename - string
%              Name of config file for which a user configuration file
%              shall be written using the distributed file as template.
%
% You can specify optional parameters as key-value pairs. Valid parameters
% and their values are:
%
%   prefix   - string
%              Toolbox prefix
%              Default: evaluation of 'commonGetPrefix(mfilename)'
%
% SEE ALSO: commonConfigGet, commonConfigSet, commonConfigMerge

% Copyright (c) 2015, Till Biskup
% 2015-06-17

% Directory within toolbox path that contains config file templates
configDistDir = 'configFiles';

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

if isempty(fileName)
    return;
end

prefix = p.Results.prefix;

infoFunction = str2func(commonCamelCase({prefix,'info'}));
info = infoFunction();

configDir = commonConfigDir(prefix);

configDistDir = fullfile(info.path,configDistDir);

% Strip possible file extension for config file
[path,name,~] = fileparts(fileName);

configDistFile = fullfile(configDistDir,path,[name '.dist']);
configFile     = fullfile(configDir,path,name);

if ~exist(configDistFile,'file')
    fprintf('(WW) File %s seems not to exist...\n',configDistFile);
    return;
end

configDist = commonConfigLoad(configDistFile,'typeConversion',true);

if exist(configFile,'file')
    config = commonConfigGet(configFile,'prefix',prefix);
    config = commonStructCopy(configDist,config);
else
    config = configDist;
end

commonConfigSet(name,config,'prefix',prefix);

end