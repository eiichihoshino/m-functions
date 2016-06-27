function filelist_by_id = get_filelist_by_id(files)
%
% GET_FILELIST_BY_ID: arranges filelist by each subject.
% Ver.1.0.2    Add error message when "files" is empty.    2016.6.27 Hoshino, E..
%
% INPUT
% 	files: a path to a directory that contains files to be listed or a cell of filenames.
%
% OUTPUT
% 	filelist: {subject x files}.
%
% [History]
% Ver.1.0.1    Add error message when "files" is not exist.    2016.6.14 Hoshino, E..
% Ver.1.0.0    Initialize.    2016.5.31 by Hoshino, E..
%
% 
if ischar(files)
    if exist(files, 'dir')
        files_struct = dir(fullfile(files, '*.mat'));
        files =  strcat(files, filesep, {files_struct.name});
        if isempty(files)
            error('Error! A directory:%s is empty.', files);
        end
    else
        error('Error! %s is not found. Check if the path exists or a input argument is a cell of filenames.', files);
    end
end
m = regexp([files{:}], '([E|N])(\d+)\D', 'tokens');
ids_of_files = cellfun(@(x) [x{1} repmat('0', [1 3-length(x{2})]) x{2}], m, 'UniformOutput', false);
unique_ids = unique(ids_of_files);
indices_of_files_by_id = cellfun(@(x) find(ismember(ids_of_files, x)), unique_ids, 'UniformOutput', false);
filelist_by_id = cell(length(unique_ids), 1 + max(cellfun(@length, indices_of_files_by_id)));
for id_i = 1:length(unique_ids)
	filenames_of_id = arrayfun(@(x) files(x), indices_of_files_by_id{id_i});
	filelist_by_id(id_i, 1) = unique_ids(id_i);
	filelist_by_id(id_i, 2:length(filenames_of_id)+1) = filenames_of_id;
end