function filelist = get_filelist_by_run(filepath)
%
% GET_FILELIST_BY_RUN: gets a filelist of runs x probes from a filepath.
% Version 1.1.0 Fix a bug of insetring the same filenames when a number of
% probe is 1. 2016.10.6 Hoshino, E.
%
% INPUT
% 	filepath: path to files to be listed
%
% OUTPUT
% 	filelist: {number_of_runs, number_of_probes}
%
% [History]
% Version 1.0.0 on 2016.5.17 Hoshino, E..
%
if nargin < 1
    filepath = '.';
end
list = dir(fullfile(filepath, '*.csv'));
filename_head = cellfun(@(x) x(1:end-5), {list.name}, 'UniformOutput', false);
filename_head = unique(filename_head);
if ~isempty(list)
    probe_numbers = regexp([list.name], 'Probe(\d)', 'tokens');
    number_of_probes = max(cell2mat(cellfun(@(x) str2num(x{1}), probe_numbers, 'UniformOutput', false)));
    number_of_runs = length(filename_head);
    
    filelist = cell(number_of_runs, number_of_probes);
    for run_i = 1:number_of_runs
        filtered = regexp({list.name}, ['^' filename_head{run_i} '.*\.csv'] , 'match');
        filelist(run_i, 1:numel([filtered{:}])) = [filtered{:}];
    end
else
    filelist = [];
end
