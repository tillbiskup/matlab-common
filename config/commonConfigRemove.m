function commonConfigRemove(fileName,varargin)
% COMMONCONFIGREMOVE Remove configuration file from user configuration.
%
% Usage
%   commonConfigRemove(filename)
%   commonConfigRemove(filename,<param>,<value>)
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
% NOTE: The file will be deleted from the file system, what means that
% normally the user configuration is lost without possibility to restore
% it again. (Actually, that depends on the settings of "recycle" in
% your current Matlab(r) session.)
%
% Nevertheless, proper configuration files can always be restored
% containing default values from the distributed files using
% commonConfigCreate - as long as there are distributed versions of the
% config file.
%
% SEE ALSO: commonConfigGet, commonConfigSet, commonConfigCreate,
% commonConfigMerge, delete, recycle

% Copyright (c) 2015, Till Biskup
% 2015-06-03

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('fileName', @(x)ischar(x));
    p.addParameter('prefix',commonGetPrefix(mfilename), @(x)ischar(x));
    p.parse(fileName,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Get config file directory
configDir = commonConfigDir(p.Results.prefix);

% Strip possible file extension for config file
[path,name,~] = fileparts(fileName);

% Remove config file
delete(fullfile(configDir,path,[name '.conf']));

end
