function new_artifact_marks = artifact_mark_by_channel(artifact_marks, number_of_channels)
%
% ARTEFACT_MARK_BY_CHANNEL: checks if more than a number of channels are marked at a same time.
%
% INPUT
% 	artifact_marks: a boolean array of artifact marks.
%	number_of_channels: marks as artifact if a number of channels more than this value are marked.
%
% OUTPUT
% 	new_artifact_marks: boolean array of the same shape as input "data". 1 if artifact is detected.
%
% Version 1.0.0 on 2016.5.30 by Hoshino, E..
% Initialize.
%
new_artifact_marks =  sum(artifact_marks, 2) > number_of_channels;