classdef SpectralImageProcessor < handle
    %% Spectral Image Processor
    % Processes multispectral/hyperspectral images for agricultural monitoring
    
    properties
        bands
        wavelengths
        band_names
    end
    
    methods
        function obj = SpectralImageProcessor()
            %% Constructor
            obj.bands = 8;
            obj.wavelengths = [475, 560, 668, 840, 705, 740, 783, 1610];
            obj.band_names = {'Blue', 'Green', 'Red', 'NIR', 'RedEdge1', 'RedEdge2', 'RedEdge3', 'SWIR1'};
        end
        
        function processed_data = processImage(obj, raw_data)
            %% Process Raw Spectral Image Data
            % Input: raw_data - multispectral image data (height x width x bands)
            % Output: processed_data - structure with processed spectral data
            
            fprintf('Processing spectral image data...\n');
            
            % Initialize processed data structure
            processed_data = struct();
            processed_data.raw_data = raw_data;
            processed_data.height = size(raw_data, 1);
            processed_data.width = size(raw_data, 2);
            processed_data.num_bands = size(raw_data, 3);
            
            % Apply radiometric correction
            processed_data.corrected_data = obj.applyRadiometricCorrection(raw_data);
            
            % Calculate vegetation indices
            processed_data.vegetation_indices = obj.calculateVegetationIndices(processed_data.corrected_data);
            
            % Apply atmospheric correction (simplified)
            processed_data.atmospherically_corrected = obj.applyAtmosphericCorrection(processed_data.corrected_data);
            
            % Calculate spectral features
            processed_data.spectral_features = obj.extractSpectralFeatures(processed_data.atmospherically_corrected);
            
            % Apply noise reduction
            processed_data.denoised_data = obj.applyNoiseReduction(processed_data.atmospherically_corrected);
            
            fprintf('Spectral image processing completed.\n');
        end
        
        function corrected_data = applyRadiometricCorrection(obj, raw_data)
            %% Apply Radiometric Correction
            % Simple radiometric correction to convert DN to reflectance
            
            % Normalize to reflectance (0-1 range)
            % If data already appears to be in [0,1], skip 16-bit scaling
            raw_double = double(raw_data);
            if isa(raw_data, 'uint16') || max(raw_double(:)) > 1 + eps
                corrected_data = raw_double / 65535; % Assuming 16-bit data
            else
                corrected_data = raw_double; % Already in reflectance range
            end
            
            % Apply band-specific corrections
            for band = 1:size(raw_data, 3)
                band_data = corrected_data(:, :, band);
                
                % Remove outliers (values > 99th percentile)
                threshold = prctile(band_data(:), 99);
                band_data(band_data > threshold) = threshold;
                
                % Apply gain and offset correction (simplified)
                gain = 1.0 + 0.1 * randn(); % Simulate calibration factors
                offset = 0.01 * randn();
                band_data = gain * band_data + offset;
                
                % Ensure values are in valid range
                band_data = max(0, min(1, band_data));
                
                corrected_data(:, :, band) = band_data;
            end
        end
        
        function vegetation_indices = calculateVegetationIndices(obj, corrected_data)
            %% Calculate Vegetation Indices
            % Computes various vegetation indices for crop health assessment
            
            vegetation_indices = struct();
            
            % Extract bands (assuming standard band order)
            blue = corrected_data(:, :, 1);
            green = corrected_data(:, :, 2);
            red = corrected_data(:, :, 3);
            nir = corrected_data(:, :, 4);
            rededge1 = corrected_data(:, :, 5);
            rededge2 = corrected_data(:, :, 6);
            rededge3 = corrected_data(:, :, 7);
            swir1 = corrected_data(:, :, 8);
            
            % NDVI (Normalized Difference Vegetation Index)
            vegetation_indices.ndvi = (nir - red) ./ (nir + red + eps);
            
            % GNDVI (Green Normalized Difference Vegetation Index)
            vegetation_indices.gndvi = (nir - green) ./ (nir + green + eps);
            
            % NDRE (Normalized Difference Red Edge)
            vegetation_indices.ndre = (nir - rededge1) ./ (nir + rededge1 + eps);
            
            % SAVI (Soil Adjusted Vegetation Index)
            L = 0.5; % Soil adjustment factor
            vegetation_indices.savi = ((nir - red) ./ (nir + red + L)) * (1 + L);
            
            % EVI (Enhanced Vegetation Index)
            vegetation_indices.evi = 2.5 * (nir - red) ./ (nir + 6*red - 7.5*blue + 1 + eps);
            
            % NDWI (Normalized Difference Water Index)
            vegetation_indices.ndwi = (green - nir) ./ (green + nir + eps);
            
            % MSR (Modified Simple Ratio) - use element-wise operations
            sr = nir ./ (red + eps);
            vegetation_indices.msr = (sr - 1) ./ sqrt(sr + 1 + eps);
            
            % CI (Chlorophyll Index) - element-wise
            vegetation_indices.ci = (nir ./ (rededge1 + eps)) - 1;
            
            % Handle NaN and infinite values
            field_names = fieldnames(vegetation_indices);
            for i = 1:length(field_names)
                index_data = vegetation_indices.(field_names{i});
                index_data(isnan(index_data) | isinf(index_data)) = 0;
                vegetation_indices.(field_names{i}) = index_data;
            end
        end
        
        function corrected_data = applyAtmosphericCorrection(obj, data)
            %% Apply Atmospheric Correction
            % Simplified atmospheric correction using dark object subtraction
            
            corrected_data = data;
            
            for band = 1:size(data, 3)
                band_data = data(:, :, band);
                
                % Find dark objects (lowest 1% of pixels)
                dark_threshold = prctile(band_data(:), 1);
                dark_object_value = mean(band_data(band_data <= dark_threshold));
                
                % Subtract dark object value
                band_data = band_data - dark_object_value;
                
                % Ensure non-negative values
                band_data = max(0, band_data);
                
                corrected_data(:, :, band) = band_data;
            end
        end
        
        function spectral_features = extractSpectralFeatures(obj, data)
            %% Extract Spectral Features
            % Extracts statistical and spectral features from the data
            
            spectral_features = struct();
            
            % Statistical features for each band
            for band = 1:size(data, 3)
                band_data = data(:, :, band);
                band_name = obj.band_names{band};
                
                spectral_features.(['mean_' band_name]) = mean(band_data(:));
                spectral_features.(['std_' band_name]) = std(band_data(:));
                spectral_features.(['min_' band_name]) = min(band_data(:));
                spectral_features.(['max_' band_name]) = max(band_data(:));
                spectral_features.(['median_' band_name]) = median(band_data(:));
            end
            
            % Spectral ratios
            red = data(:, :, 3);
            nir = data(:, :, 4);
            green = data(:, :, 2);
            
            spectral_features.red_nir_ratio = mean(red(:)) / (mean(nir(:)) + eps);
            spectral_features.green_nir_ratio = mean(green(:)) / (mean(nir(:)) + eps);
            
            % Texture features (simplified)
            spectral_features.texture_energy = obj.calculateTextureEnergy(data);
        end
        
        function texture_energy = calculateTextureEnergy(obj, data)
            %% Calculate Texture Energy
            % Simple texture energy calculation using local standard deviation
            
            % Use NIR band for texture calculation
            nir_band = data(:, :, 4);
            
            % Calculate local standard deviation (3x3 window)
            texture_energy = stdfilt(nir_band, ones(3, 3));
            texture_energy = mean(texture_energy(:));
        end
        
        function denoised_data = applyNoiseReduction(obj, data)
            %% Apply Noise Reduction
            % Applies median filtering to reduce noise
            
            denoised_data = data;
            
            for band = 1:size(data, 3)
                band_data = data(:, :, band);
                
                % Apply median filter (3x3 window)
                denoised_band = medfilt2(band_data, [3, 3]);
                
                denoised_data(:, :, band) = denoised_band;
            end
        end
    end
end
