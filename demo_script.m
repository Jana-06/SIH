%% Demo Script for AI-Powered Agricultural Monitoring System
% This script provides a quick demonstration of the system capabilities

clear; clc; close all;

fprintf('=== AI-Powered Agricultural Monitoring System Demo ===\n\n');

%% Step 1: Generate Sample Data
fprintf('Step 1: Generating sample data...\n');
multispectral_data = generateSampleMultispectralData(128, 128, 8);
sensor_data = generateSampleSensorData();
fprintf('Sample data generated successfully.\n\n');

%% Step 2: Process Spectral Data
fprintf('Step 2: Processing multispectral data...\n');
spectral_processor = SpectralImageProcessor();
processed_spectral = spectral_processor.processImage(multispectral_data);
fprintf('Spectral processing completed.\n\n');

%% Step 3: Analyze Crop Health
fprintf('Step 3: Analyzing crop health...\n');
crop_analyzer = CropHealthAnalyzer();
crop_health = crop_analyzer.analyzeHealth(processed_spectral);
fprintf('Crop health analysis completed.\n\n');

%% Step 4: Assess Soil Condition
fprintf('Step 4: Assessing soil condition...\n');
soil_analyzer = SoilConditionAnalyzer();
soil_condition = soil_analyzer.assessCondition(processed_spectral, sensor_data);
fprintf('Soil condition assessment completed.\n\n');

%% Step 5: Detect Pest Risks
fprintf('Step 5: Detecting pest risks...\n');
pest_detector = PestRiskDetector();
pest_risks = pest_detector.detectRisks(processed_spectral, crop_health);
fprintf('Pest risk detection completed.\n\n');

%% Step 6: Generate Report
fprintf('Step 6: Generating comprehensive report...\n');
config = loadConfiguration();
report_generator = ReportGenerator();
report = report_generator.generateReport(crop_health, soil_condition, pest_risks, config);
fprintf('Report generation completed.\n\n');

%% Step 7: Display Results
fprintf('Step 7: Displaying results...\n');
displayResults(crop_health, soil_condition, pest_risks, report);
fprintf('Results display completed.\n\n');

%% Step 8: Save Results
fprintf('Step 8: Saving results...\n');
saveResults(crop_health, soil_condition, pest_risks, report);
fprintf('Results saved successfully.\n\n');

%% Demo Summary
fprintf('=== Demo Summary ===\n');
fprintf('Crop Health: %s (Score: %.2f)\n', ...
    crop_health.overall_health.status, crop_health.overall_health.score);
fprintf('Soil Condition: %s (Score: %.2f)\n', ...
    soil_condition.health_assessment.status, soil_condition.health_assessment.overall_score);
fprintf('Pest Risk: %s (Score: %.2f)\n', ...
    pest_risks.overall_risk.level, pest_risks.overall_risk.score);
fprintf('Overall Assessment: %s (Score: %.2f)\n', ...
    report.executive_summary.overall_assessment.status, ...
    report.executive_summary.overall_assessment.score);

fprintf('\nDemo completed successfully!\n');
fprintf('Check the results directory for saved files and visualizations.\n');
