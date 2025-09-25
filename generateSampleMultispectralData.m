function multispectral_data = generateSampleMultispectralData(height, width, num_bands)
%% Generate Sample Multispectral Data
% Creates synthetic multispectral data for testing and demonstration

% Define band characteristics (defaults)
band_info = struct();
band_info.names = {'Blue', 'Green', 'Red', 'NIR', 'RedEdge1', 'RedEdge2', 'RedEdge3', 'SWIR1'};
band_info.wavelengths = [475, 560, 668, 840, 705, 740, 783, 1610];
band_info.typical_values = [0.1, 0.15, 0.2, 0.4, 0.25, 0.3, 0.35, 0.1];

% Provide sensible defaults so the function can be run without inputs
if nargin < 1 || isempty(height), height = 256; end
if nargin < 2 || isempty(width),  width  = 256; end
if nargin < 3 || isempty(num_bands), num_bands = numel(band_info.names); end

% Clamp number of bands to those defined in band_info
available_bands = numel(band_info.names);
if num_bands > available_bands
    warning('Requested %d bands, but only %d are defined. Using %d bands.', num_bands, available_bands, available_bands);
    num_bands = available_bands;
end
if num_bands < 1
    error('num_bands must be >= 1');
end

% Trim band_info to used bands
band_info.names = band_info.names(1:num_bands);
band_info.wavelengths = band_info.wavelengths(1:num_bands);
band_info.typical_values = band_info.typical_values(1:num_bands);

% Initialize data structure
multispectral_data = zeros(height, width, num_bands);

% Create different crop areas with varying health
[X, Y] = meshgrid(1:width, 1:height);

% Healthy crop area (center)
healthy_mask = ((X - width/2).^2 + (Y - height/2).^2) < (min(width, height)/4)^2;

% Stressed crop area (top-right)
stressed_mask = (X > width*0.6) & (Y < height*0.4);

% Bare soil area (bottom-left)
soil_mask = (X < width*0.3) & (Y > height*0.7);

% Water area (top-left)
water_mask = (X < width*0.2) & (Y < height*0.2);

% Generate data for each band
for band = 1:num_bands
    band_data = zeros(height, width);
    
    % Base values for different areas
    if band <= 3 % Visible bands (Blue, Green, Red)
        % Healthy vegetation: low visible reflectance
        band_data(healthy_mask) = band_info.typical_values(band) * 0.3;
        % Stressed vegetation: higher visible reflectance
        band_data(stressed_mask) = band_info.typical_values(band) * 0.7;
        % Bare soil: high visible reflectance
        band_data(soil_mask) = band_info.typical_values(band) * 1.2;
        % Water: very low reflectance
        band_data(water_mask) = band_info.typical_values(band) * 0.1;
    elseif band == 4 % NIR
        % Healthy vegetation: high NIR reflectance
        band_data(healthy_mask) = band_info.typical_values(band) * 1.5;
        % Stressed vegetation: lower NIR reflectance
        band_data(stressed_mask) = band_info.typical_values(band) * 0.8;
        % Bare soil: moderate NIR reflectance
        band_data(soil_mask) = band_info.typical_values(band) * 0.6;
        % Water: very low NIR reflectance
        band_data(water_mask) = band_info.typical_values(band) * 0.05;
    else % RedEdge and SWIR bands
        % Healthy vegetation: moderate reflectance
        band_data(healthy_mask) = band_info.typical_values(band) * 1.2;
        % Stressed vegetation: lower reflectance
        band_data(stressed_mask) = band_info.typical_values(band) * 0.6;
        % Bare soil: moderate reflectance
        band_data(soil_mask) = band_info.typical_values(band) * 0.8;
        % Water: low reflectance
        band_data(water_mask) = band_info.typical_values(band) * 0.1;
    end
    
    % Add noise to make it more realistic
    noise = 0.05 * randn(height, width);
    band_data = band_data + noise;
    
    % Ensure values are in valid range [0, 1]
    band_data = max(0, min(1, band_data));
    
    multispectral_data(:, :, band) = band_data;
end

% Save sample data for future use
if ~exist('data', 'dir')
    mkdir('data');
end
save('data/multispectral_data.mat', 'multispectral_data', 'band_info');

fprintf('Generated sample multispectral data with %d bands\n', num_bands);
fprintf('Data dimensions: %dx%dx%d\n', height, width, num_bands);

end
