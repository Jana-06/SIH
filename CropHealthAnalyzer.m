classdef CropHealthAnalyzer < handle
    %% Crop Health Analyzer
    % Analyzes crop health using vegetation indices and spectral data
    
    properties
        health_thresholds
        vegetation_indices
    end
    
    methods
        function obj = CropHealthAnalyzer()
            %% Constructor
            obj.health_thresholds = struct();
            obj.health_thresholds.ndvi_healthy = 0.6;
            obj.health_thresholds.ndvi_stressed = 0.3;
            obj.health_thresholds.ndvi_unhealthy = 0.1;
            
            obj.health_thresholds.gndvi_healthy = 0.4;
            obj.health_thresholds.gndvi_stressed = 0.2;
            obj.health_thresholds.gndvi_unhealthy = 0.1;
            
            obj.health_thresholds.ndre_healthy = 0.3;
            obj.health_thresholds.ndre_stressed = 0.15;
            obj.health_thresholds.ndre_unhealthy = 0.05;
        end
        
        function crop_health = analyzeHealth(obj, processed_spectral)
            %% Analyze Crop Health
            % Input: processed_spectral - processed spectral data structure
            % Output: crop_health - crop health analysis results
            
            fprintf('Analyzing crop health...\n');
            
            % Initialize crop health structure
            crop_health = struct();
            crop_health.timestamp = datetime('now');
            crop_health.image_size = [processed_spectral.height, processed_spectral.width];
            
            % Get vegetation indices
            vegetation_indices = processed_spectral.vegetation_indices;
            obj.vegetation_indices = vegetation_indices;
            
            % Analyze individual vegetation indices
            crop_health.ndvi_analysis = obj.analyzeNDVI(vegetation_indices.ndvi);
            crop_health.gndvi_analysis = obj.analyzeGNDVI(vegetation_indices.gndvi);
            crop_health.ndre_analysis = obj.analyzeNDRE(vegetation_indices.ndre);
            crop_health.savi_analysis = obj.analyzeSAVI(vegetation_indices.savi);
            crop_health.evi_analysis = obj.analyzeEVI(vegetation_indices.evi);
            
            % Calculate overall health score
            crop_health.overall_health = obj.calculateOverallHealth(crop_health);
            
            % Identify stress patterns
            crop_health.stress_patterns = obj.identifyStressPatterns(vegetation_indices);
            
            % Calculate health statistics
            crop_health.health_statistics = obj.calculateHealthStatistics(crop_health);
            
            % Generate health map
            crop_health.health_map = obj.generateHealthMap(vegetation_indices);
            
            % Detect anomalies
            crop_health.anomalies = obj.detectAnomalies(vegetation_indices);
            
            % Add maps to the output structure for visualization
            crop_health.ndvi_map = vegetation_indices.ndvi;
            crop_health.gndvi_map = vegetation_indices.gndvi;
            crop_health.ndre_map = vegetation_indices.ndre;
            crop_health.savi_map = vegetation_indices.savi;
            crop_health.evi_map = vegetation_indices.evi;
            
            fprintf('Crop health analysis completed.\n');
        end
        
        function ndvi_analysis = analyzeNDVI(obj, ndvi_data)
            %% Analyze NDVI Data
            ndvi_analysis = struct();
            
            % Calculate statistics
            ndvi_analysis.mean = mean(ndvi_data(:));
            ndvi_analysis.std = std(ndvi_data(:));
            ndvi_analysis.min = min(ndvi_data(:));
            ndvi_analysis.max = max(ndvi_data(:));
            ndvi_analysis.median = median(ndvi_data(:));
            
            % Classify health levels
            healthy_pixels = ndvi_data >= obj.health_thresholds.ndvi_healthy;
            stressed_pixels = ndvi_data >= obj.health_thresholds.ndvi_stressed & ndvi_data < obj.health_thresholds.ndvi_healthy;
            unhealthy_pixels = ndvi_data < obj.health_thresholds.ndvi_stressed;
            
            ndvi_analysis.healthy_percentage = sum(healthy_pixels(:)) / numel(ndvi_data) * 100;
            ndvi_analysis.stressed_percentage = sum(stressed_pixels(:)) / numel(ndvi_data) * 100;
            ndvi_analysis.unhealthy_percentage = sum(unhealthy_pixels(:)) / numel(ndvi_data) * 100;
            
            % Health assessment
            if ndvi_analysis.mean >= obj.health_thresholds.ndvi_healthy
                ndvi_analysis.health_status = 'Healthy';
                ndvi_analysis.health_score = 1.0;
            elseif ndvi_analysis.mean >= obj.health_thresholds.ndvi_stressed
                ndvi_analysis.health_status = 'Stressed';
                ndvi_analysis.health_score = 0.6;
            else
                ndvi_analysis.health_status = 'Unhealthy';
                ndvi_analysis.health_score = 0.2;
            end
        end
        
        function gndvi_analysis = analyzeGNDVI(obj, gndvi_data)
            %% Analyze GNDVI Data
            gndvi_analysis = struct();
            
            % Calculate statistics
            gndvi_analysis.mean = mean(gndvi_data(:));
            gndvi_analysis.std = std(gndvi_data(:));
            gndvi_analysis.min = min(gndvi_data(:));
            gndvi_analysis.max = max(gndvi_data(:));
            gndvi_analysis.median = median(gndvi_data(:));
            
            % Classify health levels
            healthy_pixels = gndvi_data >= obj.health_thresholds.gndvi_healthy;
            stressed_pixels = gndvi_data >= obj.health_thresholds.gndvi_stressed & gndvi_data < obj.health_thresholds.gndvi_healthy;
            unhealthy_pixels = gndvi_data < obj.health_thresholds.gndvi_stressed;
            
            gndvi_analysis.healthy_percentage = sum(healthy_pixels(:)) / numel(gndvi_data) * 100;
            gndvi_analysis.stressed_percentage = sum(stressed_pixels(:)) / numel(gndvi_data) * 100;
            gndvi_analysis.unhealthy_percentage = sum(unhealthy_pixels(:)) / numel(gndvi_data) * 100;
            
            % Health assessment
            if gndvi_analysis.mean >= obj.health_thresholds.gndvi_healthy
                gndvi_analysis.health_status = 'Healthy';
                gndvi_analysis.health_score = 1.0;
            elseif gndvi_analysis.mean >= obj.health_thresholds.gndvi_stressed
                gndvi_analysis.health_status = 'Stressed';
                gndvi_analysis.health_score = 0.6;
            else
                gndvi_analysis.health_status = 'Unhealthy';
                gndvi_analysis.health_score = 0.2;
            end
        end
        
        function ndre_analysis = analyzeNDRE(obj, ndre_data)
            %% Analyze NDRE Data
            ndre_analysis = struct();
            
            % Calculate statistics
            ndre_analysis.mean = mean(ndre_data(:));
            ndre_analysis.std = std(ndre_data(:));
            ndre_analysis.min = min(ndre_data(:));
            ndre_analysis.max = max(ndre_data(:));
            ndre_analysis.median = median(ndre_data(:));
            
            % Classify health levels
            healthy_pixels = ndre_data >= obj.health_thresholds.ndre_healthy;
            stressed_pixels = ndre_data >= obj.health_thresholds.ndre_stressed & ndre_data < obj.health_thresholds.ndre_healthy;
            unhealthy_pixels = ndre_data < obj.health_thresholds.ndre_stressed;
            
            ndre_analysis.healthy_percentage = sum(healthy_pixels(:)) / numel(ndre_data) * 100;
            ndre_analysis.stressed_percentage = sum(stressed_pixels(:)) / numel(ndre_data) * 100;
            ndre_analysis.unhealthy_percentage = sum(unhealthy_pixels(:)) / numel(ndre_data) * 100;
            
            % Health assessment
            if ndre_analysis.mean >= obj.health_thresholds.ndre_healthy
                ndre_analysis.health_status = 'Healthy';
                ndre_analysis.health_score = 1.0;
            elseif ndre_analysis.mean >= obj.health_thresholds.ndre_stressed
                ndre_analysis.health_status = 'Stressed';
                ndre_analysis.health_score = 0.6;
            else
                ndre_analysis.health_status = 'Unhealthy';
                ndre_analysis.health_score = 0.2;
            end
        end
        
        function savi_analysis = analyzeSAVI(obj, savi_data)
            %% Analyze SAVI Data
            savi_analysis = struct();
            
            % Calculate statistics
            savi_analysis.mean = mean(savi_data(:));
            savi_analysis.std = std(savi_data(:));
            savi_analysis.min = min(savi_data(:));
            savi_analysis.max = max(savi_data(:));
            savi_analysis.median = median(savi_data(:));
            
            % SAVI-specific thresholds
            savi_healthy_threshold = 0.4;
            savi_stressed_threshold = 0.2;
            
            % Classify health levels
            healthy_pixels = savi_data >= savi_healthy_threshold;
            stressed_pixels = savi_data >= savi_stressed_threshold & savi_data < savi_healthy_threshold;
            unhealthy_pixels = savi_data < savi_stressed_threshold;
            
            savi_analysis.healthy_percentage = sum(healthy_pixels(:)) / numel(savi_data) * 100;
            savi_analysis.stressed_percentage = sum(stressed_pixels(:)) / numel(savi_data) * 100;
            savi_analysis.unhealthy_percentage = sum(unhealthy_pixels(:)) / numel(savi_data) * 100;
            
            % Health assessment
            if savi_analysis.mean >= savi_healthy_threshold
                savi_analysis.health_status = 'Healthy';
                savi_analysis.health_score = 1.0;
            elseif savi_analysis.mean >= savi_stressed_threshold
                savi_analysis.health_status = 'Stressed';
                savi_analysis.health_score = 0.6;
            else
                savi_analysis.health_status = 'Unhealthy';
                savi_analysis.health_score = 0.2;
            end
        end
        
        function evi_analysis = analyzeEVI(obj, evi_data)
            %% Analyze EVI Data
            evi_analysis = struct();
            
            % Calculate statistics
            evi_analysis.mean = mean(evi_data(:));
            evi_analysis.std = std(evi_data(:));
            evi_analysis.min = min(evi_data(:));
            evi_analysis.max = max(evi_data(:));
            evi_analysis.median = median(evi_data(:));
            
            % EVI-specific thresholds
            evi_healthy_threshold = 0.3;
            evi_stressed_threshold = 0.15;
            
            % Classify health levels
            healthy_pixels = evi_data >= evi_healthy_threshold;
            stressed_pixels = evi_data >= evi_stressed_threshold & evi_data < evi_healthy_threshold;
            unhealthy_pixels = evi_data < evi_stressed_threshold;
            
            evi_analysis.healthy_percentage = sum(healthy_pixels(:)) / numel(evi_data) * 100;
            evi_analysis.stressed_percentage = sum(stressed_pixels(:)) / numel(evi_data) * 100;
            evi_analysis.unhealthy_percentage = sum(unhealthy_pixels(:)) / numel(evi_data) * 100;
            
            % Health assessment
            if evi_analysis.mean >= evi_healthy_threshold
                evi_analysis.health_status = 'Healthy';
                evi_analysis.health_score = 1.0;
            elseif evi_analysis.mean >= evi_stressed_threshold
                evi_analysis.health_status = 'Stressed';
                evi_analysis.health_score = 0.6;
            else
                evi_analysis.health_status = 'Unhealthy';
                evi_analysis.health_score = 0.2;
            end
        end
        
        function overall_health = calculateOverallHealth(obj, crop_health)
            %% Calculate Overall Health Score
            overall_health = struct();
            
            % Weighted average of health scores
            weights = [0.3, 0.25, 0.2, 0.15, 0.1]; % NDVI, GNDVI, NDRE, SAVI, EVI
            scores = [
                crop_health.ndvi_analysis.health_score,
                crop_health.gndvi_analysis.health_score,
                crop_health.ndre_analysis.health_score,
                crop_health.savi_analysis.health_score,
                crop_health.evi_analysis.health_score
            ];
            
            overall_health.score = sum(weights .* scores);
            
            % Determine overall status
            if overall_health.score >= 0.8
                overall_health.status = 'Excellent';
            elseif overall_health.score >= 0.6
                overall_health.status = 'Good';
            elseif overall_health.score >= 0.4
                overall_health.status = 'Fair';
            elseif overall_health.score >= 0.2
                overall_health.status = 'Poor';
            else
                overall_health.status = 'Critical';
            end
            
            % Calculate confidence level
            overall_health.confidence = 1 - std(scores) / mean(scores);
            overall_health.confidence = max(0, min(1, overall_health.confidence));
        end
        
        function stress_patterns = identifyStressPatterns(obj, vegetation_indices)
            %% Identify Stress Patterns
            stress_patterns = struct();
            
            % Water stress (low NDWI)
            water_stress_threshold = -0.1;
            water_stress_mask = vegetation_indices.ndwi < water_stress_threshold;
            stress_patterns.water_stress_percentage = sum(water_stress_mask(:)) / numel(water_stress_mask) * 100;
            
            % Nutrient stress (low NDRE)
            nutrient_stress_threshold = 0.1;
            nutrient_stress_mask = vegetation_indices.ndre < nutrient_stress_threshold;
            stress_patterns.nutrient_stress_percentage = sum(nutrient_stress_mask(:)) / numel(nutrient_stress_mask) * 100;
            
            % Chlorophyll stress (low CI)
            chlorophyll_stress_threshold = 0.1;
            chlorophyll_stress_mask = vegetation_indices.ci < chlorophyll_stress_threshold;
            stress_patterns.chlorophyll_stress_percentage = sum(chlorophyll_stress_mask(:)) / numel(chlorophyll_stress_mask) * 100;
            
            % Overall stress areas
            overall_stress_mask = water_stress_mask | nutrient_stress_mask | chlorophyll_stress_mask;
            stress_patterns.overall_stress_percentage = sum(overall_stress_mask(:)) / numel(overall_stress_mask) * 100;
        end
        
        function health_statistics = calculateHealthStatistics(obj, crop_health)
            %% Calculate Health Statistics
            health_statistics = struct();
            
            % Area statistics
            total_pixels = crop_health.image_size(1) * crop_health.image_size(2);
            
            health_statistics.total_area_pixels = total_pixels;
            health_statistics.healthy_area_percentage = crop_health.ndvi_analysis.healthy_percentage;
            health_statistics.stressed_area_percentage = crop_health.ndvi_analysis.stressed_percentage;
            health_statistics.unhealthy_area_percentage = crop_health.ndvi_analysis.unhealthy_percentage;
            
            % Index statistics
            health_statistics.ndvi_mean = crop_health.ndvi_analysis.mean;
            health_statistics.gndvi_mean = crop_health.gndvi_analysis.mean;
            health_statistics.ndre_mean = crop_health.ndre_analysis.mean;
            
            % Health distribution
            health_statistics.health_distribution = [
                crop_health.ndvi_analysis.healthy_percentage,
                crop_health.ndvi_analysis.stressed_percentage,
                crop_health.ndvi_analysis.unhealthy_percentage
            ];
        end
        
        function health_map = generateHealthMap(obj, vegetation_indices)
            %% Generate Health Map
            health_map = struct();
            
            % Create composite health map based on NDVI
            ndvi = vegetation_indices.ndvi;
            
            % Initialize health map
            health_map.data = zeros(size(ndvi));
            
            % Assign health levels
            health_map.data(ndvi >= obj.health_thresholds.ndvi_healthy) = 3; % Healthy
            health_map.data(ndvi >= obj.health_thresholds.ndvi_stressed & ndvi < obj.health_thresholds.ndvi_healthy) = 2; % Stressed
            health_map.data(ndvi < obj.health_thresholds.ndvi_stressed) = 1; % Unhealthy
            
            % Create RGB visualization
            health_map.rgb = obj.createHealthRGB(health_map.data);
            
            % Health level labels
            health_map.labels = {'Unhealthy', 'Stressed', 'Healthy'};
            health_map.colors = [1 0 0; 1 1 0; 0 1 0]; % Red, Yellow, Green
            
            % Combine weighted indices
            % health_map = (weights.ndvi * ndvi_norm) + (weights.gndvi * gndvi_norm) + (weights.ndre * ndre_norm);
            
            % Generate and save a visualization of the health map
            % h = figure('Visible', 'off');
            % imagesc(health_map);
            % title('Crop Health Map');
            % colorbar;
            % axis equal;
            % axis off;
            
            % Create a unique filename for the crop health map
            % timestamp = datestr(now, 'yyyymmddHHMMSSFFF');
            % filename = sprintf('crop_health_map_%s.png', timestamp);
            % filepath = fullfile('..', 'flask_server', 'static', 'images', filename);
            
            % Save the figure
            % saveas(h, filepath);
            % close(h);
        end
        
        function rgb_image = createHealthRGB(obj, health_data)
            %% Create RGB Visualization of Health Map
            rgb_image = zeros(size(health_data, 1), size(health_data, 2), 3);
            
            % Red channel (unhealthy)
            rgb_image(:, :, 1) = (health_data == 1) * 1.0;
            
            % Green channel (healthy)
            rgb_image(:, :, 2) = (health_data == 3) * 1.0;
            
            % Yellow channel (stressed) - combination of red and green
            rgb_image(:, :, 1) = rgb_image(:, :, 1) + (health_data == 2) * 1.0;
            rgb_image(:, :, 2) = rgb_image(:, :, 2) + (health_data == 2) * 1.0;
        end
        
        function anomalies = detectAnomalies(obj, vegetation_indices)
            %% Detect Anomalies in Vegetation Indices
            anomalies = struct();
            
            % Detect outliers in NDVI
            ndvi_data = vegetation_indices.ndvi(:);
            ndvi_mean = mean(ndvi_data);
            ndvi_std = std(ndvi_data);
            
            % Statistical outliers (beyond 3 standard deviations)
            outlier_threshold = 3;
            ndvi_outliers = abs(ndvi_data - ndvi_mean) > outlier_threshold * ndvi_std;
            
            anomalies.ndvi_outliers_percentage = sum(ndvi_outliers) / length(ndvi_data) * 100;
            
            % Detect spatial anomalies (isolated high/low values)
            ndvi_2d = vegetation_indices.ndvi;
            anomalies.spatial_anomalies = obj.detectSpatialAnomalies(ndvi_2d);
            
            % Detect temporal anomalies (if temporal data available)
            anomalies.temporal_anomalies = obj.detectTemporalAnomalies(vegetation_indices);
        end
        
        function spatial_anomalies = detectSpatialAnomalies(obj, data)
            %% Detect Spatial Anomalies
            spatial_anomalies = struct();
            
            % Use local statistics to detect anomalies
            local_mean = conv2(data, ones(5, 5)/25, 'same');
            local_std = sqrt(conv2(data.^2, ones(5, 5)/25, 'same') - local_mean.^2);
            
            % Anomalies are pixels that deviate significantly from local mean
            anomaly_threshold = 2;
            anomaly_mask = abs(data - local_mean) > anomaly_threshold * local_std;
            
            spatial_anomalies.anomaly_percentage = sum(anomaly_mask(:)) / numel(anomaly_mask) * 100;
            spatial_anomalies.anomaly_locations = find(anomaly_mask);
        end
        
        function temporal_anomalies = detectTemporalAnomalies(obj, vegetation_indices)
            %% Detect Temporal Anomalies
            % This is a placeholder for temporal analysis
            % In a real system, this would compare current data with historical data
            
            temporal_anomalies = struct();
            temporal_anomalies.detected = false;
            temporal_anomalies.description = 'Temporal analysis requires historical data';
        end
    end
end
