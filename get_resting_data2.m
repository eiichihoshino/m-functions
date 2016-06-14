raw_data_path = regexprep('../../../dataByExp/rest', '/', filesep);
output_file_path = 'preprocessed';

addpath(genpath('.'));
if exist('OCTAVE_VERSION', 'builtin') == 5
    more off;
end

%initialize UpdateChecker
checker = UpdateChecker(mfilename, fullfile(output_file_path, 'cache'));

filelist = get_pathlist_by_run(raw_data_path);
for file_i = 1:size(filelist,1)
	fprintf('Processing: %d out of %d.\n', file_i, size(filelist, 1));
    if checker.needsUpdate(filelist(file_i,:));
        ws = load_data_by_run_from_csvs(filelist(file_i,:));

        ws.data = get_resting_part(ws.data, ws.stim);

        %Apply Modified Beer-Lambert law
        ws.data = xxxxx(ws.data, ws.wavelength);

        %Detect artifacts
        data_moving_averaged = moving_average(ws.data(:,:,3), 4);
        artifact_marks = artifact_detect_by_signal_change(data_moving_averaged, 0.15, 4);
        artifact_marks = artifact_mark_extend(artifact_marks, 15, 85);
        artifact_marks_global = artifact_mark_by_channel(artifact_marks, 23);

        %Apply Butterworth filter
        ws.data = butterworth(ws.data, 3, [0.01 0.1], 10);

        %Apply artifact rejection
        ws.data0 = ws.data;
        ws.data = artifact_reject(ws.data, artifact_marks);
        ws.data = ws.data(~artifact_marks_global, :, :);
        ws.artifact_marks_by_channel = artifact_marks;
        ws.artifact_marks_for_all_channels = artifact_marks_global;

        %Save data
        [~,name,~] = fileparts(ws.filename);	
        save_filename = fullfile(output_file_path, [name '.mat']);
        if exist('OCTAVE_VERSION', 'builtin') == 5
            save('-mat7-binary', save_filename, 'ws');
        else
            save(save_filename, 'ws');
        end

        checker.didSucceed(filelist(file_i,:));
    end    
end
checker.renewCache();

fprintf('Fin.\n');