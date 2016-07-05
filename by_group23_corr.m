by_group_init;

%Figure GA23_PNA_distribution
fig_title = 'GA23_PNA_distribution';
h = figure('Name', regexprep(fig_title, '_', ' '), 'Visible', 'off');
hold on;
colors = get(h.CurrentAxes, 'ColorOrder');
for g_i = 2:3
    scatter([ids(GAs(g_i).indices).GA]/7, [ids(GAs(g_i).indices).PNA], [],  colors(g_i,:));
end
%scatter([ids(~c_valids).GA]/7, [ids(~c_valids).PNA], 'x');
%line(repmat(GA_group_division(2), [1 2]), get(get(h, 'CurrentAxes'), 'YLim'), 'Color', [0.9 0.9 0.9]);
line(repmat(GA_group_division(3), [1 2]), get(get(h, 'CurrentAxes'), 'YLim'), 'Color', [0.9 0.9 0.9]);
xlabel('GA (week)'); ylabel('PNA (day)');
saveas(h,fullfile(figure_dir, 'GA23_PNA.fig')); saveas(h,fullfile(figure_dir, 'GA23_PNA.jpg')); close(h);

%correlation between GA, PNA and z
%39-2
title_name = 'Correation between connectivity on ch2-ch39 and GA in group23';
h = figure('Name', regexprep(title_name, ' ', ''));
hold on;
colors = get(h.CurrentAxes, 'ColorOrder');
for g_i = 2:3
    x = [ids(GAs(g_i).indices).GA]'/7;
    y = arrayfun(@(x) x.runs(1).connectivity.z(2,39,1), ids(GAs(g_i).indices))';
    not_nan = ~isnan(x)&~isnan(y);
    x = x(not_nan);
    y = y(not_nan);
    scatter(x,y,[],colors(g_i,:));
end
x = [ids(GAs(2).indices | GAs(3).indices).GA]'/7;
y = arrayfun(@(x) x.runs(1).connectivity.z(2,39,1), ids(GAs(2).indices | GAs(3).indices))';
not_nan = ~isnan(x)&~isnan(y);
x = x(not_nan);
y = y(not_nan);
[r, p] = corrcoef(x,y);
%b = x\y;
%plot(linspace(0, max(x)),  linspace(0, max(x))*b, 'Color',  'blue');
fit_vals = polyfit(x,y,1);
plot(linspace(0, max(x)),  linspace(0, max(x))*fit_vals(1) + fit_vals(2), 'Color',  'black');
xlim([min(x), max(x)]); xlabel('GA (week)'); ylabel('z(R)'); %title(title_name);
legend_h = legend({...
    sprintf('%d<=GA<%d',GA_group_division(2), GA_group_division(3)) ...
    ,sprintf('%d<=GA',GA_group_division(3))...
    ,sprintf('r=%.4f, p=%.4f', r(1,2), p(1,2))...
    });
legend_h.Location = 'northeastoutside';
saveas(h, fullfile(figure_dir, [title_name '.fig'])); saveas(h, fullfile(figure_dir, [title_name '.jpg'])); close(h);

title_name = 'Correation between connectivity on ch2-ch39 and PNA in group23';
h = figure('Name', regexprep(title_name, ' ', ''));
hold on;
for g_i = 2:3
    x = [ids(GAs(g_i).indices).PNA]';
    y = arrayfun(@(x) x.runs(1).connectivity.z(2,39,1), ids(GAs(g_i).indices))';
    not_nan = ~isnan(x)&~isnan(y);
    x = x(not_nan);
    y = y(not_nan);
    scatter(x,y,[],colors(g_i,:));
end
x = [ids(GAs(2).indices | GAs(3).indices).PNA ]';
y = arrayfun(@(x) x.runs(1).connectivity.z(2,39,1), ids(GAs(2).indices|GAs(3).indices))';
%{
iii = find(ismember(x, max(x)));
x(iii) = [];
y(iii) = [];
%}
not_nan = ~isnan(x)&~isnan(y);
x = x(not_nan);
y = y(not_nan);
[r, p] = corrcoef(x,y);
%b = x\y;
%plot(linspace(0, max(x)),  linspace(0, max(x))*b, 'Color',  'blue');
fit_vals = polyfit(x,y,1);
plot(linspace(0, max(x)),  linspace(0, max(x))*fit_vals(1) + fit_vals(2), 'Color',  'black');
xlim([0 max(x)]); xlabel('PNA (day)'); ylabel('z(R)');% title(title_name);
ylim([-2,3]);
legend_h = legend({...
    sprintf('%d<=GA<%d',GA_group_division(2), GA_group_division(3)) ...
    ,sprintf('%d<=GA',GA_group_division(3))...
    ,sprintf('r=%.4f, p=%.4f', r(1,2), p(1,2))...
    });
legend_h.Location = 'northeastoutside';
saveas(h, fullfile(figure_dir, [title_name '.fig'])); saveas(h, fullfile(figure_dir, [title_name '.jpg'])); close(h);

title_name = 'Correation between connectivity on ch2-ch39 and CGA in group23';
h = figure('Name', regexprep(title_name, ' ', ''));
hold on;
for g_i = 2:3
    x = [ids(GAs(g_i).indices).GA]'+[ids(GAs(g_i).indices).PNA]';
    y = arrayfun(@(x) x.runs(1).connectivity.z(2,39,1), ids(GAs(g_i).indices))';
    not_nan = ~isnan(x)&~isnan(y);
    x = x(not_nan);
    y = y(not_nan);
    scatter(x,y,[],colors(g_i,:));
end
x = [ids(GAs(2).indices | GAs(3).indices).GA]' + [ids(GAs(2).indices | GAs(3).indices).PNA]';
y = arrayfun(@(x) x.runs(1).connectivity.z(2,39,1), ids(GAs(2).indices|GAs(3).indices))';
%{
iii = find(ismember(x, max(x)));
x(iii) = [];
y(iii) = [];
%}
not_nan = ~isnan(x)&~isnan(y);
x = x(not_nan);
y = y(not_nan);
[r, p] = corrcoef(x,y);
%b = x\y;
%plot(linspace(0, max(x)),  linspace(0, max(x))*b, 'Color',  'blue');
fit_vals = polyfit(x,y,1);
plot(linspace(0, max(x)),  linspace(0, max(x))*fit_vals(1) + fit_vals(2), 'Color',  'black');
xlim([min(x) max(x)]); xlabel('CGA (day)'); ylabel('z(R)');% title(title_name);
ylim([-2,3]);
legend_h = legend({...
    sprintf('%d<=GA<%d',GA_group_division(2), GA_group_division(3)) ...
    ,sprintf('%d<=GA',GA_group_division(3))...
    ,sprintf('r=%.4f, p=%.4f', r(1,2), p(1,2))...
    });
legend_h.Location = 'northeastoutside';
saveas(h, fullfile(figure_dir, [title_name '.fig'])); saveas(h, fullfile(figure_dir, [title_name '.jpg'])); close(h);