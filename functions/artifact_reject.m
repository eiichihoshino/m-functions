function new_data = artifact_reject(data, artifact_marks, nan2true)
%
% ARTEFACT_REJECT: applies artifact_marks to data.
% Ver. 1.0.5 Change not to use reshape. Add a parameter nan2true. 2016.10.19 Hoshino, E.
%
% INPUT
% 	data: an array. This function acts along the first array dimension whose size does not equal 1.
%	artifact_marks: a boolean vector a size agrees with a size of first some "data" dimensions.
%   nan2false: treat NaN as this value. Default is true.
%
% OUTPUT
% 	new_data: data without artifacts.
%
% [History]
% Ver. 1.0.4 Change warning to error. 2016.10.12 Hoshino, E.
% Ver. 1.0.3 Init. 2016.6.1 Hoshino, E.
%
if nargin < 3
    nan2true = false;
end
sizes_of_data = size(data);
if ~isequal(sizes_of_data(1:ndims(artifact_marks)), size(artifact_marks))
    error('Sizes of "artifact_marks" dimensions must agree with sizes of "data". Artifact_reject failed.');
end

artifact_marks(isnan(artifact_marks)) = nan2true;
artifact_marks = logical(artifact_marks);
new_data = data;
new_data(repmat(artifact_marks, [ones([1 ndims(artifact_marks)]) sizes_of_data(ndims(artifact_marks)+1:end)])) = NaN;