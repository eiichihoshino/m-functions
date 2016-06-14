checker = UpdateChecker(mfilename, fullfile(merged_file_path, 'cache'));

filelist_by_id = get_filelist_by_id(preprocessed_file_path);

for id_i = 1:size(filelist_by_id,1)
    fprintf('Processing: %d out of %d.\n', id_i, size(filelist_by_id, 1));
    
    do_files_exist = cell2mat(cellfun(@(x) exist(x, 'file'), filelist_by_id(id_i,:), 'UniformOutput', false));
    files = filelist_by_id(id_i, do_files_exist>0);
    if checker.needsUpdate(files)
        clear wss;
        for mes_i = length(files):-1:1
            load(files{mes_i});
            wss(mes_i) = ws;
        end
        
        wss = combine_same_day_data(wss);
        for ws_i = 1:length(wss)
            clear ws;
            ws = wss(ws_i);
            ws.connectivity = get_connectivity(ws.data(:,:,1:2));
            [~,name,~] = fileparts(ws.filename);
            save_filename = fullfile(merged_file_path, [name '.mat']);
            if exist('OCTAVE_VERSION', 'builtin') == 5
                save('-mat7-binary', save_filename, 'ws');
            else
                save(save_filename, 'ws');
            end
        end
        checker.didSucceed(files);
    end
end
checker.renewCache();
fprintf('Fin.\n');