function list = commonDir(pattern,varargin)
% COMMONDIR Advanced version of the Matlab(r) "dir" command working
% recursively and hiding hidden files by default.
%
% Usage
%   list = commonDir(pattern)
%
%   pattern - string
%             pattern of files to search for
%
%   list    - cell array of strings
%             list of file names

% Copyright (c) 2015, Till Biskup
% 2015-11-27

% Default output
list = cell(0);

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('pattern', @(x)ischar(x));
%     p.addParamValue('prefix','common', @(x)ischar(x));
    p.parse(pattern,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

files = dir(pattern);

for iFile = length(files):-1:1
    if any(strcmp(files(iFile).name,{'.','..'}))
        files(iFile) = [];
    end
end

list = {files.name};

end