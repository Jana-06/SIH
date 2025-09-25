classdef TrainedModelInference < handle
    %% Trained Model Inference System
    % Integrates trained models with real-time agricultural monitoring
    
    properties
        trained_models
        feature_extractor
        inference_cache
        performance_tracker
    end
    
    methods
        function obj = TrainedModelInference(model_dir)
            %% Constructor
            if nargin < 1
                model_dir = 'models';
            end
            
            obj.trained_models = struct();
            obj.feature_extractor = struct();
            obj.inference_cache = struct();
            obj.performance_tracker = struct();
            
            % Load trained models
            obj.loadTrainedModels(model_dir);
            
            % Initialize feature extractor
            obj.initializeFeatureExtractor();
            
            % Initialize performance tracking
            obj.initializePerformanceTracking();
        end
        
        function loadTrainedModels(obj, model_dir)
            %% Load Trained Models
            fprintf('Loading trained models from %s...\n', model_dir);
            
            try
                % Load models using the provided loadModels function
                models = loadModels(model_dir);
                
                obj.trained_models.kmeans = models.kmeans;
                obj.trained_models.ocsvm = models.ocsvm;
                obj.trained_models.meta = models.meta;
                
                % Check if supervised model exists
                supervised_path = fullfile(model_dir, 'supervisedModel.mat');
                if exist(supervised_path, 'file')
                    supervised_data = load(supervised_path);
                    fn = fieldnames(supervised_data);
                    obj.trained_models.supervised = supervised_data.(fn{1});
                end
                
                fprintf('Trained models loaded successfully.\n');
                
            catch ME
                fprintf('Error loading trained models: %s\n', ME.message);
                obj.trained_models = struct();
            end
        end
        
        function initializeFeatureExtractor(obj)
            %% Initialize Feature Extractor
            fprintf('Initializing feature extractor...\n');
            
            % Initialize ResNet-18 for image feature extraction
            try
                obj.feature_extractor.net = resnet18;
                obj.feature_extractor.feature_layer = 'avg_pool';
                obj.feature_extractor.input_size = obj.feature_extractor.net.Layers(1).InputSize(1:2);
                fprintf('ResNet-18 feature extractor initialized.\n');
            catch ME
                fprintf('Warning: Could not initialize ResNet-18: %s\n', ME.message);
                obj.feature_extractor.net = [];
            end
        end
        
        function initializePerformanceTracking(obj)
            %% Initialize Performance Tracking
            obj.performance_tracker.inference_times = [];
            obj.performance_tracker.accuracy_scores = [];
            obj.performance_tracker.cache_hits = 0;
            obj.performance_tracker.cache_misses = 0;
        end
        
        function inference_results = performInference(obj, multispectral_data, sensor_data, image_data, options)
            %% Perform Inference using Trained Models
            % Input: multispectral_data - spectral image data
            %        sensor_data - sensor measurements
            %        image_data - RGB image data (optional)
            %        options - inference options
            % Output: inference_results - inference results
            
            if nargin < 5
                options = struct();
            end
            
            start_time = tic;
            
            % Initialize results
            inference_results = struct();
            inference_results.timestamp = datetime('now');
            inference_results.success = false;
            inference_results.inference_time = 0;
            
            try
                % Step 1: Extract features
                features = obj.extractFeatures(multispectral_data, sensor_data, image_data, options);
                inference_results.features = features;
                
                % Step 2: Normalize features using trained model metadata
                normalized_features = obj.normalizeFeatures(features);
                inference_results.normalized_features = normalized_features;
                
                % Step 3: Perform clustering
                clustering_results = obj.performClustering(normalized_features);
                inference_results.clustering = clustering_results;
                
                % Step 4: Perform anomaly detection
                anomaly_results = obj.performAnomalyDetection(normalized_features);
                inference_results.anomaly = anomaly_results;
                
                % Step 5: Perform supervised classification (if available)
                if isfield(obj.trained_models, 'supervised')
                    classification_results = obj.performClassification(normalized_features);
                    inference_results.classification = classification_results;
                end
                
                % Step 6: Generate integrated results
                integrated_results = obj.generateIntegratedResults(inference_results);
                inference_results.integrated = integrated_results;
                
                inference_results.success = true;
                
            catch ME
                inference_results.error = ME.message;
                fprintf('Error in inference: %s\n', ME.message);
            end
            
            % Record performance
            inference_results.inference_time = toc(start_time);
            obj.updatePerformanceTracking(inference_results);
            
            fprintf('Inference completed in %.3f seconds\n', inference_results.inference_time);
        end
        
        function features = extractFeatures(obj, multispectral_data, sensor_data, image_data, options)
            %% Extract Features for Inference
            features = struct();
            
            % Extract spectral features
            features.spectral = obj.extractSpectralFeatures(multispectral_data);
            
            % Extract sensor features
            features.sensor = obj.extractSensorFeatures(sensor_data);
            
            % Extract image features (if available)
            if ~isempty(image_data) && ~isempty(obj.feature_extractor.net)
                features.image = obj.extractImageFeatures(image_data);
            else
                features.image = [];
            end
            
            % Combine features into single vector
            feature_vector = [];
            if ~isempty(features.spectral)
                feature_vector = [feature_vector, features.spectral];
            end
            if ~isempty(features.sensor)
                feature_vector = [feature_vector, features.sensor];
            end
            if ~isempty(features.image)
                feature_vector = [feature_vector, features.image];
            end
            
            features.combined = feature_vector;
        end
        
        function spectral_features = extractSpectralFeatures(obj, multispectral_data)
            %% Extract Spectral Features
            spectral_features = [];
            
            if isempty(multispectral_data)
                return;
            end
            
            % Calculate vegetation indices
            if size(multispectral_data, 3) >= 4
                red = multispectral_data(:, :, 3);
                nir = multispectral_data(:, :, 4);
                green = multispectral_data(:, :, 2);
                blue = multispectral_data(:, :, 1);
                
                % Calculate indices
                ndvi = (nir - red) ./ (nir + red + eps);
                gndvi = (nir - green) ./ (nir + green + eps);
                ndwi = (green - nir) ./ (green + nir + eps);
                
                % Extract statistical features
                spectral_features = [
                    mean(ndvi(:)), std(ndvi(:)), min(ndvi(:)), max(ndvi(:)),
                    mean(gndvi(:)), std(gndvi(:)), min(gndvi(:)), max(gndvi(:)),
                    mean(ndwi(:)), std(ndwi(:)), min(ndwi(:)), max(ndwi(:))
                ];
            end
        end
        
        function sensor_features = extractSensorFeatures(obj, sensor_data)
            %% Extract Sensor Features
            sensor_features = [];
            
            if isempty(sensor_data)
                return;
            end
            
            % Extract features from sensor data
            field_names = fieldnames(sensor_data);
            for i = 1:length(field_names)
                if isnumeric(sensor_data.(field_names{i}))
                    data = sensor_data.(field_names{i});
                    if ~isempty(data)
                        sensor_features = [sensor_features, mean(data), std(data), min(data), max(data)];
                    end
                end
            end
        end
        
        function image_features = extractImageFeatures(obj, image_data)
            %% Extract Image Features using ResNet-18
            image_features = [];
            
            if isempty(obj.feature_extractor.net) || isempty(image_data)
                return;
            end
            
            try
                % Preprocess image
                if size(image_data, 3) == 1
                    image_data = repmat(image_data, [1, 1, 3]); % grayscale -> rgb
                end
                
                % Resize to network input size
                input_size = obj.feature_extractor.input_size;
                image_data = imresize(image_data, input_size);
                image_data = im2single(image_data);
                
                % Extract features
                features = activations(obj.feature_extractor.net, image_data, ...
                    obj.feature_extractor.feature_layer, 'OutputAs', 'rows');
                image_features = features;
                
            catch ME
                fprintf('Error extracting image features: %s\n', ME.message);
                image_features = [];
            end
        end
        
        function normalized_features = normalizeFeatures(obj, features)
            %% Normalize Features using Trained Model Metadata
            normalized_features = features.combined;
            
            if isfield(obj.trained_models, 'meta')
                meta = obj.trained_models.meta;
                if isfield(meta, 'mean') && isfield(meta, 'std')
                    % Ensure feature vector matches training dimensions
                    if length(normalized_features) == length(meta.mean)
                        normalized_features = (normalized_features - meta.mean) ./ (meta.std + eps);
                    else
                        fprintf('Warning: Feature dimension mismatch with training data\n');
                    end
                end
            end
        end
        
        function clustering_results = performClustering(obj, normalized_features)
            %% Perform Clustering using Trained K-Means Model
            clustering_results = struct();
            
            if isfield(obj.trained_models, 'kmeans')
                try
                    [cluster_idx, dist_to_centroid] = predictCluster(normalized_features, 'models');
                    clustering_results.cluster_idx = cluster_idx;
                    clustering_results.dist_to_centroid = dist_to_centroid;
                    clustering_results.confidence = 1 / (1 + dist_to_centroid); % Simple confidence measure
                catch ME
                    fprintf('Error in clustering: %s\n', ME.message);
                    clustering_results.cluster_idx = 1;
                    clustering_results.dist_to_centroid = 1;
                    clustering_results.confidence = 0.5;
                end
            else
                clustering_results.cluster_idx = 1;
                clustering_results.dist_to_centroid = 1;
                clustering_results.confidence = 0.5;
            end
        end
        
        function anomaly_results = performAnomalyDetection(obj, normalized_features)
            %% Perform Anomaly Detection using Trained OC-SVM Model
            anomaly_results = struct();
            
            if isfield(obj.trained_models, 'ocsvm')
                try
                    [is_anomaly, score] = detectAnomaly(normalized_features, 'models');
                    anomaly_results.is_anomaly = is_anomaly;
                    anomaly_results.score = score;
                    anomaly_results.confidence = abs(score); % Confidence based on distance from decision boundary
                catch ME
                    fprintf('Error in anomaly detection: %s\n', ME.message);
                    anomaly_results.is_anomaly = false;
                    anomaly_results.score = 0;
                    anomaly_results.confidence = 0.5;
                end
            else
                anomaly_results.is_anomaly = false;
                anomaly_results.score = 0;
                anomaly_results.confidence = 0.5;
            end
        end
        
        function classification_results = performClassification(obj, normalized_features)
            %% Perform Classification using Trained Supervised Model
            classification_results = struct();
            
            if isfield(obj.trained_models, 'supervised')
                try
                    [predicted_label, score] = predict(obj.trained_models.supervised, normalized_features);
                    classification_results.predicted_label = predicted_label;
                    classification_results.score = score;
                    classification_results.confidence = max(score);
                catch ME
                    fprintf('Error in classification: %s\n', ME.message);
                    classification_results.predicted_label = 'Unknown';
                    classification_results.score = [];
                    classification_results.confidence = 0.5;
                end
            else
                classification_results.predicted_label = 'Unknown';
                classification_results.score = [];
                classification_results.confidence = 0.5;
            end
        end
        
        function integrated_results = generateIntegratedResults(obj, inference_results)
            %% Generate Integrated Results
            integrated_results = struct();
            
            % Combine clustering and anomaly results
            clustering = inference_results.clustering;
            anomaly = inference_results.anomaly;
            
            % Determine overall status
            if anomaly.is_anomaly
                integrated_results.status = 'Anomaly Detected';
                integrated_results.risk_level = 'High';
            elseif clustering.confidence < 0.5
                integrated_results.status = 'Uncertain';
                integrated_results.risk_level = 'Medium';
            else
                integrated_results.status = 'Normal';
                integrated_results.risk_level = 'Low';
            end
            
            % Calculate overall confidence
            integrated_results.confidence = mean([clustering.confidence, anomaly.confidence]);
            
            % Generate recommendations
            integrated_results.recommendations = obj.generateRecommendations(integrated_results, inference_results);
        end
        
        function recommendations = generateRecommendations(obj, integrated_results, inference_results)
            %% Generate Recommendations
            recommendations = {};
            
            switch integrated_results.risk_level
                case 'High'
                    recommendations{end+1} = 'Immediate investigation required - anomaly detected';
                    recommendations{end+1} = 'Increase monitoring frequency';
                    recommendations{end+1} = 'Consider preventive measures';
                case 'Medium'
                    recommendations{end+1} = 'Monitor closely for changes';
                    recommendations{end+1} = 'Verify sensor readings';
                case 'Low'
                    recommendations{end+1} = 'Continue regular monitoring';
            end
            
            % Add clustering-specific recommendations
            if isfield(inference_results, 'clustering')
                cluster_idx = inference_results.clustering.cluster_idx;
                switch cluster_idx
                    case 1
                        recommendations{end+1} = 'Healthy crop conditions detected';
                    case 2
                        recommendations{end+1} = 'Stressed crop conditions - consider intervention';
                    case 3
                        recommendations{end+1} = 'Poor crop conditions - immediate action required';
                end
            end
        end
        
        function updatePerformanceTracking(obj, inference_results)
            %% Update Performance Tracking
            obj.performance_tracker.inference_times(end+1) = inference_results.inference_time;
            
            % Keep only last 100 measurements
            if length(obj.performance_tracker.inference_times) > 100
                obj.performance_tracker.inference_times = obj.performance_tracker.inference_times(end-99:end);
            end
        end
        
        function performance_report = getPerformanceReport(obj)
            %% Get Performance Report
            performance_report = struct();
            performance_report.timestamp = datetime('now');
            
            if ~isempty(obj.performance_tracker.inference_times)
                performance_report.average_inference_time = mean(obj.performance_tracker.inference_times);
                performance_report.min_inference_time = min(obj.performance_tracker.inference_times);
                performance_report.max_inference_time = max(obj.performance_tracker.inference_times);
                performance_report.total_inferences = length(obj.performance_tracker.inference_times);
            else
                performance_report.average_inference_time = 0;
                performance_report.min_inference_time = 0;
                performance_report.max_inference_time = 0;
                performance_report.total_inferences = 0;
            end
            
            performance_report.cache_hit_rate = obj.performance_tracker.cache_hits / ...
                (obj.performance_tracker.cache_hits + obj.performance_tracker.cache_misses + eps);
        end
    end
end
