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
% NOTE FOR TOOLBOX DEVELOPERS:
% PREFIXinstall normally only calls commonInstall. If necessary, additional
% tasks can be performed as well.

% Copyright (c) 2012-15, Till Biskup
% Copyright (c) 2014-15, Deborah Meyer
% 2015-11-26

% Directory within toolbox path that contains config file templates
configDistDir = 'configFiles';
templateDistDir = 'templateFiles';

[toolboxPath,toolboxPrefix] = getToolboxPathAndPrefix;

% NOTE: Can't use "commonCamelCase" here, as it is not yet available...
infoFunction = str2func(camelCase({toolboxPrefix,'info'}));
info = infoFunction();

installed = checkInstallStatus(toolboxPath);

plotWelcomeMessage(installed,info);

if ~shallWeContinue(installed)
    return;
end

addToolboxPathsToMatlabSearchPath(installed,toolboxPath);

createConfigurationDirectory(toolboxPrefix);

if exist(fullfile(info.path,configDistDir),'dir')
    updateConfiguration(toolboxPrefix,fullfile(info.path,configDistDir));
end

createTemplateDirectory(toolboxPrefix);

if exist(fullfile(info.path,templateDistDir),'dir')
    updateTemplates(toolboxPrefix,fullfile(info.path,templateDistDir));
end

plotSuccessMessage(installed,toolboxPrefix,infoFunction);

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

%% Subfunction: camelCase
function outString = camelCase(inStrings)
for inString = 1:length(inStrings)-1
    if isstrprop(inStrings{inString}(end),'lower')
        inStrings{inString+1}(1) = upper(inStrings{inString+1}(1));
    else
        inStrings{inString+1}(1) = lower(inStrings{inString+1}(1));
    end
end
outString = [inStrings{:}];
end

%% Subfunction: checkInstallStatus
function installed = checkInstallStatus(toolboxPath)
installed = any(strfind(path,toolboxPath));
end

%% Subfunction: plotWelcomeMessage
function status = plotWelcomeMessage(installed,info)

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
% current toolbox installation - except those added to the excludeList.
excludeList = {'configFiles','doc','private','tests'};
directories = cell(0);
directories{1} = path;
traverse(path);
    function traverse(directory)
        list = dir(directory);
        for k=1:length(list)
            if list(k).isdir && ~strncmp(list(k).name,'.',1) && ...
                    ~any(strcmp(list(k).name,excludeList))
                directories{end+1} = fullfile(directory,list(k).name); %#ok<AGROW>
                traverse(fullfile(directory,list(k).name));
            end
        end
    end
end

%% Subfunction: createConfigurationDirectory
function confDir = createConfigurationDirectory(toolboxPrefix)
confDir = commonConfigDir(toolboxPrefix);
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
function updateConfiguration(toolboxPrefix,configDistDir)
fprintf('\nUpdating configuration... ');
confFiles = dir(fullfile(configDistDir,'*.conf.dist'));
if isempty(confFiles)
    fprintf('done.\n');
else
    fprintf('\n\n')
    for k=1:length(confFiles)
        fprintf('  %s\n',confFiles(k).name);
        commonConfigCreate(confFiles(k).name,'prefix',toolboxPrefix);
    end
    fprintf('\ndone.\n');
end
end

%% Subfunction: createTemplateDirectory
function tplDir = createTemplateDirectory(toolboxPrefix)
tplDir = commonTemplateDir(toolboxPrefix);
if ~exist(tplDir,'dir')
    try
        fprintf('\nCreating local templates directory... ');
        mkdir(tplDir);
        fprintf('done.\n');
    catch exception
        fprintf('failed!\n');
        disp(exception.message);
        tplDir = '';
    end
end
end

%% Subfunction: updateTemplates
function updateTemplates(toolboxPrefix,tplDistDir)
fprintf('\nUpdating templates... ');
tplFiles = dir(fullfile(tplDistDir,'*'));
if isempty(tplFiles)
    fprintf('done.\n');
else
    fprintf('\n\n')
    for k=1:length(tplFiles)
        fprintf('  %s\n',tplFiles(k).name);
        commonTemplateCreate(tplFiles(k).name,'prefix',toolboxPrefix);
    end
    fprintf('\ndone.\n');
end
end

%% Subfunction: plotSuccessMessage
function plotSuccessMessage(installed,toolboxPrefix,infoFunction)
fprintf('\nCongratulations! The %s Toolbox has been ',toolboxPrefix);
if installed
    fprintf('updated ');
else
    fprintf('installed ');
end
fprintf('on your system.\n\n');
fprintf('Please, find below a bit of information about the installation.\n\n')

infoFunction();

fprintf('\n');
end
