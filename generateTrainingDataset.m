function generateTrainingDataset(output_dir, num_samples, options)
%% Generate Training Dataset for Agricultural Monitoring
% Creates synthetic CSV and image data for training the pipeline
%
% Input:
%   output_dir - directory to save dataset
%   num_samples - number of samples to generate
%   options - generation options

if nargin < 3
    options = struct();
end

if nargin < 2
    num_samples = 1000;
end

if nargin < 1
    output_dir = 'training_data';
end

fprintf('Generating training dataset with %d samples...\n', num_samples);

% Create output directory
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% Create images subdirectory
images_dir = fullfile(output_dir, 'images');
if ~exist(images_dir, 'dir')
    mkdir(images_dir);
end

% Generate timestamps
start_date = datetime(2024, 1, 1);
timestamps = start_date + days(rand(num_samples, 1) * 365);

% Generate sensor data
sensor_data = struct();
sensor_data.soil_moisture = 0.3 + 0.4 * rand(num_samples, 1);
sensor_data.soil_temperature = 15 + 15 * rand(num_samples, 1);
sensor_data.air_temperature = 10 + 20 * rand(num_samples, 1);
sensor_data.humidity = 40 + 40 * rand(num_samples, 1);
sensor_data.ph = 5.5 + 2.5 * rand(num_samples, 1);
sensor_data.electrical_conductivity = 0.5 + 2.0 * rand(num_samples, 1);
sensor_data.light_intensity = 10000 + 40000 * rand(num_samples, 1);
sensor_data.wind_speed = 0 + 10 * rand(num_samples, 1);

% Generate weather data
weather_data = struct();
weather_data.precipitation = zeros(num_samples, 1);
rain_indices = rand(num_samples, 1) < 0.1;
weather_data.precipitation(rain_indices) = 1 + 10 * rand(sum(rain_indices), 1);
weather_data.atmospheric_pressure = 1000 + 50 * rand(num_samples, 1);

% Generate image filenames
image_filenames = cell(num_samples, 1);
for i = 1:num_samples
    image_filenames{i} = sprintf('image_%04d.png', i);
end

% Generate labels (optional)
labels = cell(num_samples, 1);
for i = 1:num_samples
    % Simple label generation based on sensor data
    if sensor_data.soil_moisture(i) > 0.6 && sensor_data.soil_temperature(i) > 20
        labels{i} = 'Healthy';
    elseif sensor_data.soil_moisture(i) < 0.3 || sensor_data.soil_temperature(i) < 15
        labels{i} = 'Stressed';
    else
        labels{i} = 'Moderate';
    end
end

% Create table
T = table();
T.timestamp = timestamps;
T.soil_moisture = sensor_data.soil_moisture;
T.soil_temperature = sensor_data.soil_temperature;
T.air_temperature = sensor_data.air_temperature;
T.humidity = sensor_data.humidity;
T.ph = sensor_data.ph;
T.electrical_conductivity = sensor_data.electrical_conductivity;
T.light_intensity = sensor_data.light_intensity;
T.wind_speed = sensor_data.wind_speed;
T.precipitation = weather_data.precipitation;
T.atmospheric_pressure = weather_data.atmospheric_pressure;
T.image_filename = image_filenames;
T.label = labels;

% Save CSV
csv_path = fullfile(output_dir, 'dataset.csv');
writetable(T, csv_path);
fprintf('CSV dataset saved to: %s\n', csv_path);

% Generate synthetic images
fprintf('Generating %d synthetic images...\n', num_samples);
for i = 1:num_samples
    % Generate synthetic multispectral-like image
    image_data = generateSyntheticImage(sensor_data, i, options);
    
    % Save image
    image_path = fullfile(images_dir, image_filenames{i});
    imwrite(image_data, image_path);
    
    if mod(i, 100) == 0
        fprintf('Generated %d/%d images\n', i, num_samples);
    end
end

fprintf('Training dataset generation completed!\n');
fprintf('Dataset saved to: %s\n', output_dir);
fprintf('CSV file: %s\n', csv_path);
fprintf('Images directory: %s\n', images_dir);

end

function image_data = generateSyntheticImage(sensor_data, sample_idx, options)
%% Generate Synthetic Image based on Sensor Data
% Creates a synthetic multispectral-like image based on sensor readings

% Image size
if isfield(options, 'image_size')
    image_size = options.image_size;
else
    image_size = [224, 224];
end

% Create base image
image_data = zeros(image_size(1), image_size(2), 3);

% Generate different regions based on sensor data
moisture = sensor_data.soil_moisture(sample_idx);
temperature = sensor_data.soil_temperature(sample_idx);
ph = sensor_data.ph(sample_idx);

% Create healthy vegetation region (center)
center_x = image_size(2) / 2;
center_y = image_size(1) / 2;
radius = min(image_size) / 4;

[X, Y] = meshgrid(1:image_size(2), 1:image_size(1));
distance = sqrt((X - center_x).^2 + (Y - center_y).^2);

% Healthy vegetation (green)
healthy_mask = distance < radius;
if moisture > 0.5 && temperature > 20
    image_data(healthy_mask) = 0.2; % Red channel
    image_data(healthy_mask + numel(image_data)/3) = 0.8; % Green channel
    image_data(healthy_mask + 2*numel(image_data)/3) = 0.1; % Blue channel
else
    % Stressed vegetation (yellowish)
    image_data(healthy_mask) = 0.6; % Red channel
    image_data(healthy_mask + numel(image_data)/3) = 0.6; % Green channel
    image_data(healthy_mask + 2*numel(image_data)/3) = 0.1; % Blue channel
end

% Create soil regions
soil_mask = distance >= radius & distance < radius * 1.5;
if ph > 6.5
    % Alkaline soil (brownish)
    image_data(soil_mask) = 0.4; % Red channel
    image_data(soil_mask + numel(image_data)/3) = 0.3; % Green channel
    image_data(soil_mask + 2*numel(image_data)/3) = 0.2; % Blue channel
else
    % Acidic soil (reddish)
    image_data(soil_mask) = 0.6; % Red channel
    image_data(soil_mask + numel(image_data)/3) = 0.2; % Green channel
    image_data(soil_mask + 2*numel(image_data)/3) = 0.1; % Blue channel
end

% Create water regions (if high moisture)
if moisture > 0.7
    water_mask = distance >= radius * 1.5;
    image_data(water_mask) = 0.1; % Red channel
    image_data(water_mask + numel(image_data)/3) = 0.3; % Green channel
    image_data(water_mask + 2*numel(image_data)/3) = 0.8; % Blue channel
end

% Add noise
noise_level = 0.05;
image_data = image_data + noise_level * randn(size(image_data));
image_data = max(0, min(1, image_data)); % Clamp values

% Convert to uint8
image_data = uint8(image_data * 255);

end
