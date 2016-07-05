subpaths = regexp(genpath('.'), pathsep, 'split');
addpath(strjoin(subpaths(cellfun(@(s) isempty(regexp(s, regexprep(strjoin({'cache', '.git'}, '|'), '\.', '\\.'))), subpaths)), pathsep));
input_dir = output_dir;
demographic_data_csv = regexprep('XXX', '/', filesep);
layout_path = regexprep('YYY', '/', filesep);
GA_group_division = [0.01 30 37];
figure_dir = 'Figures';

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
n_groups = length(GA_group_division);
c_valids =  arrayfun(@(x) x.runs(1).connectivity.valid, ids);
for g_i = n_groups:-1:1
    GAs(g_i).indices = c_valids & ismember([ids.GA_group], g_i);
end
for g_i = n_groups-1:-1:1
    PNAs(g_i).indices = c_valids & ismember([ids.PNA_group], g_i);
end
n_in_each_group = cellfun(@sum, {GAs.indices});
[l, m , n] = size(ids(1).runs(1).connectivity.n);
n_channels = l;
n_pairs = l * (l-1) /2;

%Figure GA_PNA_distribution
fig_title = 'GA_PNA_distribution';
h = figure('Name', regexprep(fig_title, '_', ' '), 'Visible', 'off');
hold on;
for g_i = 1:length(GAs)
    scatter([ids(GAs(g_i).indices).GA]/7, [ids(GAs(g_i).indices).PNA]);
end
scatter([ids(~c_valids).GA]/7, [ids(~c_valids).PNA], 'x');
line(repmat(GA_group_division(2), [1 2]), get(get(h, 'CurrentAxes'), 'YLim'), 'Color', [0.9 0.9 0.9]);
line(repmat(GA_group_division(3), [1 2]), get(get(h, 'CurrentAxes'), 'YLim'), 'Color', [0.9 0.9 0.9]);
xlabel('GA (week)'); ylabel('PNA (day)');
saveas(h,fullfile(figure_dir, 'GA_PNA.fig'));
saveas(h,fullfile(figure_dir, 'GA_PNA.jpg'));
close(h);