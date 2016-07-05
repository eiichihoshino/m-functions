by_group_init;

%correlation between GA, PNA and z
%39-2
title_name = 'Correation between connectivity on ch2-ch39 and GA';
h = figure('Name', regexprep(title_name, ' ', ''));
hold on;
colors = get(h.CurrentAxes, 'ColorOrder');
for g_i = 1:n_groups
    x = [ids(GAs(g_i).indices).GA]'/7;
    y = arrayfun(@(x) x.runs(1).connectivity.z(2,39,1), ids(GAs(g_i).indices))';
    not_nan = ~isnan(x)&~isnan(y);
    x = x(not_nan);
    y = y(not_nan);
    [GAs(g_i).r, GAs(g_i).p] = corrcoef(x,y);
    scatter(x,y,[],colors(g_i,:));
    GAs(g_i).b = x\y;
    plot(linspace(0, max([ids.GA])/7),  linspace(0, max(x))*GAs(g_i).b, 'Color',  colors(g_i,:));
end
xlim([min([ids.GA])/7, max([ids.GA])/7]); xlabel('GA (week)'); ylabel('z(R)'); title(title_name);
legend_h = legend({...
    sprintf('GA<%d',GA_group_division(2)), sprintf('r=%.4f, p=%.4f', GAs(1).r(1,2), GAs(1).p(1,2))...
    ,sprintf('%d<=GA<%d',GA_group_division(2), GA_group_division(3)), sprintf('r=%.4f, p=%.4f', GAs(2).r(1,2), GAs(2).p(1,2))...
    ,sprintf('%d<=GA',GA_group_division(3)), sprintf('r=%.4f, p=%.4f', GAs(3).r(1,2), GAs(3).p(1,2))...
    });
legend_h.Location = 'northeastoutside';
saveas(h, fullfile(figure_dir, ['corr_' title_name '.fig']));
saveas(h, fullfile(figure_dir, ['corr_' title_name '.jpg']));
close(h);

title_name = 'Correation between connectivity on ch2-ch39 and PNA';
h = figure('Name', regexprep(title_name, ' ', ''));
hold on;
for g_i = 1:2
    x = [ids(PNAs(g_i).indices).PNA]';
    y = arrayfun(@(x) x.runs(1).connectivity.z(2,39,1), ids(PNAs(g_i).indices))';
    not_nan = ~isnan(x)&~isnan(y);
    x = x(not_nan);
    y = y(not_nan);
    [r, p] = corrcoef(x,y);
    PNAs(g_i).r = r;
    PNAs(g_i).p = p;
    scatter(x,y,[],colors(g_i,:));
    b = x\y;
    PNAs(g_i).b = b;
    plot(linspace(0, max([ids.PNA])),  linspace(0, max(x))*b, 'Color', colors(g_i,:));
end
xlim([min([ids.PNA]), max([ids.PNA])]); xlabel('PNA (day)'); ylabel('z(R)'); title(title_name);
legend_h = legend({...
    'PNA<10d', sprintf('r=%.4f, p=%.4f', PNAs(1).r(1,2), PNAs(1).p(1,2))...
    ,'10d<=PNA', sprintf('r=%.4f, p=%.4f', PNAs(2).r(1,2), PNAs(2).p(1,2))...
    });
legend_h.Location = 'northeastoutside';
saveas(h, fullfile(figure_dir, ['corr_' title_name '.fig']));
saveas(h, fullfile(figure_dir, ['corr_' title_name '.jpg']));
close(h);

title_name = 'Correation between connectivity on ch2-ch39 and PNA';
h = figure('Name', regexprep(title_name, ' ', ''));
hold on;
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
scatter(x,y,[],colors(4,:));
b = x\y;
plot(linspace(0, max(x)),  linspace(0, max(x))*b, 'Color', colors(4,:));
xlim([0 max(x)]); xlabel('PNA (day)'); ylabel('z(R)'); title(title_name);
ylim([-2,3]);
legend_h = legend({...
    'data', sprintf('r=%.4f, p=%.4f', r(1,2), p(1,2))...
    });
legend_h.Location = 'northeastoutside';
saveas(h, fullfile(figure_dir, ['corrGA23wo70_' title_name '.fig']));
saveas(h, fullfile(figure_dir, ['corrGA23wo70_' title_name '.jpg']));
close(h);