function displayResults(crop_health, soil_condition, pest_risks, report)
%% Display Analysis Results
% Displays comprehensive results from agricultural monitoring analysis

fprintf('\n=== AGRICULTURAL MONITORING RESULTS ===\n\n');

%% Display Executive Summary
fprintf('EXECUTIVE SUMMARY\n');
fprintf('================\n');
fprintf('Report ID: %s\n', report.report_id);
fprintf('Analysis Date: %s\n', datestr(report.timestamp));
fprintf('Overall Assessment: %s (Score: %.2f)\n', ...
    report.executive_summary.overall_assessment.status, ...
    report.executive_summary.overall_assessment.score);
fprintf('Risk Level: %s\n', report.executive_summary.risk_assessment.level);
fprintf('\n');

%% Display Key Findings
fprintf('KEY FINDINGS\n');
fprintf('============\n');
for i = 1:length(report.executive_summary.key_findings)
    fprintf('• %s\n', report.executive_summary.key_findings{i});
end
fprintf('\n');

%% Display Priority Actions
fprintf('PRIORITY ACTIONS\n');
fprintf('================\n');
for i = 1:length(report.executive_summary.priority_actions)
    fprintf('• %s\n', report.executive_summary.priority_actions{i});
end
fprintf('\n');

%% Display Crop Health Results
fprintf('CROP HEALTH ANALYSIS\n');
fprintf('====================\n');
fprintf('Overall Health: %s (Score: %.2f)\n', ...
    crop_health.overall_health.status, crop_health.overall_health.score);
fprintf('Confidence: %.2f\n', crop_health.overall_health.confidence);
fprintf('\n');

fprintf('Vegetation Indices:\n');
fprintf('  NDVI: %.3f (%s)\n', crop_health.ndvi_analysis.mean, crop_health.ndvi_analysis.health_status);
fprintf('  GNDVI: %.3f (%s)\n', crop_health.gndvi_analysis.mean, crop_health.gndvi_analysis.health_status);
fprintf('  NDRE: %.3f (%s)\n', crop_health.ndre_analysis.mean, crop_health.ndre_analysis.health_status);
fprintf('  SAVI: %.3f (%s)\n', crop_health.savi_analysis.mean, crop_health.savi_analysis.health_status);
fprintf('  EVI: %.3f (%s)\n', crop_health.evi_analysis.mean, crop_health.evi_analysis.health_status);
fprintf('\n');

fprintf('Health Distribution:\n');
fprintf('  Healthy: %.1f%%\n', crop_health.ndvi_analysis.healthy_percentage);
fprintf('  Stressed: %.1f%%\n', crop_health.ndvi_analysis.stressed_percentage);
fprintf('  Unhealthy: %.1f%%\n', crop_health.ndvi_analysis.unhealthy_percentage);
fprintf('\n');

fprintf('Stress Patterns:\n');
fprintf('  Water Stress: %.1f%%\n', crop_health.stress_patterns.water_stress_percentage);
fprintf('  Nutrient Stress: %.1f%%\n', crop_health.stress_patterns.nutrient_stress_percentage);
fprintf('  Chlorophyll Stress: %.1f%%\n', crop_health.stress_patterns.chlorophyll_stress_percentage);
fprintf('  Overall Stress: %.1f%%\n', crop_health.stress_patterns.overall_stress_percentage);
fprintf('\n');

%% Display Soil Condition Results
fprintf('SOIL CONDITION ANALYSIS\n');
fprintf('=======================\n');
fprintf('Overall Health: %s (Score: %.2f)\n', ...
    soil_condition.health_assessment.status, soil_condition.health_assessment.overall_score);
fprintf('\n');

fprintf('Soil Parameters:\n');
fprintf('  Moisture: %.3f (%s)\n', ...
    soil_condition.moisture_analysis.sensor_moisture_mean, ...
    soil_condition.moisture_analysis.moisture_classification.level);
fprintf('  Temperature: %.1f°C (%s)\n', ...
    soil_condition.temperature_analysis.mean_temperature, ...
    soil_condition.temperature_analysis.temperature_classification.level);
