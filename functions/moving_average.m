function data = moving_average(data, window_size)
%
% MOVING_AVERAGE.
%
% INPUT
% 	data: an array. This function acts along the first array dimension whose size does not equal 1.
% 	window_size: a window size.
%
% OUTPUT
% 	data: calculated data.
%
% Version 1.0.0 on 2016.5.30 by Hoshino, E..
% Initialize.
% 
data = filter(ones(1, window_size), window_size, data);