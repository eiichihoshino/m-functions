by_group_init;

tests = [];
%ANOVA compare number of components between groups
tests{end+1}.name = 'Anova number of ICA components';
[tests{end}.p,tests{end}.tbl] = anova1(arrayfun(@(x) size(x.runs(1).ICA.A, 2), ids), [ids.GA_group]);
figHandles = get(0,'Children'); xlabel(figHandles(1).CurrentAxes, 'Groups'); ylabel(figHandles(1).CurrentAxes, 'Number of components')
for fig_i = 1:2
    saveas(figHandles(fig_i), fullfile(figure_dir, ['anova_number_of_compenents_' figHandles(fig_i).Tag '_.fig']));
    saveas(figHandles(fig_i), fullfile(figure_dir, ['anova_number_of_compenents_' figHandles(fig_i).Tag '_.jpg']));
    close(figHandles(fig_i));
end

%aggregate ICA components by channels pairs
fprintf('Aggregating ICA componentes:           ');
for id_i = length(ids):-1:1
    fprintf([repmat('\b', [1 10]) '%s of %s'], zerofill(id_i, 3, ' '), zerofill(length(ids), 3, ' '));
    n_ch = length(ids(id_i).runs(1).connectivity.n);
    ids(id_i).runs(1).connectivity.ica = NaN(n_ch,n_ch,2);
    for ii = 1:n_ch-1
        for jj = ii+1:n_ch
            products = prod(ids(id_i).runs(1).ICA.A([ii jj], :));
            ids(id_i).runs(1).connectivity.ica(ii, jj, :) = [max(products) min(products)];
            ids(id_i).runs(1).connectivity.ica(jj, ii, :) = [max(products) min(products)];
        end
    end
end
fprintf('\n');

%ANOVA maximum absolute values of ICA's A channel products
tests{end+1}.name = 'Anova ICA''s A channel products';
tests{end}.ps = NaN(length(ids(1).runs(1).connectivity.n));
tests{end}.tbls = cell(length(ids(1).runs(1).connectivity.n));
for ii = 1:n_ch-1
    for jj = ii+1:n_ch
        [tests{end}.ps(ii,jj), tests{end}.tbls{ii,jj}] = anova1(arrayfun(@(x) max(abs(x.runs(1).connectivity.ica(ii,jj,:))), ids), [ids.GA_group], 'off');
        tests{end}.ps(jj,ii) = tests{end}.ps(ii,jj);
        tests{end}.tbls{jj,ii} = tests{end}.tbls{ii,jj};
    end
end
tests{end}.ps(diag(true(1, m))) = ones(1, m);git
p_values = tests{end}.ps;
[m, n] = size(p_values);
pfdrs = zeros(m, n);
b = triu(true(m, n), 1);
[~, ~, pfdrs(b)] = fdr_bh(p_values(b));
pfdrs = pfdrs + pfdrs' + diag(ones(1, m));
tests{end}.pfdrs = pfdrs;
name = 'anova_ica_a_channels_products';
h = figure('Name', regexprep(name, '_', ' '), 'Visible', 'off');
c = colormap;
colormap(h, c(end:-1:1,:,:));
s(1) = subplot(2,1,1);
imagesc(tests{end}.ps, [0 0.1]);	colorbar;    xlabel('Channels');    ylabel('Channels'); title('p values');
s(2) = subplot(2,1,2);
imagesc(tests{end}.pfdrs, [0 0.8]);	colorbar;    xlabel('Channels');    ylabel('Channels'); title('FDR corrected p values');
saveas(h, fullfile(figure_dir, ['anova_' name '.fig']));
saveas(h, fullfile(figure_dir, ['anova_' name '.jpg']));
close(h);

%

%concatenate all subject data and calculate ICA
gs(g_i).data0 = [];
for g_i = n_groups:-1:1
    for ii = find((GAs(g_i).indices))
        gs(g_i).data0 = cat(1, gs(g_i).data0, ids(ii).runs(1).data0);
    end
end

for g_i = 1%:n_groups
    for kk = 1%:size(gs(1).data0,3)
    gs(g_i).ICA(kk) = ms_ica(gs(g_i).data0(:,:,kk)');
    end
end


%{
2016.7.4 12:00
メモリが足りません。オプションについては、HELP MEMORY と入力してください。

エラー: toeplitz (line 43)
t = x(ij);                              % actual data

エラー: icaMS_bic (line 98)
        Sig=toeplitz(R(j,N:end));

エラー: ms_ica (line 10)
[P,~]=icaMS_bic(X,interval,0);
%} 