fprintf('  pH: %.2f (%s)\n', ...
    soil_condition.ph_analysis.mean_ph, ...
    soil_condition.ph_analysis.ph_classification.level);
fprintf('  EC: %.2f dS/m (%s)\n', ...
    soil_condition.ec_analysis.mean_ec, ...
    soil_condition.ec_analysis.ec_classification.level);
fprintf('\n');

fprintf('Soil Type Analysis:\n');
fprintf('  Dominant Type: %s\n', soil_condition.soil_type_analysis.dominant_type);
fprintf('  Clay: %.1f%%\n', soil_condition.soil_type_analysis.percentage_clay);
fprintf('  Silt: %.1f%%\n', soil_condition.soil_type_analysis.percentage_silt);
fprintf('  Sand: %.1f%%\n', soil_condition.soil_type_analysis.percentage_sand);
fprintf('  Loam: %.1f%%\n', soil_condition.soil_type_analysis.percentage_loam);
fprintf('  Organic: %.1f%%\n', soil_condition.soil_type_analysis.percentage_organic);
fprintf('\n');

fprintf('Quality Index: %.2f (%s)\n', ...
    soil_condition.quality_index.value, soil_condition.quality_index.level);
fprintf('\n');

%% Display Pest Risk Results
fprintf('PEST RISK ANALYSIS\n');
fprintf('==================\n');
fprintf('Overall Risk: %s (Score: %.2f)\n', ...
    pest_risks.overall_risk.level, pest_risks.overall_risk.score);
fprintf('Confidence: %.2f\n', pest_risks.overall_risk.confidence);
fprintf('\n');

fprintf('Environmental Risk Factors:\n');
fprintf('  Temperature Risk: %.2f (%s)\n', ...
    pest_risks.environmental_analysis.temperature_analysis.risk_level, ...
    pest_risks.environmental_analysis.temperature_analysis.status);
fprintf('  Humidity Risk: %.2f (%s)\n', ...
    pest_risks.environmental_analysis.humidity_analysis.risk_level, ...
    pest_risks.environmental_analysis.humidity_analysis.status);
fprintf('  Moisture Risk: %.2f (%s)\n', ...
    pest_risks.environmental_analysis.moisture_analysis.risk_level, ...
    pest_risks.environmental_analysis.moisture_analysis.status);
fprintf('  Light Risk: %.2f (%s)\n', ...
    pest_risks.environmental_analysis.light_analysis.risk_level, ...
    pest_risks.environmental_analysis.light_analysis.status);
fprintf('\n');

fprintf('Specific Pest Risks:\n');
pest_types = {'aphids', 'whiteflies', 'thrips', 'spider_mites', 'caterpillars'};
for i = 1:length(pest_types)
    pest_type = pest_types{i};
    field_name = lower(strrep(pest_type, ' ', '_'));
    if isfield(pest_risks.pest_detection, field_name)
        pest_info = pest_risks.pest_detection.(field_name);
        fprintf('  %s: %.2f (%s)\n', ...
            pest_info.type, pest_info.risk_score, pest_info.status);
    end
end
fprintf('\n');

fprintf('Pest Presence: %s\n', pest_risks.pest_detection.overall_pest_presence.status);
fprintf('High Risk Pests: %d\n', pest_risks.pest_detection.overall_pest_presence.high_risk_pests);
fprintf('\n');

%% Display Recommendations
fprintf('RECOMMENDATIONS\n');
fprintf('===============\n');

fprintf('Crop Health Recommendations:\n');
for i = 1:length(report.recommendations_section.crop_health)
    fprintf('• %s\n', report.recommendations_section.crop_health{i});
end
fprintf('\n');

fprintf('Soil Condition Recommendations:\n');
for i = 1:length(report.recommendations_section.soil_condition)
    fprintf('• %s\n', report.recommendations_section.soil_condition{i});
end
fprintf('\n');

fprintf('Pest Management Recommendations:\n');
for i = 1:length(report.recommendations_section.pest_management)
    fprintf('• %s\n', report.recommendations_section.pest_management{i});
end
fprintf('\n');

fprintf('Integrated Recommendations:\n');
for i = 1:length(report.recommendations_section.integrated)
    fprintf('• %s\n', report.recommendations_section.integrated{i});
