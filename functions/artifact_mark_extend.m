function new_artifact_marks = artifact_mark_extend(artifact_marks, pre_period, post_period)
%
% ARTEFACT_MARK_EXTEND: extends artifact labels in the temporal dimension (the first array dimension).
%
% INPUT
% 	artifact_marks: a boolean array.
%	pre_period: adds artifacts before existed artifacts. 
% 	post_period: adds artifacts after existed artifacts.
%
% OUTPUT
% 	new_artifact_marks: boolean array of the same shape as input "data". 1 if artifact is detected.
%
% Version 1.0.0 on 2016.5.30 by Hoshino, E..
% Initialize.
%
size_of_artifact_marks = size(artifact_marks); 
artifact_marks_2d = reshape(artifact_marks, [size_of_artifact_marks(1) prod(size_of_artifact_marks(2:end))]);
new_artifact_marks_2d = zeros(size(artifact_marks_2d));
for ii = 1:size(artifact_marks_2d, 2)
	conved = conv(single(artifact_marks_2d(:, ii)), ones(1, pre_period + post_period + 1))>0;
	new_artifact_marks_2d(:, ii) = conved(pre_period+1:end-post_period);
end
new_artifact_marks = reshape(new_artifact_marks_2d, size_of_artifact_marks);
