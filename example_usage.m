%% Example Usage of AI-Powered Agricultural Monitoring System
% This script demonstrates various ways to use the agricultural monitoring system

clear; clc; close all;

fprintf('=== AI-Powered Agricultural Monitoring System - Examples ===\n\n');

%% Example 1: Complete Analysis with Sample Data
fprintf('Example 1: Complete Analysis with Sample Data\n');
fprintf('=============================================\n');

% Run the complete analysis
main;

fprintf('\nExample 1 completed. Check the results directory for saved files.\n\n');

%% Example 2: Custom Configuration Analysis
fprintf('Example 2: Custom Configuration Analysis\n');
fprintf('========================================\n');

% Load default configuration
config = loadConfiguration();

% Modify configuration for specific requirements
config.vegetation_indices.ndvi_threshold = 0.4; % Higher threshold for stricter health assessment
config.soil_analysis.moisture_threshold_low = 0.3; % Higher moisture threshold
config.pest_detection.risk_threshold_high = 0.7; % Lower high-risk threshold

fprintf('Custom configuration loaded with modified thresholds.\n');
fprintf('NDVI threshold: %.1f\n', config.vegetation_indices.ndvi_threshold);
fprintf('Moisture threshold: %.1f\n', config.soil_analysis.moisture_threshold_low);
fprintf('Pest risk threshold: %.1f\n', config.pest_detection.risk_threshold_high);

% Generate sample data with custom parameters
multispectral_data = generateSampleMultispectralData(256, 256, 8);
sensor_data = generateSampleSensorData();

% Process with custom configuration
spectral_processor = SpectralImageProcessor();
processed_spectral = spectral_processor.processImage(multispectral_data);

crop_analyzer = CropHealthAnalyzer();
crop_health = crop_analyzer.analyzeHealth(processed_spectral);

fprintf('Custom analysis completed.\n');
fprintf('Crop health status: %s (Score: %.2f)\n', ...
    crop_health.overall_health.status, crop_health.overall_health.score);

fprintf('\nExample 2 completed.\n\n');

%% Example 3: Individual Module Analysis
fprintf('Example 3: Individual Module Analysis\n');
fprintf('=====================================\n');

% Generate sample data
multispectral_data = generateSampleMultispectralData(128, 128, 8);
sensor_data = generateSampleSensorData();

% Step 1: Process spectral data
fprintf('Step 1: Processing spectral data...\n');
spectral_processor = SpectralImageProcessor();
processed_spectral = spectral_processor.processImage(multispectral_data);
fprintf('Spectral processing completed.\n');

% Step 2: Analyze crop health
fprintf('Step 2: Analyzing crop health...\n');
crop_analyzer = CropHealthAnalyzer();
crop_health = crop_analyzer.analyzeHealth(processed_spectral);
fprintf('Crop health analysis completed.\n');

% Step 3: Assess soil condition
fprintf('Step 3: Assessing soil condition...\n');
soil_analyzer = SoilConditionAnalyzer();
soil_condition = soil_analyzer.assessCondition(processed_spectral, sensor_data);
fprintf('Soil condition assessment completed.\n');

% Step 4: Detect pest risks
fprintf('Step 4: Detecting pest risks...\n');
pest_detector = PestRiskDetector();
pest_risks = pest_detector.detectRisks(processed_spectral, crop_health);
fprintf('Pest risk detection completed.\n');

% Display individual results
fprintf('\nIndividual Analysis Results:\n');
fprintf('Crop Health: %s (Score: %.2f)\n', ...
    crop_health.overall_health.status, crop_health.overall_health.score);
fprintf('Soil Condition: %s (Score: %.2f)\n', ...
    soil_condition.health_assessment.status, soil_condition.health_assessment.overall_score);
fprintf('Pest Risk: %s (Score: %.2f)\n', ...
    pest_risks.overall_risk.level, pest_risks.overall_risk.score);

fprintf('\nExample 3 completed.\n\n');

%% Example 4: Vegetation Index Analysis
fprintf('Example 4: Vegetation Index Analysis\n');
fprintf('====================================\n');

% Generate sample data
multispectral_data = generateSampleMultispectralData(64, 64, 8);

