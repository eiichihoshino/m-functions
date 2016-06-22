addpath(genpath('.'));
connectivity_use_path = 'connectivity_use';
demographic_data_csv = 'XXXX';
GA_group_division = [0.01 30 37];
figure_dir = 'Figures';

filelist_by_id = get_filelist_by_id(connectivity_use_path);
demographic_data = csv2cell(demographic_data_csv);

clear wss;
fprintf('Loading:           ');
for mes_i = size(filelist_by_id, 1):-1:1
    fprintf([repmat('\b', [1 10]) '%s of %s'], zerofill(size(filelist_by_id,1)+1-mes_i, 3, ' '), zerofill(size(filelist_by_id,1), 3, ' '));
    load(filelist_by_id{mes_i,2});
    wss(mes_i) = ws;
end
fprintf('\n');
wss0 = wss;

wss = wss0;
delete_flags = [];
for mes_i = 1:length(wss)
    m = regexp(wss(mes_i).filename, '([E|N])(\d+)\D', 'tokens');
    wss(mes_i).ID = [m{1}{1} zerofill(m{1}{2}, 3)];
    wss(mes_i).datetime = datenum(wss(mes_i).datetime(1:10), 'yyyy/mm/dd');
    index = ismember(demographic_data(:,2), wss(mes_i).ID);
    if ~sum(index)
        fprintf('%s is not found in the demographic data.\n', wss(mes_i).ID);
        delete_flags = [delete_flags mes_i];
    else
        wss(mes_i).gender = demographic_data{index, 3};
        wss(mes_i).GA = demographic_data{index, 4};
        try
            wss(mes_i).birthday = datenum(demographic_data(index, 5), 'yyyy-mm-dd');
        catch
            wss(mes_i).birthday = NaN;
        end
        wss(mes_i).PNA = wss(mes_i).datetime - wss(mes_i).birthday;
    end
end
wss(delete_flags) = [];

n_groups = length(GA_group_division);
c_valids =  arrayfun(@(x) x.connectivity.valid, wss);
GA_group_division_inf = [GA_group_division Inf];
for group_i = n_groups:-1:1
    GAs(group_i).indices = c_valids...
        & [wss.GA] >= GA_group_division_inf(group_i)*7 ...
        & [wss.GA] < GA_group_division_inf(group_i+1)*7;
end

%Figure GA_PNA_distribution
fig_title = 'GA_PNA_distribution';
h = figure('Name', regexprep(fig_title, '_', ' '), 'Visible', 'off');
hold on;
for group_i = 1:length(GAs)
    scatter([wss(GAs(group_i).indices).GA]/7, [wss(GAs(group_i).indices).PNA]);
end
scatter([wss(~c_valids).GA]/7, [wss(~c_valids).PNA], 'x');
line(repmat(GA_group_division(2), [1 2]), get(get(h, 'CurrentAxes'), 'YLim'), 'Color', [0.9 0.9 0.9]);
line(repmat(GA_group_division(3), [1 2]), get(get(h, 'CurrentAxes'), 'YLim'), 'Color', [0.9 0.9 0.9]);
xlabel('GA (week)'); ylabel('PNA (day)');
saveas(h,fullfile(figure_dir, 'GA_PNA.fig'));
saveas(h,fullfile(figure_dir, 'GA_PNA.jpg'));
close(h);


[l, m , n] = size(wss(1).connectivity.n);
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
                        arrayfun(@(x) x.connectivity.z(ii, jj, kk), wss(GAs(g_i).indices)) ...
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
                y(g_i, 1:n_in_each_group(g_i)) = arrayfun(@(x) x.connectivity.z(ii, jj, kk), wss(GAs(g_i).indices));
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
                        arrayfun(@(x) x.connectivity.z(ii, jj, kk), wss(GAs(group_combs(gc_i, 1)).indices)) ...
                        ,arrayfun(@(x) x.connectivity.z(ii, jj, kk), wss(GAs(group_combs(gc_i, 2)).indices)) ...
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