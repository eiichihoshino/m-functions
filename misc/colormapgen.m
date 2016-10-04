function cm = colormapgen(varargin)
% COLORMAPGEN: Return a colormap with specified color makers and number of
% colors.
% 	varargin{1}: a 4 columns matrix.
%   a row represents a color marker [R G B position] (range [0 1]) as
%   in the "colormapeditor".
%   varargin{2}: optional. Default is 64. Number of colors for the colormap.
%
% Example:
% cm = colormapgen([...
%        0 0 147/255 1/64;
%        0 0 1 12/64;
%        0 1 1 38/64;
%        1 1 1 1;
%        ], 5)
%
% cm =
%
%         0         0    1.0000
%         0    0.5000    1.0000
%         0    1.0000    1.0000
%    0.5000    1.0000    1.0000
%    1.0000    1.0000    1.0000
% 
% figure; colorbar; colormap(cm);
%
%	Version. 1.0.0 on 2016.10.4 by Hoshino, E..
%
markers = varargin{1};
if ~ismatrix(markers) || size(markers,1) < 2 || size(markers, 2) ~= 4
    error('varargin{1} must be an array with at least 2 row and exactly 4 columns (R, G, B, index(range=[0 1])');
end
if nargin > 1
    nc = varargin{2};
else
    nc= 64;
end
if size(markers,1) > nc
    warning('Number of colormarks exceeds number of output. Rows: %d-%d were ignored.', nc+1, size(markers,1));
    markers(nc+1:end, :) = [];
end

for ii = size(markers, 1):-1:2
    i1 = ceil(markers(ii-1,4)*nc);
    i2 = ceil(markers(ii,4)*nc);
    if i1 > i2
        error('Indicex must be aligned in the ascendin order');
    end
    if i1 == 0
        i1 = 1;
    end
    if i2 == 0
        i2 = 1;
    end
    cm( (i1:i2), 1:3) = [...
        linspace(markers(ii-1, 1), markers(ii, 1), i2 - i1+1)' ...
        linspace(markers(ii-1, 2), markers(ii, 2), i2 - i1+1)' ...
        linspace(markers(ii-1, 3), markers(ii, 3), i2 - i1+1)' ...
        ];
end