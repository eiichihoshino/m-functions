function c = csv2cell(filename, varargin)
% CSV2CELL: Load a csv to a cell.
% 	filename: path to csv file
%   varargin: skiprows if necessary.
%
%	Version. 1.0.0 on 2016.6.13 by Hoshino, E..
%
if isempty(varargin)
    skiprows = 0;
else
    if isnumeric(varargin{1})
        skiprows = varargin{1};
    else
        error('Error! %s must be a number.', varargin{1});
    end
end

fid = fopen(filename);
if fid == -1
  warning('%s was not loaded. Check if it exist.', filename);
  return
end

fprintf('%s was', filename);
index = 1;
c = cell(1,1);
while ~feof(fid)
	line = fgetl(fid);
    if index > skiprows
            if ~exist('c', 'var')
                c = cellfun(@str2doubleif, regexp(line, ',','split'), 'UniformOutput', false);
            else
                newline = cellfun(@str2doubleif, regexp(line, ',','split'), 'UniformOutput', false);
                c = cat(2, c, cell(size(c, 1), length(newline)-size(c,2)));
                c = [c; newline;];
            end
    end
	index = index + 1;
end
fclose(fid);
fprintf(' loaded.\n');

function strdouble = str2doubleif(x)
d = str2double(x);
if isnan(d)
    strdouble = x;
else
    strdouble = d;
end