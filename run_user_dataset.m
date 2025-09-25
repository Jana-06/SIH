%% Run training on user-provided CSV (tabular-only or with images if available)
clear; clc;

% User CSV path
csvPath = 'C:\\Projects\\SIH\\ifsar_ori_68ca3c3c6aacb237\\ifsar_ori_68ca3c3c6aacb237.csv';

% If you also have images referenced by an image_filename column, set this
% to the folder containing those images. Otherwise, leave as '' to use
% tabular-only features.
imageFolder = '';

% Output directory for models
outputDir = 'user_models';

% Number of clusters for KMeans
K = 3;

fprintf('Starting training on user dataset...\n');
trainPipeline(csvPath, imageFolder, outputDir, 'TrainSupervised', false, 'K', K);
fprintf('Training complete. Models saved to %s\n', outputDir);


