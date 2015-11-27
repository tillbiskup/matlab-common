function status = commonFileBackup(filename,varargin)
% COMMONFILEBACKUP Create backup copy of a file.
% 
% Usage
%   commonFileBackup(filename)
%   status = commonFileBackup(filename)
%
%   filename - string
%              Name of the file that should be backed up
%
%   status   - scalar
%              0 if everything went OK
%              1 otherwise
%
% NOTE: The file will be copied to another file with the string
%       "-backupYYYYMMDDThhmm" appended to the filename

% Copyright (c) 2015, Till Biskup
% 2015-11-27

% Assign default output
status = 1;

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('filename', @(x)ischar(x) && exist(x,'file'));
    p.parse(filename,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

[path,name,ext] = fileparts(filename);
backupname = fullfile(path,[name '-backup' datestr(now,30) ext]);

copyfile(filename,backupname);

status = 0;

end