% Process spectral data
spectral_processor = SpectralImageProcessor();
processed_spectral = spectral_processor.processImage(multispectral_data);

% Extract vegetation indices
vegetation_indices = processed_spectral.vegetation_indices;

% Display vegetation index statistics
fprintf('Vegetation Index Statistics:\n');
fprintf('NDVI: Mean=%.3f, Std=%.3f, Min=%.3f, Max=%.3f\n', ...
    mean(vegetation_indices.ndvi(:)), std(vegetation_indices.ndvi(:)), ...
    min(vegetation_indices.ndvi(:)), max(vegetation_indices.ndvi(:)));

fprintf('GNDVI: Mean=%.3f, Std=%.3f, Min=%.3f, Max=%.3f\n', ...
    mean(vegetation_indices.gndvi(:)), std(vegetation_indices.gndvi(:)), ...
    min(vegetation_indices.gndvi(:)), max(vegetation_indices.gndvi(:)));

fprintf('NDRE: Mean=%.3f, Std=%.3f, Min=%.3f, Max=%.3f\n', ...
    mean(vegetation_indices.ndre(:)), std(vegetation_indices.ndre(:)), ...
    min(vegetation_indices.ndre(:)), max(vegetation_indices.ndre(:)));

fprintf('SAVI: Mean=%.3f, Std=%.3f, Min=%.3f, Max=%.3f\n', ...
    mean(vegetation_indices.savi(:)), std(vegetation_indices.savi(:)), ...
    min(vegetation_indices.savi(:)), max(vegetation_indices.savi(:)));

fprintf('EVI: Mean=%.3f, Std=%.3f, Min=%.3f, Max=%.3f\n', ...
    mean(vegetation_indices.evi(:)), std(vegetation_indices.evi(:)), ...
    min(vegetation_indices.evi(:)), max(vegetation_indices.evi(:)));

% Create visualization
figure('Name', 'Vegetation Indices Visualization', 'Position', [100, 100, 1200, 800]);

subplot(2, 3, 1);
imagesc(vegetation_indices.ndvi);
colorbar;
title('NDVI');
axis equal tight;

subplot(2, 3, 2);
imagesc(vegetation_indices.gndvi);
colorbar;
title('GNDVI');
axis equal tight;

subplot(2, 3, 3);
imagesc(vegetation_indices.ndre);
colorbar;
title('NDRE');
axis equal tight;

subplot(2, 3, 4);
imagesc(vegetation_indices.savi);
colorbar;
title('SAVI');
axis equal tight;

subplot(2, 3, 5);
imagesc(vegetation_indices.evi);
colorbar;
title('EVI');
axis equal tight;

subplot(2, 3, 6);
imagesc(vegetation_indices.ndwi);
colorbar;
title('NDWI');
axis equal tight;

fprintf('\nExample 4 completed.\n\n');

%% Example 5: Soil Parameter Analysis
fprintf('Example 5: Soil Parameter Analysis\n');
fprintf('==================================\n');

% Generate sample sensor data
sensor_data = generateSampleSensorData();

% Display sensor data statistics
fprintf('Sensor Data Statistics:\n');
fprintf('Soil Moisture: Mean=%.3f, Std=%.3f, Min=%.3f, Max=%.3f\n', ...
    mean(sensor_data.soil_moisture), std(sensor_data.soil_moisture), ...
    min(sensor_data.soil_moisture), max(sensor_data.soil_moisture));

fprintf('Soil Temperature: Mean=%.1f°C, Std=%.1f°C, Min=%.1f°C, Max=%.1f°C\n', ...
    mean(sensor_data.soil_temperature), std(sensor_data.soil_temperature), ...
    min(sensor_data.soil_temperature), max(sensor_data.soil_temperature));

fprintf('Air Temperature: Mean=%.1f°C, Std=%.1f°C, Min=%.1f°C, Max=%.1f°C\n', ...
    mean(sensor_data.air_temperature), std(sensor_data.air_temperature), ...
    min(sensor_data.air_temperature), max(sensor_data.air_temperature));

