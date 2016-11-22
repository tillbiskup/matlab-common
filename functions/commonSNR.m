function [signalAmplitude,noiseAmplitude,SNR] = commonSNR(dataVector,varargin)
% COMMONSNR Compute signal and noise amplitude and signal-to-noise ratio
% (SNR).
%
% Usage:
%   [signalAmplitude,noiseAmplitude,SNR] = commonSNR(dataVector)
%
%   dataVector      - vector
%                     1D vector with data
%
%   signalAmplitude - scalar
%                     (noiselevel-corrected) amplitude of signal in input
%                     vector
%
%   noiseAmplitude  - scalar
%                     noise level of input vector, computed as 2x std dev.
%
%   SNR             - scalar
%                     signal-to-noise ratio of signal in input vector
%
% Optional arguments:
%   noisePoints     - scalar
%                     number of points taken from start of dataVector to
%                     compute noise for
%                     Default: 100

% Copyright (c) 2016, Till Biskup
% 2016-11-22

signalAmplitude = 0;
noiseAmplitude = 0;
SNR = 0;

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('dataVector', @(x)(isnumeric(x) && isvector(x)));
    p.addParamValue('noisePoints',100, @(x)isscalar(x));
    p.parse(dataVector,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

noiseAmplitude  = computeNoiseAmplitude(dataVector,p.Results.noisePoints);
signalAmplitude = computeSignalAmplitude(dataVector);

% Correct signal amplitude for noise level
signalAmplitude = signalAmplitude-noiseAmplitude;

SNR = signalAmplitude/noiseAmplitude;

end

function noiseAmplitude = computeNoiseAmplitude(dataVector,nPoints)

noiseAmplitude = std(dataVector(1:nPoints)-mean(dataVector(1:nPoints)))*2;

end

function signalAmplitude = computeSignalAmplitude(dataVector)

signalAmplitude = max(dataVector)-min(dataVector);

end
