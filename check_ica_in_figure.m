input_path = 'by_id_ica';
output_path = 'Figures';
GA_group_division = [0.01 30 37];
if ~exist(output_path, 'dir')
    mkdir(output_path);
end
filelist_by_id = get_filelist_by_id(input_path);

clear ids;
fprintf('Loading:           ');
for mes_i = size(filelist_by_id, 1):-1:1
    clear id;
    fprintf([repmat('\b', [1 10]) '%s of %s'], zerofill(size(filelist_by_id,1)+1-mes_i, 3, ' '), zerofill(size(filelist_by_id,1), 3, ' '));
    load(filelist_by_id{mes_i,2});
    ids(mes_i) = id;
end
fprintf('\n');
ids0 = ids;

ids = ids0;
fprintf('Saving figures:           ');
for id_i = 1:length(ids)
    fprintf([repmat('\b', [1 10]) '%s of %s'], zerofill(id_i, 3, ' '), zerofill(size(filelist_by_id,1), 3, ' '));
    [~,name,~] = fileparts(ids(id_i).runs(1).filename);
    h = figure('Name', name, 'Visible', 'off');
    %if wssGA_group_division(2)
    %[1 whiteness 0]
    h.Color = [1 1 1];
    h.InvertHardcopy = 'off';
    s(1) = subplot(4,1,1); plot(ids(id_i).runs(1).data0(:,:,1)-repmat(mean(ids(id_i).runs(1).data0(:,:,1),1), size(ids(id_i).runs(1).data0,1),1));
    xlim([1,size(ids(id_i).runs(1).data0,1)]); title({regexprep(name, '_', ' '), 'Original'});
    s(2) = subplot(4,1,2); plot((ids(id_i).runs(1).ICA.A*ids(id_i).runs(1).ICA.S)'); xlim([1,size(ids(id_i).runs(1).data0,1)])
    xlim([1,size(ids(id_i).runs(1).data0,1)]); title('Reconstructed')
    s(3) = subplot(4,1,3);
    plot(ids(id_i).runs(1).ICA.S'); xlim([0,size(ids(id_i).runs(1).ICA.S,2)])
    s(4) = subplot(4,1,4);
    imagesc(ids(id_i).runs(1).ICA.A')%,[-0.6,0.6]); colorbar;
    colorbar;
    xlabel('Channels')
    ylabel('Components')
    
    saveas(h, fullfile(output_path, ['ica_' name '.fig']));
    saveas(h, fullfile(output_path, ['ica_' name '.jpg']));
    close(h);
end
fprintf('\n');