function trainPipeline(csvPath, imageFolder, outputDir, varargin)
% trainPipeline(csvPath, imageFolder, outputDir, Name,Value)
% Main entry point: loads data, preprocesses, extracts image features,
% trains models (kmeans, one-class SVM, optional supervised classifier),
% and saves compact models to outputDir.
%
% Required:
%  csvPath   - path to CSV with multimodal metadata (sensor, weather, time, image filenames)
%  imageFolder - folder containing image files referenced in CSV
%  outputDir - directory to save trained compact models
%
% Optional Name/Value:
%  'ImageSize' (default [224 224])
%  'K'         (clusters for KMeans, default 3)
%  'OutlierFraction' (for OC-SVM, default 0.02)
%  'TrainSupervised' (true/false, default false)
%
% Example CSV columns expected:
%  timestamp, sensor1, sensor2, ..., weather1, weather2, image_filename, label (optional)
%
% Example:
%  trainPipeline('data/dataset.csv','data/images','models','TrainSupervised',true)

% DEFAULTS
p = inputParser;
addParameter(p,'ImageSize',[224 224]);
addParameter(p,'K',3);
addParameter(p,'OutlierFraction',0.02);
addParameter(p,'TrainSupervised',false);
parse(p, varargin{:});
opts = p.Results;

if ~exist(outputDir,'dir')
    mkdir(outputDir);
end

% 1) Load tabular CSV
T = readtable(csvPath);

% Validate columns (basic) — make images optional
hasImageCol = ismember('image_filename', T.Properties.VariableNames);
if ~hasImageCol
    warning('CSV missing column image_filename. Proceeding with tabular-only features.');
end

% 2) Preprocess tabular data (sensor + weather + time)
fprintf("Preprocessing tabular data...\n");
[tabularFeatures, tabMeta] = preprocessData(T);

% 3) Extract image features (pretrained CNN) — optional
imgFeatures = [];
if hasImageCol && ~isempty(imageFolder)
    fprintf("Extracting image features from %d images...\n", height(T));
    imgFiles = fullfile(imageFolder, T.image_filename);
    imgFeatures = extractImageFeatures(imgFiles, opts.ImageSize);
else
    fprintf("Skipping image feature extraction (no image column/folder provided).\n");
end

% 4) Combine multimodal features
if ~isempty(imgFeatures)
    X = [tabularFeatures, imgFeatures]; % numeric matrix, rows = samples
else
    X = tabularFeatures;
end

% 5) Train models
fprintf("Training models...\n");
models = trainModels(X, 'K', opts.K, 'OutlierFraction', opts.OutlierFraction, 'TrainSupervised', opts.TrainSupervised, 'Labels', getOptionalColumn(T,'label'));

% 6) Save compact models & metadata
fprintf("Saving models to %s\n", outputDir);
kmeansModel = models.kmeansModel;
ocsvmModel = models.ocsvmModel;
save(fullfile(outputDir,'kmeansModel.mat'), 'kmeansModel');
save(fullfile(outputDir,'ocsvmModel.mat'), 'ocsvmModel');
if isfield(models,'supervisedModel')
    supervisedModel = models.supervisedModel;
    save(fullfile(outputDir,'supervisedModel.mat'), 'supervisedModel');
end

% Save feature normalization parameters and metadata for inference
meta.mean = mean(X,1);
meta.std = std(X,[],1);
meta.tabMeta = tabMeta;
save(fullfile(outputDir,'pipeline_meta.mat'),'meta');

fprintf("Training pipeline complete. Models saved in %s\n", outputDir);

end

function val = getOptionalColumn(T,colname)
    if ismember(colname,T.Properties.VariableNames)
        val = T.(colname);
    else
        val = [];
    end
end
