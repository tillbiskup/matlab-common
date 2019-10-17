function dataset = commonNormalise(dataset,varargin)
% COMMONNORMALISE Normalise data in dataset.
%
% Usage
%   dataset = commonNormalise(dataset)
%
%   dataset - struct
%             dataset complying to common toolbox structure
%
% Optional parameters:
%   kind    - string
%             type of normalisation: area (detault) or amplitude

% Copyright (c) 2016-19, Till Biskup
% 2019-08-29

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('dataset', @(x)isstruct(x));
    p.addParameter('kind','area', @(x)ischar(x));
    p.parse(dataset,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

if strcmpi(p.Results.kind,'area')
    dataset.data = normaliseArea(dataset.data);
elseif strcmpi(p.Results.kind,'amplitude')
    dataset.data = normaliseAmplitude(dataset.data);
end

% Create and fill History
history = commonHistoryCreate();
history.kind = 'Normalisation';
history.purpose = 'Normalise data';
history.reversible = true;
history.parameters = {p.Results.kind};
dataset.history{end+1} = history;

end

function data = normaliseArea(data)

sumAbsData = data;
while ~isscalar(sumAbsData)
    sumAbsData = sum(abs(sumAbsData));
end
data = data/sumAbsData;

end

function data = normaliseAmplitude(data)

maxData = data;
while ~isscalar(maxData)
    maxData = max(maxData);
end
minData = data;
while ~isscalar(minData)
    minData = min(minData);
end
data = data/(maxData-minData);

end
