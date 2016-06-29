subpaths = regexp(genpath('.'), ';', 'split');
addpath(strjoin(subpaths(cellfun(@(s) isempty(regexp(s, regexprep(strjoin({'cache', '.git'}, '|'), '\.', '\\.'))), subpaths)), ';'));
input_dir = 'by_id_ica';
demographic_data_csv = regexprep('XXX', '/', filesep);
GA_group_division = [0.01 30 37];
figure_dir = 'Figures';
tests = [];

filelist_by_id = get_filelist_by_id(input_dir);
demographic_data = csv2cell(demographic_data_csv);

%load ids
clear ids;
fprintf('Loading:           ');
for id_i = size(filelist_by_id, 1):-1:1
    fprintf([repmat('\b', [1 10]) '%s of %s'], zerofill(size(filelist_by_id,1)+1-id_i, 3, ' '), zerofill(size(filelist_by_id,1), 3, ' '));
    load(filelist_by_id{id_i,2});
    ids(id_i) = id;
    clear id;
end
fprintf('\n');
ids0 = ids;

%add demographic data
ids = ids0;
delete_flags = [];
for id_i = 1:length(ids)
    ids(id_i).runs(1).datetime = datenum(ids(id_i).runs(1).datetime(1:10), 'yyyy/mm/dd');
    index = ismember(demographic_data(:,2), ids(id_i).ID);
    if ~sum(index)
        fprintf('%s is not found in the demographic data.\n', ids(id_i).ID);
        delete_flags = [delete_flags id_i];
    else
        ids(id_i).gender = demographic_data{index, 3};
        ids(id_i).GA = demographic_data{index, 4};
        try
            ids(id_i).birthday = datenum(demographic_data(index, 5), 'yyyy-mm-dd');
        catch
            ids(id_i).birthday = NaN;
        end
        ids(id_i).PNA = ids(id_i).runs(1).datetime - ids(id_i).birthday;
    end
end
ids(delete_flags) = [];

%add groups
for id_i = 1:length(ids)
    ids(id_i).GA_group = sum(ids(id_i).GA ./ (GA_group_division*7) >= 1);
    ids(id_i).PNA_group = sum(ids(id_i).PNA ./ [0 10] >= 1);
end

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
for id_i = 1:length(ids)
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
tests{end}.ps(diag(true(1, m))) = ones(1, m);
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


n_groups = length(GA_group_division);
c_valids =  arrayfun(@(x) x.connectivity.valid, ids);
GA_group_division_inf = [GA_group_division Inf];
for group_i = n_groups:-1:1
    GAs(group_i).indices = c_valids...
        & [ids.GA] >= GA_group_division_inf(group_i)*7 ...
        & [ids.GA] < GA_group_division_inf(group_i+1)*7;
end

%Figure GA_PNA_distribution
fig_title = 'GA_PNA_distribution';
h = figure('Name', regexprep(fig_title, '_', ' '), 'Visible', 'off');
hold on;
for group_i = 1:length(GAs)
    scatter([ids(GAs(group_i).indices).GA]/7, [ids(GAs(group_i).indices).PNA]);
end
scatter([ids(~c_valids).GA]/7, [ids(~c_valids).PNA], 'x');
line(repmat(GA_group_division(2), [1 2]), get(get(h, 'CurrentAxes'), 'YLim'), 'Color', [0.9 0.9 0.9]);
line(repmat(GA_group_division(3), [1 2]), get(get(h, 'CurrentAxes'), 'YLim'), 'Color', [0.9 0.9 0.9]);
xlabel('GA (week)'); ylabel('PNA (day)');
saveas(h,fullfile(figure_dir, 'GA_PNA.fig'));
saveas(h,fullfile(figure_dir, 'GA_PNA.jpg'));
close(h);


[l, m , n] = size(ids(1).connectivity.n);
n_in_each_group = cellfun(@sum, {GAs.indices});

%one-sample ttest
fprintf('Perfoming one-sample ttests:               ');
for g_i = n_groups:-1:1
    ttest1s(g_i).p = NaN(l, m, n);
    ttest1s(g_i).pfdr = NaN(l, m, n);
    ttest1s(g_i).t = NaN(l, m, n);
    ttest1s(g_i).df = NaN(l, m, n);
    for kk = 1:n
        n_pairs = l*(m-1)/2;
        p_i = 1;
        for ii = 1:l
            for jj = ii+1:m
                [~, p, ~, stats] = ...
                    ttest(...
                    arrayfun(@(x) x.connectivity.z(ii, jj, kk), ids(GAs(g_i).indices)) ...
                    );
                fprintf([repmat('\b', [1 14]) '%s of %s'], zerofill((n_groups-g_i)*n*n_pairs+(kk-1)*n_pairs+p_i, 5, ' '), zerofill(n_pairs*n*n_groups, 5, ' '));
                p_i = p_i + 1;
                ttest1s(g_i).p(ii, jj, kk) = p; ttest1s(g_i).p(jj, ii, kk) = p;
                ttest1s(g_i).t(ii, jj, kk) = stats.tstat; ttest1s(g_i).t(jj, ii, kk) = stats.tstat;
                ttest1s(g_i).df(ii, jj, kk) = stats.df; ttest1s(g_i).df(jj, ii, kk) = stats.df;
            end
        end
        
        p_values = ttest1s(g_i).p(:,:,kk);
        pfdrs = zeros(l, m);
        b = triu(true(l, m), 1);
        [~, ~, pfdrs(b)] = fdr_bh(p_values(b));
        pfdrs = pfdrs + pfdrs' + diag(NaN(1, l));
        ttest1s(g_i).pfdr(:,:,kk) = pfdrs;
    end
    PlotDataPositive(ttest1s(g_i).pfdr(:,:,1), ['test1_group' num2str(g_i) '_pfdr'], 0.0001, ttest1s(g_i).t(:,:,1)>0, 'newborn3d_2d_layout.csv', figure_dir)
