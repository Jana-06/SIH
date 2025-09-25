# AI-Powered Agricultural Monitoring System

A comprehensive MATLAB-based solution for monitoring crop health, soil condition, and pest risks using multispectral/hyperspectral imaging and sensor data.

## Overview

This system provides AI-powered analysis of agricultural conditions through:

- **Multispectral/Hyperspectral Image Processing**: Advanced spectral analysis using 8-band imagery
- **Crop Health Assessment**: Vegetation index analysis and stress pattern detection
- **Soil Condition Monitoring**: Comprehensive soil parameter analysis
- **Pest Risk Detection**: Environmental and spectral-based pest risk assessment
- **Comprehensive Reporting**: Detailed analysis reports with recommendations

## Features

### 🌱 Crop Health Analysis
- **Vegetation Indices**: NDVI, GNDVI, NDRE, SAVI, EVI, NDWI, MSR, CI
- **Stress Detection**: Water, nutrient, and chlorophyll stress identification
- **Health Mapping**: Spatial distribution of crop health status
- **Anomaly Detection**: Statistical and spatial anomaly identification

### 🌍 Soil Condition Assessment
- **Parameter Analysis**: Moisture, temperature, pH, electrical conductivity
- **Soil Type Classification**: Clay, silt, sand, loam, organic classification
- **Quality Index**: Comprehensive soil quality scoring
- **Recommendations**: Targeted soil management recommendations

### 🐛 Pest Risk Detection
- **Environmental Analysis**: Temperature, humidity, moisture, light conditions
- **Specific Pest Detection**: Aphids, whiteflies, thrips, spider mites, caterpillars
- **Risk Mapping**: Spatial pest risk distribution
- **Preventive Recommendations**: Integrated pest management strategies

### 📊 Advanced Analytics
- **AI/ML Integration**: Machine learning-based classification and prediction
- **Data Fusion**: Integration of spectral and sensor data
- **Statistical Analysis**: Comprehensive statistical evaluation
- **Confidence Assessment**: Analysis confidence scoring

### ⚡ Real-Time Processing
- **Low-Latency Detection**: Sub-500ms processing pipeline
- **Fast Clustering**: Real-time crop zone and anomaly clustering
- **On-Board Processing**: Optimized for edge computing deployment
- **Performance Monitoring**: Continuous latency and accuracy tracking

### 🛡️ Robust Data Handling
- **Missing Data Recovery**: Automatic interpolation and imputation
- **Noise Reduction**: Advanced filtering and calibration
- **Data Quality Assessment**: Comprehensive quality metrics
- **Automatic Calibration**: Self-calibrating sensor integration

### 🔄 Multimodal Fusion
- **Multi-Source Integration**: Sensor + Image + Weather + Temporal data
- **Early/Late Fusion**: Multiple fusion strategies
- **Temporal Analysis**: Time series and trend analysis
- **Weather Integration**: Real-time weather impact assessment

### 🚨 Early Warning System
- **Predictive Analytics**: 7-day ahead predictions
- **Risk Assessment**: Multi-level risk classification
- **Alert Generation**: Automated warning system
- **Recommendation Engine**: Actionable intervention suggestions

### 🧠 Adaptive Learning
- **Continuous Learning**: Online model updates
- **Drift Detection**: Data and concept drift monitoring
- **Performance Optimization**: Automatic hyperparameter tuning
- **Feedback Integration**: User and expert feedback incorporation

### 🎯 Trained Model Pipeline
- **End-to-End Training**: Complete pipeline from data to models
- **Multimodal Features**: Sensor + image + weather + temporal data
- **Robust Preprocessing**: Missing data handling and noise reduction
- **Compact Models**: K-means clustering, One-class SVM, supervised classifiers
- **Fast Inference**: Sub-500ms onboard-ready inference
- **Model Integration**: Seamless integration with monitoring system

## System Requirements

- MATLAB R2019b or later
- Image Processing Toolbox
- Statistics and Machine Learning Toolbox
- Computer Vision Toolbox (recommended)

## Installation

1. Clone or download the project files
2. Ensure all required MATLAB toolboxes are installed
3. Add the project directory to your MATLAB path
4. Run the main script: `main.m`

## Quick Start

### Basic Usage

```matlab
% Run the complete agricultural monitoring analysis
main
```

## Interpreting Visualizations

