%%% parameters %%%
input_path = 'by_id';
output_path = 'by_id_check_valid';
%%%%%%%%%%%%%%%%%%

subpaths = regexp(genpath('.'), ';', 'split');
addpath(strjoin(subpaths(cellfun(@(s) isempty(regexp(s, regexprep(strjoin({'cache', '.git'}, '|'), '\.', '\\.'))), subpaths)), ';'));
if ~exist(output_path, 'dir')
    mkdir(output_path);
end

%initialize UpdateChecker
checker = UpdateChecker([mfilename '.m'], fullfile(output_path, 'cache'));
filelist_by_id = get_filelist_by_id(input_path);
clear ids;
for id_i = size(filelist_by_id,1):-1:1
    fprintf('Processing: %d out of %d.\n', size(filelist_by_id,1)-id_i+1, size(filelist_by_id, 1));
    filepath = filelist_by_id(id_i, 2);
    if checker.needsUpdate(filepath)
        clear id;
        
        %load id
        load(filepath{1});
        %calculate connectivity for each run
        for run_i = length(id.runs):-1:1
            id.runs(run_i).connectivity = get_connectivity(id.runs(run_i).data(:,:,1:2));
        end
        
        %change data of pairs unsatisfying the criteria to NaN
        is_sample_short = id.runs(run_i).connectivity.n < 1200;
        n_ch = size(id.runs(run_i).connectivity.n, 1);
        if sum(sum(triu(is_sample_short(:,:,1),1))) < n_ch * (n_ch-1) * 0.375
            id.runs(run_i).connectivity.valid = true;
            id.runs(run_i).connectivity.r(is_sample_short) = NaN;
            id.runs(run_i).connectivity.z(is_sample_short) = NaN;
            id.runs(run_i).connectivity.p(is_sample_short) = NaN;
            id.runs(run_i).connectivity.pfdr(is_sample_short) = NaN;
        else
            id.runs(run_i).connectivity.valid = false;
            id.runs(run_i).connectivity.r = NaN;
            id.runs(run_i).connectivity.z = NaN;
            id.runs(run_i).connectivity.p = NaN;
            id.runs(run_i).connectivity.pfdr = NaN;
        end
        
        [~,name,~] = fileparts(id.runs(1).filename);
        save(fullfile(output_path, [name '.mat']), 'id');
        ids(id_i) = id;
    end
    checker.didSucceed(filepath);
end
checker.renewCache();