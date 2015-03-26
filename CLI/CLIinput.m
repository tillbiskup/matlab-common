function answer = CLIinput(prompt,varargin)
% CLIINPUT Display prompt in the command line waiting for user input.
%
% The function is an interface to the Matlab(r) function "input" extending
% it with optinal default values and a basic input checking, trying to
% unify the "look&feel" and to simplify the use of command-line menus.
%
% Usage
%   answer = CLIinput(prompt)
%   answer = CLIinput(prompt,<parameter>,<option>)
%
%   prompt  - string
%             String to display at the beginning of the line for user
%             input.
%             Default: ""
%             If there is a default option, this gets added in brackets,
%             such as: "(default: [a]):"
%
%   answer  - string
%             User input as string.
%
% Optional parameters
%
%   default - string
%             Default option to use, if user just hits "return".
%             Default: empty string
%
%   numeric - string
%             Whether to convert user input into numeric value(s)
%             Default: false
%
%   fun     - string
%             String of an arbitrary Matlab(r) function that can be
%             converted into a function using <str2fun> and applied to the
%             input parameter, such as all the <isa*> functions.
%
%   range   - vector
%             Vector containing the boundaries for the value
%             Length must be >= 2
%             <min(range)> is used as lower, <max(range)> as upper boundary
%
%
% If the user enters a response that does not validate, the function
% displays the prompt again.
%
% Please note: The function does not change for mutual exclusive settings
% of the optional parameters. Therefore, you're responsible to provide
% valid and compatible values for the optional parameters "numeric", "fun",
% and "range".
%
% SEE ALSO: CLImenu, input, ginput, keyboard

% Copyright (c) 2013-15, Till Biskup
% Copyright (c) 2013, Deborah Meyer
% 2015-03-26

% Parse input arguments using the inputParser functionality
parser = inputParser;   % Create an instance of the inputParser class.
parser.FunctionName  = mfilename; % Include function name in error messages
parser.KeepUnmatched = true; % Enable errors on unmatched arguments
parser.StructExpand  = true; % Enable passing arguments in a structure

parser.addRequired('prompt',@ischar);
parser.addParamValue('default','',@ischar);
parser.addParamValue('numeric',false,@islogical);
parser.addParamValue('fun','',@ischar);
parser.addParamValue('range',[],@(x)isvector(x) && length(x)>=2);
parser.parse(prompt,varargin{:});

answer = parser.Results.default;

% Set promt text
if isempty(parser.Results.default)
    menuPrompt = [parser.Results.prompt ': '];
else
    menuPrompt = [parser.Results.prompt ...
        ' (default: [' parser.Results.default ']): '];
end

% Set loop condition for while loop.
loop = true;

% As long as loop condition holds true, stay in while loop
while loop
    % Display menu in command line
    answer = input(menuPrompt,'s');
    
    % If user just hit "enter" key, set reply to default value if any
    if isempty(answer) && ~isempty(parser.Results.default)
        answer = parser.Results.default;
    end
    
    % Set loop condition to false. Every following check can set it back to
    % true meaning that the user will see the prompt again.
    loop = false;
    
    % Convert into numeric if necessary
    % Change ',' into '.'
    if parser.Results.numeric
        answer = str2num(answer); %#ok<ST2NM>
        if isempty(answer)
            loop = true;
        end
    end
    
    % Apply function if necessary
    if ~isempty(parser.Results.fun)
        fun = str2func(parser.Results.fun);
        if ~fun(answer)
            loop = true;
        end
    end
    
    % Check for range
    if ~isempty(parser.Results.range) && parser.Results.numeric
        if answer < min(parser.Results.range) ...
                || answer > max(parser.Results.range)
            loop = true;
        end
    end
end

end

