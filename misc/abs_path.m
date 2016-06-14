function abs_path_str = abs_path(a_file)
%
% ABS_PATH: get absolute path of a file.
%
% INPUT
% 	a_file: a file name / path.
%
% OUTPUT
% 	abs_path_str: absolute path string.
%
% Version 1.0.0 on 2016.6.9 by Hoshino, E..
% Initialize.
%
[~, message] = fileattrib(a_file);
abs_path_str = message.Name;
