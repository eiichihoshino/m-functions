function cell2csv(c, output_filename, varargin)
% CELL2CSV Save a cell to a csv file.
% 	c: a cell
% 	output_filename: path to csv file
%   varargin: a boolean value whether c has a header.
%
%	Version. 1.0.1 on 2016.6.10 by Hoshino, E..
%
if ~ismatrix(c)
    warning('The cell must be 2-dimensional. cell2csv was not processed.');
    return
end
if isempty(varargin)
    if any(cellfun(@isnumeric, c(1,:)))
        header = false;
    else
        header = true;
    end
else
    header = varargin{1};
end
if header
    header_c = c(1,:);
    c = c(2:end,:);
end
isD = prod(cellfun(@isnumeric, c)) + 1;
SD = {'%s', '%d'};
cFormat = strcat(',', SD(isD));
c_transposed = c';
fh = fopen(output_filename, 'w');
if header
    fprintf(fh, ['%s' repmat(',%s', [1 length(header_c)-1]) '\n'], header_c{:});
end
fprintf(fh...
    ,repmat([cFormat{1}(2:end) [cFormat{2:end}] '\n'], 1, size(c,1)) ...
    ,c_transposed{:});
fclose(fh);