function [U, varargout] = triu_flattern(X, k)
% TRIU_FLATTERN: Get flatterned array of upper triangular part of matrix.
% 	X: a matrix.
%   k: get the element on and above the kth diagonal of X. Same as k of
%   triu().
%
%	v.1.0.0 on 2016.11.7 Hoshino, E..
%
if nargin < 2
    k = 0;
end
[m,n] = size(X);
tf = triu(ones(m,n), k);
ltf = logical(tf);
U = X(ltf);
if nargout > 1
    t1 = repmat(1:m, [n 1])';
    t2 = repmat(1:n, [m 1]);
    varargout{1} = [t1(ltf) t2(ltf)];
end