checker = UpdateChecker(mfilename, fullfile(use_file_path, 'cache'));

total_number_of_pairs = number_of_channels * (number_of_channels-1) /2;

filelist_by_id_connectivity_all = get_filelist_by_id(merged_file_path);
for id_i = 1:size(filelist_by_id_connectivity_all,1)
    fprintf('Processing: %d out of %d.\n', id_i, size(filelist_by_id_connectivity_all, 1));
    
    do_files_exist = cell2mat(cellfun(@(x) exist(x, 'file'), filelist_by_id_connectivity_all(id_i,:), 'UniformOutput', false));
    files = filelist_by_id_connectivity_all(id_i, do_files_exist>0);
    if checker.needsUpdate(files)
        
        clear wss;
        for mes_i = length(files):-1:1
            load(files{mes_i});
            wss(mes_i) = ws;
        end
        lengths = arrayfun(@(x) size(x.data, 1), wss);
        %ws = wss(ismember(lengths, max(lengths)));
        [~, max_i] = max(lengths);
        clear ws;
        ws = wss(max_i);
        is_sample_short = ws.connectivity.n < 1200;
        if sum(sum(triu(is_sample_short(:,:,1),1))) < total_number_of_pairs * 0.75
            ws.connectivity.valid = true;
            ws.connectivity.r(is_sample_short) = NaN;
            ws.connectivity.z(is_sample_short) = NaN;
            ws.connectivity.p(is_sample_short) = NaN;
            ws.connectivity.pfdr(is_sample_short) = NaN;
        else
            ws.connectivity.valid = false;
            ws.connectivity.r = NaN;
            ws.connectivity.z = NaN;
            ws.connectivity.p = NaN;
            ws.connectivity.pfdr = NaN;
        end
        [~,name,~] = fileparts(ws.filename);
        save_filename = fullfile(use_file_path, [name '.mat']);
        if exist('OCTAVE_VERSION', 'builtin') == 5
            save('-mat7-binary', save_filename, 'ws');
        else
            save(save_filename, 'ws');
        end
        
        checker.didSucceed(files);
    end
end
checker.renewCache();
fprintf('Fin.\n');