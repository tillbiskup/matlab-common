function filePath = commonTemplateFilepath(fileName,varargin)
% COMMONTEMPLATEFILEPATH Return full file including path for template file.
%
% Usage
%   file = commonTemplateFilepath()
%   file = commonTemplateFilepath(<param>,<value>)
%
%   file - string
%          Full path to template file
%          Empty if not found
%
% You can specify optional parameters as key-value pairs. Valid parameters
% and their values are:
%
%   prefix   - string
%              Toolbox prefix
%
% NOTE: Currently, even if you have subdirectories in your template
% directory, only the files from the template directory itself will be
% returned.

% Copyright (c) 2016, Till Biskup
% 2016-11-18

% Assign default output
filePath = '';

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('fileName', @(x)ischar(x));
    p.addParameter('prefix','common', @(x)ischar(x));
    p.parse(fileName,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Get template file directory
templateDir = commonTemplateDir(p.Results.prefix);

filePath = fullfile(templateDir,fileName);

% Check for existence of file using dir command
if isempty(dir(filePath))
    filePath = '';
    return;
end

end
