output_dir = mfilename;

subpaths = regexp(genpath('.'), pathsep, 'split');
addpath(strjoin(subpaths(cellfun(@(s) isempty(regexp(s, regexprep(strjoin({'cache', '.git'}, '|'), '\.', '\\.'))), subpaths)), pathsep));
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%initialize UpdateChecker
checker = UpdateChecker([mfilename '.m'], fullfile(output_dir, 'cache'));

filelist = get_pathlist_by_run(input_dir);
for file_i = size(filelist,1):-1:1
	fprintf('Processing: %d out of %d.\n', file_i, size(filelist, 1));
    if checker.needsUpdate(filelist(file_i,:));
        S = load_data_by_run_from_csvs(filelist(file_i,:));
        S.data0 = S.data;
        S.intensity = get_resting_part(S.data, S.stim);

        %Apply Modified Beer-Lambert law
        S.hb = XXXX(S.intensity, S.wavelength);

        %Detect artifacts
        data_moving_averaged = moving_average(S.hb(:,:,3), 4);
        S.artifact_marks = artifact_detect_by_signal_change(data_moving_averaged, 0.15, 4);
        S.artifact_marks_extended = artifact_mark_extend(S.artifact_marks, 15, 85);
        S.artifact_marks_for_all_channels = artifact_mark_by_channel(S.artifact_marks_extended, 23);

        %Apply Butterworth filter
        S.hb_filt = butterworth(S.hb, 3, [0.01 0.1], 10);

        %Apply artifact rejection
        S.hb_filt_afreject = artifact_reject(S.hb_filt, S.artifact_marks_extended);
        S.hb_filt_afreject = S.hb_filt_afreject(~S.artifact_marks_for_all_channels, :, :);
        
        %Set final data of analysis as data
        S.data = S.hb_filt_afreject;

        %Save data
        [~,name,~] = fileparts(S.filename);
        save_filename = fullfile(output_dir, [name '.mat']);
        save(save_filename, 'S');

        checker.didSucceed(filelist(file_i,:));
    end    
end
checker.renewCache();
fprintf('Fin.\n');