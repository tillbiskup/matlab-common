function [dataStructure,warning] = loadDatasetV2_0(archiveFilenames)
% LOADDATASETV2_0 Helper function for commonLoad reading ZIP-compressed XML
% file and data (if available).
%
% Usage:
%   [dataStructure,warning] = loadDatasetV1(filenames)
%
%   archiveFilenames - cell array (of strings)
%                      Name of the files that are contained in the (already
%                      unzipped) archive.
%
%   dataStructure    - struct
%                      content of the XML file
%                      data.data holds the data read from the ZIP archive
%
%   warning          - cell array
%                      Contains warnings if there are any, otherwise empty
%
% SEE ALSO commonLoad

% Copyright (c) 2015, Till Biskup
% 2015-03-23

dataStructure = [];
warning = cell(0);

% Define names and extensions
XMLfileName = 'struct.xml';
binaryFieldNames = {'data','origdata','calculated'};
binaryDataDir = 'binaryData';

try
    [archiveDirectory,~,~] = fileparts(archiveFilenames{1});
    precision = char(...
        common_textFileRead(fullfile(archiveDirectory,'PRECISION')));
    
    % Read XML
    XMLfileName = fullfile(archiveDirectory,XMLfileName);
    XMLfileSerialize(XMLfileName);
    dataStructure = xml2struct(xmlread(XMLfileName));
    
    % Handle data that are saved as binary
    for binaryFieldName = 1:length(binaryFieldNames)
        if exist(fullfile(archiveDirectory,binaryDataDir,...
                binaryFieldNames{binaryFieldName}),'file')
            dataStructure.(binaryFieldNames{binaryFieldName}) = ...
                common_binaryFileRead(...
                fullfile(archiveDirectory,binaryDataDir,...
                binaryFieldNames{binaryFieldName}),...
                precision);
        end
    end
catch exception
    warning{end+1} = sprintf('%s\n%s\n"%s"\n',...
        exception.identifier,...
        'Problems with loading file:',...
        name);
    return;
end

end
