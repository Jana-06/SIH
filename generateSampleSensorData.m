function sensor_data = generateSampleSensorData()
%% Generate Sample Sensor Data
% Creates synthetic sensor data for soil and environmental monitoring

% Time series data (24 hours, hourly measurements)
num_hours = 24;
sensor_data = struct();

% Generate timestamps
sensor_data.timestamp = datetime(2024, 1, 1, 0:23, 0, 0);

% Soil moisture data (%)
base_moisture = 0.4;
moisture_variation = 0.1 * sin(2*pi*(0:num_hours-1)/24) + 0.05 * randn(1, num_hours);
sensor_data.soil_moisture = max(0, min(1, base_moisture + moisture_variation));

% Soil temperature data (Celsius)
base_temp = 20;
temp_variation = 5 * sin(2*pi*(0:num_hours-1)/24 + pi) + 2 * randn(1, num_hours);
sensor_data.soil_temperature = base_temp + temp_variation;

% Air temperature data (Celsius)
air_temp_variation = 8 * sin(2*pi*(0:num_hours-1)/24 + pi) + 3 * randn(1, num_hours);
sensor_data.air_temperature = base_temp + air_temp_variation;

% Humidity data (%)
base_humidity = 60;
humidity_variation = 20 * sin(2*pi*(0:num_hours-1)/24 + pi/2) + 5 * randn(1, num_hours);
sensor_data.humidity = max(0, min(100, base_humidity + humidity_variation));

% pH data
base_ph = 6.5;
ph_variation = 0.3 * sin(2*pi*(0:num_hours-1)/24) + 0.1 * randn(1, num_hours);
sensor_data.ph = max(4, min(9, base_ph + ph_variation));

% Electrical conductivity (dS/m)
base_ec = 1.2;
ec_variation = 0.2 * sin(2*pi*(0:num_hours-1)/24) + 0.05 * randn(1, num_hours);
sensor_data.electrical_conductivity = max(0, base_ec + ec_variation);

% Light intensity (lux)
base_light = 50000;
light_variation = 40000 * sin(2*pi*(0:num_hours-1)/24) + 5000 * randn(1, num_hours);
sensor_data.light_intensity = max(0, base_light + light_variation);

% Wind speed (m/s)
base_wind = 2;
wind_variation = 3 * sin(2*pi*(0:num_hours-1)/24 + pi/3) + 1 * randn(1, num_hours);
sensor_data.wind_speed = max(0, base_wind + wind_variation);

% Rainfall (mm)
rainfall_events = zeros(1, num_hours);
rainfall_events(6:8) = [2, 5, 3]; % Rain event in early morning
rainfall_events(18:20) = [1, 4, 2]; % Rain event in evening
sensor_data.rainfall = rainfall_events;

% Save sample data
if ~exist('data', 'dir')
    mkdir('data');
end
save('data/sensor_data.mat', 'sensor_data');

fprintf('Generated sample sensor data for %d hours\n', num_hours);
fprintf('Sensors included: soil moisture, temperature, humidity, pH, EC, light, wind, rainfall\n');

end
