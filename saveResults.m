function saveResults(crop_health, soil_condition, pest_risks, report)
%% Save Analysis Results
% Saves all analysis results to files for future reference

fprintf('Saving analysis results...\n');

% Create results directory if it doesn't exist
if ~exist('results', 'dir')
    mkdir('results');
end

% Create timestamp for file naming
timestamp = datestr(now, 'yyyymmdd_HHMMSS');

%% Save Individual Analysis Results
% Save crop health results
crop_health_file = sprintf('results/crop_health_%s.mat', timestamp);
save(crop_health_file, 'crop_health');
fprintf('Crop health results saved to: %s\n', crop_health_file);

% Save soil condition results
soil_condition_file = sprintf('results/soil_condition_%s.mat', timestamp);
save(soil_condition_file, 'soil_condition');
fprintf('Soil condition results saved to: %s\n', soil_condition_file);

% Save pest risk results
pest_risks_file = sprintf('results/pest_risks_%s.mat', timestamp);
save(pest_risks_file, 'pest_risks');
fprintf('Pest risk results saved to: %s\n', pest_risks_file);

% Save comprehensive report
report_file = sprintf('results/comprehensive_report_%s.mat', timestamp);
save(report_file, 'report');
fprintf('Comprehensive report saved to: %s\n', report_file);

%% Save Combined Results
combined_results = struct();
combined_results.timestamp = datetime('now');
combined_results.crop_health = crop_health;
combined_results.soil_condition = soil_condition;
combined_results.pest_risks = pest_risks;
combined_results.report = report;

combined_file = sprintf('results/combined_results_%s.mat', timestamp);
save(combined_file, 'combined_results');
fprintf('Combined results saved to: %s\n', combined_file);

%% Save Summary Data as CSV
saveSummaryCSV(crop_health, soil_condition, pest_risks, report, timestamp);

%% Save Visualization Data
saveVisualizationData(crop_health, soil_condition, pest_risks, timestamp);

%% Save Configuration and Metadata
saveMetadata(timestamp);

fprintf('All results saved successfully!\n');

end

function saveSummaryCSV(crop_health, soil_condition, pest_risks, report, timestamp)
%% Save Summary Data as CSV

% Create summary data structure
summary_data = struct();

% Crop health summary
summary_data.crop_health_overall_score = crop_health.overall_health.score;
summary_data.crop_health_status = crop_health.overall_health.status;
summary_data.crop_health_confidence = crop_health.overall_health.confidence;
summary_data.ndvi_mean = crop_health.ndvi_analysis.mean;
summary_data.gndvi_mean = crop_health.gndvi_analysis.mean;
summary_data.ndre_mean = crop_health.ndre_analysis.mean;
summary_data.savi_mean = crop_health.savi_analysis.mean;
summary_data.evi_mean = crop_health.evi_analysis.mean;
summary_data.healthy_percentage = crop_health.ndvi_analysis.healthy_percentage;
summary_data.stressed_percentage = crop_health.ndvi_analysis.stressed_percentage;
summary_data.unhealthy_percentage = crop_health.ndvi_analysis.unhealthy_percentage;
summary_data.water_stress_percentage = crop_health.stress_patterns.water_stress_percentage;
summary_data.nutrient_stress_percentage = crop_health.stress_patterns.nutrient_stress_percentage;
summary_data.chlorophyll_stress_percentage = crop_health.stress_patterns.chlorophyll_stress_percentage;

% Soil condition summary
summary_data.soil_health_overall_score = soil_condition.health_assessment.overall_score;
summary_data.soil_health_status = soil_condition.health_assessment.status;
summary_data.soil_moisture_mean = soil_condition.moisture_analysis.sensor_moisture_mean;
summary_data.soil_moisture_status = soil_condition.moisture_analysis.moisture_classification.level;
summary_data.soil_temperature_mean = soil_condition.temperature_analysis.mean_temperature;
summary_data.soil_temperature_status = soil_condition.temperature_analysis.temperature_classification.level;
summary_data.soil_ph_mean = soil_condition.ph_analysis.mean_ph;
summary_data.soil_ph_status = soil_condition.ph_analysis.ph_classification.level;
summary_data.soil_ec_mean = soil_condition.ec_analysis.mean_ec;
summary_data.soil_ec_status = soil_condition.ec_analysis.ec_classification.level;
summary_data.soil_quality_index = soil_condition.quality_index.value;
summary_data.soil_quality_level = soil_condition.quality_index.level;
summary_data.dominant_soil_type = soil_condition.soil_type_analysis.dominant_type;

