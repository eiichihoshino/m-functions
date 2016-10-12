function varargout = genvarname2(varargin)
%
% GENVARNAME2: gets matlab variable name.
%
% INPUT
% 	varargin{1}: a string to covert.
%   varargin{2}: bad character will be replaced with this string. Default is '_'. 
%
% OUTPUT
% 	varargout{1}: a matlab variable name.
%   varargout{2}: true if no replacement.
%
% [History]
% Ver. 1.0.0 Init. 2016.10.12 Hoshino, E.
%
name = varargin{1};
if isempty(name)
    if nargout > 1
        varargout{2} = false;
    end
    warning('MyComponent:genvarname2', 'Varname can not be empty');
    return;
end
tf = true;
if ~regexp(name(1), 'a-zA-Z')
    tf = false;
    warning('MyComponent:genvarname2', 'The first letter of varname must be an alphabet.');
    name = ['X' name];
    warning('MyComponent:genvarname2', 'X was inserted at the begining of varname.');
end
if numel(name) > namelengthmax
    tf = false;
    warning('MyComponent:genvarname2', 'Length of varname exceeds namelegthmax: %d', namelengthmax);
    name = name(1:namelengthmax);
    warning('MyComponent:genvarname2', 'Varname was shorten.');
end
if regexp(name, '\W', 'once')
    tf = false;
    warning('MyComponent:genvarname2', 'Varname can not contain letters other than alphabets, numbers, and underscores.');
    if nargin > 1
        replace = varargin{2};
    else
        replace = '_';
    end
    name = regexprep(name,  '\W', replace);
    warning('MyComponent:genvarname2', 'Invalid letters were replaced with ''%s''.', replace);
end
varargout{1} = name;
if nargout > 1
    varargout{2} = tf;
end