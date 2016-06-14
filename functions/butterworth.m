function data=butterworth(data, order, cutoffs, sampling_rate)
%
% BUTTERWORTH: applies Butterworth filter.
%
% INPUT
% 	data: an array. This function acts along the first array dimension whose size does not equal 1.
%	oder: order of butterworth.
% 	cutoffs: 2 elements vector to specify upper and lower limit.
%	sampling_rate: sampling rate of data.
%
% OUTPUT
% 	data: filtered data.
%
% Version 1.0.0 on 2016.5.31 by Hoshino, E..
% Initialize.
% 
[b, a] = butter(order, cutoffs/(sampling_rate/2));
size_of_data = size(data);
data_2d = reshape(data, [size_of_data(1) prod(size_of_data(2:end))]);
data_2d = filtfilt(b,a,data_2d);
data = reshape(data_2d, size_of_data);
