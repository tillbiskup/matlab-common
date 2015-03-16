function varargout = commonSave(filename,struct,varargin)
% COMMONSAVE Save data from the common toolbox as ZIP-compressed XML files.
%
% Whereas the structure of the dataset gets converted into XML, the actual
% data are extracted from the structure and saved as separate binary files
% (default precision "real*8", prior to 2015-03-16 "real*4"). Altogether,
% the XML and binary files are stored as a compressed ZIP archive, thus
% allowing for being maximally independent of both, Matlab(r) and the
% operating system used.
%
% Usage
%   commonSave(filename,struct)
%   [status] = commonSave(filename,struct)
%   [status,exception] = commonSave(filename,struct)
%
%   commonSave(filename,struct,<parameters>)
%
%   filename   - string
%                name of a valid filename
%
%   data       - struct
%                structure containing data and additional fields
%
%   status     - cell array
%                empty if there are no warnings
%
%   exception  - object
%                empty if there are no exceptions
%
%
%   parameters - key-value pairs (OPTIONAL)
%
%                Optional parameters may include:
%
%                precision - string
%                            Precision of the binary data written as binary
%                            file. 
%                            Default: real*8 (*)
%
%                extension - string
%                            File extension used for the files the dataset
%                            gets saved to.
%                            Default: .xbz
%
% (*) Prior to 2015-03-16, default was "real*4", since then default is
%     "real*8". For backwards compatibility, the additional (optional)
%     parameter "precision" has been introduced. 
%     For details of the strings specifying the precision in Matlab(r),
%     type "doc fwrite".

%
% See also COMMONLOAD, FWRITE

% Copyright (c) 2010-15, Till Biskup
% 2015-03-16

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create inputParser instance
p.FunctionName = mfilename; % Include function name in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure
p.addRequired('filename', @ischar);
p.addRequired('struct', @isstruct);
p.addParamValue('precision','real*8',@ischar);
p.addParamValue('extension','.xbz',@ischar);
p.parse(filename,struct);

% Set file extensions
zipext = p.Results.extension;
xmlext = '.xml';
datext = '.dat';

% Set file suffixes
dataSuffix = '-data';
origdataSuffix = '-origdata';

% Set default for output arguments
status = cell(0);
exception = [];

try
    [pathstr, name] = fileparts(filename);
    dataFilename = [name dataSuffix datext];
    origdataFilename = [name origdataSuffix datext];
    % Extract data from struct
    data = struct.data;
    origdata = struct.origdata;
    struct = rmfield(struct,'data');
    struct = rmfield(struct,'origdata');
    % Save data as binary
    binaryWriteStatus = writeBinary(...
        fullfile(tempdir,dataFilename),data,p.Results.precision);
    if ~isempty(binaryWriteStatus)
        status{end+1} = sprintf(...
            'Problems writing file %s:\n   %s',...
            dataFilename,binaryWriteStatus);
    end
    binaryWriteStatus = writeBinary(...
        fullfile(tempdir,origdataFilename),origdata,p.Results.precision);
    if ~isempty(binaryWriteStatus)
        status{end+1} = sprintf(...
            'Problems writing file %s:\n   %s',...
            origdataFilename,binaryWriteStatus);
    end
    % Add proper extension to file name in struct
    [structpathstr, structname] = fileparts(struct.file.name);
    struct.file.name = fullfile(structpathstr,[structname zipext]);
    % Write XML file
    docNode = struct2XML(struct);
    xmlwrite(fullfile(tempdir,[name xmlext]),docNode);
    % ZIP files
    zip(fullfile(pathstr,[name zipext]),...
        {fullfile(tempdir,dataFilename),...
        fullfile(tempdir,origdataFilename),...
        fullfile(tempdir,[name xmlext])});
    movefile([fullfile(pathstr,[name zipext]) '.zip'],...
        fullfile(pathstr,[name zipext]));
    % Delete temporary files from tempdir
    delete(fullfile(tempdir,[name xmlext]));
    delete(fullfile(tempdir,dataFilename));
    delete(fullfile(tempdir,origdataFilename));
catch exception
    status{end+1} = 'A problem occurred:';
    status{end+1} = exception.message;
end

% Assign output parameters
switch nargout
    case 1
        varargout{1} = status;
    case 2
        varargout{1} = status;
        varargout{2} = exception;
    otherwise
        % Do nothing (and _not_ loop!)
end

end

function status = writeBinary(filename,data,precision)
% WRITEBINARY Writing given data to given file as binary.
%
% NOTE: Prior to 2015-03-16, data have been written as real*4, since then,
%       default precision is real*8. To ensure backwards compatibility, an
%       additional parameter "precision" has been introduced.

% Set status
status = '';

% Open file for (only) writing
fh = fopen(filename,'w');

% Write data
count = fwrite(fh,data,precision);

% Close file
fclose(fh);

% Check whether all elements have been written
[y,x] = size(data);
if count ~= x*y
    status = sprintf('Problems with writing: %i of %i elements written',...
        count,x*y);
end

end
