function new_ws = join_same_day_data(ws)
%
% JOIN_SAME_DAY_DATA: join if data are measured on the same day.
% v.1.0.0 Init. Renamed from combine_same_day_data. Use join_structs.m.
% 2016.10.20 Hoshino, E.
%
% INPUT
% 	ws: muptiple ws to be analyzed.
%
% OUTPUT
% 	new_ws: new_ws
%
new_ws = ws(1);
new_ws(1) = [];
datetimes = cellfun(@(x) x(1:10), {ws.datetime}, 'UniformOutput', false);
unique_datetimes = unique(datetimes);
w_i = 1;
for ii = 1:length(unique_datetimes)
    indices = find(ismember(datetimes, unique_datetimes(ii)));
    for jj = 1:length(indices)
        if jj == 1
            results = ws(indices(jj));
        else
            flds = fieldnames(ws)';
            for fld = flds
                params.(fld{1}) = {};
            end
            params.filename = {[] [] ...
                @(x) strjoin( ...
                    [   x(1) ...
                        cellfun( ...
                            @(y) y(find(y == '/'|y == '\', 1, 'last')+1:end) ...
                            , x, 'UniformOutput', false) ...
                    ] ...
                , '__JOIN__') ...
            };
            params.datetime = {[] [] @(x) strjoin(x, '__JOIN__')};
            params.raw = {[] [] @(x) cat(1, x{:})};
            params.hb = {[] [] @(x) cat(1, x{:})};
            params.stim =  {[] [] @(x) cat(1, x{:})};
            results = join_structs(ws(indices(jj)), params);
        end
    end
    new_ws(w_i:w_i+numel(results)-1) = results;
    w_i = w_i + numel(results);
end