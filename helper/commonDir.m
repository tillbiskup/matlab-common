function list = commonDir(pattern,varargin)
% COMMONDIR Advanced version of the Matlab(r) "dir" command working
% recursively and omitting hidden files by default.
%
% Usage
%   list = commonDir(pattern)
%
%   pattern - string
%             pattern of files to search for
%
%   list    - cell array of strings
%             list of file names
%
% NOTE: Currently, only the two special directories "." and ".." are
%       omitted from the list (for good reasons). Further development
%       should introduce optional switches for a much finer control of what
%       shall be displayed and whether to traverse into subdirectories (and
%       possibly into what depth).
%
% SEE ALSO: dir

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
%     p.addParameter('prefix','common', @(x)ischar(x));
    p.parse(pattern,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

files = dir(pattern);

for iFile = length(files):-1:1
    % Remove special directories "." and ".."
    if any(strcmp(files(iFile).name,{'.','..'}))
        files(iFile) = [];
    end
    % Traverse into subdirectory
    if files(iFile).isdir
        sublist = commonDir(files(iFile).name);
        sublist = cellfun(@(x)fullfile(files(iFile).name,x),sublist,...
            'UniformOutput',false);
        list = [list sublist];
    else
        list{end+1} = files(iFile).name;
    end
end

% Revert sequence of entries
list = fliplr(list);

end
