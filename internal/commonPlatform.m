function platform = commonPlatform
% COMMONPLATFORM Display general platform dependend information.
%
% Usage
%   platform = commonPlatform
%
%   platform - string
%              Type of computer MATLAB is currently executing on
%
% See also: COMPUTER

% (c) 2007-14, Till Biskup
% 2014-04-10

% find platform OS
if exist('matlabroot','builtin')
    if ispc
        platform = [system_dependent('getos'),' ',...
            system_dependent('getwinsys')];
    elseif ( strfind(computer, 'MAC') == 1 )
        [fail, input] = unix('sw_vers');
        
        if ~fail
            platform = strrep(input, 'ProductName:', '');
            platform = strrep(platform, sprintf('\t'), '');
            platform = strrep(platform, sprintf('\n'), ' ');
            platform = strrep(platform, 'ProductVersion:', ' Version: ');
            platform = strrep(platform, 'BuildVersion:', 'Build: ');
        else
            platform = system_dependent('getos');
        end
    else
        [fail, input] = unix('uname -srmo');
        if ~fail
            platform = input;
        else
            platform = system_dependent('getos');
        end
    end
else
    if ispc
        platform = computer();
    elseif strfind(computer,'apple')
        [fail, input] = unix('sw_vers');
        if ~fail
            platform = strrep(input, 'ProductName:', '');
            platform = strrep(platform, sprintf('\t'), '');
            platform = strrep(platform, sprintf('\n'), ' ');
            platform = strrep(platform, 'ProductVersion:', ' Version: ');
            platform = strrep(platform, 'BuildVersion:', 'Build: ');
        else
            platform = computer();
        end
    else
        [fail, input] = unix('uname -srmo');
        if ~fail
            platform = input;
        else
            platform = computer();
        end
    end
end
% Make sure there is no additional CR/LF
platform = strtrim(platform);
