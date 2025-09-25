classdef SoilConditionAnalyzer < handle
    %% Soil Condition Analyzer
    % Analyzes soil condition using spectral data and sensor measurements
    
    properties
        soil_thresholds
        soil_types
    end
    
    methods
        function obj = SoilConditionAnalyzer()
            %% Constructor
            obj.soil_thresholds = struct();
            
            % Moisture thresholds
            obj.soil_thresholds.moisture_dry = 0.2;
            obj.soil_thresholds.moisture_optimal = 0.4;
            obj.soil_thresholds.moisture_wet = 0.8;
            
            % Temperature thresholds (Celsius)
            obj.soil_thresholds.temp_cold = 10;
            obj.soil_thresholds.temp_optimal_min = 15;
            obj.soil_thresholds.temp_optimal_max = 25;
            obj.soil_thresholds.temp_hot = 30;
            
            % pH thresholds
            obj.soil_thresholds.ph_acidic = 5.5;
            obj.soil_thresholds.ph_optimal_min = 6.0;
            obj.soil_thresholds.ph_optimal_max = 7.5;
            obj.soil_thresholds.ph_alkaline = 8.0;
            
            % Electrical conductivity thresholds (dS/m)
            obj.soil_thresholds.ec_low = 0.5;
            obj.soil_thresholds.ec_optimal = 1.5;
            obj.soil_thresholds.ec_high = 3.0;
            
            % Soil types
            obj.soil_types = {'Clay', 'Silt', 'Sand', 'Loam', 'Organic'};
        end
        
        function soil_condition = assessCondition(obj, processed_spectral, sensor_data)
            %% Assess Soil Condition
            % Input: processed_spectral - processed spectral data
            %        sensor_data - sensor measurements
            % Output: soil_condition - soil condition analysis results
            
            fprintf('Assessing soil condition...\n');
            
            % Initialize soil condition structure
            soil_condition = struct();
            soil_condition.timestamp = datetime('now');
            soil_condition.image_size = [processed_spectral.height, processed_spectral.width];
            
            % Analyze soil moisture
            soil_condition.moisture_analysis = obj.analyzeSoilMoisture(processed_spectral, sensor_data);
            
            % Analyze soil temperature
            soil_condition.temperature_analysis = obj.analyzeSoilTemperature(sensor_data);
            
            % Analyze soil pH
            soil_condition.ph_analysis = obj.analyzeSoilPH(sensor_data);
            
            % Analyze electrical conductivity
            soil_condition.ec_analysis = obj.analyzeElectricalConductivity(sensor_data);
            
            % Classify soil types
            soil_condition.soil_type_analysis = obj.classifySoilTypes(processed_spectral);
            
            % Assess soil health
            soil_condition.health_assessment = obj.assessSoilHealth(soil_condition);
            
            % Detect soil anomalies
            soil_condition.anomalies = obj.detectSoilAnomalies(processed_spectral, sensor_data);
            
            % Generate soil condition map
            soil_condition.moisture_map = obj.generateSoilConditionMap(processed_spectral, soil_condition);
            
            % Calculate soil quality index
            soil_condition.quality_index = obj.calculateSoilQualityIndex(soil_condition);
            
            fprintf('Soil condition assessment completed.\n');
        end
        
        function moisture_analysis = analyzeSoilMoisture(obj, processed_spectral, sensor_data)
            %% Analyze Soil Moisture
            moisture_analysis = struct();
            
            % Get sensor-based moisture data
            moisture_analysis.sensor_moisture = sensor_data.soil_moisture;
            moisture_analysis.sensor_moisture_mean = mean(sensor_data.soil_moisture);
            moisture_analysis.sensor_moisture_std = std(sensor_data.soil_moisture);
            
            % Estimate moisture from spectral data using NDWI
            ndwi = processed_spectral.vegetation_indices.ndwi;
            moisture_analysis.spectral_moisture_estimate = obj.estimateMoistureFromSpectral(ndwi);
            
            % Classify moisture levels
            moisture_analysis.moisture_classification = obj.classifyMoistureLevels(moisture_analysis.sensor_moisture_mean);
            
            % Calculate moisture variability
            moisture_analysis.moisture_variability = obj.calculateMoistureVariability(sensor_data.soil_moisture);
            
            % Assess moisture adequacy
            moisture_analysis.adequacy_assessment = obj.assessMoistureAdequacy(moisture_analysis.sensor_moisture_mean);
        end
        
        function moisture_estimate = estimateMoistureFromSpectral(obj, ndwi_data)
            %% Estimate Soil Moisture from Spectral Data
            % Convert NDWI to moisture estimate (simplified model)
            
            % NDWI to moisture conversion (empirical relationship)
            moisture_estimate = 0.5 + 0.3 * ndwi_data; % Simplified linear relationship
            
            % Ensure values are in valid range [0, 1]
            moisture_estimate = max(0, min(1, moisture_estimate));
        end
        
        function classification = classifyMoistureLevels(obj, moisture_value)
            %% Classify Moisture Levels
            classification = struct();
            
            if moisture_value < obj.soil_thresholds.moisture_dry
                classification.level = 'Dry';
                classification.score = 0.2;
                classification.recommendation = 'Irrigation needed';
            elseif moisture_value < obj.soil_thresholds.moisture_optimal
                classification.level = 'Low';
                classification.score = 0.4;
                classification.recommendation = 'Consider irrigation';
            elseif moisture_value <= obj.soil_thresholds.moisture_wet
                classification.level = 'Optimal';
                classification.score = 1.0;
                classification.recommendation = 'Moisture levels are adequate';
            else
                classification.level = 'Wet';
                classification.score = 0.6;
                classification.recommendation = 'Reduce irrigation';
            end
        end
        
        function variability = calculateMoistureVariability(obj, moisture_data)
            %% Calculate Moisture Variability
            variability = struct();
            
            variability.coefficient_of_variation = std(moisture_data) / mean(moisture_data);
            variability.range = max(moisture_data) - min(moisture_data);
            variability.trend = obj.calculateTrend(moisture_data);
            
            % Classify variability
            if variability.coefficient_of_variation < 0.1
                variability.level = 'Low';
            elseif variability.coefficient_of_variation < 0.3
                variability.level = 'Moderate';
            else
                variability.level = 'High';
            end
        end
        
        function trend = calculateTrend(obj, data)
            %% Calculate Data Trend
            x = 1:length(data);
            p = polyfit(x, data, 1);
            trend = p(1); % Slope
        end
        
        function adequacy = assessMoistureAdequacy(obj, moisture_value)
            %% Assess Moisture Adequacy
            adequacy = struct();
            
            % Calculate adequacy score (0-1)
            if moisture_value >= obj.soil_thresholds.moisture_optimal && moisture_value <= obj.soil_thresholds.moisture_wet
                adequacy.score = 1.0;
                adequacy.status = 'Adequate';
            else
                % Calculate distance from optimal range
                optimal_center = (obj.soil_thresholds.moisture_optimal + obj.soil_thresholds.moisture_wet) / 2;
                distance = abs(moisture_value - optimal_center);
                max_distance = 0.5; % Maximum expected distance
                adequacy.score = max(0, 1 - distance / max_distance);
                
                if adequacy.score >= 0.8
                    adequacy.status = 'Good';
                elseif adequacy.score >= 0.6
                    adequacy.status = 'Fair';
                else
                    adequacy.status = 'Poor';
                end
            end
        end
        
        function temperature_analysis = analyzeSoilTemperature(obj, sensor_data)
            %% Analyze Soil Temperature
            temperature_analysis = struct();
            
            % Get temperature data
            temperature_analysis.sensor_temperature = sensor_data.soil_temperature;
            temperature_analysis.mean_temperature = mean(sensor_data.soil_temperature);
            temperature_analysis.temperature_std = std(sensor_data.soil_temperature);
            temperature_analysis.min_temperature = min(sensor_data.soil_temperature);
            temperature_analysis.max_temperature = max(sensor_data.soil_temperature);
            
            % Classify temperature levels
            temperature_analysis.temperature_classification = obj.classifyTemperatureLevels(temperature_analysis.mean_temperature);
            
            % Calculate temperature variability
            temperature_analysis.temperature_variability = obj.calculateTemperatureVariability(sensor_data.soil_temperature);
            
            % Assess temperature adequacy
            temperature_analysis.adequacy_assessment = obj.assessTemperatureAdequacy(temperature_analysis.mean_temperature);
        end
        
        function classification = classifyTemperatureLevels(obj, temperature_value)
            %% Classify Temperature Levels
            classification = struct();
            
            if temperature_value < obj.soil_thresholds.temp_cold
                classification.level = 'Cold';
                classification.score = 0.2;
                classification.recommendation = 'Consider warming measures';
            elseif temperature_value < obj.soil_thresholds.temp_optimal_min
                classification.level = 'Cool';
                classification.score = 0.5;
                classification.recommendation = 'Temperature is below optimal';
            elseif temperature_value <= obj.soil_thresholds.temp_optimal_max
                classification.level = 'Optimal';
                classification.score = 1.0;
                classification.recommendation = 'Temperature is optimal';
            elseif temperature_value <= obj.soil_thresholds.temp_hot
                classification.level = 'Warm';
                classification.score = 0.7;
                classification.recommendation = 'Temperature is above optimal';
            else
                classification.level = 'Hot';
                classification.score = 0.3;
                classification.recommendation = 'Consider cooling measures';
            end
        end
        
        function variability = calculateTemperatureVariability(obj, temperature_data)
            %% Calculate Temperature Variability
            variability = struct();
            
            variability.daily_range = max(temperature_data) - min(temperature_data);
            variability.coefficient_of_variation = std(temperature_data) / mean(temperature_data);
            variability.trend = obj.calculateTrend(temperature_data);
            
            % Classify variability
            if variability.daily_range < 5
                variability.level = 'Low';
            elseif variability.daily_range < 15
                variability.level = 'Moderate';
            else
                variability.level = 'High';
            end
        end
        
        function adequacy = assessTemperatureAdequacy(obj, temperature_value)
            %% Assess Temperature Adequacy
            adequacy = struct();
            
            % Calculate adequacy score (0-1)
            if temperature_value >= obj.soil_thresholds.temp_optimal_min && temperature_value <= obj.soil_thresholds.temp_optimal_max
                adequacy.score = 1.0;
                adequacy.status = 'Optimal';
            else
                % Calculate distance from optimal range
                optimal_center = (obj.soil_thresholds.temp_optimal_min + obj.soil_thresholds.temp_optimal_max) / 2;
                distance = abs(temperature_value - optimal_center);
                max_distance = 15; % Maximum expected distance
                adequacy.score = max(0, 1 - distance / max_distance);
                
                if adequacy.score >= 0.8
                    adequacy.status = 'Good';
                elseif adequacy.score >= 0.6
                    adequacy.status = 'Fair';
                else
                    adequacy.status = 'Poor';
                end
            end
        end
        
        function ph_analysis = analyzeSoilPH(obj, sensor_data)
            %% Analyze Soil pH
            ph_analysis = struct();
            
            % Get pH data
            ph_analysis.sensor_ph = sensor_data.ph;
            ph_analysis.mean_ph = mean(sensor_data.ph);
            ph_analysis.ph_std = std(sensor_data.ph);
            ph_analysis.min_ph = min(sensor_data.ph);
            ph_analysis.max_ph = max(sensor_data.ph);
            
            % Classify pH levels
            ph_analysis.ph_classification = obj.classifyPHLevels(ph_analysis.mean_ph);
            
            % Assess pH adequacy
            ph_analysis.adequacy_assessment = obj.assessPHAdquacy(ph_analysis.mean_ph);
        end
        
        function classification = classifyPHLevels(obj, ph_value)
            %% Classify pH Levels
            classification = struct();
            
            if ph_value < obj.soil_thresholds.ph_acidic
                classification.level = 'Very Acidic';
                classification.score = 0.1;
                classification.recommendation = 'Lime application needed';
            elseif ph_value < obj.soil_thresholds.ph_optimal_min
                classification.level = 'Acidic';
                classification.score = 0.4;
                classification.recommendation = 'Consider lime application';
            elseif ph_value <= obj.soil_thresholds.ph_optimal_max
                classification.level = 'Optimal';
                classification.score = 1.0;
                classification.recommendation = 'pH is optimal';
            elseif ph_value <= obj.soil_thresholds.ph_alkaline
                classification.level = 'Alkaline';
                classification.score = 0.6;
                classification.recommendation = 'Consider acidification';
            else
                classification.level = 'Very Alkaline';
                classification.score = 0.2;
                classification.recommendation = 'Acidification needed';
            end
        end
        
        function adequacy = assessPHAdquacy(obj, ph_value)
            %% Assess pH Adequacy
            adequacy = struct();
            
            % Calculate adequacy score (0-1)
            if ph_value >= obj.soil_thresholds.ph_optimal_min && ph_value <= obj.soil_thresholds.ph_optimal_max
                adequacy.score = 1.0;
                adequacy.status = 'Optimal';
            else
                % Calculate distance from optimal range
                optimal_center = (obj.soil_thresholds.ph_optimal_min + obj.soil_thresholds.ph_optimal_max) / 2;
                distance = abs(ph_value - optimal_center);
                max_distance = 2.5; % Maximum expected distance
                adequacy.score = max(0, 1 - distance / max_distance);
                
                if adequacy.score >= 0.8
                    adequacy.status = 'Good';
                elseif adequacy.score >= 0.6
                    adequacy.status = 'Fair';
                else
                    adequacy.status = 'Poor';
                end
            end
        end
        
        function ec_analysis = analyzeElectricalConductivity(obj, sensor_data)
            %% Analyze Electrical Conductivity
            ec_analysis = struct();
            
            % Get EC data
            ec_analysis.sensor_ec = sensor_data.electrical_conductivity;
            ec_analysis.mean_ec = mean(sensor_data.electrical_conductivity);
            ec_analysis.ec_std = std(sensor_data.electrical_conductivity);
            ec_analysis.min_ec = min(sensor_data.electrical_conductivity);
            ec_analysis.max_ec = max(sensor_data.electrical_conductivity);
            
            % Classify EC levels
            ec_analysis.ec_classification = obj.classifyECLevels(ec_analysis.mean_ec);
            
            % Assess EC adequacy
            ec_analysis.adequacy_assessment = obj.assessECAdquacy(ec_analysis.mean_ec);
        end
        
        function classification = classifyECLevels(obj, ec_value)
            %% Classify EC Levels
            classification = struct();
            
            if ec_value < obj.soil_thresholds.ec_low
                classification.level = 'Low';
                classification.score = 0.4;
                classification.recommendation = 'Consider nutrient application';
            elseif ec_value <= obj.soil_thresholds.ec_optimal
                classification.level = 'Optimal';
                classification.score = 1.0;
                classification.recommendation = 'EC is optimal';
            elseif ec_value <= obj.soil_thresholds.ec_high
                classification.level = 'High';
                classification.score = 0.6;
                classification.recommendation = 'Monitor for salt accumulation';
            else
                classification.level = 'Very High';
                classification.score = 0.2;
                classification.recommendation = 'Leaching may be needed';
            end
        end
        
        function adequacy = assessECAdquacy(obj, ec_value)
            %% Assess EC Adequacy
            adequacy = struct();
            
            % Calculate adequacy score (0-1)
            if ec_value >= obj.soil_thresholds.ec_low && ec_value <= obj.soil_thresholds.ec_optimal
                adequacy.score = 1.0;
                adequacy.status = 'Optimal';
            else
                % Calculate distance from optimal range
                optimal_center = (obj.soil_thresholds.ec_low + obj.soil_thresholds.ec_optimal) / 2;
                distance = abs(ec_value - optimal_center);
                max_distance = 2.0; % Maximum expected distance
                adequacy.score = max(0, 1 - distance / max_distance);
                
                if adequacy.score >= 0.8
                    adequacy.status = 'Good';
                elseif adequacy.score >= 0.6
                    adequacy.status = 'Fair';
                else
                    adequacy.status = 'Poor';
                end
            end
        end
        
        function soil_type_analysis = classifySoilTypes(obj, processed_spectral)
            %% Classify Soil Types
            soil_type_analysis = struct();
            
            % Use spectral data to classify soil types
            % This is a simplified classification based on spectral characteristics
            
            % Extract relevant bands
            red = processed_spectral.denoised_data(:, :, 3);
            nir = processed_spectral.denoised_data(:, :, 4);
            swir = processed_spectral.denoised_data(:, :, 8);
            
            % Calculate soil indices
            soil_brightness = (red + nir + swir) / 3;
            soil_wetness = (red + swir) / 2 - nir;
            
            % Classify soil types based on spectral characteristics
            soil_type_analysis.soil_type_map = obj.classifySoilPixels(soil_brightness, soil_wetness);
            
            % Calculate percentages for each soil type
            for i = 1:length(obj.soil_types)
                soil_type = obj.soil_types{i};
                mask = soil_type_analysis.soil_type_map == i;
                soil_type_analysis.(['percentage_' lower(soil_type)]) = sum(mask(:)) / numel(mask) * 100;
            end
            
            % Determine dominant soil type
            [~, dominant_idx] = max([
                soil_type_analysis.percentage_clay,
                soil_type_analysis.percentage_silt,
                soil_type_analysis.percentage_sand,
                soil_type_analysis.percentage_loam,
                soil_type_analysis.percentage_organic
            ]);
            soil_type_analysis.dominant_type = obj.soil_types{dominant_idx};
        end
        
        function soil_type_map = classifySoilPixels(obj, brightness, wetness)
            %% Classify Individual Soil Pixels
            soil_type_map = zeros(size(brightness));
            
            % Define thresholds for soil type classification
            % This is a simplified approach - in practice, more sophisticated methods would be used
            
            % Clay: high brightness, high wetness
            clay_mask = brightness > 0.6 & wetness > 0.1;
            soil_type_map(clay_mask) = 1;
            
            % Silt: medium brightness, medium wetness
            silt_mask = brightness > 0.4 & brightness <= 0.6 & wetness > -0.1 & wetness <= 0.1;
            soil_type_map(silt_mask) = 2;
            
            % Sand: high brightness, low wetness
            sand_mask = brightness > 0.6 & wetness <= -0.1;
            soil_type_map(sand_mask) = 3;
            
            % Loam: medium brightness, medium wetness
            loam_mask = brightness > 0.3 & brightness <= 0.5 & wetness > -0.05 & wetness <= 0.05;
            soil_type_map(loam_mask) = 4;
            
            % Organic: low brightness, high wetness
            organic_mask = brightness <= 0.3 & wetness > 0.05;
            soil_type_map(organic_mask) = 5;
            
            % Default to loam for unclassified pixels
            soil_type_map(soil_type_map == 0) = 4;
        end
        
        function health_assessment = assessSoilHealth(obj, soil_condition)
            %% Assess Overall Soil Health
            health_assessment = struct();
            
            % Collect individual health scores
            scores = [
                soil_condition.moisture_analysis.moisture_classification.score,
                soil_condition.temperature_analysis.temperature_classification.score,
                soil_condition.ph_analysis.ph_classification.score,
                soil_condition.ec_analysis.ec_classification.score
            ];
            
            % Calculate weighted average
            weights = [0.3, 0.2, 0.3, 0.2]; % Moisture, Temperature, pH, EC
            health_assessment.overall_score = sum(weights .* scores);
            
            % Determine health status
            if health_assessment.overall_score >= 0.8
                health_assessment.status = 'Excellent';
            elseif health_assessment.overall_score >= 0.6
                health_assessment.status = 'Good';
            elseif health_assessment.overall_score >= 0.4
                health_assessment.status = 'Fair';
            else
                health_assessment.status = 'Poor';
            end
            
            % Generate recommendations
            health_assessment.recommendations = obj.generateSoilRecommendations(soil_condition);
        end
        
        function recommendations = generateSoilRecommendations(obj, soil_condition)
            %% Generate Soil Management Recommendations
            recommendations = {};
            
            % Moisture recommendations
            if soil_condition.moisture_analysis.moisture_classification.score < 0.6
                recommendations{end+1} = soil_condition.moisture_analysis.moisture_classification.recommendation;
            end
            
            % Temperature recommendations
            if soil_condition.temperature_analysis.temperature_classification.score < 0.6
                recommendations{end+1} = soil_condition.temperature_analysis.temperature_classification.recommendation;
            end
            
            % pH recommendations
            if soil_condition.ph_analysis.ph_classification.score < 0.6
                recommendations{end+1} = soil_condition.ph_analysis.ph_classification.recommendation;
            end
            
            % EC recommendations
            if soil_condition.ec_analysis.ec_classification.score < 0.6
                recommendations{end+1} = soil_condition.ec_analysis.ec_classification.recommendation;
            end
            
            % General recommendations
            if isempty(recommendations)
                recommendations{end+1} = 'Soil conditions are optimal for crop growth';
            end
        end
        
        function anomalies = detectSoilAnomalies(obj, processed_spectral, sensor_data)
            %% Detect Soil Anomalies
            anomalies = struct();
            
            % Detect moisture anomalies
            anomalies.moisture_anomalies = obj.detectMoistureAnomalies(sensor_data.soil_moisture);
            
            % Detect temperature anomalies
            anomalies.temperature_anomalies = obj.detectTemperatureAnomalies(sensor_data.soil_temperature);
            
            % Detect pH anomalies
            anomalies.ph_anomalies = obj.detectPHAnomalies(sensor_data.ph);
            
            % Detect spatial anomalies in spectral data
            anomalies.spatial_anomalies = obj.detectSpatialSoilAnomalies(processed_spectral);
        end
        
        function moisture_anomalies = detectMoistureAnomalies(obj, moisture_data)
            %% Detect Moisture Anomalies
            moisture_anomalies = struct();
            
            % Statistical outliers
            mean_moisture = mean(moisture_data);
            std_moisture = std(moisture_data);
            outlier_threshold = 2; % 2 standard deviations
            
            outliers = abs(moisture_data - mean_moisture) > outlier_threshold * std_moisture;
            moisture_anomalies.outlier_count = sum(outliers);
            moisture_anomalies.outlier_percentage = moisture_anomalies.outlier_count / length(moisture_data) * 100;
            
            % Rapid changes
            moisture_changes = abs(diff(moisture_data));
            rapid_change_threshold = 0.1; % 10% change
            rapid_changes = moisture_changes > rapid_change_threshold;
            moisture_anomalies.rapid_change_count = sum(rapid_changes);
        end
        
        function temperature_anomalies = detectTemperatureAnomalies(obj, temperature_data)
            %% Detect Temperature Anomalies
            temperature_anomalies = struct();
            
            % Statistical outliers
            mean_temp = mean(temperature_data);
            std_temp = std(temperature_data);
            outlier_threshold = 2;
            
            outliers = abs(temperature_data - mean_temp) > outlier_threshold * std_temp;
            temperature_anomalies.outlier_count = sum(outliers);
            temperature_anomalies.outlier_percentage = temperature_anomalies.outlier_count / length(temperature_data) * 100;
            
            % Extreme temperatures
            extreme_cold = temperature_data < obj.soil_thresholds.temp_cold;
            extreme_hot = temperature_data > obj.soil_thresholds.temp_hot;
            temperature_anomalies.extreme_count = sum(extreme_cold) + sum(extreme_hot);
        end
        
        function ph_anomalies = detectPHAnomalies(obj, ph_data)
            %% Detect pH Anomalies
            ph_anomalies = struct();
            
            % Statistical outliers
            mean_ph = mean(ph_data);
            std_ph = std(ph_data);
            outlier_threshold = 2;
            
            outliers = abs(ph_data - mean_ph) > outlier_threshold * std_ph;
            ph_anomalies.outlier_count = sum(outliers);
            ph_anomalies.outlier_percentage = ph_anomalies.outlier_count / length(ph_data) * 100;
            
            % Extreme pH values
            extreme_acidic = ph_data < obj.soil_thresholds.ph_acidic;
            extreme_alkaline = ph_data > obj.soil_thresholds.ph_alkaline;
            ph_anomalies.extreme_count = sum(extreme_acidic) + sum(extreme_alkaline);
        end
        
        function spatial_anomalies = detectSpatialSoilAnomalies(obj, processed_spectral)
            %% Detect Spatial Soil Anomalies
            spatial_anomalies = struct();
            
            % Use SWIR band for soil analysis
            swir_band = processed_spectral.denoised_data(:, :, 8);
            
            % Detect spatial outliers
            local_mean = conv2(swir_band, ones(5, 5)/25, 'same');
            local_std = sqrt(conv2(swir_band.^2, ones(5, 5)/25, 'same') - local_mean.^2);
            
            anomaly_threshold = 2;
            anomaly_mask = abs(swir_band - local_mean) > anomaly_threshold * local_std;
            
            spatial_anomalies.anomaly_percentage = sum(anomaly_mask(:)) / numel(anomaly_mask) * 100;
            spatial_anomalies.anomaly_locations = find(anomaly_mask);
        end
        
        function condition_map = generateSoilConditionMap(obj, processed_spectral, soil_condition)
            %% Generate Soil Condition Map
            condition_map = struct();
            
            % Create composite condition map
            condition_map.data = zeros(processed_spectral.height, processed_spectral.width);
            
            % Assign condition levels based on overall health score
            health_score = soil_condition.health_assessment.overall_score;
            
            if health_score >= 0.8
                condition_level = 3; % Excellent
            elseif health_score >= 0.6
                condition_level = 2; % Good
            else
                condition_level = 1; % Poor
            end
            
            condition_map.data(:) = condition_level;
            
            % Create RGB visualization
            condition_map.rgb = obj.createConditionRGB(condition_map.data);
            
            % Condition level labels
            condition_map.labels = {'Poor', 'Good', 'Excellent'};
            condition_map.colors = [1 0 0; 1 1 0; 0 1 0]; % Red, Yellow, Green
        end
        
        function rgb_image = createConditionRGB(obj, condition_data)
            %% Create RGB Visualization of Condition Map
            rgb_image = zeros(size(condition_data, 1), size(condition_data, 2), 3);
            
            % Red channel (poor condition)
            rgb_image(:, :, 1) = (condition_data == 1) * 1.0;
            
            % Green channel (excellent condition)
            rgb_image(:, :, 2) = (condition_data == 3) * 1.0;
            
            % Yellow channel (good condition) - combination of red and green
            rgb_image(:, :, 1) = rgb_image(:, :, 1) + (condition_data == 2) * 1.0;
            rgb_image(:, :, 2) = rgb_image(:, :, 2) + (condition_data == 2) * 1.0;
        end
        
        function quality_index = calculateSoilQualityIndex(obj, soil_condition)
            %% Calculate Soil Quality Index
            quality_index = struct();
            
            % Collect quality indicators
            moisture_score = soil_condition.moisture_analysis.moisture_classification.score;
            temperature_score = soil_condition.temperature_analysis.temperature_classification.score;
            ph_score = soil_condition.ph_analysis.ph_classification.score;
            ec_score = soil_condition.ec_analysis.ec_classification.score;
            
            % Calculate weighted quality index
            weights = [0.3, 0.2, 0.3, 0.2]; % Moisture, Temperature, pH, EC
            scores = [moisture_score, temperature_score, ph_score, ec_score];
            
            quality_index.value = sum(weights .* scores);
            
            % Classify quality level
            if quality_index.value >= 0.8
                quality_index.level = 'High';
            elseif quality_index.value >= 0.6
                quality_index.level = 'Medium';
            else
                quality_index.level = 'Low';
            end
            
            % Calculate individual component scores
            quality_index.component_scores = struct();
            quality_index.component_scores.moisture = moisture_score;
            quality_index.component_scores.temperature = temperature_score;
            quality_index.component_scores.ph = ph_score;
            quality_index.component_scores.electrical_conductivity = ec_score;
        end
    end
end
