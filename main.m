%% AI-Powered Agricultural Monitoring System
% Main script for monitoring crop health, soil condition, and pest risks
% using multispectral/hyperspectral imaging and sensor data

clear; clc; close all;

% Clean up previous results
if exist('results', 'dir')
    rmdir('results', 's');
end
mkdir('results');

%% Initialize the Agricultural Monitoring System
fprintf('Initializing AI-Powered Agricultural Monitoring System...\n');

% Add paths for all modules
addpath('modules');
addpath('data');
addpath('utils');
if exist('models','dir'), addpath('models'); end

%% Configuration
config = loadConfiguration();

%% Load or simulate input data
fprintf('Loading input data...\n');

% Multispectral/Hyperspectral image data
if exist('data/multispectral_data.mat', 'file')
    load('data/multispectral_data.mat');
    fprintf('Loaded multispectral data: %dx%dx%d\n', size(multispectral_data));
else
    % Generate sample multispectral data (8 bands: Blue, Green, Red, NIR, RedEdge, etc.)
    multispectral_data = generateSampleMultispectralData(512, 512, 8);
    fprintf('Generated sample multispectral data: %dx%dx%d\n', size(multispectral_data));
end

% Sensor data (soil moisture, temperature, humidity, etc.)
if exist('data/sensor_data.mat', 'file')
    load('data/sensor_data.mat');
    fprintf('Loaded sensor data with %d measurements\n', length(sensor_data.timestamp));
else
    sensor_data = generateSampleSensorData();
    fprintf('Generated sample sensor data\n');
end

%% Process Multispectral Data
fprintf('Processing multispectral data...\n');
spectral_processor = SpectralImageProcessor();
processed_spectral = spectral_processor.processImage(multispectral_data);

%% Analyze Crop Health
fprintf('Analyzing crop health...\n');
crop_analyzer = CropHealthAnalyzer();
crop_health = crop_analyzer.analyzeHealth(processed_spectral);

%% Assess Soil Condition
fprintf('Assessing soil condition...\n');
soil_analyzer = SoilConditionAnalyzer();
soil_condition = soil_analyzer.assessCondition(processed_spectral, sensor_data);

%% Detect Pest Risks
fprintf('Detecting pest risks...\n');
pest_detector = PestRiskDetector();
pest_risks = pest_detector.detectRisks(processed_spectral, crop_health);

%% Generate Comprehensive Report
fprintf('Generating comprehensive report...\n');
report_generator = ReportGenerator();
report = report_generator.generateReport(crop_health, soil_condition, pest_risks, config);

%% Display Results
fprintf('Displaying results...\n');
displayResults(crop_health, soil_condition, pest_risks, report);

%% Save Results
saveResults(crop_health, soil_condition, pest_risks, report);

fprintf('Agricultural monitoring analysis completed successfully!\n');
