function trueOrFalse = commonStructureHasField(structure,field)
% COMMONSTRUCTUREHASFIELD Check whether structure has given field. Field
% may be a cascaded field containing ".".
%
% Usage
%   TF = commonStructureHasField(structure,field)
%
%   structure - struct
%               Matlab structure to test
%
%   field     - string
%               Name of field to test for
%               May contain ".", i.e. be a subfield
%
% SEE ALSO: isfield

% Copyright (c) 2014-15, Till Biskup
% 2015-11-23

nDots = strfind(field,'.');

if isempty(nDots)
    trueOrFalse = isfield(structure,field);
else
    if isfield(structure,field(1:nDots(1)-1))
        trueOrFalse = commonStructureHasField(...
            structure.(field(1:nDots(1)-1)),field(nDots(1)+1:end));
    else
        trueOrFalse = false;
    end
end

end