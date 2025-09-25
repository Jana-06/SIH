
try
    cd('d:/SIH/SIH/flask_server/..');
    fprintf('Starting custom analysis for: nhap_68d2cbfbd10e17e.csv');
    trainPipeline('d:/SIH/SIH/flask_server/uploads/nhap_68d2cbfbd10e17e.csv', '', 'user_models_nhap_68d2cbfbd10e17e', 'TrainSupervised', false, 'K', 3);
    fprintf('Custom analysis complete. Models saved to user_models_nhap_68d2cbfbd10e17e');
    
    % After training, run inference on the same data to generate results
    load(fullfile('user_models_nhap_68d2cbfbd10e17e', 'kmeans_model.mat'));
    load(fullfile('user_models_nhap_68d2cbfbd10e17e', 'crop_health_model.mat'));
    load(fullfile('user_models_nhap_68d2cbfbd10e17e', 'pest_risk_model.mat'));
    
    config = loadConfiguration();
    [sensorData, ~] = preprocessData('d:/SIH/SIH/flask_server/uploads/nhap_68d2cbfbd10e17e.csv', '', config);
    
    % Run the core analysis modules with the newly trained models
    results = struct();
    results.crop_health = CropHealthAnalyzer(sensorData, kmeans_model, crop_health_model);
    results.soil_condition = SoilConditionAnalyzer(sensorData);
    results.pest_risk = PestRiskDetector(sensorData, pest_risk_model);
    
    % Generate report from the results
    ReportGenerator(results);

catch ME
    fprintf('Error in MATLAB script: %s\n', ME.message);
    for i = 1:length(ME.stack)
        fprintf('File: %s, Name: %s, Line: %d\n', ME.stack(i).file, ME.stack(i).name, ME.stack(i).line);
    end
    exit(1);
end
exit(0);
