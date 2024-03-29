function [coefficients, resSumOfSquares] = common_fitPolynomial(dataset,area,varargin)
% COMMON_FITPOLYNOMIAL Perform polynomial fits for given area of a spectrum
%
% Usage
%   [coefficients,ResSumOfSquares] = common_fitPolynomial(dataset,area)
%   [coefficients,ResSumOfSquares] = common_fitPolynomial(dataset,area,<parameters>)
%
%   dataset         - struct
%
%   area            - boolean vector
%
%   coefficients    - cell
%                     polynomial coefficients 
%
%   resSumOfSquares - cell
%                     sum of squares of corresponding fit
%                        
%
%   parameters      - key-value pairs (OPTIONAL)
%
%                     Optional parameters may include:
%
%                     plot    - string
%                               If figures should appear
%                               Default: true
%
%                     degrees - vector
%                               degree of polynomial to be fitted
%                               Default: 0:9
%                            
%                     runs    - scalar
%                               number of runs for each fit
%                               Default: 10
%
% NOTE: "area" can get defined (interactively) using common_fitAreaDefine.
%
% See also: common_fitAreaDefine

% Copyright (c) 2014-19, Till Biskup
% Copyright (c) 2014-15, Simona Huwiler
% Copyright (c) 2015, Deborah Meyer
% 2019-11-12

% Give empty return parameters
coefficients = cell(0);
resSumOfSquares = cell(0);

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('dataset', @isstruct);
    p.addRequired('area', @(x)isvector(x) && islogical(x));
    p.addParameter('plot',logical(true),@islogical);
    p.addParameter('degrees',0,@isscalar);
    p.addParameter('runs',10,@isscalar);
    p.parse(dataset,area,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

for col = 1:size(dataset.data, 2)
    for run = 1:p.Results.runs
        [coeffRun(run,:),S(run)] = polyfit(...
            reshape(dataset.axes.data(1).values(area),[],1),...
            reshape(dataset.data(area, col),[],1),...
            p.Results.degrees);
        [fitRun,~] = polyval(...
            coeffRun(run,:),...
            reshape(dataset.axes.data(1).values(area),[],1),...
            S(run));
        subtractedRun = reshape(dataset.data(area, col),[],1)-fitRun;
        sumOfSquaresRun(run) = sum(subtractedRun.^2);
    end
    
    %Get run with best fit
    [minValue,minIndex] =  min(sumOfSquaresRun);

    %Get polynomial coefficients
    coefficients{1,col} = coeffRun(minIndex,:);
    
    %Residual sum of squares
    resSumOfSquares{col} = minValue;
    clear coeffRun fitRun subtractedRun sumOfSquaresRun;
end

if p.Results.plot
       
    figure(3)
    
    plot(p.Results.degrees,cell2mat(resSumOfSquares));
    title('Residual sum of squares');
    xlabel('{\it n-th degree of polynom}');
    ylabel('{\it residual sum of squares}');
    
    for polydegree = 1:length(p.Results.degrees)
        
        %Define polynomial over whole x axis range
        fitted = polyval(coefficients{1,polydegree},dataset.axes.data(1).values);
        
        %Plot data, fit, and "residuals"
        figure(); % new figure - without number just opening new figure window
        plot(...
            dataset.axes.data(1).values,dataset.data,  'k.',...
            dataset.axes.data(1).values,fitted, 'r-',...
            dataset.axes.data(1).values,dataset.data-fitted,'b.');
        title(sprintf('Polynomial of degree %i',p.Results.degrees(polydegree)));
        xlabel('{\it magnetic field} / mT');
        ylabel('{\it intensity} / a.u.');
    end
end
