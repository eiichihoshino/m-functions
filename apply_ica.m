addpath(genpath('.'));
connectivity_use_path = 'connectivity_use';
connectivity_ica_path = 'connectivity_ica';

clear wss;
fprintf('Loading:           ');
for mes_i = size(filelist_by_id, 1)%:-1:1
    fprintf([repmat('\b', [1 10]) '%s of %s'], zerofill(size(filelist_by_id,1)+1-mes_i, 3, ' '), zerofill(size(filelist_by_id,1), 3, ' '));
    load(filelist_by_id{mes_i,2});
    for kk = 1% size(ws.data, 3):-1:1
        ws.ICA(kk) = ms_ica(ws.data0(:,:,kk)');
    end
    [~,name,~] = fileparts(ws.filename);
    save_filename = fullfile(connectivity_ica_path, [name '.mat']);
    if exist('OCTAVE_VERSION', 'builtin') == 5
        save('-mat7-binary', save_filename, 'ws');
    else
        save(save_filename, 'ws');
    end
end
fprintf('\n');
