function pathlist = get_pathlist_by_run(filepath)
%
% GET_PATHLIST_BY__RUN: gets a pathlist of runs x probes from a filepath.
% Ver, 1.0.2  Keep empty when filename of filelist is empty. 2016.10.6 Hochino, E.
%
% INPUT
% 	filepath: path to files to be listed
%
% OUTPUT
% 	filelist: {number_of_runs, number_of_probes}
%
% [History]
% Ver. 1.0.1 Use fullfile instead of strcat. 2016.10.6 Hoshino, E.
% Ver. 1.0.0 on 2016.5.17 Hoshino, E.
%
filelist = get_filelist_by_run(filepath);
[m,n] = size(filelist);
pathlist = cell(m,n);
for ii = 1:m
    for jj = 1:n
        if ~isempty(filelist{ii,jj})
            pathlist(ii,jj) = fullfile(filepath, filelist(ii,jj));
        end
    end
end