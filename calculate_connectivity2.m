addpath(genpath('.'));
if exist('OCTAVE_VERSION', 'builtin') == 5
    pkg load all;
    more off;
end

%%% parameters %%%
preprocessed_file_path = 'preprocessed';
merged_file_path = 'connectivity_merged';
use_file_path = 'connectivity_use';
number_of_channels = 46;
%%%%%%%%%%%%%%%%%%

connectivity_merge;
connectivity_select_valid;