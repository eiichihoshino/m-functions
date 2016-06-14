function pathlist = get_pathlist_by_run(filepath)
%
% GET_PATHLIST_BY__RUN: gets a pathlist of runs x probes from a filepath.
%
% INPUT
% 	filepath: path to files to be listed
%
% OUTPUT
% 	filelist: {number_of_runs, number_of_probes}
%
% Version 1.0.0 on 2016.5.17 by Hoshino, E..
%
pathlist = strcat(filepath, filesep, get_filelist_by_run(filepath));