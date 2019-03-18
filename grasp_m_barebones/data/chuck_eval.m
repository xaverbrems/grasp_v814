function varargout = chuck_eval(chuck_eval_fn,fname)

%Declare nesting+ or compound line keywords
chuck_eval_nestplus_keywords = {'while', 'for', 'try', 'if'};
chuck_eval_nestminus_keywords = {'end'};
chuck_eval_compound_line = [];
chuck_eval_new_vars_out = [];
chuck_eval_nest_counter = 0;

%Open the function file and execute one by one
chuck_eval_fid=fopen(chuck_eval_fn);

if not(chuck_eval_fid==-1)
    disp(['Executing External Function: ' chuck_eval_fn]);
    disp('  ');
    
    while ~feof(chuck_eval_fid)
        
        %Read line from file and parse
        chuck_eval_line = strtrim(fgetl(chuck_eval_fid)); %Trim any whitespaces before the first text
        if not(isempty(chuck_eval_line))
            chuck_eval_line_length = length(chuck_eval_line);
            
            %Remove commented lines
            if strcmp(chuck_eval_line(1),'%'); continue; end
            
            %Ignore the 'function' declaration at the header for now
            if chuck_eval_line_length >= 8
                if strcmp(chuck_eval_line(1:8),'function')
                    %recuperate the function's output arguments
                    chuck_eval_vars_out = extractBetween(chuck_eval_line,'function','=');
                    chuck_eval_vars_out = chuck_eval_vars_out{1};
                    chuck_eval_seperators = strfind(chuck_eval_vars_out,',');
                    chuck_eval_seperator_edges = [1, chuck_eval_seperators, length(chuck_eval_vars_out)];
                    for chuck_eval_n = 1:length(chuck_eval_seperator_edges)-1
                        chuck_eval_new_vars_out{chuck_eval_n} = chuck_eval_vars_out(chuck_eval_seperator_edges(chuck_eval_n):chuck_eval_seperator_edges(chuck_eval_n+1)); %#ok<AGROW>
                    end
                    %strip out the junk characters , [ ] whitespace
                    chuck_eval_new_vars_out = erase(chuck_eval_new_vars_out,',');
                    chuck_eval_new_vars_out = erase(chuck_eval_new_vars_out,']');
                    chuck_eval_new_vars_out = erase(chuck_eval_new_vars_out,'[');
                    chuck_eval_new_vars_out = erase(chuck_eval_new_vars_out,' ');
                    continue; end
            end
            
            %Check for comments % after commands and not part of string formatting within commands
            chuck_eval_comment = strfind(chuck_eval_line,'%');
            chuck_eval_quotes = strfind(chuck_eval_line,'''');
            if not(isempty(chuck_eval_comment)) %i.e. there is a %
                if not(isempty(chuck_eval_quotes)) %there are quotes
                    chuck_eval_temp = find(chuck_eval_quotes<chuck_eval_comment(end));
                    if isodd(length(chuck_eval_temp))
                        % % is between quotes therefore is string formatting - do nothing
                    else %remove the quote
                        chuck_eval_line = chuck_eval_line(1:chuck_eval_comment(end)-1);
                    end
                else %remove the quote
                    chuck_eval_line = chuck_eval_line(1:chuck_eval_comment(end)-1);
                end
            end
            
            %disp(['Line to be considered:   ' chuck_eval_line])
            
            %Look for nesting+ & compound line keywords. Make sure these are not in disp text displays or part of some other text
            for chuck_eval_n = 1: length(chuck_eval_nestplus_keywords)
                chuck_eval_keyword_position = strfind(chuck_eval_line,chuck_eval_nestplus_keywords{chuck_eval_n});
                if not(isempty(chuck_eval_keyword_position)) %Keyword is present somewhere
                    %disp(['Found keyword(s): ''' chuck_eval_nestplus_keywords{chuck_eval_n} ''' at position(s) ' num2str(chuck_eval_keyword_position)]);
                    for chuck_eval_m = 1: length(chuck_eval_keyword_position) %check for multiple instances
                        %Check it's not between quotes
                        if not(isempty(chuck_eval_quotes))
                            chuck_eval_nquote_before_keyword = length(find(chuck_eval_quotes < chuck_eval_keyword_position(chuck_eval_m)));
                        else
                            chuck_eval_nquote_before_keyword = 0;
                        end
                        %Check it is a word on it's own
                        if chuck_eval_keyword_position(chuck_eval_m)>1
                            if strcmp(chuck_eval_line(chuck_eval_keyword_position(chuck_eval_m)-1),' ') || strcmp(chuck_eval_line(chuck_eval_keyword_position(chuck_eval_m)-1),';')
                                chuck_eval_keyword_check = 1; %keyword is on its own so probably real
                                %disp('word on its own')
                            else
                                chuck_eval_keyword_check = 0; %keyword is part of some other text therefore not real keyword
                                %disp('part of some other text')
                            end
                        else %keyword is at the beginning so probably real
                            %disp('word is at the beginning')
                            chuck_eval_keyword_check = 1;
                        end
                        
                        if not(isodd(chuck_eval_nquote_before_keyword)) && chuck_eval_keyword_check == 1 %i.e. a real keyword is present
                            %disp(['Keyword: ''' chuck_eval_nestplus_keywords{chuck_eval_n} ''' at position ' num2str(chuck_eval_keyword_position(chuck_eval_m)) ' is real keyword'])
                            %disp(['In line:  ' chuck_eval_line]);
                            chuck_eval_nest_counter = chuck_eval_nest_counter + 1; %increase the nesting depth
                        else %not a real keyword
                            %disp('Not a real keyword')
                        end
                    end
                end
            end
            
            %Look for nesting- keywords. Make sure these are not in disp text displays or part of some other text
            for chuck_eval_n = 1: length(chuck_eval_nestminus_keywords)
                chuck_eval_keyword_position = strfind(chuck_eval_line,chuck_eval_nestminus_keywords{chuck_eval_n});
                
                if not(isempty(chuck_eval_keyword_position)) %Keyword is present somewhere
                    %disp(['Found keyword(s): ''' chuck_eval_nestminus_keywords{chuck_eval_n} ''' at position(s) ' num2str(chuck_eval_keyword_position)]);
                    for chuck_eval_m = 1: length(chuck_eval_keyword_position) %check for multiple instances
                        %Check it's not between quotes
                        if not(isempty(chuck_eval_quotes)) && not(isempty(chuck_eval_keyword_position(chuck_eval_m)))
                            chuck_eval_nquote_before_keyword = length(find(chuck_eval_quotes < chuck_eval_keyword_position(chuck_eval_m)));
                        else
                            chuck_eval_nquote_before_keyword = 0;
                        end
                        %Check it is a word on it's own
                        if chuck_eval_keyword_position(chuck_eval_m)>1
                            if strcmp(chuck_eval_line(chuck_eval_keyword_position(chuck_eval_m)-1),' ') || strcmp(chuck_eval_line(chuck_eval_keyword_position(chuck_eval_m)-1),';')
                                %keyword is on its own so probably real
                                chuck_eval_keyword_check = 1;
                            else
                                %keyword is part of some other text therefore not real keyword
                                chuck_eval_keyword_check = 0;
                            end
                        else
                            %keyword is at the beginning so probably real
                            chuck_eval_keyword_check = 1;
                        end
                        
                        if not(isodd(chuck_eval_nquote_before_keyword)) && chuck_eval_keyword_check == 1 %i.e. a real keyword is present
                            %disp(['Keyword: ''' chuck_eval_nestminus_keywords{chuck_eval_n} ''' is real keyword'])
                            %disp(['In line:  ' chuck_eval_line]);
                            
                            chuck_eval_nest_counter = chuck_eval_nest_counter - 1; %increase the nesting depth
                            %chuck_eval_compound_line = [chuck_eval_compound_line '; ' chuck_eval_line]; %#ok<AGROW> %grow compound line
                        else %not a real keyword
                            %disp('Not a real keyword')
                        end
                    end
                end
            end
            
            %disp(['Loop nest level:  ' num2str(chuck_eval_nest_counter)])
            %Look for nested commands
            if chuck_eval_nest_counter >0  %we are somewhere within the nest, keep growing command
                chuck_eval_compound_line = [chuck_eval_compound_line '; ' chuck_eval_line]; %#ok<AGROW> %grow compound line
                
                
            else %Either single command or end of a compound line coming though
                if isempty(chuck_eval_compound_line) %No compound line
                    %disp(['Executing single line: ' chuck_eval_line])
                    eval(chuck_eval_line); %Execute current line
                else %Compound line ready for execution
                    %disp(['Executing compound line: ' chuck_eval_compound_line])
                    chuck_eval_compound_line = [chuck_eval_compound_line '; ' chuck_eval_line]; %#ok<AGROW> %add the last command to the compound line
                    eval(chuck_eval_compound_line);
                    chuck_eval_compound_line = []; %clear compound line ready for next time
                end
            end
            %disp(' ')
            %qqq = input('press');
        end
    end
else
    disp('Cannot find function to evaluate')
end

%Allocate all the output variables
for chuck_eval_n = 1:length(chuck_eval_new_vars_out)
    varargout{chuck_eval_n} = eval(chuck_eval_new_vars_out{chuck_eval_n}); %#ok<AGROW>
end

