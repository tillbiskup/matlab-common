function datasafe_path = commonDatasafeGetPath(sample_no, measurement_no, method)
% Get path to datasafe for given sample, measurement and method
%
% Usage:
%   datasafe_path = commonDatasafeGetPath(sample, measurement, method)
%
%   sample - string or integer
%       Number of the sample
%
%   measurement
%       Number of the measurement
%
%   method
%       Method used to obtain the data (as used within the datasafe)
%
% Prerequisites:
%
% * A (manual) datasafe
%
% * A configuration file for the common Toolbox containing the path to the
%   datasafe

% Copyright (c) 2020, Till Biskup
% 2020-11-16

config = commonConfigGet('datasafe', 'prefix', commonGetPrefix(mfilename));
DATASAFE_DIR = config.datasafe.basedir;

if isnumeric(sample_no)
    sample_no = num2str(sample_no);
end
if isnumeric(measurement_no)
    measurement_no = num2str(measurement_no);
else
    % Get rid of leading zeros by converting str->double->str
    measurement_no = num2str(str2double(measurement_no));
end

datasafe_dir = [...
    DATASAFE_DIR, filesep, ...
    sample_no, filesep, ...
    method, filesep, ...
    measurement_no, filesep ...
    ];

if ~exist(datasafe_dir, 'dir')
    warning('Path %s does not exist...', datasafe_dir);
    return
end

infofile = commonDir([datasafe_dir, '*.info']);

datasafe_path = [datasafe_dir, infofile{1}];

end