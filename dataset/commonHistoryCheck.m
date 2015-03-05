function [missingFields,wrongType] = commonHistoryCheck(history)
% COMMONHISTORYCHECK Check data structure for compliance with
% specification. 
%
% Usage
%   [missingFields,wrongType] = commonHistoryCheck(history)
%
%   history       - struct
%                   Structure complying with minimal history record
%
%   missingFields - cell array
%                   List of fields missing in history record according to
%                   specification
%
%   wrongType     - cell array
%                   List of fields in history record with wrong type
%                   according to specification
%
% NOTE FOR TOOLBOX DEVELOPERS:
% PREFIXhistoryCheck simply calls commonHistoryCheck. This will
% automatically check a history record of the PREFIX toolbox type.
%
% SEE ALSO: commonHistoryCreate, commonDatasetCheck

% Copyright (c) 2014, Till Biskup
% 2014-04-10

% Get structure of history record corresponding to current toolbox
historyStructure = getHistoryStructure;

[missingFields,wrongType] = ...
    commonCompareModelWithStructure(historyStructure,history);

end


%% Subfunction: getHistoryStructure
function historyStructure = getHistoryStructure
    historyCreateFunction = getHistoryCreateFunction;
    historyStructure = historyCreateFunction();
end

%% Subfunction: getHistoryCreateFunction
function historyCreateFunction = getHistoryCreateFunction

[stack,~] = dbstack('-completenames');

if length(stack)>2
    stackIndex = 3;
else
    stackIndex = 2;
end

toolboxPrefix = stack(stackIndex).name(1:end-length('HistoryCheck'));

if isstrprop(toolboxPrefix(end),'lower')
    historyCreateFunction = str2func([toolboxPrefix 'HistoryCreate']);
else
    historyCreateFunction = str2func([toolboxPrefix 'historyCreate']);
end



end
