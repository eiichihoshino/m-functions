function PlotData(data, fig_title, threshold, pos_neg, layout_file, outdir, overwrite_prompt)
% PLOTDATA: plots data and save it.
%	Version. 1.0.1 2016.6.29 Hoshino, E..
%       Add negative colorbar.
%       Add an argument overwrite_prompt to plot withou a prompt.
%
%   [Inputs]
% 	data: data to be plotted
%   title_name: title of the figure and save filename.
%   threshold: less than this value are plotted.
%   pos_neg: a boolean matrix with the same size as data. warm color if
%   true and cool color if false.
%   layout_file: a csv with rows as channels and two columns as position of channel (x,y). 
%   outdir: a path of output file.
%
%   [History]
%	Version. 1.0.0 on 2016.6.22 by Hoshino, E..
%
if nargin == 0 || nargin > 7
    warning('data must be specied.');
    return;
end
if nargin < 7
    overwrite_prompt = true;
end
if nargin < 6
    outdir = '.';
end
if nargin < 5
    layout_file = 'Layout.csv';
end
if nargin < 4
    pos_neg = true(size(data));
else
    if ~isequal(size(data), size(pos_neg))
        warning('Size of "data" and "pos_neg" must be the same.');
        return;
    end
end

layout = csvread(layout_file);
h = figure('Name', regexprep(fig_title, '_', ' '), 'Visible', 'off');
hold on

plot_margin = max(range(layout))/10;
x_limit = [min(layout(:,1))-plot_margin max(layout(:,1))+plot_margin];
y_limit = [min(layout(:,2))-plot_margin max(layout(:,2))+plot_margin];
x_limit = round(x_limit./10.^(real(ceil(log10(x_limit)))-2)).*10.^(real(ceil(log10(x_limit)))-2);
y_limit = round(y_limit./10.^(real(ceil(log10(y_limit)))-2)).*10.^(real(ceil(log10(y_limit)))-2);
xlim(x_limit);
ylim(y_limit);

for ii = 1:size(data,1)-1
    for jj = ii+1:size(data,2)
        if data(ii,jj) < threshold
            %line([layout(ii,1); layout(jj,1)], [layout(ii,2); layout(jj,2)], 'LineWidth', 1-10*p(ii,jj), 'Marker','o', 'MarkerSize', 20);
            whiteness = data(ii,jj)/threshold;
            if pos_neg(ii,jj)
                line_color = [1 whiteness 0];
            else
                line_color = [0 whiteness 1];
            end
            line([layout(ii,1); layout(jj,1)], [layout(ii,2); layout(jj,2)]...
                , 'Color', line_color...
                , 'Marker','o'...
                , 'MarkerSize', 20 ...
                );
        end
    end
end
mymap = [
    [zeros(1,256); linspace(0,1,256); ones(1,256);]';
    [ones(1,256); linspace(1,0,256); zeros(1,256);]';
    ];
colormap(mymap);
v = regexp(version, '\s' , 'split'); 
stat_str = 'stat';
tick_labels = {'0', sprintf('%s<0', stat_str), sprintf('%0.1g', threshold), sprintf('%s>=0', stat_str), '0'};
if str2num(v{1}(1:3)) >= 8.5
    c = colorbar('Ticks',linspace(0,1,5)...
        ,'TickLabels',tick_labels...
        ,'FontSize', 11);
else
    c = colorbar('YTick',linspace(1,512,5),...
        'YTickLabel',tick_labels);
end
%set(c, 'Label.String', 'p-value');
set(gca, 'xticklabel', []);
set(gca, 'yticklabel', []);

for ii = 1:length(layout)
    x = layout(ii, 1);
    y = layout(ii, 2);
    line([x;x],[y;y],'Color','white','Marker','o','MarkerSize',20, 'MarkerEdgeColor', 'k');
    text(x, y, num2str(ii),'HorizontalAlignment','center');
end
out_filepath_base = fullfile(outdir, [fig_title '_' num2str(threshold)]);
if overwrite_prompt && exist([out_filepath_base '.fig'], 'file')
    choice = questdlg(...
        sprintf('%s already exists. Would you like to overwride?', [out_filepath_base '.fig'])...
        ,'Caution!'...
        ,'OK', 'Cancel', 'Cancel');
    switch choice
        case 'OK'
        case 'Cancel'
            close(h);
            return;
    end
end
saveas(h, [out_filepath_base '.jpg']);
saveas(h, [out_filepath_base '.fig']);
close(h);