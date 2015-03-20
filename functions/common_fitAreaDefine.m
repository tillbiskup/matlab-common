function area = common_fitAreaDefine(dataset)
% COMMON_FITAREADEFINE Defining fit area for whatsoever
%
% Usage
%  area = common_fitAreaDefine(dataset)
%
%   dataset  - struct
%
%   area     - boolean vector
%

% Copyright (c) 2014, Simona Huwiler, Till Biskup
% 2015-03-20

B0=dataset.axes(1).values;
spectrum = dataset.data;

% Define vector with indices for B0
B0indices = 1:1:length(B0); 

% Predefine area for fitting
areaIndices = [1:200 length(B0)-300:length(B0)];
area = zeros(1,length(B0));
area(areaIndices) = 1;

% Visualize: Plot area in spectrum
plotArea(B0indices,spectrum,areaIndices);
xlabel('{\it B0 Indices}');
ylabel('{\it intensity} / a.u.');
title('Suggested baseline area');

areaOK = input('Fitting area OK? (Press enter if happy, press n if not.). ','s');

if isempty(areaOK)
    area = logical(area);
    return;
end

areaOK = 'n';

while ~isempty(areaOK)
    promptString = sprintf('%s\n (%s %s, ...)\n',...
        'New fitting area:',...
        'indicate: StartArea1:EndArea1',...
        'StartArea2:EndArea2');
    userDefinedArea = input(promptString,'s');
    
    areaIndices = eval(['B0indices([' userDefinedArea ']);']);
    plotArea(B0indices,spectrum,areaIndices);
    xlabel('{\it B0 Indices}');
    ylabel('{\it intensity} / a.u.');
   title('Suggested baseline area');
    
    areaOK = input('Fitting area OK? (Press enter if happy, press n if not.). ','s');
    area(areaIndices) = 1; 
    
end

area = logical(area);


% Plotting Subfunction
    function plotArea(B0indices,spectrum,area)
        % Define area for baseline fit
        % Therefore: plot spectrum
        plot(B0indices,spectrum);
        set(gca,'XGrid','on');
        
        % Plot area
        hold on
        gcaYmin = min(get(gca,'YLim'));
        plot(B0indices(area),zeros(length(area),1)+gcaYmin,...
            'Color','r','LineWidth',5,'LineStyle','.');
        hold off
        
        % Exchange 0=>1 for first XTickLabel to prevent user confusion
        xTickLabel = get(gca,'XTickLabel');
        xTickLabel(1) = '1';
        set(gca,'XTickLabel',xTickLabel);
        
    end

end