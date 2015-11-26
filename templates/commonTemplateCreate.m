function commonTemplateCreate(fileName,varargin)
% COMMONTEMPLATECREATE Create user template from distributed
% template for given file.
%
% Usage
%   template = commonTemplateCreate(filename)
%   template = commonTemplateCreate(filename,<param>,<value>)
%
%   filename - string
%              Name of template file for which a user template file
%              shall be written using the distributed file as template.
%
% You can specify optional parameters as key-value pairs. Valid parameters
% and their values are:
%
%   prefix   - string
%              Toolbox prefix
%              Default: evaluation of 'commonGetPrefix(mfilename)'
%
% SEE ALSO: commonTemplateGet, commonTemplateSet, commonTemplateMerge

% Copyright (c) 2015, Till Biskup
% 2015-11-26

% Directory within toolbox path that contains template file templates
templateDistDir = 'templateFiles';

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('fileName', @(x)ischar(x));
    p.addParamValue('prefix','common', @(x)ischar(x));
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

templateDir = commonTemplateDir(prefix);

templateDistDir = fullfile(info.path,templateDistDir);

% Strip possible file extension for template file
[path,name,~] = fileparts(fileName);

templateDistFile = fullfile(templateDistDir,path,name);
templateFile     = fullfile(templateDir,path,name);

if ~exist(templateDistFile,'file')
    fprintf('(WW) File %s seems not to exist...\n',templateDistFile);
    return;
end

if exist(templateFile,'file')
    movefile(templateFile,[templateFile '-backup-' datestr(now,30)]);
end

copyfile(templateDistFile,templateFile);

end