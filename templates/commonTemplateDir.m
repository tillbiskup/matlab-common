function directory = commonTemplateDir(varargin)
% COMMONCONFIGDIR Return directory containing template files.
%
% Usage
%   directory  = commonTemplateDir
%   directory  = commonTemplateDir(prefix)
%
%   prefix    - string
%               Toolbox prefix
%               Used to get template directory for specific toolbox whose
%               prefix is known.
%
%   directory - string
%               Full path to template directory
%
% IMPORTANT NOTE: This is the one place to set the convention for template
% directories of the common toolbox and all derived toolboxes.
%
% Currently, the convention is $HOME/.matlab-toolboxes/PREFIX/tpl/

% Copyright (c) 2015, Till Biskup
% 2015-11-26

% Assign default output
directory = '';

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addOptional('prefix','common',@(x)ischar(x));
    p.parse(varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

directory = ...
    fullfile(commonHomeDir,'.matlab-toolboxes',p.Results.prefix,'tpl');

end