After running `main`, the system saves visualization images to the `results/` directory and (when the Flask server is used) shows them on the dashboard. Below is a short guide for interpreting the most important images produced by the pipeline.

- Crop Health Map
    - What it is: a three-level classification of per-pixel crop condition derived from vegetation indices.
    - Colors: Red = Unhealthy, Yellow = Stressed, Green = Healthy.
    - Use: check spatial patterns of stress (patches of yellow/red) and prioritize inspection or intervention in red zones.

- NDVI / GNDVI / NDRE Maps
    - What they are: normalized difference indices computed from spectral bands. NDVI emphasizes green biomass; GNDVI uses green band for chlorophyll sensitivity; NDRE highlights red-edge information (useful for canopy chlorophyll and early stress).
    - Colors: default colormaps show low values (cool colors) to high values (warm colors). Read the colorbar next to each image.
    - Use: compare index maps to confirm stress signals. A low NDVI with a low NDRE suggests severe stress, while low NDVI but normal NDRE may indicate surface effects.

- SAVI / EVI Maps
    - What they are: indices designed to compensate for soil brightness (SAVI) and improved atmospheric/soil sensitivity (EVI).
    - Use: rely on SAVI in sparse canopies and EVI in dense canopies for more robust signals.

- Soil Condition Map
    - What it is: visualization of soil moisture/quality across the scene (derived from sensors + spatial interpolation).
    - Use: correlate low soil moisture areas with crop stress on the health map to determine if irrigation is a primary factor.

- Pest Risk / Environmental Maps
    - What they are: risk maps computed from environmental variables and spectral signatures linked to pest presence.
    - Use: treat red/high-risk zones as candidates for targeted scouting or early treatment.

Quick analysis steps
- Run `main` (or press "Run Analysis" on the dashboard).
- Open `results/` and inspect `crop_health_map.png` first for an overview.
- Compare `ndvi_map.png`, `ndre_map.png`, and `gndvi_map.png` to verify regions of low vegetation index.
- Cross-check `soil_condition_map.png` and the pest risk images to identify correlated drivers (water stress vs pests).
- Use the `report` output (console and saved report object) for suggested recommendations generated by the system.

Tips for hackathon improvements
- Use a calibrated real multispectral/hyperspectral dataset instead of the generated samples — the diagnostics become much more meaningful with calibrated reflectance.
- Add temporal differencing (compare two dates) to highlight new stress areas — very persuasive in demos.
- Add an interactive viewer (MATLAB app, or a web zoomable image) so judges can zoom into suspicious patches and see pixel values.

Where files are saved
- Visualizations: `results/` (e.g. `crop_health_map.png`, `ndvi_map.png`, etc.)
- Analysis objects & report: saved by `saveResults.m` in the default output location (see that script for path customization).

If you'd like, I can also add these same instructions directly to the dashboard UI (HTML) under the Instructions section so judges see them during the demo.

### Custom Configuration

```matlab
% Load and modify configuration
config = loadConfiguration();

% Modify thresholds
config.vegetation_indices.ndvi_threshold = 0.4;
config.soil_analysis.moisture_threshold_low = 0.3;

% Run analysis with custom configuration
main
```

### Individual Module Usage

```matlab
% Process spectral data only
spectral_processor = SpectralImageProcessor();
processed_data = spectral_processor.processImage(multispectral_data);

% Analyze crop health
crop_analyzer = CropHealthAnalyzer();
crop_health = crop_analyzer.analyzeHealth(processed_data);

% Assess soil condition
soil_analyzer = SoilConditionAnalyzer();
soil_condition = soil_analyzer.assessCondition(processed_data, sensor_data);

% Detect pest risks
pest_detector = PestRiskDetector();
pest_risks = pest_detector.detectRisks(processed_data, crop_health);
```

## Data Format

### Input Data

#### Multispectral Data
- **Format**: 3D array (height × width × bands)
- **Bands**: 8 bands (Blue, Green, Red, NIR, RedEdge1, RedEdge2, RedEdge3, SWIR1)
- **Data Type**: Double precision (0-1 range)

#### Sensor Data
- **Format**: Structure with time series data
- **Parameters**: Soil moisture, temperature, humidity, pH, EC, light, wind, rainfall
- **Frequency**: Hourly measurements (24 hours)

### Output Data

#### Analysis Results
- **Crop Health**: Health scores, vegetation indices, stress patterns
- **Soil Condition**: Parameter values, quality index, soil type classification
- **Pest Risks**: Risk scores, environmental factors, specific pest detection

