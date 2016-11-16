function artifact_marks = artifact_detect_by_signal_change(data, threshold, time_point_difference)
%
% ARTEFACT_DECTECT_BY_SIGNAL_CHANGE: detects artifacts as signal change more than "threshold" within "time_point_difference".
%
% INPUT
% 	data: an array. This function acts along the first array dimension.
%	threshold: detects if more than this value. 
% 	time_point_difference: detects if signal_change occurs within this value.
%
% OUTPUT
% 	artifact_marks: boolean array of the same shape as input "data". 1 if artifact is detected.
%
% Version 1.0.0 on 2016.5.30 by Hoshino, E..
% Initialize.
% 
if nargin < 3
	time_point_difference = 1;
end
if nargin < 2
	threshold = 0.15;
end
comma_colons = repmat(',:', [1 ndims(data)-1]);
artifact_marks = threshold < abs(...
	eval(sprintf('data(1+time_point_difference:end%s) - data(1:end-time_point_difference%s)'...
	, comma_colons, comma_colons)));
eval(sprintf('artifact_marks(1:%d%s) = 0;', time_point_difference-1, repmat(',:', [1 ndims(artifact_marks)-1])));
artifact_marks = padarray(artifact_marks ...
	 ,eval(sprintf('[%d%s]', time_point_difference, repmat(' 0', [1 ndims(artifact_marks)-1])))...
	 , 'post');
