function new_data = artifact_reject(data, artifact_marks)
%
% ARTEFACT_REJECT: applies artifact_marks to data.
%
% INPUT
% 	data: an array. This function acts along the first array dimension whose size does not equal 1.
%	artifact_marks: a boolean vector a size agrees with a size of first some "data" dimensions.
%
% OUTPUT
% 	new_data: data without artifacts.
%
% Version 1.0.0.3 on 2016.6.1 by Hoshino, E..
% Initialize.
%
sizes_of_data = size(data);
if ~isequal(sizes_of_data(1:ndims(artifact_marks)), size(artifact_marks))
    warning('Sizes of "artifact_marks" dimensions must agree with sizes of "data". Artifact_reject failed.');
    return;
end
n_elements = numel(artifact_marks);
artifact_marks_reshaped = reshape(artifact_marks, [n_elements 1]);
data_reshaped = reshape(data, [n_elements numel(data)/n_elements]);
data_reshaped(logical(artifact_marks_reshaped), :) = NaN;
new_data = reshape(data_reshaped, sizes_of_data);