fprintf('Humidity: Mean=%.1f%%, Std=%.1f%%, Min=%.1f%%, Max=%.1f%%\n', ...
    mean(sensor_data.humidity), std(sensor_data.humidity), ...
    min(sensor_data.humidity), max(sensor_data.humidity));

fprintf('pH: Mean=%.2f, Std=%.2f, Min=%.2f, Max=%.2f\n', ...
    mean(sensor_data.ph), std(sensor_data.ph), ...
    min(sensor_data.ph), max(sensor_data.ph));

fprintf('Electrical Conductivity: Mean=%.2f dS/m, Std=%.2f dS/m, Min=%.2f dS/m, Max=%.2f dS/m\n', ...
    mean(sensor_data.electrical_conductivity), std(sensor_data.electrical_conductivity), ...
    min(sensor_data.electrical_conductivity), max(sensor_data.electrical_conductivity));

% Create time series visualization
figure('Name', 'Sensor Data Time Series', 'Position', [200, 200, 1200, 800]);

subplot(2, 3, 1);
plot(sensor_data.timestamp, sensor_data.soil_moisture);
title('Soil Moisture');
ylabel('Moisture');
grid on;

subplot(2, 3, 2);
plot(sensor_data.timestamp, sensor_data.soil_temperature);
title('Soil Temperature');
ylabel('Temperature (°C)');
grid on;

subplot(2, 3, 3);
plot(sensor_data.timestamp, sensor_data.air_temperature);
title('Air Temperature');
ylabel('Temperature (°C)');
grid on;

subplot(2, 3, 4);
plot(sensor_data.timestamp, sensor_data.humidity);
title('Humidity');
ylabel('Humidity (%)');
grid on;

subplot(2, 3, 5);
plot(sensor_data.timestamp, sensor_data.ph);
title('pH');
ylabel('pH');
grid on;

subplot(2, 3, 6);
plot(sensor_data.timestamp, sensor_data.electrical_conductivity);
title('Electrical Conductivity');
ylabel('EC (dS/m)');
grid on;

fprintf('\nExample 5 completed.\n\n');

%% Example 6: Pest Risk Analysis
fprintf('Example 6: Pest Risk Analysis\n');
fprintf('=============================\n');

% Generate sample data
multispectral_data = generateSampleMultispectralData(64, 64, 8);
sensor_data = generateSampleSensorData();

% Process data
spectral_processor = SpectralImageProcessor();
processed_spectral = spectral_processor.processImage(multispectral_data);

crop_analyzer = CropHealthAnalyzer();
crop_health = crop_analyzer.analyzeHealth(processed_spectral);

pest_detector = PestRiskDetector();
pest_risks = pest_detector.detectRisks(processed_spectral, crop_health);

% Display pest risk results
fprintf('Pest Risk Analysis Results:\n');
fprintf('Overall Risk: %s (Score: %.2f)\n', ...
    pest_risks.overall_risk.level, pest_risks.overall_risk.score);

fprintf('\nEnvironmental Risk Factors:\n');
fprintf('Temperature Risk: %.2f (%s)\n', ...
    pest_risks.environmental_analysis.temperature_analysis.risk_level, ...
    pest_risks.environmental_analysis.temperature_analysis.status);

fprintf('Humidity Risk: %.2f (%s)\n', ...
    pest_risks.environmental_analysis.humidity_analysis.risk_level, ...
    pest_risks.environmental_analysis.humidity_analysis.status);

fprintf('Moisture Risk: %.2f (%s)\n', ...
    pest_risks.environmental_analysis.moisture_analysis.risk_level, ...
    pest_risks.environmental_analysis.moisture_analysis.status);

fprintf('Light Risk: %.2f (%s)\n', ...
    pest_risks.environmental_analysis.light_analysis.risk_level, ...
    pest_risks.environmental_analysis.light_analysis.status);

fprintf('\nSpecific Pest Risks:\n');
pest_types = {'aphids', 'whiteflies', 'thrips', 'spider_mites', 'caterpillars'};
for i = 1:length(pest_types)
    pest_type = pest_types{i};
    pest_info = pest_risks.pest_detection.(pest_type);
    fprintf('%s: %.2f (%s)\n', ...
        pest_info.type, pest_info.risk_score, pest_info.status);
end

fprintf('\nExample 6 completed.\n\n');