% Pest risk summary
summary_data.pest_risk_overall_score = pest_risks.overall_risk.score;
summary_data.pest_risk_level = pest_risks.overall_risk.level;
summary_data.pest_risk_confidence = pest_risks.overall_risk.confidence;
summary_data.temperature_risk = pest_risks.environmental_analysis.temperature_analysis.risk_level;
summary_data.humidity_risk = pest_risks.environmental_analysis.humidity_analysis.risk_level;
summary_data.moisture_risk = pest_risks.environmental_analysis.moisture_analysis.risk_level;
summary_data.light_risk = pest_risks.environmental_analysis.light_analysis.risk_level;
summary_data.aphid_risk = pest_risks.pest_detection.aphids.risk_score;
summary_data.whitefly_risk = pest_risks.pest_detection.whiteflies.risk_score;
summary_data.thrip_risk = pest_risks.pest_detection.thrips.risk_score;
summary_data.mite_risk = pest_risks.pest_detection.spider_mites.risk_score;
summary_data.caterpillar_risk = pest_risks.pest_detection.caterpillars.risk_score;

% Overall assessment
summary_data.overall_assessment_score = report.executive_summary.overall_assessment.score;
summary_data.overall_assessment_status = report.executive_summary.overall_assessment.status;
summary_data.overall_risk_level = report.executive_summary.risk_assessment.level;

% Convert to table and save as CSV
field_names = fieldnames(summary_data);
values = struct2cell(summary_data);
summary_table = table(field_names, values, 'VariableNames', {'Parameter', 'Value'});

csv_file = sprintf('results/summary_%s.csv', timestamp);
writetable(summary_table, csv_file);
fprintf('Summary data saved to: %s\n', csv_file);

end

function saveVisualizationData(crop_health, soil_condition, pest_risks, timestamp)
%% Save Visualization Data

% Save health maps as images
if isfield(crop_health, 'health_map') && isfield(crop_health.health_map, 'rgb')
    health_map_file = sprintf('results/crop_health_map_%s.png', timestamp);
    imwrite(crop_health.health_map.rgb, health_map_file);
    fprintf('Crop health map saved to: %s\n', health_map_file);
end

if isfield(soil_condition, 'condition_map') && isfield(soil_condition.condition_map, 'rgb')
    soil_map_file = sprintf('results/soil_condition_map_%s.png', timestamp);
    imwrite(soil_condition.condition_map.rgb, soil_map_file);
    fprintf('Soil condition map saved to: %s\n', soil_map_file);
end

if isfield(pest_risks, 'risk_map') && isfield(pest_risks.risk_map, 'rgb')
    risk_map_file = sprintf('results/pest_risk_map_%s.png', timestamp);
    imwrite(pest_risks.risk_map.rgb, risk_map_file);
    fprintf('Pest risk map saved to: %s\n', risk_map_file);
end

% Save vegetation indices as images
if isfield(crop_health, 'vegetation_indices')
    indices_file = sprintf('results/vegetation_indices_%s.mat', timestamp);
    save(indices_file, 'crop_health');
    fprintf('Vegetation indices saved to: %s\n', indices_file);
end

end

function saveMetadata(timestamp)
%% Save Metadata and Configuration

metadata = struct();
metadata.analysis_timestamp = datetime('now');
metadata.matlab_version = version;
metadata.system_info = computer;
metadata.analysis_type = 'AI-Powered Agricultural Monitoring';
metadata.version = '1.0';
metadata.description = 'Comprehensive agricultural monitoring using multispectral imaging and sensor data';

% Save metadata
metadata_file = sprintf('results/metadata_%s.mat', timestamp);
save(metadata_file, 'metadata');
fprintf('Metadata saved to: %s\n', metadata_file);

% Create README file
readme_file = sprintf('results/README_%s.txt', timestamp);
fid = fopen(readme_file, 'w');
fprintf(fid, 'Agricultural Monitoring Analysis Results\n');
fprintf(fid, '=======================================\n\n');
fprintf(fid, 'Analysis Date: %s\n', datestr(now));
fprintf(fid, 'Analysis Type: AI-Powered Agricultural Monitoring\n');
fprintf(fid, 'Version: 1.0\n\n');
fprintf(fid, 'Files Description:\n');
fprintf(fid, '- crop_health_*.mat: Crop health analysis results\n');
fprintf(fid, '- soil_condition_*.mat: Soil condition analysis results\n');
fprintf(fid, '- pest_risks_*.mat: Pest risk analysis results\n');
fprintf(fid, '- comprehensive_report_*.mat: Complete analysis report\n');
fprintf(fid, '- combined_results_*.mat: All results combined\n');
fprintf(fid, '- summary_*.csv: Summary data in CSV format\n');
fprintf(fid, '- *_map_*.png: Visualization maps\n');
fprintf(fid, '- metadata_*.mat: Analysis metadata\n');
fprintf(fid, '- README_*.txt: This file\n\n');
fprintf(fid, 'For questions or support, contact the development team.\n');
fclose(fid);
fprintf('README file saved to: %s\n', readme_file);

end
