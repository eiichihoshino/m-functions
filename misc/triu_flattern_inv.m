function X = triu_flattern_inv(U, k)
% TRIU_FLATTERN_INV: Inverse function of triu_flattern.
%                    Get upper triangular part of matrix from flatterned array.
% 	X: an array.
%   k: Same as k of
%   triu().
%
%	v.1.0.0 on 2016.11.7 Hoshino, E..
%
if nargin < 2
    k = 0;
end
if k < 0
    warning('MyComponent:triu_flattern_inv', 'k must be more than or equal to 0');
end
n = real((-1+sqrt(1+8*numel(U)))/2);
n = n + k;
X = NaN(n);
tf = triu(ones(size(X)), k);
X(logical(tf)) = U;