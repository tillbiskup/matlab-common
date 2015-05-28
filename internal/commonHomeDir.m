function homeDir = commonHomeDir
% COMMONHOMEDIR Return home directory of current user independent of
% platform used.
%
% Usage
%   homeDir = commonHomeDir
%
% SEE ALSO: commonParseDir

% Copyright (c) 2015, Till Biskup
% 2015-05-28

if ispc
    homeDir = getenv('USERPROFILE');
else
    homeDir = getenv('HOME');
end

end