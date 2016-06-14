function resting_part = get_resting_part(data, stim)
%
% GET_RESTING_PART Check if a data has a resting state and return time points of resting state.
%
% INPUT
% 	data: [time points x ...]. ETG MES data or Hb data.
% 	stim: [time points x 1]. A time series vector of column Mark.
%
% OUTPUT
% 	resting_part: data of resting state. Can be empty unless data contains resting state.
%
% Version 1.0.0 on 2016.5.26 by Hoshino.
% Initialize.
% 
indices = find(stim);
if isempty(indices)
	resting_part = data;
else
	resting_part = eval(['data(1:indices(1)-151' repmat(',:', [1 ndims(data)-1]) ');']);
end