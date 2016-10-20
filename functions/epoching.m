function [epochs] = epoching(data, event_timings, pre, post)
%
% EPOCHING: gets epochs by marks.
%
% INPUT
% 	data: n-d array. The first axis will be treaded as timepoints.
%   events: a vector inidicating stimulus onset and offset. The onset and offset must be pairs.
%   The numeric values were Must be the same as size(data,1).
%   pre, post: extracting epoch time [(onset-pre):(offset-post)]
%
% OUTPUT
% 	epochs: (n+1)-d araay. The first axis will be a number of epochs.
%
% [History]
% Ver. 1.0.0 Init. 2016.10.6 Hoshino, E.
%
stims = find(event_timings);
if mod(numel(stims), 2)
    warning('MyComponent:epoching', 'The number of event marks are odd. Event mark: %d at t = %d was dropped.', event_timings(stims(end)), stims(end));
    stims(end) = [];
end
stims2d = reshape(stims, [2 numel(stims)/2])';
%determine period
stims2d = stims2d + repmat([-pre, post], [size(stims2d,1) 1]);
%remove exceeded rows
if any(stims2d(:,1)<0)
    warning('MyComponent:epoching', 'The some epochs were assigned to negatimve timepoints. Those epochs were excluded.');
    stims2d(stims2d(:,1)<0,:) = [];
end
if any(stims2d(:,2)>size(data,1))
    warning('MyComponent:epoching', 'The some epochs were assigned to more than the limit of timepoints. Theose epochs were excluded.');
    stims2d(stims2d(:,2)>size(data,1),:) = [];
end
epochs_size = size(data);
epochs_size = [size(stims2d,1)  max(stims2d(:, 2) - stims2d(:,1))+1 epochs_size(2:end)];
epochs = NaN(epochs_size);
for b_i = 1:size(stims2d,1)
    eval(sprintf('epochs(b_i,1:stims2d(b_i, 2) - stims2d(b_i,1)+1 %s) = data(stims2d(b_i,1):stims2d(b_i,2) %s);' ...
        , repmat(',:', [1 ndims(data)-1]) ...
        , repmat(',:', [1 ndims(data)-1]) ...
    ));
end