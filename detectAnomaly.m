function [isAnomaly, score] = detectAnomaly(sampleRow, modelDir)
% [isAnomaly, score] = detectAnomaly(sampleRow, modelDir)
% sampleRow: numeric 1xF feature vector (must match pipeline normalization)
% modelDir: folder containing ocsvmModel.mat and pipeline_meta.mat
%
% returns isAnomaly (logical), and score (signed distance; negative = anomaly usually)

if ~exist(modelDir,'dir')
    error('Model directory not found.');
end

% Load OCSVM
tmp = load(fullfile(modelDir,'ocsvmModel.mat'));
if isstruct(tmp)
    % Expect variable is compact model - if saved with saveCompactModel, it will be a struct-like.
    ocsvm = tmp.compactModel; % some uses may differ; try generic load
    % In our training we saved with saveCompactModel(models.ocsvmModel,...)
    % So load again safely:
    ocData = load(fullfile(modelDir,'ocsvmModel.mat'));
    fn = fieldnames(ocData);
    ocsvm = ocData.(fn{1}); % pick first variable
else
    ocsvm = tmp;
end

% Load meta
metaData = load(fullfile(modelDir,'pipeline_meta.mat'));
meta = metaData.meta;

% Normalize sample using meta stats
if isfield(meta,'mean') && isfield(meta,'std')
    sampleNorm = (sampleRow - meta.mean) ./ (meta.std + eps);
else
    sampleNorm = sampleRow;
end

% Score using ocsvm
[~,score] = predict(ocsvm, sampleNorm);
% score is Nx2 for binary models; with one-class SVM, score(:,2) often >0 for inliers
% We'll treat negative sign as anomaly depending on orientation:
if ismatrix(score)
    % If score has 2 columns, use second column
    s = score(:,2);
else
    s = score;
end

% Heuristic decision boundary (flip if necessary)
threshold = 0; % OC-SVM decision boundary is zero
isAnomaly = (s < threshold);

end
