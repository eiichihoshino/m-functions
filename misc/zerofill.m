function zerofilled = zerofill(x, len, varargin)
% ZEROFILL: Return a zerofilled string.
% 	x: a number or a string to be zero-filled.
%   len: length of a zerofilled string.
%   varargin{1}: a character which fills string 'x'. Default '0'.
%   varargin{2}: 'head' of 'tail', which specifies a direction to be
%   filled. Defaut 'head'.
%
% Example:
%   zerofill(31, 4, 'z', 'tail')
%   >> 31zz
%
%	Version. 1.0.0 on 2016.6.21 by Hoshino, E..
%
if isempty(varargin)
    fill_char = '0';
else
    fill_char = varargin{1};
end
if length(varargin) > 1
    d = varargin{2};
else
    d = 'head';
end
if isnumeric(x)
    x = num2str(x);
end
zerofilled = repmat(fill_char, [1 len-length(x)]);
if strcmp(d, 'head')
    zerofilled = [zerofilled x];
elseif strcmp(d, 'tail')
    zerofilled = [x zerofilled];
else
    error('Error! Unknown direction=%s. The forth argument must be ''head'' or ''tail''', d);
end
