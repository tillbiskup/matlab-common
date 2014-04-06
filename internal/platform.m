function p = platform
% PLATFORM Display general platform dependend information.
%
% Usage
%   p = platform
%
%   p - string
%       Type of computer MATLAB is currently executing on
%
% See also: COMPUTER

% (c) 2007-14, Till Biskup
% 2014-04-06

% find platform OS
if exist('matlabroot','builtin')
    if ispc
        p = [system_dependent('getos'),' ',system_dependent('getwinsys')];
    elseif ( strfind(computer, 'MAC') == 1 )
        [fail, input] = unix('sw_vers');
        
        if ~fail
            p = strrep(input, 'ProductName:', '');
            p = strrep(p, sprintf('\t'), '');
            p = strrep(p, sprintf('\n'), ' ');
            p = strrep(p, 'ProductVersion:', ' Version: ');
            p = strrep(p, 'BuildVersion:', 'Build: ');
        else
            p = system_dependent('getos');
        end
    else
        [fail, input] = unix('uname -srmo');
        if ~fail
            p = input;
        else
            p = system_dependent('getos');
        end
    end
else
    if ispc
        p = computer();
    elseif strfind(computer,'apple')
        [fail, input] = unix('sw_vers');
        if ~fail
            p = strrep(input, 'ProductName:', '');
            p = strrep(p, sprintf('\t'), '');
            p = strrep(p, sprintf('\n'), ' ');
            p = strrep(p, 'ProductVersion:', ' Version: ');
            p = strrep(p, 'BuildVersion:', 'Build: ');
        else
            p = computer();
        end
    else
        [fail, input] = unix('uname -srmo');
        if ~fail
            p = input;
        else
            p = computer();
        end
    end
end
% Make sure there is no additional CR/LF
p = strtrim(p);
