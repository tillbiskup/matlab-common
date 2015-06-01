function commonConfigEdit(fileName,varargin)
% COMMONCONFIGEDIT Open configuration file in Matlab(r) editor.
%
% Usage
%   commonConfigEdit(filename)
%   commonConfigEdit(filename,<param>,<value>)
%
%   filename - string
%              Name of config file to get contents from
%              Only filename without path and extension
%
% You can specify optional parameters as key-value pairs. Valid parameters
% and their values are:
%
%   prefix   - string
%              Toolbox prefix
%              Default: evaluation of 'commonGetPrefix(mfilename)'
%
% NOTE: If the config directory doesn't exist, it will get created. If the
% file doesn't exist, the Matlab(r) editor will show a dialogue asking the
% user whether she/he wants to create the file.
%
% SEE ALSO: commonConfigGet, commonConfigSet, commonConfigCreate,
% commonConfigMerge

% Copyright (c) 2015, Till Biskup
% 2015-06-01

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

% If config directory doesn't exist, create it
if ~exist(configDir,'dir')
    mkdir(configDir);
end

if ~exist(fullfile(configDir,path),'dir')
    mkdir(fullfile(configDir,path));
end

% Open file in Matlab(r) editor
edit(fullfile(configDir,path,[name '.conf']));

end