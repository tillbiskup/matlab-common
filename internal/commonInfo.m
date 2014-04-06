function varargout = commonInfo(varargin)
% COMMONINFO Display/return information about the common toolbox
% commonInfo without any input and output parameters displays information
% about the common toolbox at the Matlab(r) command line.
%
% If called with an output parameter, commonInfo returns a structure
% "info" that contains all the information known to Matlab(r) about the
% command toolbox.
%
% Usage
%   commonInfo
%
%   info = commonInfo;
%
%   version = commonInfo('version')
%   url = commonInfo('url')
%   dir = commonInfo('dir')
%   modules = commonInfo('modules')
%
%   info    - struct
%             Fields: maintainer, url, bugtracker, vcs, version, path
%
%             maintainer - struct
%                          Fields: name, email
%
%             url        - string
%                          URL of the toolbox website
%
%             bugtracker - struct
%                          Fields: type, url
%
%             vcs        - struct
%                          Fields: type, url
%
%             version    - struct
%                          Fields: Name, Version, Release, Date
%                          This struct is identical to the output of the
%                          Matlab(r) "ver" command.
%
%             path       - string
%                          installation directory of the toolbox
%
%   version - string
%             <version> yyyy-mm-dd
%
%   url     - string
%             URL of the toolbox website
%
%   dir     - string
%             installation directory of the toolbox
%
%   modules - cell array of structs
%             Struct fields: maintainer, url, bugtracker, vcs, version, path
%
% See also VER

% (c) 2007-14, Till Biskup
% 2014-04-06

% The place to centrally manage the revision number and date is the file
% "Contents.m" in the root directory of the common toolbox.
%
% THE VALUES IN THAT FILE SHOULD ONLY BE CHANGED BY THE OFFICIAL MAINTAINER
% OF THE TOOLBOX!
%
% As the "ver" command works not reliably, as it works only in case the
% toolbox is on the Matlab(r) search path, we parse this file here
% manually.
%
% Additional information about the maintainer, the URL, etcetera, are
% stored below. Again:
%
% THESE VALUES SHOULD ONLY BE CHANGED BY THE OFFICIAL MAINTAINER OF THE
% TOOLBOX!

info = struct();
info.maintainer(1) = struct(...
    'name','Till Biskup',...
    'email','till@till-biskup.de'...
    );
info.url = ''; %'http://till-biskup.de/en/software/matlab/common/';
info.bugtracker = struct(...
    'type','BugZilla',...
    'url','https://r3c.de/bugs/till/'...
    );
info.vcs = struct(...
    'type','git',...
    'url',''...
    );
info.description = ...
    'a Matlab toolbox providing infrastructure for other toolboxes';

% Get install directory
[path,~,~] = fileparts(mfilename('fullpath'));
info.path = path(1:end-9);

info = parseContentsFile(info);

if nargin
    switch lower(varargin{1})
        case 'version'
            varargout{1} = ...
                sprintf('%s %s',info.version.Version,info.version.Date);
        case 'url'
            varargout{1} = info.url;
        case 'dir'
            varargout{1} = info.path;
        case 'modules'
            varargout{1} = getModuleInfo(info);
        otherwise
    end
elseif nargout
    varargout{1} = info;
else
    displayInfoOnCommandLine(info);
end

end % End of main function


function info = parseContentsFile(info)
% For all version information, parse the "Contents.m" file located in the
% toolbox root directory

contentsFile = fullfile(info.path,'Contents.m');
% Read first two lines of "Contents.m"
contentsFileHeader = cell(2,1);
fid = fopen(contentsFile);
for k=1:2
    contentsFileHeader{k} = fgetl(fid);
end
fclose(fid);

info.name = contentsFileHeader{1}(3:end);
contentsFileContent = textscan(contentsFileHeader{2}(3:end),'%s %s %s %s');

info.version = struct();
info.version.Name = contentsFileHeader{1}(3:end);
info.version.Version = contentsFileContent{2}{1};

% Handle optional "release" string
if isempty(contentsFileContent{4})
    info.version.Release = '';
    info.version.Date = ...
        datestr(datenum(char(contentsFileContent{3}{1}), 'dd-mmm-yyyy'),...
        'yyyy-mm-dd');
else
    info.version.Release = contentsFileContent{3}{1};
    info.version.Date = ...
        datestr(datenum(char(contentsFileContent{4}{1}), 'dd-mmm-yyyy'),...
        'yyyy-mm-dd');
end
end

function moduleInfo = getModuleInfo(info)
% Get modules from subdirectories in 'module' directory
moduleDirs = dir(fullfile(info.path,'modules'));
% Get prefix of toolbox - aka first word in info string
prefix = info.name(1:find(isspace(info.name))-1);
moduleInfo = struct();
for k=1:length(moduleDirs)
    if moduleDirs(k).isdir && ...
            ~strncmp(moduleDirs(k).name,'.',1) && ...
            ~strcmp(moduleDirs(k).name,'private')
        infoFunName = [prefix moduleDirs(k).name 'info'];
        if exist(infoFunName,'file')
            infoFun = str2func(infoFunName);
            moduleInfo.(moduleDirs(k).name) = infoFun();
        else
            moduleInfo.(moduleDirs(k).name) = struct();
        end
    end
end
end

function displayInfoOnCommandLine(info)
% Display info on Matlab(r) command line

fprintf('==================================================================\n');
fprintf('\n');
fprintf(' %s\n',info.name);
fprintf(' - %s\n',info.description);
fprintf('\n');
fprintf(' Release:         %s %s\n',info.version.Version,info.version.Date);
fprintf(' Directory:       %s\n',info.path);
fprintf(' Matlab version:  %s\n',version);
fprintf(' Platform:        %s\n',platform);
fprintf('\n');
fprintf(' Homepage:        <a href="%s">%s</a>\n',info.url,info.url);
for k=1:length(info.maintainer)
    fprintf(' Maintainer:      %s, <%s>\n',info.maintainer(k).name,...
        info.maintainer(k).email);
end
fprintf('\n');
fprintf(' Bug tracker:     <a href="%s">%s</a>\n',...
    info.bugtracker.url,info.bugtracker.url);
fprintf('\n');
fprintf('==================================================================\n');
end
