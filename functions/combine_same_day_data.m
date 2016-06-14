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
% Version 1.0.0.3 on 2016.6.10 by Hoshino, E..
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
            new_wave_structs(ii).data = [new_wave_structs(ii).data; wave_structs(indices(jj)).data;];
            new_wave_structs(ii).data0 = [new_wave_structs(ii).data0; wave_structs(indices(jj)).data0;];
            new_wave_structs(ii).artifact_marks_by_channel = [new_wave_structs(ii).artifact_marks_by_channel; wave_structs(indices(jj)).artifact_marks_by_channel;];
            new_wave_structs(ii).artifact_marks_for_all_channels = [new_wave_structs(ii).artifact_marks_for_all_channels; wave_structs(indices(jj)).artifact_marks_for_all_channels;];
        end
    end
end