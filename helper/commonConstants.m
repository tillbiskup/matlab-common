function [constant,unit] = commonConstants(varargin)
% COMMONCONSTANTS Return value of natural constant.
%
% Central place to store and retreive values of natural constants used
% throughout spectroscopy. Whereever possible, the CODATA values in their
% latest version will be used.
%
% Usage
%   constant = commonConstants('name')
%   [constant,unit] = commonConstants('name')
%
%   name     - string
%              Name of the constant
%
%   constant - scalar
%              Value of the constant
%
% If invoked without input parameter, a list of available constants will be
% printed to the command line.

% Copyright (c) 2015, Till Biskup
% 2015-09-14

% Define constants
% Columns: name of constant, value of constant, unit of value, source
constants = {...
    'c'   ,299792458,      'm s^-1','2014 CODATA'; ...
    'h'   ,6.626070040e-34,'J s'   ,'2014 CODATA'; ...
    'hbar',1.054571800e-34,'J s'   ,'2014 CODATA'; ...
    'mub' ,927.4009994e-26,'J T^-1','2014 CODATA'  ...
    };

% Assign default output
constant = [];
unit = '';

if nargin == 0
    constant = constants;
    printConstants(constants);
    return;
end

if ~any(strcmpi(varargin{1},constants(:,1)))
    disp(['Can''t find a value for constant "' varargin{1} '".']);
    return;
end

constant = constants{strcmpi(varargin{1},constants(:,1)),2};
unit = constants{strcmpi(varargin{1},constants(:,1)),3};

end

function printConstants(constants)

fprintf('\n');
fprintf('Name\tValue\t\tUnit\tSource\n')
for const = 1:size(constants,1)
    fprintf('%s\t%e\t%s\t%s\n',constants{const});
end
fprintf('\n');

end
