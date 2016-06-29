input_dir = 'by_id_ica';
figure_dir = 'Figures';
GA_group_division = [0.01 30 37];
if ~exist(figure_dir, 'dir')
    mkdir(figure_dir);
end
filelist_by_id = get_filelist_by_id(input_dir);

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
    my_xlim = [1,size(ids(id_i).runs(1).data0,1)];
    s(1) = subplot(3,2,1); plot(ids(id_i).runs(1).data0(:,:,1)-repmat(mean(ids(id_i).runs(1).data0(:,:,1),1), size(ids(id_i).runs(1).data0,1),1));
    xlim(my_xlim); title({regexprep(name, '_', ' '), 'Original'});
    s(3) = subplot(3,2,3); plot((ids(id_i).runs(1).ICA.A*ids(id_i).runs(1).ICA.S)'); xlim(my_xlim)
    xlim([1,size(ids(id_i).runs(1).data0,1)]); title('Reconstructed')
    s(5) = subplot(3,2,5);
    plot(ids(id_i).runs(1).ICA.S'); xlim(my_xlim); title('ICA components')
    s(2) = subplot(3,2,2);
    imagesc(ids(id_i).runs(1).ICA.A',[-0.6,0.6]);  colorbar;    xlabel('Channels');     ylabel('Components'); 
    s(4) = subplot(3,2,4);
    imagesc_h = imagesc(ids(id_i).runs(1).ICA.A',  [-0.6,0.6]);	colorbar;    xlabel('Channels');    ylabel('Components');
    set(imagesc_h, 'alphadata', abs(ids(id_i).runs(1).ICA.A')>0.1);
    s(6) = subplot(3,2,6);
    imagesc(max(abs(ids(id_i).runs(1).connectivity.ica(:,:,:)), [], 3));	colorbar;    xlabel('Channels');    ylabel('Channels');
    
    saveas(h, fullfile(figure_dir, ['ica_' name '.fig']));
    saveas(h, fullfile(figure_dir, ['ica_' name '.jpg']));
    close(h);
end
fprintf('\n');