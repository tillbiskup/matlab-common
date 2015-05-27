classdef tpl < handle
% TPL A template engine used to handle templates from within Matlab(r).
%
% Currently, the engine can:
%
%   * replace variables in a template with content given in a structure
%     (the field name of the structure needs to correspond to the variable
%     in the template) 
%
%   * include other templates from within a template using the "include"
%     statement
%
%   * handle "for" and "if" statements
%
% Nesting is currently only supported for variables and includes, not for
% for and if statements.
%
% PLEASE NOTE: TPL is written making use of Matlab(r)'s OOP capabilities.
% Therefore, the example below is slightly more complicated than that of a
% "simple" function.
%
% Usage:
%   obj = tpl();
%   obj.setTemplate('test.tpl');
%   S = struct(...); % Assignments
%   obj.setAssignments(S);
%   output = obj.render();

% (c) 2014, Till Biskup
% 2014-06-24
    
    properties (Access = private)
        
        % Directory for the templates
        %
        % @var       string
        templateDir = '';
        
        % Delimiter for a standard placeholder
        %
        % @var       2x1 cell of strings
        delimiter = {'{{','}}'};

        % Identification string for a variable
        %
        % @var       string
        variableChar = '@';
        
        % Format string for numerical variables (used in sprintf)
        %
        % @var       string
        formatString = '%03.2f';
        
        % Position of opening/closing delimiters for a standard placeholder
        % in template
        %
        % @var       array
        posOpenDelimiter = [];
        posCloseDelimiter = [];

        % Full path to the template file
        %
        % @var       string
        templateFile = '';
        
        % Content of the template
        %
        % @var       string
        template = '';
        
        % Parsed content of the template
        %
        % @var       nx2 cell array of strings
        parsedContent = cell(0,3);
        
        % Position in parsed content of the template
        %
        % @var       scalar
        position = 0;
        
        % Start, branch, and end position of loops/conditions
        %
        % @var       scalar
        posStart = 0;
        posBranch = 0;
        posEnd = 0;
        
        % Assignments of variables to be replaced and their contents
        %
        % @var       struct
        assignments = struct();
    end
    
    methods (Access = private)
        function loadFile(this)
            % LOADFILE Read the template file
            %
            % @access    private
            if isempty(this.templateFile)
                return;
            end
            fid = fopen(this.templateFile);
            
            contents = '';
            
            tline = fgets(fid);
            while ischar(tline)
                contents = [contents tline]; %#ok<AGROW>
                tline = fgets(fid);
            end
            fclose(fid);
            this.template = contents;
        end
        
        function output = parse(this)
            % PARSE Actual parsing of template
            %
            % @access    private
            this.assignDelimiterPositions();
            
            stringPosition = 1;
            for idx = 2:2:length(this.posOpenDelimiter)*2
                this.parsedContent(idx-1,:) = {'text',this.template(...
                    stringPosition:this.posOpenDelimiter(idx/2)-1),...
                    this.template(...
                    stringPosition:this.posOpenDelimiter(idx/2)-1)};
                this.parsedContent(idx,:) = {'token',strtrim(...
                    this.template(this.posOpenDelimiter(idx/2) + ...
                    length(this.delimiter{1}) : ...
                    this.posCloseDelimiter(idx/2)-1)),...
                    this.template(this.posOpenDelimiter(idx/2) : ...
                    this.posCloseDelimiter(idx/2) + ...
                    length(this.delimiter{2})-1)};
                stringPosition = this.posCloseDelimiter(idx/2) + ...
                    length(this.delimiter{1});
            end
            
            if stringPosition <= length(this.template)
                this.parsedContent(end+1,:) = ...
                    {'text',this.template(stringPosition:end),...
                    this.template(stringPosition:end)};
            end
            this.parsedContent = this.parsedContent(...
                ~cellfun('isempty',this.parsedContent(:,1)),:);
            
            level = 0;
            evaluateSymbol = '';
            
            for idx=1:size(this.parsedContent,1)
                this.position = idx;
                if strcmpi(this.parsedContent{idx,1},'token')
                    % Handle nesting
                    if strfind(this.parsedContent{idx,2},this.delimiter{1})
                        tplobj = tpl();
                        tplobj.setTemplateContent(this.parsedContent{idx,2});
                        tplobj.setAssignments(this.assignments);
                        this.parsedContent{idx,2} = tplobj.render();
                    end
                    % Handle variable replacement
                    if strncmp(this.parsedContent{idx,2},'@',1)
                        this.expandVariable();
                    else
                        % Handle everything else
                        switch strtok(this.parsedContent{idx,2},' ')
                            case 'include'
                                this.expandInclude();
                            case 'if'
                                if level == 0
                                    evaluateSymbol = 'if';
                                    this.posStart = idx;
                                end
                                level = level + 1;
                                %this.expandIf();
                            case 'for'
                                if level == 0
                                    evaluateSymbol = 'for';
                                    this.posStart = idx;
                                end
                                level = level + 1;
                                %this.expandFor();
                            case 'else'
                                if level == 1
                                    this.posBranch = idx;
                                end
                            case 'end'
                                level = level - 1;
                                if level == 0
                                    this.posEnd = idx;
                                    switch evaluateSymbol
                                        case 'for'
                                            this.expandFor();
                                        case 'if'
                                            this.expandIf();
                                    end
                                end
                        end
                    end
                end
            end
                        
            % Assign parsed and replaced content to output
            output = this.parsedContent(:,2);
            output = output(~cellfun('isempty',output));
            output = [output{:}];
        end
        
        function assignDelimiterPositions(this)
            % ASSIGNDELIMITERPOSITIONS Assign positions of delimiters in
            % template and test for consistency. 
            %
            % @access    private
            openDelimiterPos = strfind(this.template,this.delimiter{1});
            closeDelimiterPos = strfind(this.template,this.delimiter{2});
            if length(closeDelimiterPos) ~= length(openDelimiterPos) || ...
                    any(closeDelimiterPos<=openDelimiterPos)
                exception = MException('tpl:ParseError',...
                    'Delimiter mismatch');
                throw(exception);
            end
            pos = 1;
            level = 0;
            while pos <= length(this.template)-length(this.delimiter{1})+1
                switch this.template(pos:pos+length(this.delimiter{1})-1)
                    case this.delimiter{1}
                        if level == 0
                            this.posOpenDelimiter(end+1) = pos;
                        end
                        level = level+1;
                    case this.delimiter{2}
                        if level == 1
                            this.posCloseDelimiter(end+1) = pos;
                        end
                        level = level-1;
                end
                pos = pos + 1;
            end
        end
        
        function expandVariable(this)
            % EXPANDVARIABLE Expand variables in template using the fields
            % in this.assigments
            %
            % @access    private
            [varname,option] = ...
                strtok(this.parsedContent{this.position,2}(2:end),'|');
            [varname,varindex] = strtok(varname,'(');
            if ~isempty(varindex)
                varindex = str2double(varindex(2:end-1));
            end
            if ~commonIsCascadedField(this.assignments,varname)
                return;
            end
            % Assign defaults
            strFormat = this.formatString;
            if ~isempty(option)
                [splitting] = regexp(option(2:end),'=','split');
                switch lower(splitting{1})
                    case {'format','fmt','f'}
                        strFormat = [ '%' splitting{2}];
                end
            end
            if ~isempty(strFormat) && ~strncmpi(strFormat,'%',1)
                strFormat = [ '%' strFormat ];
            end
            if ~isempty(varindex) && ...
                    round(varindex) <= length(this.assignments.(varname))
                if iscell(this.assignments.(varname))
                    replacement = this.assignments.(varname){round(varindex)};
                else
                    replacement = this.assignments.(varname)(round(varindex));
                end
            else
                replacement = ...
                    commonGetCascadedField(this.assignments,varname);
            end
            if isnumeric(replacement)
                if isempty(strFormat)
                    this.parsedContent{this.position,2} = ...
                        num2str(replacement);
                else
                    if length(replacement) > 1
                        strFormat = [strFormat ' '];
                    end
                    this.parsedContent{this.position,2} = ...
                        sprintf(strFormat,replacement);
                end
                if length(replacement) > 1
                    this.parsedContent{this.position,2} = ...
                        [ '[' this.parsedContent{this.position,2} ']' ];
                end
            else
                this.parsedContent{this.position,2} = replacement;
            end
            
        end
        
        function expandInclude(this)
            % EXPANDINCLUDE Handle include statements in template
            %
            % @access    private
            filename = strtrim(this.parsedContent{this.position,2}...
                (length('include')+1:end));
            tplobj = tpl('tpldir',this.templateDir);
            tplobj.setTemplate(filename);
            tplobj.setAssignments(this.assignments);
            this.parsedContent{this.position,2} = tplobj.render();
        end
        
        function expandIf(this)
            % EXPANDIF Handle if conditions in template
            %
            % @access    private
            
            % Get condition
            conditionString = strtrim(...
                this.parsedContent{this.posStart,2}(length('if')+1:end));
            if isfield(this.assignments,conditionString)
                condition = this.assignments.(conditionString);
            else
                try
                    condition = eval(conditionString);
                catch  %#ok<CTCH>
                    % For now, silently ignore
                    condition = false;
                end
            end
            content = '';
            % Empty parsedContent that is no longer needed
            this.parsedContent{this.posStart,2} = '';
            this.removeLinefeed(this.posStart+1);
            if condition
                % Empty parsedContent in else condition if available
                if ~isempty(this.posBranch)
                    for idx=this.posBranch:this.posEnd-1
                        this.parsedContent{idx,2} = '';
                        this.removeLinefeed(idx+1);
                    end
                    content = this.parsedContent(...
                        this.posStart+1:this.posBranch-1,3);
                end
            elseif ~isempty(this.posBranch)
                for idx=this.posStart:this.posBranch
                    this.parsedContent{idx,2} = '';
                    this.removeLinefeed(idx+1);
                end
                content = this.parsedContent(...
                    this.posBranch+1:this.posEnd-1,3);
            else
                for idx=this.posStart:this.posEnd-1
                    this.parsedContent{idx,2} = '';
                    this.removeLinefeed(idx+1);
                end
            end
            % Evaluate contents
            tplobj = tpl();
            tplobj.setTemplateContent(content);
            assign = this.assignments;
            tplobj.setAssignments(assign);
            this.parsedContent{this.posStart+1,2} = tplobj.render();
            if this.posEnd > this.posStart+2
                for idx = this.posStart+2:this.posEnd-1
                    this.parsedContent{idx,2} = '';
                end
            end
            this.parsedContent{this.posEnd,2} = '';
            this.removeLinefeed(this.posEnd+1);
        end
        
        function expandFor(this)
            % EXPANDFOR Handle for loops in template
            %
            % @access    private            
            condition = strtrim(...
                this.parsedContent{this.posStart,2}(length('for')+1:end));
            % Empty parsedContent that is no longer needed
            this.parsedContent{this.posStart,2} = '';
            this.removeLinefeed(this.posStart+1);
            
            % Parse condition
            condition = strtrim(regexp(condition,'=','split'));
            variable = condition{1};
            rangeString = strtrim(regexp(condition{2},':','split'));
            range = zeros(1,length(rangeString));
            for idx = 1:length(rangeString)
                if strncmp(rangeString{idx},'@',1) ...
                        && isfield(this.assignments,rangeString{idx}(2:end)) ...
                        && isscalar(this.assignments.(rangeString{idx}(2:end)))
                    range(idx) = this.assignments.(rangeString{idx}(2:end));
                else
                    range(idx) = str2double(rangeString{idx});
                end
            end
            
            loop = this.parsedContent(this.posStart+1:this.posEnd-1,3);

            % Parse loop
            loopContent = '';
            for idx = range(1):range(2)
                tplobj = tpl();
                tplobj.setTemplateContent(loop);
                assign = this.assignments;
                assign.(variable) = idx;
                tplobj.setAssignments(assign);
                loopContent = [ loopContent char(13) ...
                    strtrim(tplobj.render()) ]; %#ok<AGROW>
            end
            
            % Assign output
            this.parsedContent{this.posStart+1,2} = loopContent;
            if this.posEnd > this.posStart+1
                for idx = this.posStart+2:this.posEnd-1
                    this.parsedContent{idx,2} = '';
                end
            end
            
            this.parsedContent{this.posEnd,2} = '';
            this.removeLinefeed(this.posEnd+1);
        end
        
        function removeLinefeed(this,position)
            % REMOVELINEFEED Remove obsolete additional linefeeds
            %
            % @access    private
            if position > size(this.parsedContent,1)
                return;
            end
            if all(isspace(this.parsedContent{position,2}))
                this.parsedContent{position,2} = '';
            end
        end
    end
    
    methods (Access = public)
        function obj = tpl(varargin)
            % CONSTRUCTOR Used to initialise the object
            %
            % @param     string tplDir
            % @access    public
            p = inputParser;       % Create an imputParser instance 
            p.StructExpand = true; % Allow passing arguments in a structure
            p.addParamValue('tplDir','',@(x)ischar(x));
            p.parse(varargin{:});
            
            if exist(p.Results.tplDir,'dir')
                obj.templateDir = p.Results.tplDir;
            end
        end
        
        function setTemplateDir(this,directory)
            % SETTEMPLATEDIR Set the directory where templates are located.
            %
            % @param     string directory
            % @access    public
            if exist(directory,'dir')
                this.templateDir = directory;
            end
        end
        
        function setTemplate(this,filename)
            % SETTEMPLATE Set the template file and load its contents.
            %
            % @param     string filename
            % @access    public
            if exist(filename,'file')
                this.templateFile = filename;
                this.loadFile;
            elseif exist(fullfile(this.templateDir,filename),'file')
                this.templateFile = fullfile(this.templateDir,filename);
                this.loadFile;
            end
        end
        
        function setTemplateContent(this,content)
            % SETTEMPLATECONTENT Set the template content.
            %
            % @param     string/cell content
            % @access    public
            if iscell(content)
                content = sprintf('%s',content{:});
            end
            this.template = content;
        end
        
        function setAssignments(this,assignments)
            % SETASSIGNMENTS Set structure with key-value pairs used to
            % replace placeholders in template with real content.
            %
            % @param     struct assignments
            % @access    public
            
            % For now, just check if input argument is a struct
            % Later on, this should be handled properly
            if ~isstruct(assignments)
                return;
            end
            this.assignments = assignments;
        end
        
        function addAssignments(this,assignments)
            % ADDASSIGNMENTS Add structure with key-value pairs used to
            % replace placeholders in template with real content to
            % assignments property.
            %
            % @param     struct assignments
            % @access    public
            
            % For now, just check if input argument is a struct
            % Later on, this should be handled properly
            if ~isstruct(assignments)
                return;
            end
            fieldNames = fieldnames(assignments);
            for fieldname = 1:length(fieldNames)
                if isfield(this.assignments,fieldNames{fieldname})
                    warning(['Field "%s" already exists' ...
                        'and will be overwritten'],...
                        fieldNames{fieldname});
                end
                this.assignments.(fieldNames{fieldname}) = ...
                    assignments(fieldNames{fieldname});
            end
        end
        
        function output = render(this)
            % RENDER Output the parsed and rendered template
            output = this.parse;
        end
        
    end
        
end