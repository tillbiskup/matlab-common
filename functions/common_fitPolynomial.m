function [coefficients, resSumOfSquares] = common_fitPolynomial(dataset,area,varargin)
% COMMON_FITPOLYNOMIAL Perform polynomial fits for given area of a spectrum
%
% Usage
%   [coefficients,ResSumOfSquares] = common_fitPolynomial(dataset,area)
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
% NOTE: "area" can get defined (interactively) using common_fitAreaDefine.
%
% See also: common_fitAreaDefine

% Copyright (c) 2014-15, Simona Huwiler, Till Biskup
% 2015-03-16



B0 = dataset.axes(1).values;
spectrum = dataset.data;

% Define degree of polynomial
polydegrees = 0:9;

runs = 10;

for polydegree = 1:length(polydegrees)
    %Print polynomial degree
    fprintf('Current degree: %i\n',polydegrees(polydegree));
    
    for run = 1:runs    
        [coeffRun(run,:),S(run)] = polyfit(B0(area),spectrum(area),polydegrees(polydegree));
        [fitRun,delta] = polyval(coeffRun(run,:),B0(area),S(run));
        subtractedRun = spectrum(area)-fitRun;
        sumOfSquaresRun(run) = sum(subtractedRun.*subtractedRun);
    end
    
    %Get run with best fit
    [minValue,minIndex] =  min(sumOfSquaresRun);

    %Get polynomial coefficients
    coefficients{1,polydegree} = coeffRun(minIndex,:);

    %Get polynomial
    fit(polydegree,:) = polyval(coefficients{polydegree},B0(area),S(minIndex));
    
    %Residual sum of squares
    resSumOfSquares(polydegree) = minValue;
    coefficients{2,polydegree} = minValue;
    clear coeffRun fitRun subtractedRun sumOfSquaresRun;

end


figure(3)
plot(polydegrees,resSumOfSquares);
title('Residual sum of squares');
xlabel('{\it n-th degree of polynom}');
ylabel('{\it residual sum of squares}');

for polydegree = 1:length(polydegrees)

    %Define polynomial over whole x axis range
    fitted = polyval(coefficients{1,polydegree},B0);
    
    %Plot data, fit, and "residuals"
    figure(); % new figure - without number just opening new figure window
    plot(...
        B0,spectrum,  'k.',...
        B0,fitted, 'r-',...
        B0,spectrum-fitted,'b.');
    title(sprintf('Polynomial of degree %i',polydegrees(polydegree)));
        xlabel('{\it magnetic field} / mT');
        ylabel('{\it intensity} / a.u.');

end
