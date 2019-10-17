function files = commonTemplateFiles(varargin)
% COMMONTEMPLATEFILES Return list of available template files.
%
% Usage
%   files = commonTemplateFiles()
%   files = commonTemplateFiles(<param>,<value>)
%
%   files - cell array (of strings)
%           Name of template files available for the toolbox and located in
%           the toolbox template directory (without extension)
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

% Copyright (c) 2015, Till Biskup
% 2015-11-26

% Assign default output
files = cell(0);

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addParameter('prefix','common', @(x)ischar(x));
    p.parse(varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Get template file directory
templateDir = commonTemplateDir(p.Results.prefix);

fileList = dir(fullfile(templateDir,'*'));

files = cell(length(fileList),1);
for idx = 1:length(fileList)
    [path,name,~] = fileparts(fileList(idx).name);
    files{idx} = fullfile(path,name);
end

%files = struct2cell(fileList.name);

end