#### Visualization
- **Health Maps**: RGB visualization of crop health status
- **Condition Maps**: Soil condition spatial distribution
- **Risk Maps**: Pest risk spatial distribution
- **Statistical Plots**: Bar charts, pie charts, trend analysis

## Configuration

### Vegetation Index Thresholds
```matlab
config.vegetation_indices.ndvi_threshold = 0.3;
config.vegetation_indices.gndvi_threshold = 0.2;
config.vegetation_indices.ndre_threshold = 0.15;
config.vegetation_indices.savi_threshold = 0.2;
```

### Soil Analysis Parameters
```matlab
config.soil_analysis.moisture_threshold_low = 0.2;
config.soil_analysis.moisture_threshold_high = 0.8;
config.soil_analysis.temperature_optimal_min = 15;
config.soil_analysis.temperature_optimal_max = 25;
config.soil_analysis.ph_optimal_min = 6.0;
config.soil_analysis.ph_optimal_max = 7.5;
```

### Pest Detection Thresholds
```matlab
config.pest_detection.risk_threshold_low = 0.3;
config.pest_detection.risk_threshold_medium = 0.6;
config.pest_detection.risk_threshold_high = 0.8;
```

## File Structure

```
SIH/
├── main.m                          # Main analysis script
├── loadConfiguration.m             # Configuration loader
├── generateSampleMultispectralData.m # Sample data generator
├── generateSampleSensorData.m      # Sample sensor data generator
├── modules/                        # Core analysis modules
│   ├── SpectralImageProcessor.m    # Spectral image processing
│   ├── CropHealthAnalyzer.m        # Crop health analysis
│   ├── SoilConditionAnalyzer.m     # Soil condition assessment
│   ├── PestRiskDetector.m          # Pest risk detection
│   └── ReportGenerator.m           # Report generation
├── utils/                          # Utility functions
│   ├── displayResults.m            # Results visualization
│   └── saveResults.m               # Results saving
├── data/                           # Data directory
├── results/                        # Results directory
└── README.md                       # This file
```

## Examples

### Example 1: Basic Analysis
```matlab
% Run complete analysis with sample data
main
```

### Example 2: Training Pipeline
```matlab
% Generate training dataset
generateTrainingDataset('training_data', 1000);

% Train models
trainPipeline('training_data/dataset.csv', 'training_data/images', 'models', ...
    'TrainSupervised', true, 'K', 5);
```

### Example 3: Trained Model Inference
```matlab
% Initialize trained model inference
trained_inference = TrainedModelInference('models');

% Perform inference
results = trained_inference.performInference(multispectral_data, sensor_data, image_data);
fprintf('Status: %s, Risk: %s\n', results.integrated.status, results.integrated.risk_level);
```

### Example 4: Complete Training and Inference Demo
```matlab
% Run complete training and inference demonstration
run('examples/training_and_inference_demo.m')
```

### Example 5: Advanced Features Demo
```matlab
% Run advanced features demonstration
run('examples/advanced_features_demo.m')
```

### Example 6: Real-Time Processing
```matlab
% Initialize real-time detector
realtime_detector = RealTimeDetector();

% Process data in real-time
results = realtime_detector.processRealTime(multispectral_data, 'multispectral');
fprintf('Processing time: %.3f seconds\n', results.processing_time);
```

### Example 7: Robust Data Processing
```matlab
% Initialize robust data processor
robust_processor = RobustDataProcessor();

% Process noisy/missing data
processed_data = robust_processor.processRobustData(raw_data, 'multispectral');
fprintf('Data quality: %s\n', processed_data.final_quality.status);
```

### Example 8: Multimodal Fusion
```matlab
% Initialize multimodal fusion
multimodal_fusion = MultimodalFusion();

% Perform fusion
fusion_results = multimodal_fusion.performMultimodalFusion(...
    multispectral_data, sensor_data, weather_data, temporal_data);
```

### Example 9: Early Warning System
```matlab
% Initialize early warning system
early_warning = EarlyWarningSystem();

% Generate warnings
warning_results = early_warning.generateEarlyWarnings(current_data, historical_data);
```

### Example 10: Adaptive Learning
```matlab
% Initialize adaptive learning
adaptive_learning = AdaptiveLearningSystem();

% Perform learning
learning_results = adaptive_learning.performAdaptiveLearning(...
    new_data, current_models, feedback_data);
```

