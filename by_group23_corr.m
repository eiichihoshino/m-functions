by_group_init;

%correlation between GA, PNA, CGA and z(R) of ch2-39
age_groups = {'GA', 'PNA', 'CGA'};
rs = NaN(length(age_groups), n_groups+1);
ps = rs;
fit_vals = cell(length(age_groups), n_groups+1);
g23_valids =  GAs(2).indices | GAs(3).indices;
for ag_i = 1:length(age_groups)
    title_name = ['Correlation between connectivity of ch2-ch39 of and ' age_groups{ag_i} '_group23'];
    max_x = max([ids(g23_valids).(age_groups{ag_i})]);
    min_x = min([ids(g23_valids).(age_groups{ag_i})]);
    h = figure('Name', regexprep(title_name, '_', ' '), 'Visible', 'off');
    hold on;
    colors = get(h.CurrentAxes, 'ColorOrder');
    colors(4,:) = 0;
    for g_i = 2:4
        if g_i < 4
            indices = GAs(g_i).indices;
        else
            indices = g23_valids;
        end
        x = [ids(indices).(age_groups{ag_i})]';
        if ag_i == 1
            x = x/7;
        end
        y = arrayfun(@(x) x.runs(1).connectivity.z(2,39,1), ids(indices))';
        not_nan = ~isnan(x)&~isnan(y);
        x = x(not_nan);
        y = y(not_nan);
        if g_i <4
            scatter(x,y,[],colors(g_i,:));
        end
        [r,p] = corrcoef(x,y);
        rs(ag_i, g_i) = r(1,2);
        ps(ag_i, g_i) = p(1,2);
        %b = x\y;
        %plot(linspace(0, max_x),  linspace(0, max(x))*b, 'Color',  colors(g_i,:));
        if g_i == 4
            fit_vals{ag_i, g_i} = polyfit(x,y,1);
            plot(linspace(0, max_x),  linspace(0, max_x)*fit_vals{ag_i, g_i}(1) + fit_vals{ag_i, g_i}(2), 'Color', colors(g_i,:));
        end
    end
    if ag_i == 1
    xlim([min_x/7, max_x/7]); xlabel([age_groups{ag_i} ' (week)']); ylabel('z(R)');% title(title_name);
    else    
    xlim([min_x, max_x]); xlabel([age_groups{ag_i} ' (day)']); ylabel('z(R)');% title(title_name);
    end
    ylim( get(h.CurrentAxes, 'YLim')+[-(range(get(h.CurrentAxes, 'YLim'))+1)/2 (range(get(h.CurrentAxes, 'YLim'))+1)/2] );
    legend_h = legend({...%sprintf('GA<%d',GA_group_division(2)), sprintf('r=%.4f, p=%.4f', rs(ag_i,1), ps(ag_i,1))...
        sprintf('%d<=GA<%d',GA_group_division(2), GA_group_division(3)) ...%, sprintf('r=%.4f, p=%.4f',rs(ag_i,2), ps(ag_i,2))...
        ,sprintf('%d<=GA',GA_group_division(3)) ...%, sprintf('r=%.4f, p=%.4f', rs(ag_i,3), ps(ag_i,3))...
        ,sprintf('Overall r=%.4f, p=%.4f', rs(ag_i,4), ps(ag_i,4)) ...
        }); legend_h.Location = 'northeastoutside';
    saveas(h, fullfile(figure_dir, [title_name '.fig'])); saveas(h, fullfile(figure_dir, [title_name '.jpg'])); close(h);
end