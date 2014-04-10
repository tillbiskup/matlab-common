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
% (c) 2014, Deborah Meyer
% 2014-04-10

% Define version of dataset structure
structureVersion = '0.1';

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
    'functionName','',...
    'kind','', ...
    'purpose','' ...
    );
% NOTE: Matlab doesn't handle cells defined in structs together with other
%       parameters. Therefore, you have to add them explicitly afterwards.
history.parameters = cell(0);
history.comment = cell(0);

history.format(1) = struct(...
    'type','common history',...
    'version',structureVersion ...
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