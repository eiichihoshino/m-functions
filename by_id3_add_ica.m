%%% parameters %%%
input_dir = output_dir;
output_dir = mfilename;
%%%%%%%%%%%%%%%%%%

subpaths = regexp(genpath('.'), pathsep, 'split');
addpath(strjoin(subpaths(cellfun(@(s) isempty(regexp(s, regexprep(strjoin({'cache', '.git'}, '|'), '\.', '\\.'))), subpaths)), pathsep));
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

filelist_by_id = get_filelist_by_id(input_dir);
clear ids;
for id_i = size(filelist_by_id,1):-1:1
    fprintf('Loading: %d out of %d.\n', size(filelist_by_id,1)-id_i+1, size(filelist_by_id, 1));
    filepath = filelist_by_id(id_i, 2);
    %load runs
    load(filepath{1});
    for kk = 1% size(ws.data, 3):-1:1
        id.runs(1).ICA(kk) = ms_ica(id.runs(1).data0(:,:,kk)');
    end
    [~,name,~] = fileparts(id.runs(1).filename);
    save(fullfile(output_dir, [name '.mat']), 'id');
    ids(id_i) = id;
end
