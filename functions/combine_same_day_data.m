function new_wave_structs = combine_same_day_data(wave_structs)
%
% COMBINE_SAME_DAY_DATA: combines if data are measured on the same day.
% Ver. 1.0.5 Change when same day data have mismatched dimension 2016.10.6 Hoshino, E.
%
% INPUT
% 	wave_structs: muptiple wave_structs to be analyzed.
%
% OUTPUT
% 	new_wave_structs: new_wave_structs
%
% [History]
% v.1.0.4, Hoshino, 2016.8.36. Change combining fields more general,
% specific fields to 'data' and onward.
% v.1.0.3, Hoshino, 2016.6.10.
%
new_wave_structs = wave_structs(1);
new_wave_structs(1) = [];
datetimes = cellfun(@(x) x(1:10), {wave_structs.datetime}, 'UniformOutput', false);
unique_datetimes = unique(datetimes);
w_i = 1;
for ii = 1:length(unique_datetimes)
    indices = find(ismember(datetimes, unique_datetimes(ii)));
    for jj = 1:length(indices)
        if jj == 1
            results = wave_structs(indices(jj));
        else
            flds = fieldnames(wave_structs);
            for fld = flds(find(ismember(flds, 'raw')):end)
                try
                    results.(fld{1}) = [results.(fld{1}); wave_structs(indices(jj)).(fld{1});];
                catch ME
                    if (strcmp(ME.identifier,'MATLAB:catenate:dimensionMismatch'))
                        warning('MyComponent:debug', 'Same day data were found but not combined.\n\nDimension mismatch:\n%s has\n%s: %s\n%s: [%s]\n\n%s has\n%s: %s\n%s: [%s]\n\n'...
                            ,wave_structs(indices(jj)).filename ...
                            ,'datetime', wave_structs(indices(jj)).datetime ...
                            ,fld{1}, strjoin(arrayfun(@num2str, size(wave_structs(indices(jj)).(fld{1})), 'UniformOutput', false), ' x ')...
                            ,wave_structs(indices(jj-1)).filename ...
                            ,'datetime', wave_structs(indices(jj-1)).datetime ... 
                            ,fld{1}, strjoin(arrayfun(@num2str, size(wave_structs(indices(jj-1)).(fld{1})), 'UniformOutput', false), ' x ')...
                            );
                        results = wave_structs(indices);
                    else
                        rethrow(ME)
                    end
                end
            end
        end
    end
    new_wave_structs(w_i:w_i+numel(results)-1) = results;
    w_i = w_i + numel(results);
end