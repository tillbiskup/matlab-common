function commonConfigSet(fileName,config,varargin)
% COMMONCONFIGSET Write configuration to given file.
%
% Usage
%   config = commonConfigSet(filename,config)
%
%   filename - string
%              Name of config file to save configuration to
%              Only filename without path and extension
%
%   config   - struct
%              Configuration to be saved to given config file
%
% You can specify optional parameters as key-value pairs. Valid parameters
% and their values are:
%
%   prefix   - string
%              Toolbox prefix
%              Default: evaluation of 'commonGetPrefix(mfilename)'
%
% SEE ALSO: commonConfigGet, commonConfigCreate, commonConfigMerge

% Copyright (c) 2015, Till Biskup
% 2015-05-28

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('fileName', @(x)ischar(x));
    p.addRequired('config', @(x)isstruct(x));
    p.addParameter('prefix',commonGetPrefix(mfilename), @(x)ischar(x));
    p.parse(fileName,config,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% If config is empty, nothing gets written. Therefore, mistakes here don't
% waste user configuration files...
if isempty(config)
    return;
end

% Get config file directory
configDir = commonConfigDir(p.Results.prefix);

% Strip possible file extension for config file
[path,name,~] = fileparts(fileName);

% Create header with title line and current date
header = ['Configuration file for ' p.Results.prefix ' toolbox'];

% Save config file
commonConfigSave(fullfile(configDir,path,[name '.conf']),config,...
    'overwrite',true,'header',header);

end
