classdef UpdateChecker < handle
%
% UPDATECHACKER: cache load files and check if they are up to date.
%
% METHOD
% 	UpdateChecker(m_file, cache_path):
%       - m_file: mfilename of caller.
%       - cache_path: path to cache.
%
% Version 1.0.1 Remove cache_path and subdirs from path. 2016.6.24 Hoshino, E..
% Version 1.0.0 on 2016.6.10 by Hoshino, E..
%
    properties
        m_files; %{filepath, needs_update, succeded}
        input_files; %{filepath, needs_update, succeded}
        cache_path;
    end
    methods
        function self = UpdateChecker(m_file, cache_path)
            if ismember(cache_path,regexp(path, pathsep, 'split'))
                rmpath(genpath(['.' filesep cache_path]));
            end
            self.m_files = matlab.codetools.requiredFilesAndProducts(m_file);
            self.m_files = [self.m_files' repmat({1 0}, [length(self.m_files) 1])];
            self.cache_path = cache_path;
            if ~exist(self.cache_path, 'dir')
                return;
            end
            
            for file_i = 1:size(self.m_files, 1)
                if self.compare_to_cache(self.m_files{file_i, 1})
                    self.m_files{file_i, 2} = 0;
                end
            end
        end
        
        function needs_update = needsUpdate(self, files)
            do_files_exist = cell2mat(cellfun(@(x) exist(x, 'file'), files, 'UniformOutput', false));
            if ~all(do_files_exist)
                indices = find(~do_files_exist);
                error('File: %s does not exist.', files{indices(1)});
            end
            if isempty(self.input_files)
                self.input_files = [files' repmat({1 0}, [length(files) 1])];
            else
                new_files = setdiff(files, self.input_files(:,1));
                self.input_files = [self.input_files; [new_files' repmat({1 0}, [length(new_files) 1])];];
            end
            if any([self.m_files{:,2}])
                needs_update = true;
                return;
            end
            
            for file_i = 1:length(files)
                if self.compare_to_cache(files{file_i})
                    [self.input_files{ismember(self.input_files(:,1), files), 2}] = deal(0);
                else
                    [self.input_files{ismember(self.input_files(:,1), files), 2}] = deal(1);
                    needs_update = true;
                    return
                end
            end
            needs_update = false;
        end
        
        function didSucceed(self, files)
            indices = ismember(files, self.input_files(:,1));
            if ~all(indices)
                error('Error! %s must needsUpdate before didSucceed.', files{1});
            end
            [self.input_files{ismember(self.input_files(:,1), files), 3}] = deal(1);
        end
        
        function renewCache(self)
            if ~exist(self.cache_path, 'dir')
                [status,message,messageid] = mkdir(self.cache_path);
                if ~status
                    warning(messageid, message);
                end
            end
            if all([self.input_files{:, 3}])
                for file_i = 1:length(self.m_files)
                    if self.m_files{file_i, 2}
                        self.copy_to_cache(self.m_files{file_i, 1});
                    end
                end
            end
            for file_i = 1:length(self.input_files)
                if self.input_files{file_i, 2}
                    if self.input_files{file_i, 3}
                        self.copy_to_cache(self.input_files{file_i, 1});
                    else
                        %fprintf('%s is out of date but not checked as succeeded..\n', self.input_files{file_i, 1});
                    end
                end
            end
        end
    end
    
    methods (Access = private)
        function is_equal = compare_to_cache(self, a_file)
            is_equal = true;
            
            cache_file_path = fullfile(self.cache_path, regexprep(abs_path(a_file), '[*:\?\"<>\|]', ''));
            if exist(cache_file_path, 'file')
                if contentEquals(a_file, cache_file_path)
                    fprintf('%s is up to date.\n', regexprep(cache_file_path, sprintf('^.*%s',filesep), ''));
                else
                    %fprintf('%s is old.\n',cache_file_path);
                    is_equal = false;
                    return;
                end
            else
                is_equal = false;
                return;
            end
        end
        function copy_to_cache(self, a_file)
            cache_dir_path = fullfile(self.cache_path, regexprep(fileparts(abs_path(a_file)), '[*:\?\"<>\|]', ''));
            if ~exist(cache_dir_path, 'dir')
                [status,message,messageid] = mkdir(cache_dir_path);
                if ~status
                    warning(messageid, message);
                end
            end
            [status,message,messageid] = copyfile(a_file, cache_dir_path);
            if status
                fprintf('%s is cached.\n', regexprep(a_file, sprintf('^.*%s',filesep), ''));
            else
                warning(messageid, message);
            end
        end
    end
end