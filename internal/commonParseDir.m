function dir = commonParseDir(dir)
% COMMONPARSEDIR Parse directory string and replace certain keywords, such
% as "pwd" and "~".

% Copyright (c) 2013-14, Till Biskup
% 2014-04-08

% Replace "PWD" and empty string with current directory
if any(strcmpi(dir,{'pwd',''}))
    dir = pwd;
end

% Replace tilde as first character of string with user/home directory
if strncmp(dir,'~',1)
    if ispc
        userdir = getenv('USERPROFILE');
    else
        userdir = getenv('HOME');
    end
    dir = [ userdir dir(2:end) ];
end

end
