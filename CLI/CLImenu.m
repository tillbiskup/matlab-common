function answer = CLImenu(options,varargin)
% CLIMENU Display menu in the command line with options waiting for user
% input.
%
% The function is an interface to the Matlab(r) function "input" trying to
% unify the "look&feel" and to simplify the use of command-line menus.
%
% Usage
%   answer = CLImenu(options)
%   answer = CLImenu(options,<parameter>,<option>)
%
%   options - cell array (nx2)
%             Strings with options.
%             The first column contains the character(s) to type, the
%             second the description of each option.
%
%   answer  - string | cell array of strings
%             User input as string.
%             In case multiple selections are allowed (see below), cell
%             array of strings containing the selected options.
%
% Optional parameters
%
%   title   - string
%             Title string displayed at the beginning of the menu.
%             Default: "Please choose an option:"
%
%   prompt  - string
%             String to display at the beginning of the line for user
%             input.
%             Default: "Your choice:"
%             If there is a default option, this gets added in brackets,
%             such as: "Your choice (default: [a]):"
%
%   default - string
%             Default option to use, if user just hits "return".
%             Default: empty string (meaning no option).
%
%   multiple - boolean
%              Option to use, if multiple answers should be possible
%              Default: false
%
% If the user chooses an option that doesn't exist, the function displays
% an error message telling the user that the chosen option doesn't exist,
% followed by the menu again.
%
% The (optional) default option is tested against the options provided. If
% the default isn't contained in the options, the routine replies with an
% error message and quits.
%
% Please note: Be short and comprehensive with your options' description,
% particularly due to the rather limited length of a usual command line.
% Restrict yourself to less than 60 characters for each description, if
% ever possible. Have in mind: Somebody has to read (and understand) it...
%
% SEE ALSO: CLIinput, input, ginput, keyboard

% Copyright (c) 2013-15, Till Biskup
% Copyright (c) 2013, Deborah Meyer
% 2015-03-26

% Parse input arguments using the inputParser functionality
parser = inputParser;   % Create an instance of the inputParser class.
parser.FunctionName  = mfilename; % Include function name in error messages
parser.KeepUnmatched = true; % Enable errors on unmatched arguments
parser.StructExpand  = true; % Enable passing arguments in a structure

parser.addRequired('options',@(x)iscell(x) && size(x,2) == 2);
parser.addParameter('title','Please choose an option:',@ischar);
parser.addParameter('prompt','Your choice',@ischar);
parser.addParameter('default','',@ischar);
parser.addParameter('multiple',false,@islogical);
parser.parse(options,varargin{:});

answer = parser.Results.default;

% If default option, check whether it exists in the options given
% As we cannot set parser.Results, add variable "default"
if ~isempty(parser.Results.default)
    if parser.Results.multiple
        % Parse multiple options, i.e. split string into cell array
        default = parseMultipleOptions(parser.Results.default);
        
        notmapped = mapCellArrays(parser.Results.options(:,1),default);
        if ~isempty(notmapped)
            % Tell user that some default value doesn't exist in options
            disp(['ERROR: You chose "' parser.Results.default '" as default, ' ...
                'but at least one option doesn''t exist.']);
            return;
        end
    elseif ~any(strcmpi(parser.Results.options(:,1),parser.Results.default))
        disp(['You chose "' parser.Results.default '" as default, ' ...
            'but the option doesn''t exist.']);
        return;
    else
        default = parser.Results.default;
    end
else
    default = parser.Results.default;
end

% Determine maximum length of options for aligned display of description of
% options
maxLengthOption = max(cellfun(@(x)length(x),options(:,1)));

% Create options of menu
menuOptions = cell(size(options,1),1);
for k=1:size(options,1)
    menuOptions{k} = sprintf(' [%s]%s %s\\n',options{k,1},...
        blanks(maxLengthOption-length(options{k,1})),options{k,2});
end

% Set menu title
if parser.Results.multiple ...
        && strcmp(parser.Results.title,'Please choose an option:')
    menuTitle = 'Please choose one or more options:\n';
else
    menuTitle = [parser.Results.title '\n'];
end

% Set promt text
if isempty(default)
    menuPrompt = [parser.Results.prompt ': '];
else
    if iscell(default)
        menuPrompt = [parser.Results.prompt ...
            ' (default: [' strJoin(default,',') ']): '];
    else
        menuPrompt = [parser.Results.prompt ' (default: [' default ']): '];
    end
end

% Set loop condition for while loop.
loop = true;

% As long as loop condition holds true, stay in while loop
while loop
    % Display menu in command line
    answer = input([menuTitle menuOptions{:} menuPrompt],'s');
    
    % If user just hit "enter" key, set reply to default value if any
    if isempty(answer) && ~isempty(default)
        if parser.Results.multiple
            answer = strJoin(default);
        else
            answer = default;
        end
    end
    
    % Check whether reply is valid, otherwise start loop again
    if parser.Results.multiple
        % Parse multiple options, i.e. split string into cell array
        answer = parseMultipleOptions(answer);
        
        notmapped = mapCellArrays(parser.Results.options(:,1),answer);
        if isempty(notmapped)
            loop = false;
        else
            % Tell user that some default value doesn't exist in options
            disp(' ');
            disp(['You chose "' strJoin(answer) '", ' ...
                'but at least one option doesn''t exist.']);
            disp(' ');
        end
    else
        if any(strcmpi(options(:,1),answer))
            loop = false;
        else
            disp(' ');
            disp(['Option "' answer '" not understood.']);
            disp(' ');
            loop = true;
        end
    end
end

end

function parsedOptions = parseMultipleOptions(options)
% PARSEMULTIPLEOPTIONS Split string into cell array of substrings.

% Define possible delimiters
delimiter = {',',';','  ',' ','|'};
% Find matches of delimiters in options
matches = cellfun(@(x)any(strfind(options,x)),delimiter);
if any(matches)
    % Split options according to first match in deliminter
    options = regexp(options,delimiter{find(matches,1)},'split');
    % Remove leading and trailing whitespace
    parsedOptions = strtrim(options);
else
    parsedOptions{1} = options;
end
end

function notmapped = mapCellArrays(fullset,subset)
% MAPCELLARRAYS Map subset to fullset and return indices of subset that
% cannot be mapped to fullset.

% Initialise variables
subsetExists = logical(length(subset));

% Loop over subset and try to map to fullset
for k=1:length(subset)
    subsetExists(k) = any(strcmpi(subset(k),strtrim(fullset)));
end

% Return indices of unmapped subset entries (if any)
notmapped = find(~subsetExists);
end
