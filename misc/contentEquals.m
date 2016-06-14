function is_equal = contentEquals(file_1, file_2)
%
% contentEqual: compares files.
%
% INPUT
% 	file_1: path to file 1.
%   file_2: path to file 2.
%
% OUTPUT
% 	is_equal: true / false.
%
% Version 1.0.0 on 2016.6.3 by Hoshino, E..
% Initialize.
%
is_equal = javaMethod(...
    'contentEquals','org.apache.commons.io.FileUtils'...
    ,javaObject('java.io.File', file_1)...
    ,javaObject('java.io.File', file_2)...
    );