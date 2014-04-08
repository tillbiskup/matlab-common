function commonInstall(varargin)
% COMMONINSTALL Installing the common Toolbox or any other toolbox
% specified on your system. 
%
% If called directly, commonInstall will install the common Toolbox, if
% called from within the install routine of another toolbox, it will try to
% install the toolbox identified by that routine. 
%
% Usage
%   commonInstall
%

% (c) 2012-14, Till Biskup
% (c) 2014, Deborah Meyer
% 2014-04-08

[toolboxPath,toolboxPrefix] = getToolboxPathAndPrefix;

installed = checkInstallStatus(toolboxPath);

plotWelcomeMessage(installed,toolboxPrefix);

if ~shallWeContinue(installed)
    return;
end

addToolboxPathsToMatlabSearchPath(installed,toolboxPath);

%createConfigurationDirectory;

if installed
    %updateConfiguration;
end

plotSuccessMessage(installed,toolboxPrefix);

end

%% Subfunction: getToolboxPathAndPrefix
function [toolboxPath,toolboxPrefix] = getToolboxPathAndPrefix

[stack,~] = dbstack('-completenames');

if length(stack)>2
    stackIndex = 3;
else
    stackIndex = 2;
end

[toolboxPath,~,~] = fileparts(stack(stackIndex).file);
toolboxPath = toolboxPath(1:end-length('/internal'));
toolboxPrefix = stack(stackIndex).name(1:end-length('install'));

end

%% Subfunction: checkInstallStatus
function installed = checkInstallStatus(toolboxPath)
installed = any(strfind(path,toolboxPath));
end

%% Subfunction: plotWelcomeMessage
function status = plotWelcomeMessage(installed,toolboxPrefix)

infoFunction = getToolboxInfoFunction(toolboxPrefix);
info = infoFunction();

status = false;
fprintf('\n');
fprintf('==================================================================\n');
fprintf('\n');
if installed
    fprintf(' WELCOME. This will update\n');
else
    fprintf(' WELCOME. This will install\n');
end
fprintf('\n');
fprintf('     %s\n',info.name);
fprintf('     - %s\n',info.description);
fprintf('\n');
fprintf(' on your system.\n');
fprintf('\n');
fprintf('==================================================================\n');
fprintf('\n');
end

%% Sub(sub)function: getToolboxInfoFunction
function infoFunction = getToolboxInfoFunction(toolboxPrefix)
if isstrprop(toolboxPrefix(end),'lower')
    infoFunction = str2func([toolboxPrefix 'Info']);
else
    infoFunction = str2func([toolboxPrefix 'info']);
end
end

%% Subfunction: shallWeContinue 
function TrueOrFalse = shallWeContinue(installed)

TrueOrFalse = false;

if installed
    userQuestion = 'Do you want to update the toolbox now? Y/n [Y]: ';
else
    userQuestion = 'Do you want to install the toolbox now? Y/n [Y]: ';
end
reply = input(userQuestion, 's');
if isempty(reply)
    reply = 'Y';
end
if strcmpi(reply,'y')
    TrueOrFalse = true;
else
    if installed
        fprintf('\nUpdate aborted... good-bye.\n\n');
    else
        fprintf('\nInstallation aborted... good-bye.\n\n');
    end
end
end

%% Subfunction: addToolboxPathsToMatlabSearchPath
function addToolboxPathsToMatlabSearchPath(installed,toolboxPath)

paths = getToolboxPaths(toolboxPath);

% Print paths that get added
if installed
    fprintf('\nRefreshing ');
else
    fprintf('\nAdding ');
end
fprintf('the following paths to the Matlab(tm) search path:\n\n');
cellfun(@(x)fprintf('  %s\n',char(x)),paths);

% Actually add
cellfun(@(x)addpath(char(x)),paths);

% Trying to save path
fprintf('\nSaving path... ')
spstatus = savepath;
if spstatus
    fprintf('FAILED!\n');
    % Test whether global pathdef.m is writable
    pathdefFileName = fullfile(matlabroot,'toolbox','local','pathdef.m');
    fh = fopen(pathdefFileName,'w');
    if fh == -1
        fprintf('\n   You have no write permissions to the file\n   %s.\n',...
            pathdefFileName);
        fprintf('   Therefore, you need to manually save the Matlab path.\n');
    else
        close(fh);
    end 
else
    fprintf('done.\n');
end

end

%% Subfunction: getToolboxPaths
function directories = getToolboxPaths(path)
% GETTOOLBOXPATHS Internal function returning all subdirectories of the
% current toolbox installation.
directories = cell(0);
directories{1} = path;
traverse(path);
    function traverse(directory)
        list = dir(directory);
        for k=1:length(list)
            if list(k).isdir && ~strncmp(list(k).name,'.',1) && ...
                    ~strcmp(list(k).name,'private')
                directories{end+1} = fullfile(directory,list(k).name); %#ok<AGROW>
                traverse(fullfile(directory,list(k).name));
            end
        end
    end
end

%% Subfunction: createConfigurationDirectory
function confDir = createConfigurationDirectory(toolboxPrefix)
confDir = commonParseDir(['~/.matlab-toolboxes/' toolboxPrefix]);
if ~exist(confDir,'dir')
    try
        fprintf('\nCreating local config directory... ');
        mkdir(confDir);
        fprintf('done.\n');
    catch exception
        fprintf('failed!\n');
        disp(exception.message);
        confDir = '';
    end
end
end

%% Subfunction: updateConfiguration
function updateConfiguration
fprintf('\nUpdating configuration... ');
confFiles = trEPRconf('files');
if isempty(confFiles)
    fprintf('done.\n');
else
    fprintf('\n\n')
    for k=1:length(confFiles)
        tocopy = trEPRiniFileRead(confFiles{k},'typeConversion',true);
        master = trEPRiniFileRead([confFiles{k} '.dist'],...
            'typeConversion',true);
        newConf = structcopy(master,tocopy);
        header = 'Configuration file for trEPR toolbox';
        trEPRiniFileWrite(confFiles{k},...
            newConf,'header',header,'overwrite',true);
        [~,cfname,cfext] = fileparts(confFiles{k});
        fprintf('  merging %s%s\n',cfname,cfext);
    end
    fprintf('\ndone.\n');
end
end

%% Subfunction: plotSuccessMessage
function plotSuccessMessage(installed,toolboxPrefix)
fprintf('\nCongratulations! The %s Toolbox has been ',toolboxPrefix);
if installed
    fprintf('updated ');
else
    fprintf('installed ');
end
fprintf('on your system.\n\n');
fprintf('Please, find below a bit of information about the installation.\n\n')

infoFunction = getToolboxInfoFunction(toolboxPrefix);
infoFunction();

fprintf('\n');
end
