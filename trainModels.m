function models = trainModels(X, varargin)
% models = trainModels(X, 'K',3, 'OutlierFraction',0.02, 'TrainSupervised', false, 'Labels', [])
p = inputParser;
addParameter(p,'K',3);
addParameter(p,'OutlierFraction',0.02);
addParameter(p,'TrainSupervised',false);
addParameter(p,'Labels',[]);
parse(p,varargin{:});
opts = p.Results;

% 1) KMeans clustering
K = opts.K;
[idx,C] = kmeans(X, K, 'Replicates',5, 'MaxIter',500);
kmeansModel = struct('Centroids',C,'K',K);

% 2) One-Class SVM for anomaly detection
% fitcsvm requires a label; for OC-SVM we train with "normal" data only.
% Heuristic: consider largest cluster as normal
clusterSizes = histcounts(idx,1:(K+1));
[~,normalCluster] = max(clusterSizes);
normalIdx = (idx==normalCluster);
X_normal = X(normalIdx,:);

% If not enough normal samples, fallback to using full dataset
if sum(normalIdx) < 10
    warning("Not enough normal cluster samples. Training OC-SVM on full dataset.");
    X_trainOC = X;
else
    X_trainOC = X_normal;
end

ocModel = fitcsvm(X_trainOC, ones(size(X_trainOC,1),1), ...
    'KernelScale','auto','Standardize',true, ...
    'OutlierFraction',opts.OutlierFraction, 'KernelFunction','rbf');

% Convert to compact
ocsvmModel = compact(ocModel);

models.kmeansModel = kmeansModel;
models.ocsvmModel = ocsvmModel;

% 3) Optional supervised classifier (if labels provided)
if opts.TrainSupervised && ~isempty(opts.Labels)
    Y = opts.Labels;
    if iscell(Y)
        Y = categorical(Y);
    end
    % align lengths
    if length(Y) ~= size(X,1)
        error('Labels length mismatch with feature rows.');
    end
    % Train a light-weight ensemble (fast)
    supervised = fitcensemble(X,Y,'Method','Bag','NumLearningCycles',50);
    models.supervisedModel = compact(supervised);
end
end
