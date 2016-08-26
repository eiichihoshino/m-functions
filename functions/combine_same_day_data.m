function new_wave_structs = combine_same_day_data(wave_structs)
%
% COMBINE_SAME_DAY_DATA: combines if data are measured on the same day.
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
for ii = 1:length(unique_datetimes)
    indices = find(ismember(datetimes, unique_datetimes(ii)));
    for jj = 1:length(indices)
        if jj == 1
            new_wave_structs(ii) = wave_structs(indices(jj));
        else
            flds = fieldnames(wave_structs);
            for fld = flds(find(ismember(flds, 'data')):end)
                new_wave_structs(ii).(fld{1}) = [new_wave_structs(ii).(fld{1}); wave_structs(indices(jj)).(fld{1});];
            end
        end
    end
end