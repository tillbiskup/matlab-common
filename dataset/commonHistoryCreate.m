function history = commonHistoryCreate
% COMMONHISTORYCREATE Create and return data structure of most general
% history record.
%
% Usage
%   history = commonHistoryCreate
%
%   history - struct
%             Structure complying with minimal history record
%
% SEE ALSO: commonDatasetCreate

% (c) 2014, Till Biskup
% 2014-04-10

% Define version of dataset structure
version = '0.1';

% Get toolbox info
infoFunction = getToolboxInfoFunction;
toolboxInfo = infoFunction();

% Define history record structure
history = struct(...
    'date',datestr(now,31),...
    'system',struct(...
        'username',getUsername,...
        'platform',deblank(commonPlatform),...
        'matlab',version,...
        'toolbox',toolboxInfo.version ...
        ),...
    'method','',...
    'parameters',struct(...
        ),...
    'info',struct(...
        ),...
    'format',struct(...
        'type','common history',...
        'version',version ...
        ) ...
    );

end

%% Subfunction: getToolboxInfoFunction
function infoFunction = getToolboxInfoFunction

[stack,~] = dbstack('-completenames');

if length(stack)>2
    stackIndex = 3;
else
    stackIndex = 2;
end

toolboxPrefix = stack(stackIndex).name(1:end-length('HistoryCreate'));

if isstrprop(toolboxPrefix(end),'lower')
    infoFunction = str2func([toolboxPrefix 'Info']);
else
    infoFunction = str2func([toolboxPrefix 'info']);
end

end

%% Subfunction: getUsername
function username = getUsername
% GETUSERNAME Get username of current user in platform-independent manner.
% Worst case: username is an empty string. Therefore, nothing should rely
% on it.

% Windows style
username = getenv('UserName');
% Unix style
if isempty(username)
    username = getenv('USER'); 
end


end