%% Example 7: Report Generation
fprintf('Example 7: Report Generation\n');
fprintf('============================\n');

% Generate sample data
multispectral_data = generateSampleMultispectralData(64, 64, 8);
sensor_data = generateSampleSensorData();

% Process data
spectral_processor = SpectralImageProcessor();
processed_spectral = spectral_processor.processImage(multispectral_data);

crop_analyzer = CropHealthAnalyzer();
crop_health = crop_analyzer.analyzeHealth(processed_spectral);

soil_analyzer = SoilConditionAnalyzer();
soil_condition = soil_analyzer.assessCondition(processed_spectral, sensor_data);

pest_detector = PestRiskDetector();
pest_risks = pest_detector.detectRisks(processed_spectral, crop_health);

% Generate comprehensive report
config = loadConfiguration();
report_generator = ReportGenerator();
report = report_generator.generateReport(crop_health, soil_condition, pest_risks, config);

% Display report summary
fprintf('Report Generation Results:\n');
fprintf('Report ID: %s\n', report.report_id);
fprintf('Analysis Date: %s\n', datestr(report.timestamp));
fprintf('Overall Assessment: %s (Score: %.2f)\n', ...
    report.executive_summary.overall_assessment.status, ...
    report.executive_summary.overall_assessment.score);

fprintf('\nKey Findings:\n');
for i = 1:length(report.executive_summary.key_findings)
    fprintf('• %s\n', report.executive_summary.key_findings{i});
end

fprintf('\nPriority Actions:\n');
for i = 1:length(report.executive_summary.priority_actions)
    fprintf('• %s\n', report.executive_summary.priority_actions{i});
end

fprintf('\nExample 7 completed.\n\n');

%% Example 8: Batch Processing
fprintf('Example 8: Batch Processing\n');
fprintf('===========================\n');

% Simulate processing multiple datasets
num_datasets = 3;
results = cell(num_datasets, 1);

for i = 1:num_datasets
    fprintf('Processing dataset %d of %d...\n', i, num_datasets);
    
    % Generate different sample data for each dataset
    multispectral_data = generateSampleMultispectralData(32, 32, 8);
    sensor_data = generateSampleSensorData();
    
    % Process data
    spectral_processor = SpectralImageProcessor();
    processed_spectral = spectral_processor.processImage(multispectral_data);
    
    crop_analyzer = CropHealthAnalyzer();
    crop_health = crop_analyzer.analyzeHealth(processed_spectral);
    
    % Store results
    results{i} = struct();
    results{i}.dataset_id = i;
    results{i}.crop_health_score = crop_health.overall_health.score;
    results{i}.crop_health_status = crop_health.overall_health.status;
    results{i}.ndvi_mean = crop_health.ndvi_analysis.mean;
    results{i}.gndvi_mean = crop_health.gndvi_analysis.mean;
end

% Display batch processing results
fprintf('\nBatch Processing Results:\n');
fprintf('Dataset\tHealth Score\tStatus\t\tNDVI\tGNDVI\n');
fprintf('-------\t------------\t------\t\t----\t-----\n');
for i = 1:num_datasets
    fprintf('%d\t%.2f\t\t%s\t\t%.3f\t%.3f\n', ...
        results{i}.dataset_id, results{i}.crop_health_score, ...
        results{i}.crop_health_status, results{i}.ndvi_mean, results{i}.gndvi_mean);
end

fprintf('\nExample 8 completed.\n\n');

%% Summary
fprintf('=== All Examples Completed ===\n');
fprintf('The AI-Powered Agricultural Monitoring System has been demonstrated\n');
fprintf('with various usage scenarios. Check the results directory for saved files.\n\n');

fprintf('Key Features Demonstrated:\n');
fprintf('• Complete agricultural monitoring analysis\n');
fprintf('• Custom configuration management\n');
fprintf('• Individual module usage\n');
fprintf('• Vegetation index analysis\n');
fprintf('• Soil parameter analysis\n');
fprintf('• Pest risk assessment\n');
fprintf('• Comprehensive report generation\n');
fprintf('• Batch processing capabilities\n\n');

fprintf('For more information, refer to the README.md file and documentation.\n');
