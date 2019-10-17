function result = commonTextFileIsEqual(filename1,filename2,varargin)
% COMMONTEXTFILEISEQUAL Test text files for identical content.
%
% Usage
%   result = commonTextFileIsEqual(filename1,filename2)
%
%   filename1 - string
%               Name of first (text) file
%
%   filename2 - string
%               Name of second (text) file
%
%   result    - boolean
%               result of comparison
%
% NOTE: commonTextFileIsEqual uses internally the function "isequaln" to
%       compare the two cell arrays returned by commonTextFileRead. You may
%       use this function as well for binary files, but with no guarantee
%       what result you will get.

% Copyright (c) 2015, Till Biskup
% 2015-11-27

% Assign default
result = false;

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('filename1', @(x)ischar(x) && exist(x,'file'));
    p.addRequired('filename2', @(x)ischar(x) && exist(x,'file'));
%    p.addParameter('SCnorm',true,@islogical);
    p.parse(filename1,filename2,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

file1content = commonTextFileRead(filename1);
file2content = commonTextFileRead(filename2);

result = isequaln(file1content,file2content);

end
