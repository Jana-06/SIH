classdef PestRiskDetector < handle
    %% Pest Risk Detector
    % Detects pest risks using spectral data and environmental conditions
    
    properties
        pest_thresholds
        pest_types
        environmental_factors
    end
    
    methods
        function obj = PestRiskDetector()
            %% Constructor
            obj.pest_thresholds = struct();
            
            % Risk level thresholds
            obj.pest_thresholds.low_risk = 0.3;
            obj.pest_thresholds.medium_risk = 0.6;
            obj.pest_thresholds.high_risk = 0.8;
            
            % Environmental thresholds
            obj.pest_thresholds.temp_optimal_min = 20;
            obj.pest_thresholds.temp_optimal_max = 30;
            obj.pest_thresholds.humidity_optimal_min = 60;
            obj.pest_thresholds.humidity_optimal_max = 80;
            
            % Pest types
            obj.pest_types = {'Aphids', 'Whiteflies', 'Thrips', 'Spider Mites', 'Caterpillars'};
            
            % Environmental factors
            obj.environmental_factors = {'Temperature', 'Humidity', 'Moisture', 'Light', 'Wind'};
        end
        
        function pest_risks = detectRisks(obj, processed_spectral, crop_health)
            %% Detect Pest Risks
            % Input: processed_spectral - processed spectral data
            %        crop_health - crop health analysis results
            % Output: pest_risks - pest risk analysis results
            
            fprintf('Detecting pest risks...\n');
            
            % Initialize pest risks structure
            pest_risks = struct();
            pest_risks.timestamp = datetime('now');
            pest_risks.image_size = [processed_spectral.height, processed_spectral.width];
            
            % Analyze spectral indicators
            pest_risks.spectral_analysis = obj.analyzeSpectralIndicators(processed_spectral);
            
            % Analyze environmental conditions
            pest_risks.environmental_analysis = obj.analyzeEnvironmentalConditions(processed_spectral);
            
            % Detect specific pest types
            pest_risks.pest_detection = obj.detectSpecificPests(processed_spectral, crop_health);
            
            % Calculate overall risk score
            pest_risks.overall_risk = obj.calculateOverallRisk(pest_risks);
            
            % Generate risk map
            pest_risks.risk_map = obj.generateRiskMap(processed_spectral, pest_risks);
            
            % Generate recommendations
            pest_risks.recommendations = obj.generatePestRecommendations(pest_risks);
            
            fprintf('Pest risk detection completed.\n');
        end
        
        function spectral_analysis = analyzeSpectralIndicators(obj, processed_spectral)
            %% Analyze Spectral Indicators for Pest Detection
            spectral_analysis = struct();
            
            % Get vegetation indices
            vegetation_indices = processed_spectral.vegetation_indices;
            
            % Analyze stress indicators
            spectral_analysis.stress_indicators = obj.analyzeStressIndicators(vegetation_indices);
            
            % Analyze chlorophyll content
            spectral_analysis.chlorophyll_analysis = obj.analyzeChlorophyllContent(vegetation_indices);
            
            % Analyze water content
            spectral_analysis.water_content_analysis = obj.analyzeWaterContent(vegetation_indices);
            
            % Detect spectral anomalies
            spectral_analysis.spectral_anomalies = obj.detectSpectralAnomalies(processed_spectral);
            
            % Return the spectral analysis structure
            spectral_analysis = spectral_analysis;
        end
        
        function stress_indicators = analyzeStressIndicators(obj, vegetation_indices)
            %% Analyze Stress Indicators
            stress_indicators = struct();
            
            % NDVI stress analysis
            ndvi = vegetation_indices.ndvi;
            stress_indicators.ndvi_stress = obj.calculateStressLevel(ndvi, 0.3, 0.6);
            
            % GNDVI stress analysis
            gndvi = vegetation_indices.gndvi;
            stress_indicators.gndvi_stress = obj.calculateStressLevel(gndvi, 0.2, 0.4);
            
            % NDRE stress analysis
            ndre = vegetation_indices.ndre;
            stress_indicators.ndre_stress = obj.calculateStressLevel(ndre, 0.15, 0.3);
            
            % Overall stress score
            stress_indicators.overall_stress = mean([
                stress_indicators.ndvi_stress,
                stress_indicators.gndvi_stress,
                stress_indicators.ndre_stress
            ]);
        end
        
        function stress_level = calculateStressLevel(obj, index_data, low_threshold, high_threshold)
            %% Calculate Stress Level from Index Data
            mean_value = mean(index_data(:));
            
            if mean_value >= high_threshold
                stress_level = 0.2; % Low stress
            elseif mean_value >= low_threshold
                stress_level = 0.6; % Medium stress
            else
                stress_level = 1.0; % High stress
            end
        end
        
        function chlorophyll_analysis = analyzeChlorophyllContent(obj, vegetation_indices)
            %% Analyze Chlorophyll Content
            chlorophyll_analysis = struct();
            
            % CI (Chlorophyll Index)
            ci = vegetation_indices.ci;
            chlorophyll_analysis.ci_mean = mean(ci(:));
            chlorophyll_analysis.ci_std = std(ci(:));
            
            % Chlorophyll stress assessment
            if chlorophyll_analysis.ci_mean >= 0.3
                chlorophyll_analysis.stress_level = 0.2;
                chlorophyll_analysis.status = 'Healthy';
            elseif chlorophyll_analysis.ci_mean >= 0.1
                chlorophyll_analysis.stress_level = 0.6;
                chlorophyll_analysis.status = 'Stressed';
            else
                chlorophyll_analysis.stress_level = 1.0;
                chlorophyll_analysis.status = 'Severely Stressed';
            end
        end
        
        function water_content_analysis = analyzeWaterContent(obj, vegetation_indices)
            %% Analyze Water Content
            water_content_analysis = struct();
            
            % NDWI (Normalized Difference Water Index)
            ndwi = vegetation_indices.ndwi;
            water_content_analysis.ndwi_mean = mean(ndwi(:));
            water_content_analysis.ndwi_std = std(ndwi(:));
            
            % Water stress assessment
            if water_content_analysis.ndwi_mean >= 0.1
                water_content_analysis.stress_level = 0.2;
                water_content_analysis.status = 'Adequate';
            elseif water_content_analysis.ndwi_mean >= -0.1
                water_content_analysis.stress_level = 0.6;
                water_content_analysis.status = 'Moderate';
            else
                water_content_analysis.stress_level = 1.0;
                water_content_analysis.status = 'Severe';
            end
        end
        
        function spectral_anomalies = detectSpectralAnomalies(obj, processed_spectral)
            %% Detect Spectral Anomalies
            spectral_anomalies = struct();
            
            % Use multiple bands for anomaly detection
            bands = processed_spectral.denoised_data;
            
            % Calculate spectral angle for anomaly detection
            spectral_anomalies.anomaly_map = obj.calculateSpectralAnomalies(bands);
            
            % Calculate anomaly statistics
            anomaly_data = spectral_anomalies.anomaly_map(:);
            spectral_anomalies.anomaly_percentage = sum(anomaly_data > 0.5) / length(anomaly_data) * 100;
            spectral_anomalies.mean_anomaly_score = mean(anomaly_data);
        end
        
        function anomaly_map = calculateSpectralAnomalies(obj, bands)
            %% Calculate Spectral Anomalies
            [height, width, num_bands] = size(bands);
            anomaly_map = zeros(height, width);
            
            % Calculate spectral angle for each pixel
            for i = 1:height
                for j = 1:width
                    pixel_spectrum = squeeze(bands(i, j, :));
                    
                    % Calculate spectral angle with reference spectrum
                    reference_spectrum = mean(mean(bands, 1), 2);
                    reference_spectrum = squeeze(reference_spectrum);
                    
                    % Calculate cosine similarity
                    dot_product = sum(pixel_spectrum .* reference_spectrum);
                    norm_pixel = sqrt(sum(pixel_spectrum.^2));
                    norm_reference = sqrt(sum(reference_spectrum.^2));
                    
                    if norm_pixel > 0 && norm_reference > 0
                        cosine_similarity = dot_product / (norm_pixel * norm_reference);
                        anomaly_map(i, j) = 1 - cosine_similarity;
                    end
                end
            end
        end
        
        function environmental_analysis = analyzeEnvironmentalConditions(obj, processed_spectral)
            %% Analyze Environmental Conditions
            environmental_analysis = struct();
            
            % Temperature analysis (simulated from spectral data)
            environmental_analysis.temperature_analysis = obj.analyzeTemperatureConditions(processed_spectral);
            
            % Humidity analysis
            environmental_analysis.humidity_analysis = obj.analyzeHumidityConditions(processed_spectral);
            
            % Moisture analysis
            environmental_analysis.moisture_analysis = obj.analyzeMoistureConditions(processed_spectral);
            
            % Light analysis
            environmental_analysis.light_analysis = obj.analyzeLightConditions(processed_spectral);
            
            % Overall environmental risk
            environmental_analysis.overall_risk = obj.calculateEnvironmentalRisk(environmental_analysis);
        end
        
        function temperature_analysis = analyzeTemperatureConditions(obj, processed_spectral)
            %% Analyze Temperature Conditions
            temperature_analysis = struct();
            
            % Simulate temperature from thermal band (if available)
            % For demonstration, use SWIR band as proxy
            thermal_proxy = processed_spectral.denoised_data(:, :, 8);
            temperature_analysis.mean_temperature = 20 + 10 * mean(thermal_proxy(:));
            
            % Assess temperature risk
            if temperature_analysis.mean_temperature >= obj.pest_thresholds.temp_optimal_min && ...
               temperature_analysis.mean_temperature <= obj.pest_thresholds.temp_optimal_max
                temperature_analysis.risk_level = 0.8; % High risk (optimal for pests)
                temperature_analysis.status = 'Optimal for pests';
            else
                temperature_analysis.risk_level = 0.3; % Low risk
                temperature_analysis.status = 'Suboptimal for pests';
            end
        end
        
        function humidity_analysis = analyzeHumidityConditions(obj, processed_spectral)
            %% Analyze Humidity Conditions
            humidity_analysis = struct();
            
            % Estimate humidity from spectral data
            % Use NDWI as proxy for humidity
            ndwi = processed_spectral.vegetation_indices.ndwi;
            humidity_analysis.estimated_humidity = 50 + 30 * mean(ndwi(:));
            
            % Assess humidity risk
            if humidity_analysis.estimated_humidity >= obj.pest_thresholds.humidity_optimal_min && ...
               humidity_analysis.estimated_humidity <= obj.pest_thresholds.humidity_optimal_max
                humidity_analysis.risk_level = 0.8; % High risk
                humidity_analysis.status = 'Optimal for pests';
            else
                humidity_analysis.risk_level = 0.3; % Low risk
                humidity_analysis.status = 'Suboptimal for pests';
            end
        end
        
        function moisture_analysis = analyzeMoistureConditions(obj, processed_spectral)
            %% Analyze Moisture Conditions
            moisture_analysis = struct();
            
            % Use NDWI for moisture analysis
            ndwi = processed_spectral.vegetation_indices.ndwi;
            moisture_analysis.moisture_level = mean(ndwi(:));
            
            % Assess moisture risk
            if moisture_analysis.moisture_level > 0.1
                moisture_analysis.risk_level = 0.7; % High risk (high moisture)
                moisture_analysis.status = 'High moisture - favorable for pests';
            elseif moisture_analysis.moisture_level > -0.1
                moisture_analysis.risk_level = 0.5; % Medium risk
                moisture_analysis.status = 'Moderate moisture';
            else
                moisture_analysis.risk_level = 0.2; % Low risk
                moisture_analysis.status = 'Low moisture - less favorable for pests';
            end
        end
        
        function light_analysis = analyzeLightConditions(obj, processed_spectral)
            %% Analyze Light Conditions
            light_analysis = struct();
            
            % Use visible bands for light analysis
            visible_bands = processed_spectral.denoised_data(:, :, 1:3);
            light_analysis.light_intensity = mean(visible_bands(:));
            
            % Assess light risk
            if light_analysis.light_intensity < 0.3
                light_analysis.risk_level = 0.8; % High risk (low light)
                light_analysis.status = 'Low light - favorable for pests';
            else
                light_analysis.risk_level = 0.3; % Low risk
                light_analysis.status = 'Adequate light - less favorable for pests';
            end
        end
        
        function overall_risk = calculateEnvironmentalRisk(obj, environmental_analysis)
            %% Calculate Overall Environmental Risk
            overall_risk = struct();
            
            % Collect individual risk scores
            risk_scores = [
                environmental_analysis.temperature_analysis.risk_level,
                environmental_analysis.humidity_analysis.risk_level,
                environmental_analysis.moisture_analysis.risk_level,
                environmental_analysis.light_analysis.risk_level
            ];
            
            % Calculate weighted average
            weights = [0.3, 0.3, 0.2, 0.2]; % Temperature, Humidity, Moisture, Light
            overall_risk.score = sum(weights .* risk_scores);
            
            % Determine risk level
            if overall_risk.score >= obj.pest_thresholds.high_risk
                overall_risk.level = 'High';
            elseif overall_risk.score >= obj.pest_thresholds.medium_risk
                overall_risk.level = 'Medium';
            else
                overall_risk.level = 'Low';
            end
        end
        
        function pest_detection = detectSpecificPests(obj, processed_spectral, crop_health)
            %% Detect Specific Pest Types
            pest_detection = struct();
            
            % Detect each pest type
            for i = 1:length(obj.pest_types)
                pest_type = obj.pest_types{i};
                field_name = lower(strrep(pest_type, ' ', '_'));
                pest_detection.(field_name) = obj.detectPestType(pest_type, processed_spectral, crop_health);
            end
            
            % Calculate overall pest presence
            pest_detection.overall_pest_presence = obj.calculateOverallPestPresence(pest_detection);
        end
        
        function pest_info = detectPestType(obj, pest_type, processed_spectral, crop_health)
            %% Detect Specific Pest Type
            pest_info = struct();
            pest_info.type = pest_type;
            
            % Get relevant spectral data
            vegetation_indices = processed_spectral.vegetation_indices;
            
            % Pest-specific detection logic
            switch lower(pest_type)
                case 'aphids'
                    pest_info = obj.detectAphids(vegetation_indices, crop_health);
                case 'whiteflies'
                    pest_info = obj.detectWhiteflies(vegetation_indices, crop_health);
                case 'thrips'
                    pest_info = obj.detectThrips(vegetation_indices, crop_health);
                case 'spider mites'
                    pest_info = obj.detectSpiderMites(vegetation_indices, crop_health);
                case 'caterpillars'
                    pest_info = obj.detectCaterpillars(vegetation_indices, crop_health);
            end
        end
        
        function aphid_info = detectAphids(obj, vegetation_indices, crop_health)
            %% Detect Aphids
            aphid_info = struct();
            aphid_info.type = 'Aphids';
            
            % Aphids cause yellowing and stunting
            % Use NDVI and GNDVI for detection
            ndvi = vegetation_indices.ndvi;
            gndvi = vegetation_indices.gndvi;
            
            % Calculate aphid risk
            aphid_info.risk_score = obj.calculatePestRisk(ndvi, gndvi, 0.4, 0.3);
            aphid_info.confidence = 0.7;
            aphid_info.affected_area_percentage = sum(ndvi(:) < 0.4) / numel(ndvi) * 100;
            
            if aphid_info.risk_score > 0.6
                aphid_info.status = 'High Risk';
            elseif aphid_info.risk_score > 0.3
                aphid_info.status = 'Medium Risk';
            else
                aphid_info.status = 'Low Risk';
            end
        end
        
        function whitefly_info = detectWhiteflies(obj, vegetation_indices, crop_health)
            %% Detect Whiteflies
            whitefly_info = struct();
            whitefly_info.type = 'Whiteflies';
            
            % Whiteflies cause yellowing and sooty mold
            ndvi = vegetation_indices.ndvi;
            ndwi = vegetation_indices.ndwi;
            
            whitefly_info.risk_score = obj.calculatePestRisk(ndvi, ndwi, 0.3, 0.1);
            whitefly_info.confidence = 0.6;
            whitefly_info.affected_area_percentage = sum(ndvi(:) < 0.3) / numel(ndvi) * 100;
            
            if whitefly_info.risk_score > 0.6
                whitefly_info.status = 'High Risk';
            elseif whitefly_info.risk_score > 0.3
                whitefly_info.status = 'Medium Risk';
            else
                whitefly_info.status = 'Low Risk';
            end
        end
        
        function thrip_info = detectThrips(obj, vegetation_indices, crop_health)
            %% Detect Thrips
            thrip_info = struct();
            thrip_info.type = 'Thrips';
            
            % Thrips cause silvering and distortion
            ndvi = vegetation_indices.ndvi;
            ndre = vegetation_indices.ndre;
            
            thrip_info.risk_score = obj.calculatePestRisk(ndvi, ndre, 0.35, 0.2);
            thrip_info.confidence = 0.5;
            thrip_info.affected_area_percentage = sum(ndvi(:) < 0.35) / numel(ndvi) * 100;
            
            if thrip_info.risk_score > 0.6
                thrip_info.status = 'High Risk';
            elseif thrip_info.risk_score > 0.3
                thrip_info.status = 'Medium Risk';
            else
                thrip_info.status = 'Low Risk';
            end
        end
        
        function mite_info = detectSpiderMites(obj, vegetation_indices, crop_health)
            %% Detect Spider Mites
            mite_info = struct();
            mite_info.type = 'Spider Mites';
            
            % Spider mites cause stippling and webbing
            ndvi = vegetation_indices.ndvi;
            gndvi = vegetation_indices.gndvi;
            
            mite_info.risk_score = obj.calculatePestRisk(ndvi, gndvi, 0.3, 0.25);
            mite_info.confidence = 0.6;
            mite_info.affected_area_percentage = sum(ndvi(:) < 0.3) / numel(ndvi) * 100;
            
            if mite_info.risk_score > 0.6
                mite_info.status = 'High Risk';
            elseif mite_info.risk_score > 0.3
                mite_info.status = 'Medium Risk';
            else
                mite_info.status = 'Low Risk';
            end
        end
        
        function caterpillar_info = detectCaterpillars(obj, vegetation_indices, crop_health)
            %% Detect Caterpillars
            caterpillar_info = struct();
            caterpillar_info.type = 'Caterpillars';
            
            % Caterpillars cause defoliation
            ndvi = vegetation_indices.ndvi;
            savi = vegetation_indices.savi;
            
            caterpillar_info.risk_score = obj.calculatePestRisk(ndvi, savi, 0.25, 0.2);
            caterpillar_info.confidence = 0.8;
            caterpillar_info.affected_area_percentage = sum(ndvi(:) < 0.25) / numel(ndvi) * 100;
            
            if caterpillar_info.risk_score > 0.6
                caterpillar_info.status = 'High Risk';
            elseif caterpillar_info.risk_score > 0.3
                caterpillar_info.status = 'Medium Risk';
            else
                caterpillar_info.status = 'Low Risk';
            end
        end
        
        function risk_score = calculatePestRisk(obj, index1, index2, threshold1, threshold2)
            %% Calculate Pest Risk Score
            mean1 = mean(index1(:));
            mean2 = mean(index2(:));
            
            % Calculate risk based on how far below thresholds
            risk1 = max(0, (threshold1 - mean1) / threshold1);
            risk2 = max(0, (threshold2 - mean2) / threshold2);
            
            risk_score = (risk1 + risk2) / 2;
        end
        
        function overall_presence = calculateOverallPestPresence(obj, pest_detection)
            %% Calculate Overall Pest Presence
            overall_presence = struct();
            
            % Collect risk scores from all pests
            risk_scores = [];
            for i = 1:length(obj.pest_types)
                pest_type = obj.pest_types{i};
                field_name = lower(strrep(pest_type, ' ', '_'));
                pest_info = pest_detection.(field_name);
                risk_scores(end+1) = pest_info.risk_score;
            end
            
            % Calculate overall presence
            overall_presence.max_risk = max(risk_scores);
            overall_presence.mean_risk = mean(risk_scores);
            overall_presence.high_risk_pests = sum(risk_scores > 0.6);
            
            if overall_presence.max_risk > 0.6
                overall_presence.status = 'High Pest Pressure';
            elseif overall_presence.mean_risk > 0.3
                overall_presence.status = 'Medium Pest Pressure';
            else
                overall_presence.status = 'Low Pest Pressure';
            end
        end
        
        function overall_risk = calculateOverallRisk(obj, pest_risks)
            %% Calculate Overall Risk Score
            overall_risk = struct();
            
            % Collect risk components
            spectral_risk = pest_risks.spectral_analysis.stress_indicators.overall_stress;
            environmental_risk = pest_risks.environmental_analysis.overall_risk.score;
            pest_presence_risk = pest_risks.pest_detection.overall_pest_presence.mean_risk;
            
            % Calculate weighted overall risk
            weights = [0.3, 0.3, 0.4]; % Spectral, Environmental, Pest Presence
            risk_scores = [spectral_risk, environmental_risk, pest_presence_risk];
            
            % Ensure all values are scalars
            if ~isscalar(spectral_risk)
                spectral_risk = mean(spectral_risk(:));
            end
            if ~isscalar(environmental_risk)
                environmental_risk = mean(environmental_risk(:));
            end
            if ~isscalar(pest_presence_risk)
                pest_presence_risk = mean(pest_presence_risk(:));
            end
            
            risk_scores = [spectral_risk, environmental_risk, pest_presence_risk];
            overall_risk.score = sum(weights .* risk_scores);
            
            % Determine risk level
            if overall_risk.score >= obj.pest_thresholds.high_risk
                overall_risk.level = 'High';
            elseif overall_risk.score >= obj.pest_thresholds.medium_risk
                overall_risk.level = 'Medium';
            else
                overall_risk.level = 'Low';
            end
            
            % Calculate confidence
            overall_risk.confidence = 1 - std(risk_scores) / mean(risk_scores);
            overall_risk.confidence = max(0, min(1, overall_risk.confidence));
        end
        
        function risk_map = generateRiskMap(obj, processed_spectral, pest_risks)
            %% Generate Pest Risk Map (pixel-wise)
            % Combines per-pixel spectral stress deficits, anomaly, moisture and light favorability
            risk_map = struct();

            [H, W, ~] = size(processed_spectral.denoised_data);
            vi = processed_spectral.vegetation_indices;

            % 1) Spectral stress deficits (lower index => higher deficit)
            % thresholds chosen to mirror specific pest detectors and general vigor
            thr_ndvi  = 0.35;  % general vigor
            thr_gndvi = 0.30;  % chlorophyll
            thr_ndre  = 0.20;  % red-edge stress

            ndvi  = vi.ndvi;  
            gndvi = vi.gndvi; 
            ndre  = vi.ndre;

            risk_ndvi  = max(0, (thr_ndvi  - ndvi)  ./ max(thr_ndvi,  eps));
            risk_gndvi = max(0, (thr_gndvi - gndvi) ./ max(thr_gndvi, eps));
            risk_ndre  = max(0, (thr_ndre  - ndre)  ./ max(thr_ndre,  eps));
            spectral_stress = (risk_ndvi + risk_gndvi + risk_ndre) / 3; % HxW

            % 2) Spectral anomaly (0..1 already)
            anomaly_map = pest_risks.spectral_analysis.spectral_anomalies.anomaly_map;
            anomaly_map = min(1, max(0, anomaly_map));

            % 3) Moisture favorability from NDWI (wetter => more favorable for many pests)
            ndwi = vi.ndwi; % scale approx [-0.2 .. 0.3]
            moisture_component = (ndwi - (-0.1)) ./ (0.3 - (-0.1)); % map -0.1->0, 0.3->1
            moisture_component = min(1, max(0, moisture_component));

            % 4) Low-light favorability from visible bands (lower light => higher risk)
            vis = processed_spectral.denoised_data(:, :, 1:3);
            vis_mean = mean(vis, 3);
            light_component = (0.3 - vis_mean) ./ 0.3; % <0.3 favors pests
            light_component = min(1, max(0, light_component));

            % 5) Weighted combination to overall pixel-wise pest risk score in [0,1]
            w_stress = 0.4; w_anom = 0.2; w_moist = 0.2; w_light = 0.2;
            risk_score_px = w_stress*spectral_stress + w_anom*anomaly_map + w_moist*moisture_component + w_light*light_component;
            risk_score_px = min(1, max(0, risk_score_px));

            % 6) Discretize to Low/Medium/High per pixel
            risk_levels = ones(H, W); % 1=Low, 2=Medium, 3=High
            risk_levels(risk_score_px >= obj.pest_thresholds.medium_risk) = 2;
            risk_levels(risk_score_px >= obj.pest_thresholds.high_risk)   = 3;

            risk_map.data = risk_levels;
            risk_map.score = risk_score_px;
            risk_map.rgb  = obj.createRiskRGB(risk_levels);
            risk_map.labels = {'Low Risk', 'Medium Risk', 'High Risk'};
            risk_map.colors = [0 1 0; 1 1 0; 1 0 0]; % Green, Yellow, Red
        end
        
        function rgb_image = createRiskRGB(obj, risk_data)
            %% Create RGB Visualization of Risk Map
            rgb_image = zeros(size(risk_data, 1), size(risk_data, 2), 3);
            
            % Green channel (low risk)
            rgb_image(:, :, 2) = (risk_data == 1) * 1.0;
            
            % Yellow channel (medium risk) - combination of red and green
            rgb_image(:, :, 1) = (risk_data == 2) * 1.0;
            rgb_image(:, :, 2) = rgb_image(:, :, 2) + (risk_data == 2) * 1.0;
            
            % Red channel (high risk)
            rgb_image(:, :, 1) = rgb_image(:, :, 1) + (risk_data == 3) * 1.0;
        end
        
        function recommendations = generatePestRecommendations(obj, pest_risks)
            %% Generate Pest Management Recommendations
            recommendations = {};
            
            % Overall risk recommendations
            overall_risk = pest_risks.overall_risk.level;
            switch overall_risk
                case 'High'
                    recommendations{end+1} = 'Immediate pest control measures required';
                    recommendations{end+1} = 'Consider biological control agents';
                    recommendations{end+1} = 'Monitor crop health closely';
                case 'Medium'
                    recommendations{end+1} = 'Implement preventive measures';
                    recommendations{end+1} = 'Increase monitoring frequency';
                    recommendations{end+1} = 'Consider early intervention';
                case 'Low'
                    recommendations{end+1} = 'Continue regular monitoring';
                    recommendations{end+1} = 'Maintain good cultural practices';
            end
            
            % Specific pest recommendations
            pest_detection = pest_risks.pest_detection;
            for i = 1:length(obj.pest_types)
                pest_type = obj.pest_types{i};
                field_name = lower(strrep(pest_type, ' ', '_'));
                pest_info = pest_detection.(field_name);
                
                if pest_info.risk_score > 0.6
                    recommendations{end+1} = sprintf('High risk of %s detected - consider targeted treatment', pest_type);
                elseif pest_info.risk_score > 0.3
                    recommendations{end+1} = sprintf('Monitor for %s activity', pest_type);
                end
            end
            
            % Environmental recommendations
            environmental_analysis = pest_risks.environmental_analysis;
            if environmental_analysis.temperature_analysis.risk_level > 0.6
                recommendations{end+1} = 'Temperature conditions favor pest development';
            end
            if environmental_analysis.humidity_analysis.risk_level > 0.6
                recommendations{end+1} = 'High humidity conditions - monitor for fungal diseases';
            end
        end
    end
end
