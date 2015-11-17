function history = commonHistoryCreate(varargin)
% COMMONHISTORYCREATE Create and return data structure of most general
% history record.
%
% Usage
%   history = commonHistoryCreate
%   history = commonHistoryCreate(versionString)
%
%   history       - struct
%                   Structure complying with minimal history record
%
%                   date         - string
%                                  timestamp "yyyy-mm-dd HH:MM:SS"
%
%                   system       - struct
%                                  username - string
%                                  platform - string
%                                  matlab   - string
%                                  toolbox  - struct
%                                  
%                   functionName - string
%                                  name of Matlab function used
%
%                   parameters   - cell array
%                                  (input) parameters of function defined
%                                  in "functionName"
%
%                   kind         - string
%                                  kind of operation
%                                  examples: "phase correction"
%
%                   purpose      - string
%                                  Short description why the operation was
%                                  performed
%
%                   comment      - cell array
%                                  Any additional comment
%
%                   format       - array of structs
%                                  Information about the history record
%                                  format for each of the toolboxes.
%
%                                  The first struct, format(1), always
%                                  refers to the common toolbox.
%
%                                  fields: type, version
%
%                   tplVariables - struct
%                                  information used for generating reports
%                                  via templates
%
%                   reversible   - boolean
%                                  information if performed operation is
%                                  reversible
%
%   versionString - string (OPTIONAL)
%                   version information of specific history record
%                   Only used when called from within another function of
%                   the scheme "PREFIXhistoryCreate" from another toolbox.
%
% NOTE FOR TOOLBOX DEVELOPERS:
% PREFIXhistoryCreate calls commonHistoryCreate with versionString as input
% parameter and optionally adds own fields as necessary. Information about
% the PREFIX toolbox as well as the respective history format gets added
% automatically.
%
% SEE ALSO: commonDatasetCreate

% Copyright (c) 2014, Till Biskup
% Copyright (c) 2014-15, Deborah Meyer
% 2015-11-17

% Define version of dataset structure
structureVersion = '0.2';

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
    'purpose','', ...
    'reversible', true, ...
    'tplVariables',struct() ...
    );
% NOTE: Matlab doesn't handle cells defined in structs together with other
%       parameters. Therefore, you have to add them explicitly afterwards.
history.parameters = cell(0);
history.comment = cell(0);

history.format(1) = struct(...
    'type','common history',...
    'version',structureVersion ...
    );

% Add format information for derived history record from other toolbox.
if ~strcmpi(toolboxInfo.prefix,'common')
    if nargin
        derivedStructureVersion = varargin{1};
    else
        derivedStructureVersion = '';
    end
    history.format(end+1) = struct(...
        'type',[toolboxInfo.prefix ' history'],...
        'version',derivedStructureVersion ...
        );
end
    
end

%% Subfunction: getToolboxInfoFunction
function infoFunction = getToolboxInfoFunction

[stack,~] = dbstack('-completenames');

suffix = 'HistoryCreate';

if length(stack)>2 && strcmpi(...
        stack(3).name(end-length(suffix)+1:end),suffix)
    stackIndex = 3;
else
    stackIndex = 2;
end

toolboxPrefix = stack(stackIndex).name(1:end-length(suffix));

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