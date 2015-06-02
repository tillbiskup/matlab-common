function [data,warnings] = commonConfigLoad(fileName,varargin)
% COMMONCONFIGLOAD Load a Windows-style ini file and return them as
% MATLAB(r) struct structure. 
%
% Usage
%   data = commonConfigLoad(filename)
%   [data,warnings] = commonConfigLoad(filename)
%   data = commonConfigLoad(filename,'<parameter>','<option>')
%
%   filename - string
%              Name of the config file to read
%
%   data     - struct
%              MATLAB(r) struct structure containing the contents of the
%              config file read
%
%   warnings - cell array (of strings)
%              Contains further information if something went wrong.
%              Otherwise empty.
%
% You can specify optional parameters as key-value pairs. Valid parameters
% and their values are:
%
%   commentChar    - char
%                    Character used for comment lines in the ini file
%                    Default: %
%
%   assignmentChar - char
%                    Character used for the assignment of values to keys
%                    Default: =
%
%   blockStartChar - char
%                    Character used for starting a block
%                    Default: [
%
%   blockEndChar   - char
%                    Character used for ending a block
%                    Default: ]
%
%   typeConversion - boolean
%                    Whether or not to perform a type conversion str2num
%
% See also: commonConfigSave 

% Copyright (c) 2008-15, Till Biskup
% Copyright (c) 2013, Bernd Paulus
% 2015-06-02

% TODO
%	* Change handling of whitespace characters (subfunctions) thus that it
%	  is really all kinds of whitespace that is dealt with, not only spaces.

% Assign default output
data = struct();
warnings = cell(0);

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('fileName', @(x)ischar(x));
    p.addParamValue('commentChar','%',@ischar);
    p.addParamValue('assignmentChar','=',@ischar);
    p.addParamValue('blockStartChar','[',@ischar);
    p.addParamValue('blockEndChar','[',@ischar);
    p.addParamValue('typeConversion',false,@islogical);
    p.parse(fileName,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Assign parameters from parser
commonAssignParsedVariables(p.Results);

if isempty(fileName)
    warnings{end+1} = 'No filename';
    return;
end

if ~exist(fileName,'file')
    warnings{end+1} = 'File does not exist';
    return;
end

configFileContents = commonTextFileRead(fileName);

% read parameters to structure
blockname = '';
for k=1:length(configFileContents)
    if ~isempty(configFileContents{k}) ...
            && ~strcmp(configFileContents{k}(1),commentChar)
        if strcmp(configFileContents{k}(1),blockStartChar)
            % set blockname
            blockEndCharPos = strfind(configFileContents{k},blockEndChar);
            blockname = configFileContents{k}(...
                1+length(blockStartChar):blockEndCharPos(1)-1);
        else
            [names] = regexp(configFileContents{k},...
                ['(?<key>[a-zA-Z0-9._-{}]+)\s*' assignmentChar '\s*(?<val>.*)'],...
                'names');
            if ~isfield(data,blockname)
                data.(blockname) = struct();
            end
            if isfield(data.(blockname),names.key)
                % Warning message telling the user that the field gets
                % overwritten and printing the old and the new field value
                % for comparison.
                warnings{end+1} = sprintf(...
                    ['WARNING: Field ''%s.%s'' already exists'...
                    ' and will get overwritten.\n\toriginal '...
                    'value: ''%s''\n\tnew value     : ''%s''\n'],...
                    blockname,names.key,...
                    data.(blockname).(names.key),names.val); %#ok<AGROW>
            end
            
            names.val = strtrim(names.val);
            
            if typeConversion && regexp('[','[\[0-9.]?') && ...
                    ~isempty(str2num(names.val)) %#ok<ST2NM>
                names.val = str2num(names.val); %#ok<ST2NM>
            end
            
            data.(blockname) = commonSetCascadedField(data.(blockname),...
                strtrim(names.key),names.val);
        end
    end
end

end
