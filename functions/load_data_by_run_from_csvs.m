function wave_struct=load_data_by_run_from_csvs(filenames)
%
% LOAD_DATA_BY_RUN_FROM_CSVS: loads and combines data from files.
% Ver. 1.0.4 Refine format. 2016.10.20 Hoshino, E.
%
% INPUT
% 	filenames: filepath to be loaded.
%
% OUTPUT
% 	wave_struct.filename: the common part of filenames
% 	wave_struct.datetime: a measurement datetime
% 	wave_struct.wavelength: wavelength
% 	wave_struct.data: {timepoints, channels}
% 	wave_struct.stim: stimulus marks.
%
% [History]
% Ver. 1.0.3 Add a line to ignore empty inputs. 2016.10.6 Hoshino, E.
% Ver. 1.0.2 on 2016.6.1 Hoshino, E.
%
filenames = filenames(~cellfun(@isempty, filenames));
filename_heads = cellfun(@(x) x(1:end-5), filenames, 'UniformOutput', false);
filename_heads = unique(filename_heads);
if length(filename_heads) > 1
    warning('Filenames we are going to combine are different. ');
end
wave_structs = cell2mat(cellfun(@(x) load_data_from_csv(x), filenames, 'UniformOutput', false));
[~,name_1,ext_1] = fileparts(filenames{1});
for file_i  = 1:length(wave_structs)
    [~,name_i,ext_i] = fileparts(filenames{file_i});
    if ~isequal(wave_structs(1).datetime, wave_structs(file_i).datetime)
        warning('"Mark" of %s is different from that of %s.', [name_i ext_i], [name_1 ext_1]);
    end
    if ~isequal(wave_structs(1).stim, wave_structs(file_i).stim)
        warning('"Date" of %s is different from that of %s.', [name_i ext_i], [name_1 ext_1]);
    end
end
wave_struct.filename = filename_heads{1};
wave_struct.datetime = wave_structs(1).datetime;
wave_struct.wavelength = [wave_structs(:).wavelength];
wave_struct.data = [wave_structs(:).data];
wave_struct.stim = wave_structs(1).stim;

function ws=load_data_from_csv(filename)
ws.filename = filename;
ws.datetime = [];
ws.wavelength = [];
ws.data = [];
ws.stim = [];

fid = fopen(filename);
if fid == -1
    warning('%s was not loaded. Check if it exist.', filename);
    return
end

fprintf('%s was', filename);
index = 1;
while ~feof(fid)
    line = fgetl(fid);
    if regexp(line, '^AnalyzeMode')
        elems = regexp(line, ',', 'split');
        if ~regexp(elems{2}, '^Contin')
            warning('MyComponent:debug', '"AnnalyzeMode" of %s is not "Continuous".', filename);
            return;
        end
    elseif regexp(line, '^Date')
        elems = regexp(line, ',', 'split');
        ws.datetime = elems{2};
    elseif regexp(line, '^Wave\ Length')
        wavelengths = regexp(line, '(?<=\().+?(?=\))', 'match');
        ws.wavelength = cell2mat(cellfun(@str2double, wavelengths, 'UniformOutput', false));
    elseif regexp(line, '^Probe')
        elems = regexp(line, ',', 'split');
        column_index_of_mark = find(ismember(elems, 'Mark'));
        %column_index_of_BodyMovement = find(ismember(elems, 'BodyMovement'));
        %column_index_of_RemovalMark = find(ismember(elems, 'RemovalMark'));
        %column_index_of_PreScan = find(ismember(elems, 'PreScan'));
    elseif regexp(line, '^1,')
        isSD = cellfun(@(x) isnan(str2double(x)), regexp(line, ',','split'), 'UniformOutput', false);
        SD = {'%f', '%s'};
        fseek(fid, 0, 'bof');
        ws.data = textscan(fid, [SD{cell2mat(isSD)+1}], 'Delimiter', ',', 'Headerlines', index-1);
    end
    index = index + 1;
end
fclose(fid);
if exist('column_index_of_mark', 'var') && ~isempty(column_index_of_mark)
    ws.stim = ws.data{:, column_index_of_mark};
else
    warning('MyComponent:debug', 'A column name "Mark" was not found in a line start with Probe."');
end
if ~isempty(ws.wavelength)
    ws.data = [ws.data{1, 2:length(ws.wavelength)+1}];
else
    warning('MyComponent:debug', 'A line start with "Wave Length" was not found.');
end
fprintf(' loaded.\n');