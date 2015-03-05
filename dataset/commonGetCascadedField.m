function value = commonGetCascadedField (struct, fieldName, varargin)
% COMMONGETCASCADEDFIELD Helper function that returns the value of a
% structure array field even if the fieldName is a structure array itself.
%
% Usage
%   value = commonGetCascadedField(struct,fieldName)
%   value = commonGetCascadedField(struct,fieldName,index)
%
%   struct    - structure array
%               structure array to be read
%
%   fieldName - string
%               name of the field with the desired value
%               may include dots
%               may also include curly brackets to call cell arrays
%
%   index     - integer (OPTIONAL)
%               index of a specific value in case fieldName contains a vector
%
%   value     - (various)
%               field value of struct(fieldName)
%
% SEE ALSO: commonSetCascadedField

% Copyright (c) 2011-14, Till Biskup
% Copyright (c) 2011-13, Bernd Paulus
% 2014-04-11

try
    % Get number of "." in fieldName
    nDots = strfind(fieldName,'.');
    curlies = strfind(fieldName,'{');
    currentIsCell = false;
    % if target field is cell array
    if ~isempty(curlies)
        % ... get index of first cell array call
        cellind = str2double(fieldName(...
            min(strfind(fieldName,'{'))+1:min(strfind(fieldName,'}'))-1));
    end
    % If there are no ".", we have the target field and can read out
    if isempty(nDots)
        if ~isempty(curlies)
            % In case of cell array adjust fieldName
            fieldName = fieldName(1:min(curlies));
            % Consider possible optional index for target vector
            if nargin == 3
                value = struct.(fieldName){cellind}(varargin{1});
            else
                value = struct.(fieldName){cellind};
            end
        else
            if nargin == 3
                value = struct.(fieldName)(varargin{1});
            else
                value = struct.(fieldName);
            end
        end
    % If there are still ".", we need to look further into the struct
    else
        % In case of cell array adjust fieldName
        if ~isempty(curlies) && min(curlies) < nDots(1)
            fieldName(min(curlies):nDots(1)-1) = [];
            % Don't forget to refresh nDots
            nDots = strfind(fieldName,'.');
            % Set logical switch
            currentIsCell = true;
        end
        % If fieldName is not a field of struct, remove it
        if ~isfield(struct,fieldName(1:nDots(1)-1))
            struct.(fieldName(1:nDots(1)-1)) = [];
        end
        % Get content of the next field
        if currentIsCell
            struct = struct.(fieldName(1:nDots(1)-1)){cellind};
        else
            struct = struct.(fieldName(1:nDots(1)-1));
        end
        % ... and call this function again
        % Consider possible optional index for target vector
        if nargin == 3
            value = commonGetCascadedField(...
                struct,...
                fieldName(nDots(1)+1:end),...
                varargin{1});
        else
            value = commonGetCascadedField(...
                struct,...
                fieldName(nDots(1)+1:end));
        end
    end
catch exception
    disp(fieldName);
    disp(struct);
    disp(['An exception occurred in ' ...
        exception.stack(1).name  '.']);
end

end