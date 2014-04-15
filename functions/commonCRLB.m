function [lowerBounds,warnings] = commonCRLB(derivative,variance)
% COMMONCRLB  Calculate standard deviations of fit parameters using the 
%   Cramer-Rao lower bounds.
%
% Usage
%   lowerBounds = commonCRLB(derivative,variance)
%
% derivative  - m x n matrix
%               each column is the derivative of the model function with
%               respect to a single parameter
% 
% variance    - double
%               variance of signals' noise, e.g. variance of residuals
%
% lowerBounds - vector
%               standard deviations of parameters
%               nth element corresponds to nth column in derivative
%
% warnings    - cell array of strings
%               possible warning messages if something went wrong
%               usually this should be empty
%
% Depends on
%   fresnelC, fresnelS
%
% See also
%   fun_oopeseem_fit, fit_oopeseem, fresnelC, fresnelS
%

% (c) 2014, Bernd Paulus
% 2014-04-15


%% Allocate output and check input
lowerBounds = [];
warnings = {};

if ~isnumeric(derivative)
    warnings{end+1} = ...
        ['\n\tInput argument ''derivative'' has to be numeric!' ...
         '\n\tAborting...\n'];
    return
end
if ~isnumeric(variance)
    warnings{end+1} = ...
        ['\n\tInput argument ''variance'' has to be numeric!' ...
         '\n\tAborting...\n'];
    return
end


%% create Fisher information matrix
% use matrix product to create matrix and sum up elements at once
fisher = real(derivative' * derivative)/variance;


%% calculate lower bounds
lowerBounds = sqrt(diag(inv(fisher)));


end