end
fprintf('\n');

%one-way anova
fprintf('Perfoming one-way ANOVA:               ');
anova.p = NaN(l, m, n);
anova.pfdr = NaN(l, m, n);
anova.F = NaN(l, m, n);
anova.df = NaN(l, m, n);
for kk = 1:n
    n_pairs = l*(m-1)/2;
    p_i = 1;
    for ii = 1:l
        for jj = ii+1:m
            y = NaN(n_groups, max(n_in_each_group));
            for g_i = 1:n_groups
                y(g_i, 1:n_in_each_group(g_i)) = arrayfun(@(x) x.connectivity.z(ii, jj, kk), ids(GAs(g_i).indices));
            end
            [p, tbl] = anova1(y',[],'off');
            anova.p(ii, jj, kk) = p; anova.p(jj, ii, kk) = p;
            anova.F(ii, jj, kk) = tbl{2,5}; anova.F(jj, ii, kk) = tbl{2,5};
            anova.df(ii, jj, kk) = tbl{4,3}; anova.df(jj, ii, kk) = tbl{4,3};
            fprintf([repmat('\b', [1 14]) '%s of %s'], zerofill((kk-1)*n_pairs+p_i, 5, ' '), zerofill(n_pairs*n, 5, ' '));
            p_i = p_i + 1;
        end
    end
    
    p_values = anova.p(:,:,kk);
    pfdrs = zeros(l, m);
    b = triu(true(l, m), 1);
    [~, ~, pfdrs(b)] = fdr_bh(p_values(b));
    pfdrs = pfdrs + pfdrs' + diag(NaN(1, l));
    anova.pfdr(:,:,kk) = pfdrs;
end
PlotDataPositive(anova.pfdr(:,:,1), 'anova1_pfdr', 0.1, anova.F(:,:,1)>0, 'newborn3d_2d_layout.csv', figure_dir)

fprintf('\n');

%unpaired -t
group_combs = nchoosek(1:n_groups, 2);
fprintf('Perfoming unpaired ttests:               ');
for gc_i = size(group_combs,1):-1:1
    ttest2s(gc_i).p = NaN(l, m, n);
    ttest2s(gc_i).pfdr = NaN(l, m, n);
    ttest2s(gc_i).t = NaN(l, m, n);
    ttest2s(gc_i).df = NaN(l, m, n);
    for kk = 1:n
        n_pairs = l*(m-1)/2;
        p_i = 1;
        for ii = 1:l
            for jj = ii+1:m
                [~, p, ~, stats] = ...
                    ttest2(...
                    arrayfun(@(x) x.connectivity.z(ii, jj, kk), ids(GAs(group_combs(gc_i, 1)).indices)) ...
                    ,arrayfun(@(x) x.connectivity.z(ii, jj, kk), ids(GAs(group_combs(gc_i, 2)).indices)) ...
                    ,0.05,'both','unequal');
                fprintf([repmat('\b', [1 14]) '%s of %s'], zerofill((n_groups-gc_i)*n*n_pairs+(kk-1)*n_pairs+p_i, 5, ' '), zerofill(n_pairs*n*n_groups, 5, ' '));
                p_i = p_i + 1;
                ttest2s(gc_i).p(ii, jj, kk) = p; ttest2s(gc_i).p(jj, ii, kk) = p;
                ttest2s(gc_i).t(ii, jj, kk) = stats.tstat; ttest2s(gc_i).t(jj, ii, kk) = stats.tstat;
                ttest2s(gc_i).df(ii, jj, kk) = stats.df; ttest2s(gc_i).df(jj, ii, kk) = stats.df;
            end
        end
        
        p_values = ttest2s(gc_i).p(:,:,kk);
        pfdrs = zeros(l, m);
        b = triu(true(l, m), 1);
        [~, ~, pfdrs(b)] = fdr_bh(p_values(b));
        pfdrs = pfdrs + pfdrs' + diag(NaN(1, l));
        ttest2s(gc_i).pfdr(:,:,kk) = pfdrs;
    end
    PlotDataPositive(ttest2s(gc_i).pfdr(:,:,1), ['test2_group_' regexprep(num2str(group_combs(gc_i,:)), '\s', '_')  '_pfdr'], 0.05, ttest2s(gc_i).t(:,:,1)>0, 'newborn3d_2d_layout.csv', figure_dir)
end
fprintf('\n');