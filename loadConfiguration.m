function config = loadConfiguration()
%% Load Configuration Parameters
% Returns configuration structure with all system parameters

config = struct();

% Image processing parameters
config.image_processing = struct();
config.image_processing.bands = {'Blue', 'Green', 'Red', 'NIR', 'RedEdge1', 'RedEdge2', 'RedEdge3', 'SWIR1'};
config.image_processing.wavelengths = [475, 560, 668, 840, 705, 740, 783, 1610]; % nm
config.image_processing.resolution = 0.1; % meters per pixel

% Vegetation indices parameters
config.vegetation_indices = struct();
config.vegetation_indices.ndvi_threshold = 0.3;
config.vegetation_indices.gndvi_threshold = 0.2;
config.vegetation_indices.ndre_threshold = 0.15;
config.vegetation_indices.savi_threshold = 0.2;

% Soil analysis parameters
config.soil_analysis = struct();
config.soil_analysis.moisture_threshold_low = 0.2;
config.soil_analysis.moisture_threshold_high = 0.8;
config.soil_analysis.temperature_optimal_min = 15; % Celsius
config.soil_analysis.temperature_optimal_max = 25; % Celsius
config.soil_analysis.ph_optimal_min = 6.0;
config.soil_analysis.ph_optimal_max = 7.5;

% Pest detection parameters
config.pest_detection = struct();
config.pest_detection.risk_threshold_low = 0.3;
config.pest_detection.risk_threshold_medium = 0.6;
config.pest_detection.risk_threshold_high = 0.8;

% AI/ML model parameters
config.ml_models = struct();
config.ml_models.crop_health_model = 'trained_models/crop_health_classifier.mat';
config.ml_models.soil_condition_model = 'trained_models/soil_condition_classifier.mat';
config.ml_models.pest_risk_model = 'trained_models/pest_risk_classifier.mat';

% Output parameters
config.output = struct();
config.output.save_images = true;
config.output.save_data = true;
config.output.generate_report = true;
config.output.report_format = 'pdf';

end