## Output and Results

### Console Output
The system provides detailed console output including:
- Analysis progress updates
- Key findings and statistics
- Priority actions and recommendations
- Technical summary

### Saved Files
Results are automatically saved to the `results/` directory:
- `crop_health_*.mat`: Crop health analysis results
- `soil_condition_*.mat`: Soil condition analysis results
- `pest_risks_*.mat`: Pest risk analysis results
- `comprehensive_report_*.mat`: Complete analysis report
- `summary_*.csv`: Summary data in CSV format
- `*_map_*.png`: Visualization maps
- `metadata_*.mat`: Analysis metadata

### Visualization
The system generates multiple visualization figures:
- Crop Health Analysis Dashboard
- Soil Condition Analysis Dashboard
- Pest Risk Analysis Dashboard
- Statistical plots and charts

## Troubleshooting

### Common Issues

1. **Memory Issues**: For large images, consider processing in smaller chunks
2. **Toolbox Missing**: Ensure all required toolboxes are installed
3. **Data Format**: Verify input data format matches requirements
4. **Path Issues**: Ensure all project files are in the MATLAB path

### Performance Optimization

1. **Image Size**: Reduce image resolution for faster processing
2. **Band Selection**: Use only necessary spectral bands
3. **Parallel Processing**: Enable parallel computing for large datasets
4. **Memory Management**: Clear unused variables during processing

## Contributing

To contribute to this project:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

## Run and Deploy (Windows and Docker)

The project contains both MATLAB code (analysis) and a small Flask web server (dashboards). Here are the most common ways to run it.

### Option A: Run MATLAB analysis directly (Windows)
- Open MATLAB and set the current folder to the project root (the folder with `main.m`).
- Run: `main`
- Visualizations are saved to `results/`.

Alternatively, from PowerShell (with MATLAB on PATH):
- cd to the project root
- Run (expands your current folder):
    - `matlab -batch "cd('$( (Get-Location).Path.Replace('\\','/') )'); main;"`

### Option B: Run the Flask dashboards (expects MATLAB installed on the machine)
1) Create a Python 3.10+ environment and install dependencies:
    - `pip install -r flask_server/requirements.txt`
2) Start the server from the `flask_server` folder:
    - `python app.py` (binds to http://localhost:5001 by default)
3) Click "Run Analysis" on the page; the server will launch MATLAB in batch mode and update images under `results/`.

Environment variables:
- `PORT` (default 5001)
- `FLASK_DEBUG=1` to enable debug server in development
- `MATLAB_CMD` to point to a specific MATLAB executable (e.g., `"C:\\Program Files\\MATLAB\\R2023b\\bin\\matlab.exe"`)

### Option C: Docker (for the Flask server)
The Docker image includes Python and your Flask server, but does not include MATLAB. Use this when you either:
- have MATLAB available on the host and mount it in (advanced), or
- compile your MATLAB code to use the MATLAB Runtime and use a MATLAB Runtime base image.

Quick demo container (server only):
1) Build: `docker build -t sih-flask .`
2) Run: `docker run --rm -p 5001:5001 -e PORT=5001 -e MATLAB_CMD=matlab sih-flask`

Notes:
- The container copies the whole project into `/app`. The Flask app runs from `/app/flask_server` and calls MATLAB with `cd('..'); main;`.
- If MATLAB isn't present in the container, the /run-matlab endpoint will return an error. For production, compile MATLAB to a deployable application and base your image on a MATLAB Runtime image.

### Common gotchas
- If the results folder shows duplicate or stale images, delete the `results/` directory and re-run.
- If the Flask pages don't load images, ensure `results/` contains the latest `.png` files and that `/run-matlab` completed successfully.

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation and examples

## Version History

- **v1.0**: Initial release with core functionality
  - Multispectral image processing
  - Crop health analysis
  - Soil condition assessment
  - Pest risk detection
  - Comprehensive reporting

## Future Enhancements

- [ ] Temporal analysis capabilities
- [ ] Machine learning model training
- [ ] Real-time data integration
- [ ] Mobile app interface
- [ ] Cloud deployment options
- [ ] Additional vegetation indices
- [ ] Advanced soil analysis algorithms
- [ ] Integration with IoT sensors

## Acknowledgments

This project was developed as part of the Smart India Hackathon (SIH) initiative, focusing on AI-powered agricultural monitoring solutions.
