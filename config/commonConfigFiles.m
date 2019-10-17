function files = commonConfigFiles(varargin)
% COMMONCONFIGFILES Return list of available configuration files.
%
% Usage
%   files = commonConfigFiles()
%   files = commonConfigFiles(<param>,<value>)
%
%   files - cell array (of strings)
%           Name of config files available for the toolbox and located in
%           the toolbox configuration directory (without extension)
%
% You can specify optional parameters as key-value pairs. Valid parameters
% and their values are:
%
%   prefix   - string
%              Toolbox prefix
%              Default: evaluation of 'commonGetPrefix(mfilename)'
%
% NOTE: Currently, even if you have subdirectories in your configuration
% directory, only the files from the configuraton directory itself will be
% returned.
%
% SEE ALSO: commonConfigGet, commonConfigSet, commonConfigCreate,
% commonConfigMerge

% Copyright (c) 2015, Till Biskup
% 2015-09-15

% Assign default output
files = cell(0);

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addParameter('prefix',commonGetPrefix(mfilename), @(x)ischar(x));
    p.parse(varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Get config file directory
configDir = commonConfigDir(p.Results.prefix);

fileList = dir(fullfile(configDir,'*.conf'));

files = cell(length(fileList),1);
for idx = 1:length(fileList)
    [path,name,~] = fileparts(fileList(idx).name);
    files{idx} = fullfile(path,name);
end

%files = struct2cell(fileList.name);

end