end
fprintf('\n');

%% Display Technical Summary
fprintf('TECHNICAL SUMMARY\n');
fprintf('=================\n');
fprintf('Analysis Confidence: %.2f\n', report.summary.key_metrics.overall_assessment_score);
fprintf('Data Quality: %s\n', report.summary.completeness.data_quality);
fprintf('Sections Completed: %d\n', report.summary.completeness.sections_completed);
fprintf('\n');

%% Create Visualization Figures
createVisualizationFigures(crop_health, soil_condition, pest_risks);

fprintf('=== END OF RESULTS ===\n\n');

end

function createVisualizationFigures(crop_health, soil_condition, pest_risks)
%% Create Visualization Figures

results_dir = 'results'; % Directory to save results
if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

    % --- Save Soil Condition Map ---
    figure('Visible', 'off');
    imagesc(soil_condition.moisture_map.data);
    title('Soil Condition Map');
    colormap(parula);
    colorbar;
    axis equal; axis off;
    saveas(gcf, fullfile(results_dir, 'soil_condition_map.png'));
    close(gcf);% --- Save NDVI Map ---
figure('Visible', 'off');
imagesc(crop_health.ndvi_map);
title('NDVI Map');
colormap(jet);
colorbar;
axis equal; axis off;
saveas(gcf, fullfile(results_dir, 'ndvi_map.png'));
close(gcf);

% --- Save GNDVI Map ---
figure('Visible', 'off');
imagesc(crop_health.gndvi_map);
title('GNDVI Map');
colormap(jet);
colorbar;
axis equal; axis off;
saveas(gcf, fullfile(results_dir, 'gndvi_map.png'));
close(gcf);

% --- Save NDRE Map ---
figure('Visible', 'off');
imagesc(crop_health.ndre_map);
title('NDRE Map');
colormap(jet);
colorbar;
axis equal; axis off;
saveas(gcf, fullfile(results_dir, 'ndre_map.png'));
close(gcf);

% --- Save SAVI Map ---
figure('Visible', 'off');
imagesc(crop_health.savi_map);
title('SAVI Map');
colormap(jet);
colorbar;
axis equal; axis off;
saveas(gcf, fullfile(results_dir, 'savi_map.png'));
close(gcf);

% --- Save EVI Map ---
figure('Visible', 'off');
imagesc(crop_health.evi_map);
title('EVI Map');
colormap(jet);
colorbar;
axis equal; axis off;
saveas(gcf, fullfile(results_dir, 'evi_map.png'));
close(gcf);

% --- Save Crop Health Map ---
figure('Visible', 'off');
imagesc(crop_health.health_map.data);
title('Crop Health Map');
% Custom colormap: 1=Red (Unhealthy), 2=Yellow (Stressed), 3=Green (Healthy)
colormap([1 0 0; 1 1 0; 0 1 0]); 
caxis([1 3]); % Set color axis limits
colorbar('Ticks', [1.33, 2, 2.67], 'TickLabels', {'Unhealthy', 'Stressed', 'Healthy'});
axis equal; axis off;
saveas(gcf, fullfile(results_dir, 'crop_health_map.png'));
close(gcf);

% --- Save Pest Risk Map (RGB discrete levels) ---
if isfield(pest_risks, 'risk_map') && isfield(pest_risks.risk_map, 'rgb')
    figure('Visible', 'off');
    image(pest_risks.risk_map.rgb);
    title('Pest Risk Map');
    axis equal; axis off;
    saveas(gcf, fullfile(results_dir, 'pest_risk_map.png'));
    close(gcf);
end

% --- Save Pest Risk Score Map (continuous 0..1) ---
if isfield(pest_risks, 'risk_map') && isfield(pest_risks.risk_map, 'score')
    figure('Visible', 'off');
    imagesc(pest_risks.risk_map.score, [0 1]);
    title('Pest Risk Score Map');
    colormap(jet);
    colorbar;
    axis equal; axis off;
    saveas(gcf, fullfile(results_dir, 'pest_risk_score_map.png'));
    close(gcf);
end

fprintf('All visualization maps have been saved to the ''results'' directory.\n');
end