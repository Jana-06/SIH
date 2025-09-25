classdef ReportGenerator < handle
    %% Report Generator
    % Generates comprehensive reports from analysis results
    
    methods
        function report = generateReport(obj, crop_health, soil_condition, pest_risks, config)
            %% Generate Comprehensive Report
            % Input: crop_health - crop health analysis results
            %        soil_condition - soil condition analysis results
            %        pest_risks - pest risk analysis results
            %        config - configuration parameters
            % Output: report - comprehensive report structure
            
            fprintf('Generating comprehensive report...\n');
            
            % Initialize report structure
            report = struct();
            report.timestamp = datetime('now');
            report.report_id = obj.generateReportID();
            
            % Executive summary
            report.executive_summary = obj.generateExecutiveSummary(crop_health, soil_condition, pest_risks);
            
            % Crop health section
            report.crop_health_section = obj.generateCropHealthSection(crop_health);
            
            % Soil condition section
            report.soil_condition_section = obj.generateSoilConditionSection(soil_condition);
            
            % Pest risk section
            report.pest_risk_section = obj.generatePestRiskSection(pest_risks);
            
            % Recommendations section
            report.recommendations_section = obj.generateRecommendationsSection(crop_health, soil_condition, pest_risks);
            
            % Technical details section
            report.technical_details = obj.generateTechnicalDetails(crop_health, soil_condition, pest_risks, config);
            
            % Generate report summary
            report.summary = obj.generateReportSummary(report);
            
            fprintf('Report generation completed.\n');
        end
        
        function report_id = generateReportID(obj)
            %% Generate Unique Report ID
            timestamp = datetime('now');
            report_id = sprintf('AGR_%s_%s', ...
                datestr(timestamp, 'yyyymmdd'), ...
                datestr(timestamp, 'HHMMSS'));
        end
        
        function executive_summary = generateExecutiveSummary(obj, crop_health, soil_condition, pest_risks)
            %% Generate Executive Summary
            executive_summary = struct();
            
            % Overall assessment
            executive_summary.overall_assessment = obj.calculateOverallAssessment(crop_health, soil_condition, pest_risks);
            
            % Key findings
            executive_summary.key_findings = obj.extractKeyFindings(crop_health, soil_condition, pest_risks);
            
            % Priority actions
            executive_summary.priority_actions = obj.identifyPriorityActions(crop_health, soil_condition, pest_risks);
            
            % Risk assessment
            executive_summary.risk_assessment = obj.assessOverallRisk(crop_health, soil_condition, pest_risks);
        end
        
        function overall_assessment = calculateOverallAssessment(obj, crop_health, soil_condition, pest_risks)
            %% Calculate Overall Assessment
            overall_assessment = struct();
            
            % Collect individual scores
            crop_score = crop_health.overall_health.score;
            soil_score = soil_condition.health_assessment.overall_score;
            pest_score = 1 - pest_risks.overall_risk.score; % Invert pest risk to get health score
            
            % Ensure all scores are scalars
            if ~isscalar(crop_score)
                crop_score = mean(crop_score(:));
            end
            if ~isscalar(soil_score)
                soil_score = mean(soil_score(:));
            end
            if ~isscalar(pest_score)
                pest_score = mean(pest_score(:));
            end
            
            % Calculate weighted overall score
            weights = [0.4, 0.3, 0.3]; % Crop, Soil, Pest (inverted)
            scores = [crop_score, soil_score, pest_score];
            overall_assessment.score = sum(weights .* scores);
            
            % Determine overall status
            if overall_assessment.score >= 0.8
                overall_assessment.status = 'Excellent';
                overall_assessment.description = 'Agricultural conditions are optimal for crop production';
            elseif overall_assessment.score >= 0.6
                overall_assessment.status = 'Good';
                overall_assessment.description = 'Agricultural conditions are generally favorable with minor issues';
            elseif overall_assessment.score >= 0.4
                overall_assessment.status = 'Fair';
                overall_assessment.description = 'Agricultural conditions require attention and management';
            else
                overall_assessment.status = 'Poor';
                overall_assessment.description = 'Agricultural conditions require immediate intervention';
            end
            
            % Component scores
            overall_assessment.component_scores = struct();
            overall_assessment.component_scores.crop_health = crop_score;
            overall_assessment.component_scores.soil_condition = soil_score;
            overall_assessment.component_scores.pest_management = pest_score;
        end
        
        function key_findings = extractKeyFindings(obj, crop_health, soil_condition, pest_risks)
            %% Extract Key Findings
            key_findings = {};
            
            % Crop health findings
            if crop_health.overall_health.score < 0.6
                key_findings{end+1} = sprintf('Crop health is %s (Score: %.2f)', ...
                    crop_health.overall_health.status, crop_health.overall_health.score);
            end
            
            % Soil condition findings
            if soil_condition.health_assessment.overall_score < 0.6
                key_findings{end+1} = sprintf('Soil condition is %s (Score: %.2f)', ...
                    soil_condition.health_assessment.status, soil_condition.health_assessment.overall_score);
            end
            
            % Pest risk findings
            if pest_risks.overall_risk.score > 0.6
                key_findings{end+1} = sprintf('High pest risk detected (%s level)', ...
                    pest_risks.overall_risk.level);
            end
            
            % Stress pattern findings
            if crop_health.stress_patterns.overall_stress_percentage > 20
                key_findings{end+1} = sprintf('Significant stress patterns detected (%.1f%% of area)', ...
                    crop_health.stress_patterns.overall_stress_percentage);
            end
            
            % Soil moisture findings
            if soil_condition.moisture_analysis.moisture_classification.score < 0.6
                key_findings{end+1} = sprintf('Soil moisture is %s', ...
                    soil_condition.moisture_analysis.moisture_classification.level);
            end
            
            % Default finding if no issues
            if isempty(key_findings)
                key_findings{end+1} = 'All agricultural parameters are within normal ranges';
            end
        end
        
        function priority_actions = identifyPriorityActions(obj, crop_health, soil_condition, pest_risks)
            %% Identify Priority Actions
            priority_actions = {};
            
            % High priority actions
            if pest_risks.overall_risk.score > 0.8
                priority_actions{end+1} = 'URGENT: Implement immediate pest control measures';
            end
            
            if crop_health.overall_health.score < 0.3
                priority_actions{end+1} = 'URGENT: Address severe crop health issues';
            end
            
            if soil_condition.health_assessment.overall_score < 0.3
                priority_actions{end+1} = 'URGENT: Address critical soil condition issues';
            end
            
            % Medium priority actions
            if pest_risks.overall_risk.score > 0.6
                priority_actions{end+1} = 'HIGH: Implement preventive pest management';
            end
            
            if crop_health.overall_health.score < 0.6
                priority_actions{end+1} = 'HIGH: Improve crop health through targeted interventions';
            end
            
            if soil_condition.moisture_analysis.moisture_classification.score < 0.6
                priority_actions{end+1} = 'MEDIUM: Optimize irrigation management';
            end
            
            % Low priority actions
            if crop_health.overall_health.score < 0.8
                priority_actions{end+1} = 'LOW: Continue monitoring and fine-tune management practices';
            end
            
            % Default action
            if isempty(priority_actions)
                priority_actions{end+1} = 'Continue current management practices and regular monitoring';
            end
        end
        
        function risk_assessment = assessOverallRisk(obj, crop_health, soil_condition, pest_risks)
            %% Assess Overall Risk
            risk_assessment = struct();
            
            % Collect risk factors
            crop_risk = 1 - crop_health.overall_health.score;
            soil_risk = 1 - soil_condition.health_assessment.overall_score;
            pest_risk = pest_risks.overall_risk.score;
            
            % Ensure all risk scores are scalars
            if ~isscalar(crop_risk)
                crop_risk = mean(crop_risk(:));
            end
            if ~isscalar(soil_risk)
                soil_risk = mean(soil_risk(:));
            end
            if ~isscalar(pest_risk)
                pest_risk = mean(pest_risk(:));
            end
            
            % Calculate overall risk
            weights = [0.3, 0.2, 0.5]; % Crop, Soil, Pest
            risk_scores = [crop_risk, soil_risk, pest_risk];
            risk_assessment.overall_risk = sum(weights .* risk_scores);
            
            % Determine risk level
            if risk_assessment.overall_risk > 0.7
                risk_assessment.level = 'High';
                risk_assessment.description = 'Significant risk to crop production';
            elseif risk_assessment.overall_risk > 0.4
                risk_assessment.level = 'Medium';
                risk_assessment.description = 'Moderate risk requiring attention';
            else
                risk_assessment.level = 'Low';
                risk_assessment.description = 'Low risk with good management';
            end
            
            % Risk factors
            risk_assessment.risk_factors = struct();
            risk_assessment.risk_factors.crop_health_risk = crop_risk;
            risk_assessment.risk_factors.soil_condition_risk = soil_risk;
            risk_assessment.risk_factors.pest_risk = pest_risk;
        end
        
        function crop_health_section = generateCropHealthSection(obj, crop_health)
            %% Generate Crop Health Section
            crop_health_section = struct();
            
            % Overall health summary
            crop_health_section.overall_health = struct();
            crop_health_section.overall_health.status = crop_health.overall_health.status;
            crop_health_section.overall_health.score = crop_health.overall_health.score;
            crop_health_section.overall_health.confidence = crop_health.overall_health.confidence;
            
            % Vegetation index analysis
            crop_health_section.vegetation_indices = struct();
            crop_health_section.vegetation_indices.ndvi = crop_health.ndvi_analysis;
            crop_health_section.vegetation_indices.gndvi = crop_health.gndvi_analysis;
            crop_health_section.vegetation_indices.ndre = crop_health.ndre_analysis;
            crop_health_section.vegetation_indices.savi = crop_health.savi_analysis;
            crop_health_section.vegetation_indices.evi = crop_health.evi_analysis;
            
            % Stress patterns
            crop_health_section.stress_patterns = crop_health.stress_patterns;
            
            % Health statistics
            crop_health_section.health_statistics = crop_health.health_statistics;
            
            % Anomalies
            crop_health_section.anomalies = crop_health.anomalies;
        end
        
        function soil_condition_section = generateSoilConditionSection(obj, soil_condition)
            %% Generate Soil Condition Section
            soil_condition_section = struct();
            
            % Overall soil health
            soil_condition_section.overall_health = struct();
            soil_condition_section.overall_health.status = soil_condition.health_assessment.status;
            soil_condition_section.overall_health.score = soil_condition.health_assessment.overall_score;
            
            % Soil parameters
            soil_condition_section.parameters = struct();
            soil_condition_section.parameters.moisture = soil_condition.moisture_analysis;
            soil_condition_section.parameters.temperature = soil_condition.temperature_analysis;
            soil_condition_section.parameters.ph = soil_condition.ph_analysis;
            soil_condition_section.parameters.electrical_conductivity = soil_condition.ec_analysis;
            
            % Soil type analysis
            soil_condition_section.soil_type_analysis = soil_condition.soil_type_analysis;
            
            % Quality index
            soil_condition_section.quality_index = soil_condition.quality_index;
            
            % Anomalies
            soil_condition_section.anomalies = soil_condition.anomalies;
            
            % Recommendations
            soil_condition_section.recommendations = soil_condition.health_assessment.recommendations;
        end
        
        function pest_risk_section = generatePestRiskSection(obj, pest_risks)
            %% Generate Pest Risk Section
            pest_risk_section = struct();
            
            % Overall risk assessment
            pest_risk_section.overall_risk = pest_risks.overall_risk;
            
            % Spectral analysis
            pest_risk_section.spectral_analysis = pest_risks.spectral_analysis;
            
            % Environmental analysis
            pest_risk_section.environmental_analysis = pest_risks.environmental_analysis;
            
            % Specific pest detection
            pest_risk_section.pest_detection = pest_risks.pest_detection;
            
            % Risk map information
            pest_risk_section.risk_map = struct();
            pest_risk_section.risk_map.labels = pest_risks.risk_map.labels;
            pest_risk_section.risk_map.colors = pest_risks.risk_map.colors;
            
            % Recommendations
            pest_risk_section.recommendations = pest_risks.recommendations;
        end
        
        function recommendations_section = generateRecommendationsSection(obj, crop_health, soil_condition, pest_risks)
            %% Generate Recommendations Section
            recommendations_section = struct();
            
            % Crop health recommendations
            recommendations_section.crop_health = obj.generateCropHealthRecommendations(crop_health);
            
            % Soil condition recommendations
            recommendations_section.soil_condition = soil_condition.health_assessment.recommendations;
            
            % Pest management recommendations
            recommendations_section.pest_management = pest_risks.recommendations;
            
            % Integrated recommendations
            recommendations_section.integrated = obj.generateIntegratedRecommendations(crop_health, soil_condition, pest_risks);
        end
        
        function crop_recommendations = generateCropHealthRecommendations(obj, crop_health)
            %% Generate Crop Health Recommendations
            crop_recommendations = {};
            
            % Based on overall health
            if crop_health.overall_health.score < 0.6
                crop_recommendations{end+1} = 'Implement targeted fertilization program';
                crop_recommendations{end+1} = 'Optimize irrigation scheduling';
                crop_recommendations{end+1} = 'Consider crop rotation or intercropping';
            end
            
            % Based on stress patterns
            if crop_health.stress_patterns.water_stress_percentage > 30
                crop_recommendations{end+1} = 'Increase irrigation frequency in water-stressed areas';
            end
            
            if crop_health.stress_patterns.nutrient_stress_percentage > 30
                crop_recommendations{end+1} = 'Apply targeted nutrient supplementation';
            end
            
            if crop_health.stress_patterns.chlorophyll_stress_percentage > 30
                crop_recommendations{end+1} = 'Consider foliar nutrient application';
            end
            
            % Default recommendations
            if isempty(crop_recommendations)
                crop_recommendations{end+1} = 'Continue current crop management practices';
                crop_recommendations{end+1} = 'Maintain regular monitoring schedule';
            end
        end
        
        function integrated_recommendations = generateIntegratedRecommendations(obj, crop_health, soil_condition, pest_risks)
            %% Generate Integrated Recommendations
            integrated_recommendations = {};
            
            % Integrated pest and disease management
            if pest_risks.overall_risk.score > 0.6
                integrated_recommendations{end+1} = 'Implement integrated pest management (IPM) strategy';
                integrated_recommendations{end+1} = 'Use biological control agents where appropriate';
                integrated_recommendations{end+1} = 'Monitor pest populations regularly';
            end
            
            % Soil-crop-pest interactions
            soil_score = soil_condition.health_assessment.overall_score;
            crop_score = crop_health.overall_health.score;
            if ~isscalar(soil_score)
                soil_score = mean(soil_score(:));
            end
            if ~isscalar(crop_score)
                crop_score = mean(crop_score(:));
            end
            if soil_score < 0.6 && crop_score < 0.6
                integrated_recommendations{end+1} = 'Address soil health issues to improve crop resilience';
                integrated_recommendations{end+1} = 'Consider soil amendments and organic matter addition';
            end
            
            % Water management
            if soil_condition.moisture_analysis.moisture_classification.score < 0.6
                integrated_recommendations{end+1} = 'Optimize water management to improve both soil and crop health';
                integrated_recommendations{end+1} = 'Consider precision irrigation systems';
            end
            
            % Monitoring and data collection
            integrated_recommendations{end+1} = 'Establish regular monitoring schedule for all parameters';
            integrated_recommendations{end+1} = 'Maintain detailed records of management practices and outcomes';
            integrated_recommendations{end+1} = 'Review and adjust management strategies based on monitoring results';
        end
        
        function technical_details = generateTechnicalDetails(obj, crop_health, soil_condition, pest_risks, config)
            %% Generate Technical Details Section
            technical_details = struct();
            
            % Analysis parameters
            technical_details.analysis_parameters = struct();
            technical_details.analysis_parameters.timestamp = datetime('now');
            technical_details.analysis_parameters.image_size = crop_health.image_size;
            technical_details.analysis_parameters.configuration = config;
            
            % Data quality metrics
            technical_details.data_quality = struct();
            technical_details.data_quality.crop_health_confidence = crop_health.overall_health.confidence;
            technical_details.data_quality.pest_risk_confidence = pest_risks.overall_risk.confidence;
            
            % Algorithm information
            technical_details.algorithms = struct();
            technical_details.algorithms.vegetation_indices = 'NDVI, GNDVI, NDRE, SAVI, EVI, NDWI, MSR, CI';
            technical_details.algorithms.soil_analysis = 'Spectral-based soil type classification and parameter estimation';
            technical_details.algorithms.pest_detection = 'Multi-spectral anomaly detection and environmental risk assessment';
            
            % Limitations and assumptions
            technical_details.limitations = struct();
            technical_details.limitations.spectral_data = 'Analysis based on multispectral data with 8 bands';
            technical_details.limitations.sensor_data = 'Limited sensor data available for validation';
            technical_details.limitations.temporal_analysis = 'Single time point analysis - temporal trends not considered';
        end
        
        function summary = generateReportSummary(obj, report)
            %% Generate Report Summary
            summary = struct();
            
            % Report metadata
            summary.report_id = report.report_id;
            summary.timestamp = report.timestamp;
            summary.analysis_type = 'AI-Powered Agricultural Monitoring';
            
            % Key metrics
            summary.key_metrics = struct();
            summary.key_metrics.overall_assessment_score = report.executive_summary.overall_assessment.score;
            summary.key_metrics.overall_assessment_status = report.executive_summary.overall_assessment.status;
            summary.key_metrics.risk_level = report.executive_summary.risk_assessment.level;
            summary.key_metrics.priority_actions_count = length(report.executive_summary.priority_actions);
            
            % Summary statistics
            summary.statistics = struct();
            summary.statistics.crop_health_score = report.crop_health_section.overall_health.score;
            summary.statistics.soil_condition_score = report.soil_condition_section.overall_health.score;
            summary.statistics.pest_risk_score = report.pest_risk_section.overall_risk.score;
            
            % Report completeness
            summary.completeness = struct();
            summary.completeness.sections_completed = 6; % All sections
            summary.completeness.data_quality = 'High';
            summary.completeness.recommendations_provided = true;
        end
    end
end
