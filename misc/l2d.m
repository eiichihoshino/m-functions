function d = l2d(x, false_value)
% L2D: Convert logical to double.
% 	x: a logical array.
%   false_value: false (=0) will be converted to this value. Default is NaN.
%
%	v.1.0.0 on 2016.10.25 Hoshino, E..
%
if nargin < 2
    false_value = NaN;
end
d = double(x);
d(d==0) = false_value;