function connectivity = get_connectivity(data)
%
% GET_CONNECTIVITY: calculates connectivities.
%
% INPUT
% 	data: an array. This function acts along the first array dimension whose size does not equal 1.
%
% OUTPUT
%   connectivity.z: Fisher's z tranformed r value
% 	connectivity.p: p-values of connectivity
%   connectivity.pfdr: fdr corrected p-values
%
% Version 1.0.0.0 on 2016.6.1 by Hoshino, E..
% Initialize.
%

if exist('OCTAVE_VERSION', 'builtin') == 5
	pkg load all;
	more off;
    %eval('corrcoef = @corr;');
end

sizes_of_data = size(data);
if ndims(data) < 4
    data_for_analysis = data;
else
    data_for_analysis = reshape(data, [sizes_of_data(1:2) prod(sizes_of_data(3:end))]);
end
r3 = [];
p3 = [];
pfdr3 = [];
n3 = [];
for ii = 1:size(data_for_analysis, 3)
    [r, p] = corrcoef(data_for_analysis(:,:,ii), 'rows', 'pairwise');
    r3 = cat(3, r3, r);
    p3 = cat(3, p3, p);
    
    b = true(size(p));
    pfdr = ones(size(p));
    [~,~,pfdr_vector] = fdr_bh(p(triu(b,1)));
    pfdr(triu(b,1)) = pfdr_vector;
    pfdr = pfdr + pfdr' - 1;
    pfdr3 = cat(3, pfdr3, pfdr);
    
    n = zeros(size(p));
    for jj = 1:sizes_of_data(2)
        for kk = jj:sizes_of_data(2)
            n(jj,kk) = sum(~isnan(data_for_analysis(:,jj,ii) .* data_for_analysis(:,kk,ii)));
        end
    end
    n = n + triu(n, 1)';
    n3 = cat(3, n3, n);
end
sizes_of_r = size(r);
connectivity.r = reshape(r3, [sizes_of_r(1:2) sizes_of_data(3:end)]);
connectivity.z = atanh(connectivity.r);
connectivity.p = reshape(p3, [sizes_of_r(1:2) sizes_of_data(3:end)]);
connectivity.pfdr = reshape(pfdr3, [sizes_of_r(1:2) sizes_of_data(3:end)]);
connectivity.n = reshape(n3, [sizes_of_r(1:2) sizes_of_data(3:end)]);