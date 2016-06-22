function ICA = ms_ica(X)
%% MS-ICA
% Number of IC components interval to search
interval=2:size(X,1);
% remove mean
X=X-repmat(mean(X,2),1,size(X,2));

% - 1th Part - Finding best model wrt. number of components using BIC
% BIC
[P,~]=icaMS_bic(X,interval,0);
[most_prop,most_prop_K]=max(P);
most_prop_K=interval(most_prop_K);
disp(sprintf('\nEstimated components %d with P=%0.2f\n',most_prop_K,most_prop));

% - 2nd Part - finding ICA components using BIC estimat of K (number of source components)
disp(sprintf('PCA and MS %d components:',most_prop_K));
% PCA
[U,D,V]=svd(X',0);
Xica=( U(:,1:most_prop_K)*D(1:most_prop_K,1:most_prop_K) )';
% ICA
[ICA.S, ICA.Aica, ICA.ll]=icaMS(Xica);
ICA.A=V(:,1:most_prop_K)*ICA.Aica;
S = ICA.S';