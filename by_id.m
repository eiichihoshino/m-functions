%%% parameters %%%
input_dir = output_dir;
output_dir = mfilename;
%%%%%%%%%%%%%%%%%%

subpaths = regexp(genpath('.'), pathsep, 'split');
addpath(strjoin(subpaths(cellfun(@(s) isempty(regexp(s, regexprep(strjoin({'cache', '.git'}, '|'), '\.', '\\.'))), subpaths)), pathsep));
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%initialize UpdateChecker
checker = UpdateChecker([mfilename '.m'], fullfile(output_dir, 'cache'));
filelist_by_id = get_filelist_by_id(input_dir);
clear ids;
for id_i = 1:size(filelist_by_id,1)
    fprintf('Processing: %d out of %d.\n', id_i, size(filelist_by_id, 1));
    do_files_exist = cell2mat(cellfun(@(x) exist(x, 'file'), filelist_by_id(id_i,:), 'UniformOutput', false));
    files = filelist_by_id(id_i, do_files_exist>0);
    if checker.needsUpdate(files)
        clear runs id;
        
        %load a run
        for mes_i = length(files):-1:1
            load(files{mes_i});
            runs(mes_i) = ws;
        end
        
        %combine same day data
        runs = combine_same_day_data(runs);
        
        %sort runs in descending order of duration, the longest is the
        %first. (the first one is valid in this study)
        [~, I] = sort(arrayfun(@(x) size(x.data, 1), runs) ,'descend');
        runs = runs(I);
        
        %add ID
        id.runs = runs;
        m = regexp(runs(1).filename, '([E|N])(\d+)\D', 'tokens');
        id.ID = [m{1}{1} zerofill(m{1}{2}, 3)];       
        
        [~,name,~] = fileparts(runs(1).filename);
        save(fullfile(output_dir, [name '.mat']), 'id');
    end
    checker.didSucceed(files);
    ids(id_i) = id;
end
checker.renewCache();