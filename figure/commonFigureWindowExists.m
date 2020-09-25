function answer = commonFigureWindowExists(varargin)
% COMMONFIGUREWINDOWEXISTS Check whether there is an open figure window.
%
% Usage:
%    TF = commonFigureWindowExists
%    TF = commonFigureWindowExists(handle)
%
%   handle - MATLAB(r) graphics handle
%
% If used without input argument, checks whether there is any open MATLAB(r)
% figure window. Note that "gcf" can't be used in this context as it opens a
% figure window if none existed before.
%
% If called with input argument, checks whether handle is a valid and existing
% MATLAB(r) figure handle.
%
% SEE ALSO: gcf, figure, findobj, allchild

% Copyright (c) 2015-20, Till Biskup
% 2020-09-25

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addOptional('handle',[],@ishghandle);
    p.parse(varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

if ~nargin
    answer = ~isempty(findobj(allchild(0),'type','figure'));
    return;
end

answer = strcmpi(get(p.Results.handle,'type'),'figure');

end