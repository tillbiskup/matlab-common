function baseline = common_computeBaseline(dataset,coefficients,varargin)
% COMMON_COMPUTEBASELINE Create polynomial or exponential baseline from given
% coefficients for a given dataset. At the moment only polynomial baselines
% are supported.
%
% Usage
%   dataset = cwepr_createPolynomialBaseline(dataset,coefficients);
%   dataset = cwepr_createPolynomialBaseline(dataset,coefficients,<parameters>);
%
%   dataset      - struct
%
%   coefficients - vector
%                  polynomial or exponential coefficients
%
%   baseline     - vector
%
%
%  parameters    - key-value pairs (OPTIONAL)
%
%  Optional parameters may include:
%
%        kind    - string
%                  Kind of Baseline                               
%                  eather polynomial or exponential 
%                  Default: polynomial
%
%        degree  - scalar
%                  degree of polynomial or exponential 
%                  Default: lenght of coefficients minus 1
%                            

% See also: common_fitPolynomial

% Copyright (c) 2014-15, Till Biskup
% Copyright (c) 2014-15, Simona Huwiler
% Copyright (c) 2015, Deborah Meyer
% 2015-11-04


baseline = 0;
kindcell = {'polynomial','exponential'};

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('dataset', @isstruct);
    p.addRequired('coefficients', @isvector);
    p.addParamValue('kind','polynomial',@(x)any(strcmpi(x,kindcell)));
    p.addParamValue('degree',length(coefficients)-1,@isscalar);
    p.parse(dataset,coefficients,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Chek wether coefficients correspond to degree of polynomial
if length(coefficients) <= p.Results.degree
    warning('Your desired degree exceeds your coefficients');
    return
end


coeff = coefficients(1:p.Results.degree);

switch lower(p.Results.kind)
    case 'polynomial'
        baseline = polyval(coeff,dataset.axes.data(1).values);
    case 'exponential'
        % Schreiben wir uns den selbst?
    otherwise
        % Doesn't exist...
end

end