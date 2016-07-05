by_group_init;

tests = [];

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
        for ii = 1:l-1
            for jj = ii+1:m
                [~, p, ~, stats] = ...
                    ttest(...
                    arrayfun(@(x) x.runs(1).connectivity.z(ii, jj, kk), ids(GAs(g_i).indices)) ...
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
    PlotData(ttest1s(g_i).pfdr(:,:,1), ['test1_group' num2str(g_i) '_pfdr'], 0.0001, ttest1s(g_i).t(:,:,1)>0, layout_path, figure_dir, false)
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
    for ii = 1:l-1
        for jj = ii+1:m
            y = NaN(n_groups, max(n_in_each_group));
            for g_i = 1:n_groups
                y(g_i, 1:n_in_each_group(g_i)) = arrayfun(@(x) x.runs(1).connectivity.z(ii, jj, kk), ids(GAs(g_i).indices));
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
PlotData(anova.pfdr(:,:,1), 'anova1_pfdr', 0.1, anova.F(:,:,1)>0, layout_path, figure_dir, false)
PlotData(anova.p(:,:,1), 'anova1_p', 0.01, anova.F(:,:,1)>0, layout_path, figure_dir, false)
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
        for ii = 1:l-1
            for jj = ii+1:m
                [~, p, ~, stats] = ...
                    ttest2(...
                    arrayfun(@(x) x.runs(1).connectivity.z(ii, jj, kk), ids(GAs(group_combs(gc_i, 1)).indices)) ...
                    ,arrayfun(@(x) x.runs(1).connectivity.z(ii, jj, kk), ids(GAs(group_combs(gc_i, 2)).indices)) ...
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
    PlotData(ttest2s(gc_i).pfdr(:,:,1), ['test2_group_' regexprep(num2str(group_combs(gc_i,:)), '\s+', '_')  '_pfdr'], 0.05, ttest2s(gc_i).t(:,:,1)>0, layout_path, figure_dir, false)
    PlotData(ttest2s(gc_i).p(:,:,1), ['test2_group_' regexprep(num2str(group_combs(gc_i,:)), '\s+', '_')  '_p'], 0.001, ttest2s(gc_i).t(:,:,1)>0, layout_path, figure_dir, false)
end
fprintf('\n');

%2way-ANOVA
connectivity_type_path = regexprep('XXX', '/', filesep);
conn_types = sortrows(cell2mat(csv2cell(connectivity_type_path, 1)),2);
n_types = length(unique(conn_types(:,5)));
[l,m,n] = size(ids(1).runs(1).connectivity.n);
n_pairs = l*(m-1)/2;
zs = nan(n_pairs, length(ids));
for id_i = 1:length(ids)
    if c_valids(id_i)
        zs(:, id_i) = ids(id_i).runs(1).connectivity.z(cat(3, triu(true(l,m),1), false(l,m)));
    end
end
triu_indices = zeros(l);
triu_indices(triu(true(l),1)) = 1:n_pairs;
zs_by_type = nan(n_types, size(zs,2));
for t_i = 1:n_types
    zs_by_type(t_i, :) = nanmean(zs(ismember(conn_types(:,5), t_i), :));
end
zs_by_type = zs_by_type';

type_labels = arrayfun(@(x) sprintf('type%d',x), unique(conn_types(:,5)), 'UniformOutput', false)';
data = [...
    array2table(zs_by_type, 'VariableNames', type_labels) ...
    array2table(nominal(arrayfun(@(x) sprintf('GA%d',x), [ids.GA_group], 'UniformOutput', false)'),'VariableNames',{'GA'}) ...
    ];
rm = fitrm(data, sprintf('%s-%s~%s', type_labels{1}, type_labels{end}, 'GA'), 'WithinDesign', table(nominal(type_labels'), 'VariableNames', {'type'}));
ranova_result = ranova(rm,'WithinModel','type');
mauchly_result = mauchly(rm);
tmptbl = array2table([NaN mauchly_result.DF NaN NaN mauchly_result.pValue NaN NaN NaN], 'VariableNames', ranova_result.Properties.VariableNames);
ranova_result_combined = table;
ranova_result_combined(7,:) = tmptbl;
ranova_result_combined(1:6,:) = ranova_result;
ranova_result_combined.Properties.RowNames = [ranova_result.Properties.RowNames;{'Mauchly'}];