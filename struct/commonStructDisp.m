function commonStructDisp(structure)
% COMMONSTRUCTDISP Display structure array contents.
%   COMMONSTRUCTDISP(S) recursively displays the contents of a struct array.
%
%   See also CELLDISP.

% Copyright (c) 2011-15, Till Biskup
% 2015-09-18

if ~nargin
    help commonStructDisp
    return;
end

if ~isstruct(structure)
    fprintf('%s has wrong type',structure);
    return;
end

traverse(structure,inputname(1));

end


function traverse(structure,parent,varargin)

if nargin < 3
    depth = 1;
else
    depth = varargin{1};
end

space = '';
for m = 1:depth
    space = [space '    '];
end

fieldNames = fieldnames(structure);
maxlen = size(char(fieldNames),2);
for k=1:length(fieldNames)
    addspace = '';
    for m = 1:(maxlen-length(fieldNames{k}))
        addspace = [addspace ' '];
    end
    if length(structure.(fieldNames{k})) > 1 && ...
            isstruct(structure.(fieldNames{k})(1))
        fprintf('%s%s%s : <1x%i struct>\n',space,fieldNames{k},addspace,...
            length(structure.(fieldNames{k})));
        traverse(structure.(fieldNames{k})(1),...
            [parent '.' fieldNames{k}],depth+1);
    elseif isstruct(structure.(fieldNames{k}))
        fprintf('%s%s%s : <1x1 struct>\n',space,fieldNames{k},addspace);
        traverse(structure(1).(fieldNames{k}),...
            [parent '.' fieldNames{k}],depth+1);
    else
        if isnumeric(structure.(fieldNames{k}))
            if isscalar(structure.(fieldNames{k}))
                fprintf('%s%s%s : %s\n',space,fieldNames{k},addspace,...
                    num2str(structure.(fieldNames{k})));
            else
                if isempty(structure.(fieldNames{k}))
                    fprintf('%s%s%s : []\n',...
                        space,fieldNames{k},addspace);
                else
                    [xdim,ydim] = size(structure.(fieldNames{k}));
                    fprintf('%s%s%s : <%ix%i double>\n',...
                        space,fieldNames{k},addspace,xdim,ydim);
                end
            end
        elseif iscell(structure.(fieldNames{k}))
            [xdim,ydim] = size(structure.(fieldNames{k}));
            fprintf('%s%s%s : <%ix%i cell>\n',...
                space,fieldNames{k},addspace,xdim,ydim);
        elseif ischar(structure.(fieldNames{k}))
            fprintf('%s%s%s : ''%s''\n',...
                space,fieldNames{k},addspace,structure.(fieldNames{k}));
        end
    end
end

end
